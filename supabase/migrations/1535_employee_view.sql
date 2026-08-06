create or replace view hr.v_employee_detail as
select
  e.id,
  e.name,
  e.code,
  e.gender_id,

  -- 状态
  e.employment_status_id,
  status.name as employment_status_name,

  e.employment_type_id,
  et.name as employment_type_name,

  -- 当前主岗
  pp.post_id as primary_post_id,
  pp.post_name as primary_post_name,

  -- 当前主组织
  pp.organization_id,
  pp.organization_name,

  -- 职称
  titles,

  -- 学历
  educations

from hr.employees e

left join lateral (
  select
    ea.post_id,
    po.name as post_name,
    ea.organization_id,
    org.name as organization_name
  from hr.employee_assignments ea
  left join hr.posts po
    on po.id = ea.post_id
  left join hr.organizations org
    on org.id = ea.organization_id
  where ea.employee_id = e.id
    and ea.is_primary = true
    and ea.end_date is null
  order by ea.start_date desc
  limit 1
) pp on true

left join lateral (
  select jsonb_agg(
    jsonb_build_object(
      'title_id', t.title_id,
      'title_name', md.name,
      'obtained_date', t.obtained_date
    )
    order by t.obtained_date desc
  ) as titles
  from hr.employee_titles t
  left join public.master_data md
    on md.id = t.title_id
  where t.employee_id = e.id
) tt on true

left join lateral (
  select jsonb_agg(
    jsonb_build_object(
      'school', ed.school,
      'education_level_id', ed.education_level_id,
      'education_level_name', md.name,
      'start_date', ed.start_date,
      'end_date', ed.end_date
    )
    order by ed.start_date desc
  ) as educations
  from hr.educations ed
  left join public.master_data md
    on md.id = ed.education_level_id
  where ed.employee_id = e.id
) eds on true

left join public.master_data status
  on status.id = e.employment_status_id

left join public.master_data et
  on et.id = e.employment_type_id

where e.deleted_at is null;


create or replace view hr.v_employee_list as
with primary_position as (
  select
    ea.employee_id,
    ea.post_id,
    ea.organization_id
  from hr.employee_assignments ea
  where ea.is_primary = true
    and ea.end_date is null
)

select
  e.id,
  e.name,
  e.code,

  -- 主组织（来自主岗位）
  pp.organization_id,
  org.name as organization_name,

  status.name as employment_status_name,
  e.sort_order,
  e.created_at,

  -- 主岗
  po.name as post_name

from hr.employees e

-- 主岗位
left join primary_position pp
  on pp.employee_id = e.id

-- 岗位名称
left join hr.posts po
  on po.id = pp.post_id

-- 主组织
left join hr.organizations org
  on org.id = pp.organization_id

-- 状态
left join public.master_data status
  on status.id = e.employment_status_id;


create or replace view hr.v_org_role_assignments as
select
  ea.id as assignment_id,

  -- 人
  e.id as employee_id,
  e.name as employee_name,

  -- 组织
  o.id as organization_id,
  o.name as organization_name,
  o.org_type_id,

  -- org_type 信息
  md_type.code as org_type_code,
  md_type.name as org_type_name,


  -- 岗位
  p.id as post_id,
  p.name as post_name,

  -- 角色类型
  ora.role_type_id,
  md_role.code as role_type_code,
  md_role.name as role_type_name,

  -- 主岗
  ea.is_primary,

  -- 时间
  ea.start_date,
  ea.end_date

from hr.employee_assignments ea

join hr.employees e
  on e.id = ea.employee_id

join hr.organizations o
  on o.id = ea.organization_id

-- 组织类型
left join public.master_data md_type
  on md_type.id = o.org_type_id


-- 岗位
left join hr.posts p
  on p.id = ea.post_id

-- 角色类型（来自 master_data）
left join hr.organization_role_assignments ora
  on ora.employee_id = ea.employee_id
  and ora.organization_id = ea.organization_id
  and ora.end_date is null

join public.master_data md_role
  on md_role.id = ora.role_type_id

where ea.end_date is null;


create or replace view hr.v_org_responsibles as
select
  o.id as organization_id,
  o.name as organization_name,

  md_role.code as role_type_code,
  md_role.name as role_type_name,

  e.id as employee_id,
  e.name as employee_name

from hr.organization_role_assignments ora

join hr.employees e
  on e.id = ora.employee_id

join hr.organizations o
  on o.id = ora.organization_id


-- 角色
join public.master_data md_role
  on md_role.id = ora.role_type_id

where ora.end_date is null;


create or replace view hr.v_employee_picker as
with primary_position as (
  select
    ea.employee_id,
    ea.post_id,
    ea.organization_id
  from hr.employee_assignments ea
  where ea.is_primary = true
    and ea.end_date is null
)

select
  e.id,
  e.name,
  e.code,

  -- 主组织（来自主岗位）
  pp.organization_id,
  org.name as organization_name, 
  e.sort_order,
  
  -- 主岗
  pp.post_id,
  po.name as post_name

from hr.employees e

-- 主岗位
left join primary_position pp
  on pp.employee_id = e.id

-- 岗位名称
left join hr.posts po
  on po.id = pp.post_id

-- 主组织
left join hr.organizations org
  on org.id = pp.organization_id;
