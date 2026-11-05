
create or replace view tbm.v_parameter_threshold_list
with (security_invoker = true)
as
select
  -- 阈值
  t.*,
  di.name as severity_name,
  -- TBM 参数
  tp.tbm_code,
  tp.parameter_code,
  coalesce(nullif(trim(tp.custom_name), ''), p.name) as parameter_name,
  coalesce(nullif(trim(tp.custom_unit), ''), p.unit) as parameter_unit,
  tp.value_max,
  tp.value_min,

  -- 标准参数
  p.subsystem_code,
  p.data_type

from tbm.tbm_parameter_threshold_rules t
join tbm.tbm_parameters tp
  on tp.id = t.tbm_parameter_id
join tbm.parameters p
  on p.code = tp.parameter_code
left join master_data.dictionary_items di
  on di.code =t.severity_code;

-- 允许 authenticated 使用 tbm schema
grant usage on schema tbm to authenticated;

-- 允许 authenticated 查询 View
grant select on tbm.v_parameter_threshold_list
to authenticated;


create or replace view tbm.v_tbm_assignments_list
with (security_invoker = true)
as
select
  a.*,
  tt.name as tbm_name,
  ptu.name as tunnel_name,
  ptu.start_ring,
  ptu.end_ring,
  ptu.start_chainage,
  ptu.end_chainage,
  peu.full_name as section_name,
  pp.name as project_name

from tbm.assignments a
left join tbm.tbms tt
  on tt.code = a.tbm_code
left join proj.tunnels ptu
  on ptu.id = a.tunnel_id
left join proj.engineering_units peu  
  on peu.id=ptu.engineering_unit_id
left join proj.projects pp
  on pp.id = peu.project_id;

-- 允许 authenticated 使用 tbm schema
grant usage on schema tbm to authenticated;

-- 允许 authenticated 查询 View
grant select on tbm.v_tbm_assignments_list
to authenticated;


create or replace view tbm.v_current_assignments
with (security_invoker = true)
as
select
  a.id,
  a.tbm_code,
  s.name as tbm_name,
  a.tunnel_id,
  t.name as tunnel_name,
  t.engineering_unit_id,
  eu.name as engineering_unit_name,
  eu.project_id,
  p.name as project_name,
  p.organization_id,
  o.name as organization_name,

  a.advance_direction,

  t.start_ring,
  t.end_ring,
  t.start_chainage,
  t.end_chainage

from tbm.assignments a

join tbm.tbms s
  on s.code = a.tbm_code
join proj.tunnels t
  on t.id = a.tunnel_id
join proj.engineering_units eu  
  on eu.id=t.engineering_unit_id
join proj.projects p
  on p.id = eu.project_id
left join hrm.organizations o
    on o.id = p.organization_id;

-- 允许 authenticated 使用 tbm schema
grant usage on schema tbm to authenticated;

-- 允许 authenticated 查询 View
grant select on tbm.v_current_assignments
to authenticated;