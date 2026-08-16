
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
  t.advance_direction,
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
  tl.advance_direction,
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
  vtl.full_name,
  vtl.project_name,
  vtl.tunnel_status_name

from proj.v_tunnel_list vtl;



create or replace view app.v_tunnel_risk_overview
with (security_invoker = true)
as

select

    r.id as risk_id,

    r.tunnel_id,
    t.name as tunnel_name,

    prj.id as project_id,
    prj.name as project_name,

    md.name as region_name,


    r.name as risk_name,
    r.risk_level,

    r.start_chainage,
    r.end_chainage,

    r.burial_depth,

    geo.layer as geo_class_layer,
    geo.name as geo_class_name,

    rock.name as geo_rock_class_name,

    r.description,

    r.created_at,
    r.updated_at


from proj.tunnel_risks r

left join proj.tunnels t
    on t.id = r.tunnel_id

left join proj.projects prj
    on prj.id = t.project_id

left join public.master_data md
    on md.id = prj.region_id

left join proj.geo_classes geo
  on geo.id = r.geo_class_id

left join proj.geo_rock_classes rock
  on rock.id = r.geo_rock_class_id;