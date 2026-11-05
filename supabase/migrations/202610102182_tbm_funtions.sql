create or replace function tbm.apply_ring_phase(
  p_tbm_code text,
  p_tunnel_id uuid,
  p_ring_no integer,
  p_phase_type text,
  p_started_at timestamptz,
  p_chainage numeric
)
returns jsonb
language plpgsql
volatile
security invoker
set search_path = ''
as $$
declare
  v_current tbm.ring_phase_records%rowtype;

  v_ring_changed boolean;
  v_phase_changed boolean;
  v_ring_delta bigint;
begin
  -- =========================================
  -- 1. 参数校验
  -- =========================================
  if p_tbm_code is null
     or p_tunnel_id is null
     or p_ring_no is null
     or p_phase_type is null
     or p_started_at is null then

    raise exception 'Ring phase arguments cannot be null'
      using errcode = '22004';
  end if;

  -- =========================================
  -- 2. 同一 TBM 串行处理
  -- =========================================
  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(p_tbm_code, 0)
  );

  -- =========================================
  -- 3. 查询当前活动阶段
  -- =========================================
  select *
  into v_current
  from tbm.ring_phase_records
  where tbm_code = p_tbm_code
    and ended_at is null
  for update;

  -- =========================================
  -- 4. 首次初始化
  -- =========================================
  if not found then

    insert into tbm.ring_phase_records (
      tbm_code,
      tunnel_id,
      ring_no,
      tbm_phase_type,
      started_at,
      start_chainage
    )
    values (
      p_tbm_code,
      p_tunnel_id,
      p_ring_no,
      p_phase_type,
      p_started_at,
      p_chainage
    );

    return pg_catalog.jsonb_build_object(
      'inserted', true,
      'ringChanged', false,
      'phaseChanged', false,
      'ringDelta', null,
      'error', null
    );
  end if;

  -- =========================================
  -- 5. 隧道一致性校验
  -- =========================================
  if v_current.tunnel_id <> p_tunnel_id then

    raise exception
      'TBM % tunnel mismatch: current %, incoming %',
      p_tbm_code,
      v_current.tunnel_id,
      p_tunnel_id
      using errcode = '22023';
  end if;

  -- =========================================
  -- 6. 时间回退：拒绝更新
  -- =========================================
  if p_started_at <= v_current.started_at then

    return pg_catalog.jsonb_build_object(
      'inserted', false,
      'ringChanged', false,
      'phaseChanged', false,
      'ringDelta', null,
      'error', 'time_rollback'
    );
  end if;

  -- =========================================
  -- 7. 判断环号、阶段是否变化
  -- =========================================
  v_ring_changed :=
    v_current.ring_no is distinct from p_ring_no;

  v_phase_changed :=
    v_current.tbm_phase_type is distinct from p_phase_type;

  v_ring_delta :=
    p_ring_no::bigint - v_current.ring_no::bigint;

  -- =========================================
  -- 8. 环号回退：拒绝更新
  -- =========================================
  if v_ring_delta < 0 then

    return pg_catalog.jsonb_build_object(
      'inserted', false,
      'ringChanged', false,
      'phaseChanged', false,
      'ringDelta', v_ring_delta,
      'error', 'ring_rollback'
    );
  end if;

  -- =========================================
  -- 9. 状态未变化：不写数据库
  -- =========================================
  if not (v_ring_changed or v_phase_changed) then

    return pg_catalog.jsonb_build_object(
      'inserted', false,
      'ringChanged', false,
      'phaseChanged', false,
      'ringDelta', 0,
      'error', null
    );
  end if;

  -- =========================================
  -- 10. 结束上一阶段
  -- =========================================
  update tbm.ring_phase_records
  set
    ended_at = p_started_at,
    end_chainage = p_chainage
  where id = v_current.id;

  -- =========================================
  -- 11. 创建新的当前阶段
  -- =========================================
  insert into tbm.ring_phase_records (
    tbm_code,
    tunnel_id,
    ring_no,
    tbm_phase_type,
    started_at,
    start_chainage
  )
  values (
    p_tbm_code,
    p_tunnel_id,
    p_ring_no,
    p_phase_type,
    p_started_at,
    p_chainage
  );

  -- =========================================
  -- 12. 返回处理结果
  -- =========================================
  return pg_catalog.jsonb_build_object(
    'inserted', true,
    'ringChanged', v_ring_changed,
    'phaseChanged', v_phase_changed,
    'ringDelta', v_ring_delta,
    'error', null
  );
end;
$$;

-- 撤销所有角色默认执行权限
revoke execute on function tbm.apply_ring_phase(
  text, uuid, integer, text, timestamptz, numeric
) from public;

-- 撤销客户端角色权限
revoke execute on function tbm.apply_ring_phase(
  text, uuid, integer, text, timestamptz, numeric
) from anon, authenticated;

-- 授予后端角色执行权限
grant execute on function tbm.apply_ring_phase(
  text, uuid, integer, text, timestamptz, numeric
) to service_role;


