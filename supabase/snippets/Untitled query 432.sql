
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
    t.name::text as tunnel_name,
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

-- 权限
revoke execute on function tbm.get_ring_phase_details(
  text[], timestamptz, timestamptz
) from public, anon, authenticated;

grant execute on function tbm.get_ring_phase_details(
  text[], timestamptz, timestamptz
) to service_role;


select *
from tbm.get_ring_phase_details(
  array['crec1137', 'rbns423'],
  '2026-11-08 19:00:00+08',
  '2026-11-09 19:00:00+08'
);