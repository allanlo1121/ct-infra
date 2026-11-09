drop function if exists tbm.get_ring_progress(
  text[],
  timestamptz,
  timestamptz
);


-- ============================================================
-- RPC：统计盾构机指定时段内的完成环数
--
-- 统计维度：TBM + 隧道-- 
-- 时间范围：[p_start_time, p_end_time)
--
-- 支持：
--   1. 单台 TBM
--   2. 多台 TBM
--   3. 同一 TBM 跨项目、跨隧道施工
--
-- 返回:ringNumbers: number[] 出现的环号集合
--
-- ============================================================


create or replace function tbm.get_ring_progress(
  p_tbm_codes text[],
  p_start_time timestamptz,
  p_end_time timestamptz
)
returns table (
  tbm_code text,
  tbm_name text,
  project_name text,
  tunnel_name text,

  ring_numbers integer[],
  first_ring integer,
  last_ring integer,
  observed_ring_count integer,
  ring_span integer
)
language plpgsql
stable
security invoker
set search_path = ''
as $$
begin
  -- 参数验证
  if p_tbm_codes is null
     or cardinality(p_tbm_codes) = 0 then
    raise exception 'p_tbm_codes cannot be empty';
  end if;

  if p_start_time is null
     or p_end_time is null
     or p_start_time >= p_end_time then
    raise exception 'Invalid time range';
  end if;

  return query
  with ring_data as (
    select distinct
      r.tbm_code,
      r.tunnel_id,
      r.ring_no

    from tbm.ring_phase_records r

    where r.tbm_code = any(p_tbm_codes)
      and r.ring_no is not null

      -- 阶段记录与查询时间范围有交集
      and r.started_at < p_end_time
      and coalesce(r.ended_at, now()) > p_start_time
  ),

  ring_summary as (
    select
      r.tbm_code,
      r.tunnel_id,

      array_agg(
        r.ring_no
        order by r.ring_no
      ) as ring_numbers,

      min(r.ring_no) as first_ring,
      max(r.ring_no) as last_ring,

      count(*)::integer as observed_ring_count,

      (
        max(r.ring_no) - min(r.ring_no) + 1
      )::integer as ring_span

    from ring_data r

    group by
      r.tbm_code,
      r.tunnel_id
  )

  select
    s.tbm_code,
    t.name as tbm_name,
    p.name as project_name,
    tu.full_name as tunnel_name,

    s.ring_numbers,
    s.first_ring,
    s.last_ring,
    s.observed_ring_count,
    s.ring_span

  from ring_summary s

  join tbm.tbms t
    on t.code = s.tbm_code

  join proj.tunnels tu
    on tu.id = s.tunnel_id

  join proj.engineering_units eu
    on eu.id =tu.engineering_unit_id

  join proj.projects p
    on p.id = eu.project_id

  order by
    s.tbm_code,
    p.name,
    tu.name;

end;
$$;

-- 权限控制
revoke execute on function tbm.get_ring_progress(
  text[],
  timestamptz,
  timestamptz
) from public, anon, authenticated;

grant execute on function tbm.get_ring_progress(
  text[],
  timestamptz,
  timestamptz
) to service_role;

-- =========================================
-- 3. RPC 执行权限
-- =========================================

revoke execute on function tbm.get_ring_progress(
  text[],
  timestamptz,
  timestamptz
) from public, anon, authenticated;

grant execute on function tbm.get_ring_progress(
  text[],
  timestamptz,
  timestamptz
) to service_role;

-- =========================================
-- 4. 函数说明
-- =========================================

comment on function tbm.get_ring_progress(
  text[],
  timestamptz,
  timestamptz
) is
'统计指定盾构设备在时间范围内的完成环数。
按 TBM 和隧道分组，返回项目、隧道和设备名称。
暂以管片拼装最后结束时间作为整环完成时间。';