create or replace function tbm.get_organization_context (p_tbm_code text) returns table (tbm_code text, tunnel_id uuid, engineering_unit_id uuid, project_id uuid, organization_id uuid) language sql stable security invoker
set
  search_path = '' as $$
  select
    a.tbm_code,
    a.tunnel_id,
    eu.id as engineering_unit_id,
    p.id as project_id,
    p.organization_id
  from tbm.assignments a
  join proj.tunnels t
    on t.id = a.tunnel_id
  join proj.engineering_units eu
    on eu.id = a.tunnel_id
  join proj.projects p
    on p.id = eu.project_id
  join hrm.organizations o
    on o.id = p.organization_id
  where a.tbm_code = p_tbm_code
    -- 当前有效绑定
    and a.start_date <= current_date
    and a.end_date is null
    -- 必须存在所属组织
    and p.organization_id is not null
  limit 1;
$$;

revoke all on function tbm.get_organization_context (text)
from
  public,
  anon,
  authenticated;

grant
execute on function tbm.get_organization_context (text) to service_role;

grant usage on schema tbm to service_role;

-- =========================================
-- 新版：参数报警历史记录
-- 只 INSERT，不 UPDATE
-- 返回新报警 ID，没有插入返回 NULL
-- =========================================
create function tbm.apply_parameter_alarm (
  p_tbm_code text,
  p_tunnel_id uuid,
  p_parameter_code text,
  p_severity_code text,
  p_rule_snapshot jsonb,
  p_alarm_value numeric,
  p_ring_no integer,
  p_chainage numeric,
  p_occurred_at timestamptz
) returns bigint language plpgsql volatile security invoker
set
  search_path = '' as $$
declare
  v_last tbm.parameter_alarms%rowtype;

  v_min_delta numeric;
  v_min_interval_ms integer;

  v_alarm_id bigint;
begin

  -- =====================================
  -- 1. 没有命中报警，直接返回
  -- =====================================

  if p_severity_code is null then
    return null;
  end if;


  -- =====================================
  -- 2. 参数校验
  -- =====================================

  if p_tbm_code is null
     or p_tbm_code = ''
     or p_tunnel_id is null
     or p_parameter_code is null
     or p_parameter_code = ''
     or p_alarm_value is null
     or p_occurred_at is null
     or p_rule_snapshot is null
     or pg_catalog.jsonb_typeof(p_rule_snapshot) <> 'object'
  then
    raise exception 'Invalid parameter alarm arguments'
      using errcode = '22023';
  end if;

  -- 报警等级编码必须是8位数字
  if p_severity_code !~ '^[0-9]{8}$' then
    raise exception 'Invalid severity code: %', p_severity_code
      using errcode = '22023';
  end if;


  -- =====================================
  -- 3. 读取最小记录条件
  -- =====================================

  v_min_delta := coalesce(
    (p_rule_snapshot ->> 'min_record_delta')::numeric,
    0
  );

  v_min_interval_ms := coalesce(
    (p_rule_snapshot ->> 'min_record_interval_ms')::integer,
    0
  );

  if v_min_delta < 0
     or v_min_interval_ms < 0
  then
    raise exception 'Invalid parameter alarm record limits'
      using errcode = '22023';
  end if;


  -- =====================================
  -- 4. 同一 TBM 参数串行处理
  -- =====================================

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(
      p_tbm_code || ':' || p_parameter_code,
      0
    )
  );


  -- =====================================
  -- 5. 查询发生时间之前最近一条报警
  -- =====================================

  select *
  into v_last
  from tbm.parameter_alarms
  where tbm_code = p_tbm_code
    and tunnel_id = p_tunnel_id
    and parameter_code = p_parameter_code
    and occurred_at <= p_occurred_at
  order by occurred_at desc, id desc
  limit 1;


-- =====================================
-- 6. 判断是否需要新增报警
-- =====================================

if found
   and p_severity_code = v_last.severity_code
then

  -- 数值变化不足，跳过
  if v_min_delta > 0
     and pg_catalog.abs(
       p_alarm_value - v_last.alarm_value
     ) < v_min_delta
  then
    return null;
  end if;

  -- 时间间隔不足，跳过
  if v_min_interval_ms > 0
     and p_occurred_at <
       v_last.occurred_at
       + v_min_interval_ms * interval '1 millisecond'
  then
    return null;
  end if;

end if;


  -- =====================================
  -- 7. 插入报警历史
  -- =====================================

  insert into tbm.parameter_alarms (
    tbm_code,
    tunnel_id,
    parameter_code,
    severity_code,
    rule_snapshot,
    alarm_value,
    ring_no,
    chainage,
    occurred_at
  )
  values (
    p_tbm_code,
    p_tunnel_id,
    p_parameter_code,
    p_severity_code,
    p_rule_snapshot,
    p_alarm_value,
    p_ring_no,
    p_chainage,
    p_occurred_at
  )
  returning id into v_alarm_id;


  -- =====================================
  -- 8. 返回新报警 ID
  -- =====================================

  return v_alarm_id;

end;
$$;

revoke all on function tbm.apply_parameter_alarm (text, uuid, text, text, jsonb, numeric, integer, numeric, timestamptz)
from
  public,
  anon,
  authenticated;

grant
execute on function tbm.apply_parameter_alarm (text, uuid, text, text, jsonb, numeric, integer, numeric, timestamptz) to service_role;