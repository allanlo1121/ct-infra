
create schema if not exists app;

grant usage on schema app to anon;
grant usage on schema app to authenticated;

grant usage, select on all sequences in schema app to anon;
grant usage, select on all sequences in schema app to authenticated;

alter default privileges in schema app
grant usage, select on sequences to anon;

alter default privileges in schema app
grant usage, select on sequences to authenticated;




alter publication supabase_realtime add table proj.tunnels;
alter publication supabase_realtime add table proj.tunnel_status_timeline;
alter publication supabase_realtime add table tbm.tbm_connection_status;
-- alter publication supabase_realtime add table tbm.tbm_phase_active;
alter publication supabase_realtime add table tbm.tbm_assignments;
-- alter publication supabase_realtime add table warning.warning_events;


create or replace view app.v_tunnel_runtime as
select
  t.id as tunnel_id,

  ta.tbm_id,

  t.project_id,
  p.name as project_name,

  p.organization_id,
  o.name as organization_name,

  region.id as region_id,
  region.name as region_name,

  t.name as tunnel_name,
  t.full_name as tunnel_full_name,
  t.prefix,

  t.start_chainage,
  t.end_chainage,

  t.advance_direction,

  t.start_ring,
  t.end_ring,

  t.actual_start_date,
  t.actual_end_date,

  tsv.schedule_start_date,
  tsv.schedule_end_date,

  t.longitude,
  t.latitude,

  t.sort_order,
  t.remark,

  ps.tunnel_status_id,
  s.name as tunnel_status_name



from proj.tunnels t

left join proj.projects p
  on p.id = t.project_id

left join master_data region
  on region.id = p.region_id

left join hr.organizations o
  on o.id = p.organization_id
 and o.deleted_at is null


left join proj.tunnel_status_timeline ps
  on ps.tunnel_id = t.id
 and ps.valid_to is null

left join master_data s
  on s.id = ps.tunnel_status_id


left join (
  select distinct on (tunnel_id)
    id,
    tunnel_id,
    version_no,
    schedule_start_date,
    schedule_end_date
  from proj.tunnel_schedule_versions
  order by tunnel_id, version_no desc
) tsv
  on tsv.tunnel_id = t.id


left join tbm.tbm_assignments ta
  on ta.tunnel_id = t.id
 and ta.end_date is null;


create or replace view app.v_tbm_runtime_state as

select

  t.*,

  heartbeat.is_online as heartbeat_is_online,
  heartbeat.last_seen_at as heartbeat_last_seen_at,

  realdata.is_online as realdata_is_online,
  realdata.last_seen_at as realdata_last_seen_at


from tbm.tbm_runtime_state_current t


left join tbm.tbm_connection_status heartbeat
  on heartbeat.tbm_id = t.tbm_id
 and heartbeat.type = 'heartbeat'


left join tbm.tbm_connection_status realdata
  on realdata.tbm_id = t.tbm_id
 and realdata.type = 'realdata';



-- 隧道掘进当前\日\周\月进度总览视图
create or replace view app.v_tbm_progress_overview as
with settings as (
  select *
  from public.stat_period_settings
  where code = 'tunnel_progress'
    and current_date >= effective_from
    and current_date < coalesce(effective_to, date '9999-12-31')
  order by effective_from desc
  limit 1
),

bounds as (
  select
    s.*,
    now() at time zone s.timezone as local_now,
    case
      when (now() at time zone s.timezone)::time >= s.day_cutoff_time
        then ((now() at time zone s.timezone)::date + 1)
      else (now() at time zone s.timezone)::date
    end as current_work_date
  from settings s
),

periods as (
  select
    current_work_date,
    current_work_date
      - (((extract(dow from current_work_date)::int - week_start_dow + 7) % 7))
      as week_start_work_date,
    case
      when extract(day from current_work_date)::int >= month_start_day
        then date_trunc('month', current_work_date)::date + (month_start_day - 1)
      else
        (date_trunc('month', current_work_date)::date - interval '1 month')::date
          + (month_start_day - 1)
    end as month_start_work_date
  from bounds
),

daily as (
  select
    tbm_id,
    work_date,
    max(ring_end) as ring_end,
    max(chainage_end) as chainage_end
  from tbm.tbm_daily_progress
  group by tbm_id, work_date
),

progress_base as (
  select
    d.*,

    greatest(
      d.ring_end - lag(d.ring_end) over (
        partition by d.tbm_id order by d.work_date
      ),
      0
    ) as daily_ring_count,

    greatest(
      d.chainage_end - lag(d.chainage_end) over (
        partition by d.tbm_id order by d.work_date
      ),
      0
    ) as daily_advance_meter

  from daily d
),

progress as (
  select
    pb.tbm_id,
    max(pb.ring_end) as total_ring_end,

    sum(pb.daily_ring_count) filter (
      where pb.work_date = p.current_work_date
    ) as today_ring_count,

    sum(pb.daily_ring_count) filter (
      where pb.work_date between p.week_start_work_date and p.current_work_date
    ) as week_ring_count,

    sum(pb.daily_ring_count) filter (
      where pb.work_date between p.month_start_work_date and p.current_work_date
    ) as month_ring_count,

    sum(pb.daily_advance_meter) filter (
      where pb.work_date = p.current_work_date
    ) as today_advance_meter,

    sum(pb.daily_advance_meter) filter (
      where pb.work_date between p.week_start_work_date and p.current_work_date
    ) as week_advance_meter,

    sum(pb.daily_advance_meter) filter (
      where pb.work_date between p.month_start_work_date and p.current_work_date
    ) as month_advance_meter,

    max(pb.chainage_end) as total_advance_meter

  from progress_base pb
  cross join periods p
  group by pb.tbm_id
)

select
  pg.*,
  p.current_work_date,
  p.week_start_work_date,
  p.month_start_work_date,
  now() as refreshed_at
from progress pg
cross join periods p;


create or replace view app.v_tbm_parameter_alerts as

select

    a.id,

    a.tbm_id,

    a.parameter_code,

    p.name as parameter_name,

    p.unit,

    a.ring_no,

    a.chainage,

    a.alarm_value,

    a.severity,

    a.updated_at



from tbm.tbm_parameter_alarms a


left join tbm.tbm_runtime_parameters p
on p.code = a.parameter_code;