select *
from tbm.get_ring_progress(
  array['crec1137'],
  '2026-11-08 19:00:00+08',
  '2026-11-09 19:00:00+08'
);



create or replace function tbm.get_ring_phase_details(
  p_tbm_codes text[],
  p_start_time timestamptz,
  p_end_time timestamptz
)
returns table (
  tbm_code text,
  tbm_name text,
  project_name text,
  tunnel_name text,
  ring_no integer,

  excavation_seconds numeric,
  segment_erection_seconds numeric,
  waiting_seconds numeric,
  stopped_seconds numeric,
  fault_seconds numeric,
  cutter_change_seconds numeric,
  maintenance_seconds numeric,
  unknown_seconds numeric,
  total_seconds numeric
)
language plpgsql
stable
security invoker
set search_path = ''
as $$
begin
  -- 参数验证
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
  with phase_data as (
    select
      r.tbm_code,
      r.tunnel_id,
      r.ring_no,
      r.tbm_phase_type,

      -- 仅计算与查询时间段重叠的部分
      greatest(
        0,
        extract(
          epoch from (
            least(
              coalesce(r.ended_at, now()),
              p_end_time
            )
            -
            greatest(r.started_at, p_start_time)
          )
        )
      ) as duration_seconds

    from tbm.ring_phase_records r

    where r.tbm_code = any(p_tbm_codes)
      and r.started_at < p_end_time
      and coalesce(r.ended_at, now()) > p_start_time
  ),

  phase_summary as (
    select
      d.tbm_code,
      d.tunnel_id,
      d.ring_no,

      sum(d.duration_seconds)
        filter (
          where d.tbm_phase_type = 'excavation'
        ) as excavation_seconds,

      sum(d.duration_seconds)
        filter (
          where d.tbm_phase_type = 'segment_erection'
        ) as segment_erection_seconds,

      sum(d.duration_seconds)
        filter (
          where d.tbm_phase_type = 'waiting'
        ) as waiting_seconds,

      sum(d.duration_seconds)
        filter (
          where d.tbm_phase_type = 'stopped'
        ) as stopped_seconds,

      sum(d.duration_seconds)
        filter (
          where d.tbm_phase_type = 'fault'
        ) as fault_seconds,

      sum(d.duration_seconds)
        filter (
          where d.tbm_phase_type = 'cutter_change'
        ) as cutter_change_seconds,

      sum(d.duration_seconds)
        filter (
          where d.tbm_phase_type = 'maintenance'
        ) as maintenance_seconds,

      sum(d.duration_seconds)
        filter (
          where d.tbm_phase_type = 'unknown'
        ) as unknown_seconds,

      sum(d.duration_seconds) as total_seconds

    from phase_data d

    group by
      d.tbm_code,
      d.tunnel_id,
      d.ring_no
  )

  select
    s.tbm_code,
    m.name::text as tbm_name,
    p.name::text as project_name,
    t.full_name::text as tunnel_name,
    s.ring_no,

    round(coalesce(s.excavation_seconds, 0), 0),
    round(coalesce(s.segment_erection_seconds, 0), 0),
    round(coalesce(s.waiting_seconds, 0), 0),
    round(coalesce(s.stopped_seconds, 0), 0),
    round(coalesce(s.fault_seconds, 0), 0),
    round(coalesce(s.cutter_change_seconds, 0), 0),
    round(coalesce(s.maintenance_seconds, 0), 0),
    round(coalesce(s.unknown_seconds, 0), 0),
    round(coalesce(s.total_seconds, 0), 0)

  from phase_summary s

  join tbm.tbms m
    on m.code = s.tbm_code

  join proj.tunnels t
    on t.id = s.tunnel_id

  join proj.engineering_units eu
    on eu.id =t.engineering_unit_id

  join proj.projects p
    on p.id = eu.project_id


  order by
    p.name,
    t.name,
    s.tbm_code,
    s.ring_no;

end;
$$;


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
    t.full_name::text as tunnel_name,

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