
create or replace function rbac.jwt_permissions()
returns jsonb
language sql
stable
security definer
set search_path = public, rbac, hr ,proj, eqp, tbm
as $$

with current_employee as (
  select e.id
  from hr.employees e
  where e.auth_id = auth.uid()
    and e.deleted_at is null
  limit 1
),

-- 1️⃣ 岗位带来的角色
post_roles_cte as (
  select pr.role_id
  from current_employee ce
  join hr.employee_assignments ea
    on ea.employee_id = ce.id
   and ea.end_date is null
  join rbac.post_roles pr
    on pr.post_id = ea.post_id
),

-- 2️⃣ 用户直接角色
user_roles_cte as (
  select ur.role_id
  from rbac.user_roles ur
    where ur.user_id = auth.uid()
    and ur.is_disabled = false
),

-- 3️⃣ 合并角色
all_roles as (
  select role_id from post_roles_cte
  union
  select role_id from user_roles_cte
)

-- 4️⃣ 输出权限
select coalesce(
  jsonb_agg(distinct p.code) filter (where p.is_disabled = false),
  '[]'::jsonb
)
from all_roles r
join rbac.role_permissions rp
  on rp.role_id = r.role_id
join rbac.permissions p
  on p.id = rp.permission_id;

$$;

create or replace function rbac.current_role_ids()
returns setof uuid
language sql
stable
security definer
as $$
with ce as (
  select system.current_employee_id() as id
),

roles_union as (
  -- 岗位角色
  select pr.role_id
  from ce
  join hr.employee_assignments ea
    on ea.employee_id = ce.id
   and ea.end_date is null
  join rbac.post_roles pr
    on pr.post_id = ea.post_id

  union

  -- 人员角色
  select ur.role_id
  from ce
  join rbac.user_roles ur
    on ur.user_id = ce.id
)
select role_id from roles_union;
$$;



create or replace function rbac.is_super_admin()
returns boolean
language sql
stable
security definer
set search_path = public,rbac,hr,proj,eqp,tbm
as $$
  select exists (
    select 1
    from rbac.user_roles ur
    join rbac.roles r on r.id = ur.role_id
    where ur.user_id = auth.uid()
      and r.code = 'SUPER_ADMIN'
      and r.is_disabled = false
  );
$$;
    


create or replace function rbac.has_permission(p_code text)
returns boolean
language sql
stable
security definer
as $$
select exists (
  select 1
  from rbac.current_role_ids() r
  join rbac.role_permissions rp on rp.role_id = r
  join rbac.permissions p on p.id = rp.permission_id
  where p.code = p_code
    and p.is_disabled = false
);
$$;

-- 确保函数可执行
grant execute on function rbac.has_permission(text) to authenticated;


create or replace function rbac.current_role_ids()
returns setof uuid
language sql
stable
security definer
as $$
with ce as (
  select system.current_employee_id() as id
),

roles_union as (
  -- 岗位角色
  select pr.role_id
  from ce
  join hr.employee_assignments ea
    on ea.employee_id = ce.id
   and ea.end_date is null
  join rbac.post_roles pr
    on pr.post_id = ea.post_id

  union

  -- 人员角色
  select ur.role_id
  from ce
  join rbac.user_roles ur
    on ur.user_id = auth.uid()
    and ur.is_disabled = false
)
select role_id from roles_union;
$$;


create or replace function system.allowed_org_ids()
returns setof uuid
language sql
stable
security definer
set search_path = rbac, public
as $$

with is_admin as (
  select rbac.is_super_admin() as ok
),

-- 当前用户角色
my_roles as (
  select ur.role_id
  from rbac.user_roles ur
  where ur.user_id = auth.uid()
    and ur.is_disabled = false
),

-- 角色范围
scopes as (
  select rs.*
  from rbac.role_scopes rs
  join my_roles r on r.role_id = rs.role_id
)

-- ✅ 1️⃣ 超级管理员 → 全部
select o.id
from hr.organizations o
where (select ok from is_admin)

union

-- ✅ 2️⃣ 非超级管理员 → scope 控制
select distinct o2.id
from scopes rs
left join hr.organizations anchor
  on anchor.id = rs.organization_id
join hr.organizations o2
  on (
    -- ALL
    rs.scope_type = 'ALL'

    -- 向下展开
    or (
      rs.scope_type in ('COMPANY','PROJECT','DEPARTMENT')
      and anchor.path is not null
      and o2.path <@ anchor.path
    )

    -- CUSTOM（单点）
    or (
      rs.scope_type = 'CUSTOM'
      and o2.id = rs.organization_id
    )
  )
where not (select ok from is_admin);

$$;
