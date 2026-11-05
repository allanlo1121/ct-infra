drop table tbm.parameter_alarms cascade;

create table tbm.parameter_alarms (
  id bigint generated always as identity primary key,

  tbm_code text not null references tbm.tbms(code),
  tunnel_id uuid not null references proj.tunnels(id),
  parameter_code text not null references tbm.parameters(code),

  severity_code text not null
    references master_data.dictionary_items(code),

  rule_snapshot jsonb not null,
  alarm_value numeric not null,

  ring_no integer,
  chainage numeric,

  occurred_at timestamptz not null,

  created_at timestamptz not null default now(),
  created_by uuid default auth.uid()
    references auth.users(id) on delete set null
);





-- 5. TABLE PERMISSIONS for tbm_parameter_alarms
-- =========================================
-- 1. 清理原有 RLS 策略
-- =========================================

drop policy if exists "parameter_alarms_read"
on tbm.parameter_alarms;

drop policy if exists "parameter_alarms_insert_authorized"
on tbm.parameter_alarms;

drop policy if exists "parameter_alarms_update_authorized"
on tbm.parameter_alarms;

drop policy if exists "parameter_alarms_delete_authorized"
on tbm.parameter_alarms;


-- =========================================
-- 2. 撤销原有权限
-- =========================================

revoke all on table tbm.parameter_alarms
from public, anon, authenticated, service_role;


-- =========================================
-- 3. 普通用户只读
-- =========================================

grant select on table tbm.parameter_alarms
to authenticated;


-- =========================================
-- 4. Pulse 服务端允许读取、插入
-- =========================================

grant select, insert on table tbm.parameter_alarms
to service_role;


-- =========================================
-- 5. 启用 RLS
-- =========================================

alter table tbm.parameter_alarms
enable row level security;


-- =========================================
-- 6. 只允许已登录用户读取
-- =========================================

create policy "parameter_alarms_read"
on tbm.parameter_alarms
for select
to authenticated
using (true);

create or replace function tbm.apply_parameter_alarm (
  p_tbm_code text,
  p_tunnel_id uuid,
  p_parameter_code text,
  p_severity_code text,
  p_rule_snapshot jsonb,
  p_alarm_value numeric,
  p_ring_no integer,
  p_chainage numeric,
  p_started_at timestamptz
) returns jsonb language plpgsql security invoker
set
  search_path = '' as $$
declare
  v_current tbm.parameter_alarms%rowtype;

  v_alarm_id bigint;
  v_change_type text;

  v_deadband numeric;
  v_threshold numeric;
  v_reference numeric;
  v_threshold_type text;
  v_recovery_delay_ms integer;

  v_still_active boolean;
  v_downgrading boolean;
  v_recovery_started_at timestamptz;
begin
  -- 1. 参数校验
  if p_tbm_code is null
     or p_tunnel_id is null
     or p_parameter_code is null
     or p_alarm_value is null
     or p_started_at is null then
    raise exception 'Parameter alarm required arguments cannot be null'
      using errcode = '22004';
  end if;

  if p_severity_code is not null
     and (
       p_rule_snapshot is null
       or pg_catalog.jsonb_typeof(p_rule_snapshot) <> 'object'
     ) then
    raise exception 'Rule snapshot is required for active alarm'
      using errcode = '22023';
  end if;

  -- 2. 同一设备、同一参数串行处理
  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(
      p_tbm_code || ':' || p_parameter_code,
      0
    )
  );

  -- 3. 查询当前活动报警
  select *
  into v_current
  from tbm.parameter_alarms
  where tbm_code = p_tbm_code
    and parameter_code = p_parameter_code
    and ended_at is null
  for update;

  -- 4. 当前没有活动报警
  if not found then

    -- 当前正常，不操作
    if p_severity_code is null then
      return pg_catalog.jsonb_build_object(
        'changed', false,
        'changeType', 'unchanged',
        'alarmId', null,
        'previousAlarmId', null,
        'previousSeverity', null,
        'currentSeverity', null,
        'previousValue', null,
        'recoveryStartedAt', null
      );
    end if;

    -- 创建新报警
    insert into tbm.parameter_alarms (
      tbm_code,
      tunnel_id,
      parameter_code,
      severity_code,
      rule_snapshot,
      alarm_value,
      ring_no,
      chainage,
      started_at,
      recovery_started_at
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
      p_started_at,
      null
    )
    returning id into v_alarm_id;

    return pg_catalog.jsonb_build_object(
      'changed', true,
      'changeType', 'started',
      'alarmId', v_alarm_id,
      'previousAlarmId', null,
      'previousSeverity', null,
      'currentSeverity', p_severity_code,
      'previousValue', null,
      'recoveryStartedAt', null
    );
  end if;

  -- 5. 隧道一致性
  if v_current.tunnel_id <> p_tunnel_id then
    raise exception
      'TBM % tunnel mismatch: current %, incoming %',
      p_tbm_code,
      v_current.tunnel_id,
      p_tunnel_id
      using errcode = '22023';
  end if;

  -- 6. 过期数据
  if p_started_at < v_current.started_at
   or (
     v_current.recovery_started_at is not null
     and p_started_at < v_current.recovery_started_at
   ) then
    return pg_catalog.jsonb_build_object(
      'changed', false,
      'changeType', 'stale',
      'alarmId', v_current.id,
      'previousAlarmId', v_current.id,
      'previousSeverity', v_current.severity_code,
      'currentSeverity', v_current.severity_code,
      'previousValue', v_current.alarm_value,
      'recoveryStartedAt', v_current.recovery_started_at
    );
  end if;

  -- 7. 判断是否降级或恢复
  -- 主数据编码为8位数字，编码越大，等级越高
 if v_current.severity_code !~ '^[0-9]{8}$'
   or (
     p_severity_code is not null
     and p_severity_code !~ '^[0-9]{8}$'
   ) then
  raise exception 'Invalid severity code'
    using errcode = '22023';
