
drop  view runtime.v_tbm_assignment cascade;

create or replace view runtime.v_tbm_assignments as
select
  t.id as tunnel_id,

  ta.tbm_code,
  tbm.name as tbm_name,
  tbm.tbm_type_id,
  tbm_type.name as tbm_type_name,

  t.project_id,
  p.name as project_name,

  p.organization_id,
  o.name as organization_name,

  region.id as region_id,
  region.name as region_name,

  t.name as tunnel_name,
  t.full_name as tunnel_full_name,

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

  ps.tunnel_status_id,
  s.name as tunnel_status_name

from tbm.tbm_assignments ta

left join tbm.tbms tbm
  on tbm.code = ta.tbm_code

left join public.master_data tbm_type
  on tbm_type.id = tbm.tbm_type_id

left join proj.tunnels t
  on ta.tunnel_id = t.id

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

 and ta.end_date is null;



create or replace view runtime.v_parameter_alarms as
select
    a.id,

    a.tbm_code,
    t.id as tunnel_id,
    t.name as tunnel_name,

    t.project_id,
    prj.name as project_name,

    prj.region_id,
    md.name as region_name,

    a.parameter_code,
    p.name as parameter_name,
    p.unit,

    a.ring_no,
    a.chainage,
    a.alarm_value,
    a.severity,

    a.updated_at

from runtime.parameter_alarms a

left join tbm.parameters p
    on p.code = a.parameter_code

left join tbm.tbm_assignments ta
    on ta.tbm_code = a.tbm_code
   and ta.end_date is null

left join proj.tunnels t
    on t.id = ta.tunnel_id

left join proj.projects prj
    on prj.id = t.project_id

left join public.master_data md
    on md.id = prj.region_id;
