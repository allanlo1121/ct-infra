create or replace view tbm.v_assignment_details
with (security_invoker = true)
as
select
  -- 分配信息
  a.id,
  a.tbm_code,
  a.tunnel_id,
  a.start_date,
  a.end_date,
  a.advance_direction,

  -- TBM 信息
  m.name as tbm_name,

  -- 隧道信息
  t.full_name as tunnel_name,
  t.start_ring,
  t.end_ring,
  t.start_chainage,
  t.end_chainage,

  -- 工程单元信息
  t.engineering_unit_id,
  eu.full_name as engineering_unit_name,

  -- 项目信息
  eu.project_id,
  p.name as project_name,

  -- 组织信息
  p.organization_id,
  o.name as organization_name

from tbm.assignments a
join tbm.tbms m
  on m.code = a.tbm_code
join proj.tunnels t
  on t.id = a.tunnel_id
join proj.engineering_units eu
  on eu.id = t.engineering_unit_id
join proj.projects p
  on p.id = eu.project_id
left join hrm.organizations o
  on o.id = p.organization_id;


-- 1. View 所在 Schema 的使用权限
grant usage on schema tbm to authenticated;

-- 2. View 查询权限
grant select on tbm.v_assignment_details
to authenticated;

-- 3. 底层业务表的查询权限
grant select on tbm.assignments
to authenticated;

grant select on tbm.tbms
to authenticated;

grant select on master_data.dictionary_items
to authenticated;

grant select on proj.tunnels
to authenticated;

grant select on proj.engineering_units
to authenticated;

grant select on proj.projects
to authenticated;

-- 4. 底层 Schema 的使用权限
grant usage on schema proj to authenticated;