end if;

  v_downgrading :=
    p_severity_code is null
    or p_severity_code::bigint <
       v_current.severity_code::bigint;

  -- 8. 同等级或升级，不需要恢复延时
  if not v_downgrading then

    -- 8.1 同等级
    if p_severity_code = v_current.severity_code then

      if v_current.alarm_value is distinct from p_alarm_value
         or v_current.ring_no is distinct from p_ring_no
         or v_current.chainage is distinct from p_chainage
         or v_current.recovery_started_at is not null then

        update tbm.parameter_alarms
        set
          alarm_value = p_alarm_value,
          ring_no = p_ring_no,
          chainage = p_chainage,
          recovery_started_at = null,
          updated_at = now()
        where id = v_current.id;

        v_change_type := 'value_updated';
      else
        v_change_type := 'unchanged';
      end if;

      return pg_catalog.jsonb_build_object(
        'changed', false,
        'changeType', v_change_type,
        'alarmId', v_current.id,
        'previousAlarmId', v_current.id,
        'previousSeverity', v_current.severity_code,
        'currentSeverity', v_current.severity_code,
        'previousValue', v_current.alarm_value,
        'recoveryStartedAt', null
      );
    end if;

    -- 更高等级：立即升级
    v_change_type := 'severity_changed';

  else
    -- 9. 降级或恢复：读取旧报警的规则快照
    v_threshold_type := coalesce(
      v_current.rule_snapshot ->> 'thresholdType',
      v_current.rule_snapshot ->> 'threshold_type'
    );

    v_threshold := coalesce(
      (v_current.rule_snapshot ->> 'thresholdValue')::numeric,
      (v_current.rule_snapshot ->> 'threshold_value')::numeric
    );

    v_reference := coalesce(
      (v_current.rule_snapshot ->> 'referenceValue')::numeric,
      (v_current.rule_snapshot ->> 'reference_value')::numeric
    );

    v_deadband := coalesce(
      (v_current.rule_snapshot ->> 'deadband')::numeric,
      0
    );

    v_recovery_delay_ms := coalesce(
      (v_current.rule_snapshot ->> 'recoveryDelayMs')::integer,
      (v_current.rule_snapshot ->> 'recovery_delay_ms')::integer,
      0
    );

    if v_threshold is null
   or v_threshold_type is null
   or v_threshold_type not in ('upper', 'lower', 'deviation')
   or (
     v_threshold_type = 'deviation'
     and v_reference is null
   )
   or v_deadband is null
   or v_deadband < 0
   or v_recovery_delay_ms is null
   or v_recovery_delay_ms < 0 then

  raise exception 'Invalid current alarm rule snapshot'
    using errcode = '22023';
