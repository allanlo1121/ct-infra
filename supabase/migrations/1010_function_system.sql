
--上下文函数

--当前用户
create or replace function system.current_employee_id()
returns uuid
language plpgsql
stable
security definer
set search_path = public, hr
as $$
declare
  v_employee_id uuid;
begin
  select p.id into v_employee_id
  from hr.employees p
  where p.auth_id = auth.uid()
    and p.deleted_at is null
  limit 1;

  if v_employee_id is not null then
    return v_employee_id;
  end if;

  -- fallback（系统任务）
  return '00000000-0000-0000-0000-000000000001';
end;
$$;

--当前组织
create or replace function system.current_org_id()
returns uuid
language sql
stable
security definer
set search_path = public, hr
as $$
  select ea.organization_id
  from hr.employees e
  join hr.employee_assignments ea
    on ea.employee_id = e.id
   and ea.is_primary = true
   and ea.end_date is null
  where e.auth_id = auth.uid()
    and e.deleted_at is null
  limit 1
$$;


--组织范围
-- create or replace function system.allowed_org_ids()
-- returns setof uuid
-- language sql
-- stable
-- security definer
-- set search_path = public, hr
-- as $$
--   select o2.id
--   from public.organizations o1
--   join public.organizations o2
--     on o2.path <@ o1.path
--   where o1.id = system.current_org_id()
-- $$;

-- ============================================
--  首次进入建立管理员账户的函数
-- ============================================

create or replace function system.bootstrap(p_user_id uuid)
returns void
language plpgsql
security definer
as $$
declare
  v_role_id uuid;
  v_employee_id uuid;
begin

  if auth.role() <> 'service_role' then
    raise exception 'permission denied';
  end if;

  -- 已初始化直接返回
  if exists (
    select 1
    from system.bootstrap_state
    where version = '1.0.0'
      and completed = true
  ) then
    return;
  end if;

  -- =========================
  -- 1️⃣ 创建角色
  -- =========================
  insert into rbac.roles (code, name)
  values ('SUPER_ADMIN', '超级管理员')
  on conflict (code) do nothing;

  select id into v_role_id
  from rbac.roles
  where code = 'SUPER_ADMIN';

  -- 创建 employee，并绑定 auth
  insert into hr.employees (
    id,
    auth_id,
    name,
    code
  )
  values (
    gen_random_uuid(),
    p_user_id,           -- ⭐ 绑定 auth
    '系统管理员',
    'SUPER_ADMIN'
  )
  returning id into v_employee_id;

  -- =========================
  -- 3️⃣ 绑定用户
  -- =========================
  insert into rbac.user_roles (user_id, role_id)
  values (p_user_id, v_role_id)
  on conflict do nothing;

  -- =========================
  -- 4️⃣ 标记完成
  -- =========================
  insert into system.bootstrap_state (version, completed, executed_at)
  values ('1.0.0', true, now())
  on conflict (version)
  do update set completed = true,
                executed_at = now();

end;
$$;

create or replace function public.bootstrap(p_user_id uuid)
returns void
language plpgsql
security definer
as $$
begin
  if auth.role() <> 'service_role' then
    raise exception 'permission denied';
  end if;

  perform system.bootstrap(p_user_id);
end;
$$;

-- 移除默认权限
revoke execute on function public.bootstrap(p_user_id uuid) from anon;
revoke execute on function public.bootstrap(p_user_id uuid) from authenticated;

-- 只给 service_role
grant execute on function public.bootstrap(p_user_id uuid) to service_role;


-- 确保 owner 是 postgres
alter function system.bootstrap(p_user_id uuid) owner to postgres;
alter function public.bootstrap(p_user_id uuid) owner to postgres;