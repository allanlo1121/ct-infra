

drop table tbm.tbm_phase_records cascade;
create table tbm.tbm_phase_records (

  id uuid primary key default gen_random_uuid(),

  tbm_id uuid not null references tbm.tbms(id),

  ring_no integer null,
  start_chainage numeric null,
  end_chainage numeric null,

  phase_type tbm.phase_type not null,

  start_at timestamptz not null,

  end_at timestamptz null
);


drop table tbm.tbm_runtime_state_current cascade;

create table tbm.tbm_runtime_state_current (

  tbm_id uuid primary key,

  -- 当前施工位置
  ring_no integer,
  chainage numeric,

  -- 当前模式
  phase_type tbm.phase_type not null,


  -- 推进系统
  thrust_speed numeric,
  penetration_rate numeric,
  thrust_pressure numeric,
  thrust_cylinder_stroke numeric,
  total_thrust numeric,


  -- 刀盘系统
  cutter_speed numeric,
  cutter_torque numeric,

  -- 时间
  recorded_at timestamptz,
  updated_at timestamptz
);


select *
from proj.v_tunnel_list;


create type proj.advance_direction as enum (
  'chainage_increase',
  'chainage_decrease'
);

alter table proj.tunnels
add column advance_direction proj.advance_direction;


alter table proj.tunnels
alter column advance_direction
set default 'chainage_increase';


drop view app.v_tunnel_runtime cascade;

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


 INSERT INTO "tbm"."tbm_daily_progress" ( "tbm_id", "work_date", "ring_end", "chainage_end") VALUES ( 'df7dd9d0-090a-443b-ba15-75f989616e69', '2026-08-01', 0, '0');