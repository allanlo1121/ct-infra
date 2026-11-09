
drop function if exists tbm.get_parameter_alarms(
  text[],
  timestamptz,
  timestamptz
)

-- 返回类型发生变化，先删除旧函数
create or replace function tbm.get_parameter_alarms(
  p_tbm_codes text[],
  p_start_time timestamptz,
  p_end_time timestamptz
)
returns table (
  id bigint,

  tbm_code text,
  tbm_name text,
  project_name text,
  tunnel_name text,

  parameter_code text,
  parameter_name text,
  parameter_unit text,

  severity_code text,
  severity_name text,

  alarm_value numeric,
  threshold_type text,
  reference_value numeric,
  threshold_value numeric,

  min_record_delta numeric,
  min_record_interval_ms integer,
  digits integer,

  ring_no integer,
  chainage numeric,
  occurred_at timestamptz
)
language plpgsql
stable
security invoker
set search_path = ''
as $$
begin

  -- 参数检查
  if p_tbm_codes is null
    or cardinality(p_tbm_codes) = 0
  then
    raise exception 'p_tbm_codes cannot be empty';
  end if;

  if p_start_time is null
    or p_end_time is null
    or p_start_time >= p_end_time
  then
    raise exception 'Invalid time range';
  end if;

  return query
  select
    a.id,

    a.tbm_code,
    m.name::text as tbm_name,
    p.name::text as project_name,
    t.name::text as tunnel_name,

    a.parameter_code,

    a.rule_snapshot ->> 'parameter_name'
      as parameter_name,

    a.rule_snapshot ->> 'parameter_unit'
      as parameter_unit,

    a.severity_code,

    a.rule_snapshot ->> 'severity_name'
      as severity_name,

    a.alarm_value,

    a.rule_snapshot ->> 'threshold_type'
      as threshold_type,

    (a.rule_snapshot ->> 'reference_value')::numeric
      as reference_value,

    (a.rule_snapshot ->> 'threshold_value')::numeric
      as threshold_value,

    (a.rule_snapshot ->> 'min_record_delta')::numeric
      as min_record_delta,

    (a.rule_snapshot ->> 'min_record_interval_ms')::integer
      as min_record_interval_ms,

    (a.rule_snapshot ->> 'digits')::integer
      as digits,

    a.ring_no,
    a.chainage,
    a.occurred_at

  from tbm.parameter_alarms a

  join tbm.tbms m
    on m.code = a.tbm_code

  join proj.tunnels t
    on t.id = a.tunnel_id

  join proj.engineering_units eu
    on eu.id =t.engineering_unit_id

  join proj.projects p
    on p.id = eu.project_id


  where
    a.tbm_code = any(p_tbm_codes)
    and a.occurred_at >= p_start_time
    and a.occurred_at < p_end_time

  order by
    a.occurred_at desc,
    a.id desc

  limit 500;

end;
$$;


-- 权限
revoke execute on function tbm.get_parameter_alarms(
  text[],
  timestamptz,
  timestamptz
) from public, anon, authenticated;

grant execute on function tbm.get_parameter_alarms(
  text[],
  timestamptz,
  timestamptz
) to service_role;


select *
from tbm.get_parameter_alarms(
  array['crec1137', 'rbns423'],
  '2026-11-08 19:00:00+08',
  '2026-11-09 19:00:00+08'
);