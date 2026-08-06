
create or replace view proj.v_tunnel_list as
select
  t.id,

  t.project_id,
  p.name as project_name,
  p.organization_id,
  o.name as organization_name,

  region.id as region_id,
  region.name as region_name,

  t.name,
  t.full_name,
  t.prefix,

  t.start_chainage,
  t.end_chainage,
  t.start_ring,
  t.end_ring,

  t.actual_start_date,
  t.actual_end_date,

  tsv.schedule_start_date,
  tsv.schedule_end_date,
  tsv.version_no,

  t.geology,
  t.longitude,
  t.latitude,
  t.sort_order,
  t.remark,

  ps.tunnel_status_id,
  s.name as tunnel_status_name,
  ps.valid_from,
  ps.valid_to

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

left join public.master_data s
  on s.id = ps.tunnel_status_id

-- 取最新的计划进度版本
left join (
  select distinct on (tunnel_id)
    *
  from proj.tunnel_schedule_versions
  order by tunnel_id, version_no desc
) tsv
  on tsv.tunnel_id = t.id;



create or replace view proj.v_tunnel_detail as
select
  tl.id,
  tl.name,
  tl.organization_name,
  tl.project_name,

  tl.prefix,
  tl.start_chainage,
  tl.end_chainage,
  tl.start_ring,
  tl.end_ring,

  tl.schedule_start_date,
  tl.schedule_end_date,
  tl.actual_start_date,
  tl.actual_end_date,
  tl.tunnel_status_name,

  tl.geology,
  tl.longitude,
  tl.latitude,
  tl.sort_order,
  tl.remark,

  t.created_at,
  t.updated_at,
  t.created_by,
  t.updated_by

from proj.v_tunnel_list tl

left join proj.tunnels t
  on t.id = tl.id;


create or replace view proj.v_tunnel_picker as
select
  vtl.id,
  vtl.name,
  vtl.project_name,  
  vtl.organization_name,
  vtl.tunnel_status_name

from proj.v_tunnel_list vtl;




create or replace view proj.v_tunnel_workspace_detail as
select
  t.id,

  t.project_id,
  p.name as project_name,
  p.organization_id,
  o.name as organization_name,

  t.name,
  t.full_name,
  t.start_chainage,
  t.end_chainage,
  t.start_ring,
  t.end_ring,

  tbm.id as tbm_id,
  tbm.code as tbm_code,
  tbm.name as tbm_name,

  t.actual_start_date,
  t.actual_end_date,

  tsv.schedule_start_date,
  tsv.schedule_end_date, 
  tsv.version_no,
  t.sort_order,


  ps.tunnel_status_id,
  s.name as tunnel_status_name

from proj.tunnels t

left join proj.projects p
  on p.id = t.project_id

left join hr.organizations o
  on o.id = p.organization_id
 and o.deleted_at is null

left join proj.tunnel_status_timeline ps
  on ps.tunnel_id = t.id
 and ps.valid_to is null

left join public.master_data s
  on s.id = ps.tunnel_status_id

left join tbm.tbm_assignments ta
  on ta.tunnel_id = t.id
 and ta.end_date is null

left join tbm.tbms tbm
  on tbm.id = ta.tbm_id

-- 取最新的计划进度版本
left join (
  select distinct on (tunnel_id)
    *
  from proj.tunnel_schedule_versions
  order by tunnel_id, version_no desc
) tsv
  on tsv.tunnel_id = t.id;
