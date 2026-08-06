
create or replace view rbac.v_user_permissions as
with current_employee as (
  select e.id
  from hr.employees e
  where e.auth_id = auth.uid()
    and e.deleted_at is null
  limit 1
),

-- 岗位角色
post_roles_cte as (
  select pr.role_id
  from current_employee ce
  join hr.employee_assignments ea
    on ea.employee_id = ce.id
   and ea.end_date is null
  join rbac.post_roles pr
    on pr.post_id = ea.post_id
),

-- 用户角色
user_roles_cte as (
  select ur.role_id
  from  rbac.user_roles ur
    where ur.user_id = auth.uid()
    and ur.is_disabled = false
),

all_roles as (
  select role_id from post_roles_cte
  union
  select role_id from user_roles_cte
)

select
  ce.id as user_id,
  p.code as permission_code
from current_employee ce
join all_roles r on true
join rbac.role_permissions rp on rp.role_id = r.role_id
join rbac.permissions p on p.id = rp.permission_id
where p.is_disabled = false;

create or replace view public.v_user_menu as
select m.*
from system.menus m
where m.is_disabled = false
  and (
    m.permission_code is null
    or exists (
      select 1
      from rbac.v_user_permissions up
      where up.permission_code = m.permission_code
    )
  )
order by  m.sort_order;


create or replace view public.v_user_favorite_projects as
select
  p.id,
  p.name,
  '/workspace/projects/' || p.id::text || '/overview' as url,
  'Map' as icon
from rbac.user_favorite_projects uf
join proj.projects p
  on p.id = uf.project_id
where uf.user_id = auth.uid()
  and uf.is_disabled = false
order by uf.sort_order;


create or replace view public.v_runtime_user as
with current_employee as (
  select e.*
  from hr.employees e
  where e.auth_id = auth.uid()
    and e.deleted_at is null
  limit 1
),

-- 当前岗位
current_positions as (
  select ea.*
  from hr.employee_assignments ea
  join current_employee ce on ce.id = ea.employee_id
  where ea.end_date is null
),

-- 主岗位
primary_position as (
  select *
  from current_positions
  where is_primary = true
  limit 1
),

-- 岗位角色
post_roles_cte as (
  select pr.role_id
  from current_positions ea
  join rbac.post_roles pr
    on pr.post_id = ea.post_id
),

-- 用户角色
user_roles_cte as (
  select ur.role_id
  from rbac.user_roles ur
  where ur.user_id = auth.uid()
    and ur.is_disabled = false
),

-- 所有角色
all_roles as (
  select role_id from post_roles_cte
  union
  select role_id from user_roles_cte
),

-- 用户收藏项目
favorite_projects_cte as (
  select
    coalesce(
      jsonb_agg(
        jsonb_build_object(
          'id', p.id,
          'name', p.name,
          'url', '/workspace/projects/' || p.id::text || '/overview',
          'icon', 'Map'
        )
        order by uf.sort_order
      ),
      '[]'::jsonb
    ) as favorite_projects
  from rbac.user_favorite_projects uf
  join proj.projects p
    on p.id = uf.project_id
  where uf.user_id = auth.uid()
    and uf.is_disabled = false
)

select
  u.id as user_id,
  ce.id as employee_id,
  ce.name,

  pp.organization_id,
  o.path as org_path,

   -- 所有组织
  (
    select coalesce(array_agg(distinct ep.organization_id), '{}')
    from current_positions ep
    where ep.organization_id is not null
  ) as organization_ids,

    -- 角色
  (
    select coalesce(array_agg(distinct r.code), '{}')
    from all_roles ar
    join rbac.roles r on r.id = ar.role_id
    where r.is_disabled = false
  ) as roles,

    -- 权限（统一来源）
  (
    select coalesce(array_agg(distinct p.code), '{}')
    from all_roles ar
    join rbac.role_permissions rp on rp.role_id = ar.role_id
    join rbac.permissions p on p.id = rp.permission_id
    where p.is_disabled = false
  ) as permissions,
  
  -- 收藏项目
  fp.favorite_projects

from auth.users u
join current_employee ce on true
left join primary_position pp on true
left join hr.organizations o on o.id = pp.organization_id
left join favorite_projects_cte fp on true
where u.id = auth.uid();