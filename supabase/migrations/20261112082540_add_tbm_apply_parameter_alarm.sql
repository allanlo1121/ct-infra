-- ==========================================
-- 删除旧函数（返回类型发生变化）
-- ==========================================
drop function if exists tbm.apply_parameter_alarm (text, uuid, text, text, jsonb, numeric, integer, numeric, timestamptz);

-- ==========================================
-- 参数报警历史记录
-- 返回本次报警ID及上一条报警值
-- ==========================================
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
) returns table (alarm_id bigint, previous_alarm_value numeric) language plpgsql volatile security invoker
set
    search_path = '' as $$
declare
  v_last tbm.parameter_alarms%rowtype;
  v_has_last boolean := false;

  v_min_delta numeric;
  v_min_interval_ms integer;

  v_alarm_id bigint;
  v_previous_alarm_value numeric;
begin

  -- =====================================
  -- 1. 没有命中报警，直接返回
  -- =====================================

  if p_severity_code is null then
    return;
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
  -- 5. 获取上一条报警记录
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

  v_has_last := found;

  -- 首次报警时为 null
  v_previous_alarm_value := case
    when v_has_last then v_last.alarm_value
    else null
  end;

  -- =====================================
  -- 6. 判断是否需要新增报警
  -- =====================================

  if v_has_last
     and p_severity_code = v_last.severity_code
  then

    -- 数值变化不足，跳过
    if v_min_delta > 0
       and pg_catalog.abs(
         p_alarm_value - v_last.alarm_value
       ) < v_min_delta
    then
      return;
    end if;

    -- 时间间隔不足，跳过
    if v_min_interval_ms > 0
       and p_occurred_at <
         v_last.occurred_at
         + v_min_interval_ms * interval '1 millisecond'
    then
      return;
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
  -- 8. 返回插入结果及前值
  -- =====================================

  return query
  select
    v_alarm_id,
    v_previous_alarm_value;

end;
$$;