end if;

    -- 10. 滞回判断：当前等级是否仍应保持
    v_still_active := case v_threshold_type
      when 'upper' then
        p_alarm_value > v_threshold - v_deadband

      when 'lower' then
        p_alarm_value < v_threshold + v_deadband

     when 'deviation' then
  abs(p_alarm_value - v_reference)
    > greatest(
        v_threshold - v_deadband,
        0
      )
    end;

    -- 11. 仍在滞回区间内，保持原等级
    if v_still_active then

      update tbm.parameter_alarms
      set
        alarm_value = p_alarm_value,
        ring_no = p_ring_no,
        chainage = p_chainage,
        recovery_started_at = null,
        updated_at = now()
      where id = v_current.id;

      return pg_catalog.jsonb_build_object(
        'changed', false,
        'changeType', 'value_updated',
        'alarmId', v_current.id,
        'previousAlarmId', v_current.id,
        'previousSeverity', v_current.severity_code,
        'currentSeverity', v_current.severity_code,
        'previousValue', v_current.alarm_value,
        'recoveryStartedAt', null
      );
    end if;

    -- 12. 已离开滞回区间，开始或继续恢复计时
    v_recovery_started_at := coalesce(
      v_current.recovery_started_at,
      p_started_at
    );

    -- 尚未达到恢复延时
    if p_started_at <
       v_recovery_started_at
       + v_recovery_delay_ms * interval '1 millisecond' then

      update tbm.parameter_alarms
      set
        alarm_value = p_alarm_value,
        ring_no = p_ring_no,
        chainage = p_chainage,
        recovery_started_at = v_recovery_started_at,
        updated_at = now()
      where id = v_current.id;

      return pg_catalog.jsonb_build_object(
        'changed', false,
        'changeType', 'recovery_pending',
        'alarmId', v_current.id,
        'previousAlarmId', v_current.id,
        'previousSeverity', v_current.severity_code,
        'currentSeverity', v_current.severity_code,
        'previousValue', v_current.alarm_value,
        'recoveryStartedAt', v_recovery_started_at
      );
    end if;

    -- 恢复延时已达到
    v_change_type := case
      when p_severity_code is null then 'recovered'
      else 'severity_changed'
    end;
  end if;

  -- 13. 结束旧报警
  update tbm.parameter_alarms
  set
    ended_at = p_started_at,
    updated_at = now()
  where id = v_current.id;

  -- 14. 完全恢复
  if p_severity_code is null then
    return pg_catalog.jsonb_build_object(
      'changed', true,
      'changeType', 'recovered',
      'alarmId', null,
      'previousAlarmId', v_current.id,
      'previousSeverity', v_current.severity_code,
      'currentSeverity', null,
      'previousValue', v_current.alarm_value,
      'recoveryStartedAt', null
    );
  end if;

  -- 15. 创建新等级报警
  insert into tbm.parameter_alarms (
    tbm_code,
    tunnel_id,
    parameter_code,
    severity_code,
    rule_snapshot,
    alarm_value,
    ring_no,
    chainage,
    started_at,
    recovery_started_at
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
    p_started_at,
    null
  )
  returning id into v_alarm_id;

  -- 16. 返回结果
  return pg_catalog.jsonb_build_object(
    'changed', true,
    'changeType', v_change_type,
    'alarmId', v_alarm_id,
    'previousAlarmId', v_current.id,
    'previousSeverity', v_current.severity_code,
    'currentSeverity', p_severity_code,
    'previousValue', v_current.alarm_value,
    'recoveryStartedAt', null
  );
end;
$$;

alter table tbm.tbm_parameter_threshold_rules
add column deadband numeric not null default 0 check (deadband >= 0),
add column recovery_delay_ms integer not null default 0 check (recovery_delay_ms >= 0);

alter table tbm.parameter_alarms
add column recovery_started_at timestamptz;

-- 查询最后一次记录 index
create index idx_parameter_alarms_latest
on tbm.parameter_alarms (
  tbm_code,
  tunnel_id,
  parameter_code,
  occurred_at desc,
  id desc
);

create table tbm.parameter_alarm_verifications (
  id bigint generated always as identity primary key,

  alarm_id bigint not null
    references tbm.parameter_alarms(id),

  previous_status text not null,
  new_status text not null,

  remark text,

  verified_at timestamptz not null default now(),
  verified_by uuid not null references auth.users(id)
);



-- =========================================
-- 删除旧版函数
-- 原参数名为 p_started_at
-- =========================================

drop function if exists tbm.apply_parameter_alarm(
  text,
  uuid,
  text,
  text,
  jsonb,
  numeric,
  integer,
  numeric,
  timestamptz
);


-- =========================================
-- 新版：参数报警历史记录
-- 只 INSERT，不 UPDATE
-- 返回新报警 ID，没有插入返回 NULL
-- =========================================



create function tbm.apply_parameter_alarm(
  p_tbm_code text,
  p_tunnel_id uuid,
  p_parameter_code text,
  p_severity_code text,
  p_rule_snapshot jsonb,
  p_alarm_value numeric,
  p_ring_no integer,
  p_chainage numeric,
  p_occurred_at timestamptz
)
returns bigint
language plpgsql
volatile
security invoker
set search_path = ''
as $$
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


revoke all
on function tbm.apply_parameter_alarm(
  text, uuid, text, text, jsonb,
  numeric, integer, numeric, timestamptz
)
from public, anon, authenticated;

grant execute
on function tbm.apply_parameter_alarm(
  text, uuid, text, text, jsonb,
  numeric, integer, numeric, timestamptz
)
to service_role;