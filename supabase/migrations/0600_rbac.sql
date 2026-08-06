

-- =====================================================
-- 0601 RBAC SCHEMA PERMISSIONS
-- =====================================================

create schema if not exists rbac;

-- schema usage
grant usage on schema rbac to authenticated, service_role;

-- existing tables
grant select, insert, update, delete
on all tables in schema rbac
to authenticated, service_role;

-- existing sequences
grant usage, select
on all sequences in schema rbac
to authenticated, service_role;

-- future tables
alter default privileges for role postgres in schema rbac
grant select, insert, update, delete
on tables to authenticated, service_role;

-- future sequences
alter default privileges for role postgres in schema rbac
grant usage, select
on sequences to authenticated, service_role;


-- =====================================================
-- 1) TABLES
-- =====================================================

-- 角色
create table if not exists rbac.roles (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,         -- SUPER_ADMIN
  name text not null,
  description text,

  sort_order int not null default 0,
  is_disabled boolean default false

);

-- 角色-范围（可选，支持基于组织范围的权限控制）
create table if not exists rbac.role_scopes (
  id uuid primary key default gen_random_uuid(),
  role_id uuid not null references rbac.roles(id) on delete cascade,

  -- 范围类型
  scope_type text not null check (
    scope_type in (
      'ALL',           -- 全集团
      'COMPANY',       -- 公司
      'PROJECT',       -- 项目
      'DEPARTMENT',    -- 部门（当前部门）
      'CUSTOM'         -- 自定义组织集合
    )
  ),

  -- 绑定的组织（当 scope_type 不是 ALL 时）
  organization_id uuid references hr.organizations(id)

);

create index on rbac.role_scopes(role_id);
create index on rbac.role_scopes(organization_id);

-- 权限定义
create table if not exists rbac.permissions (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,         -- project.read
  name text not null,
  description text,
  module text not null,
  action text not null,
  resource text,           -- 可选，进一步细化权限作用的资源（如特定项目 ID）

  sort_order int not null default 0,
  is_disabled boolean default false,
  constraint permissions_module_action_unique unique (module, action)
);

-- 岗位-角色（可选）
create table if not exists rbac.post_roles (
  id uuid primary key default gen_random_uuid(),

  post_id uuid not null references hr.posts(id) on delete cascade,
  role_id uuid not null references rbac.roles(id) on delete cascade,

  sort_order int not null default 0,

  unique (post_id, role_id)
);

-- 数据范围（可选）
create table if not exists rbac.post_data_scopes (
  id uuid primary key default gen_random_uuid(),

  post_id uuid not null references hr.posts(id) on delete cascade,

  scope_type_id uuid not null references public.master_data(id), -- DATA_SCOPE

  -- 可选：限定到具体资源（例如 project / tunnel）
  resource_type text,      -- 'project' | 'tunnel' | null
  resource_id uuid,        -- 具体项目ID（可空）

  sort_order int not null default 0,

  unique (post_id, scope_type_id, resource_type, resource_id)
);

-- 角色-权限
create table if not exists rbac.role_permissions (
  id uuid primary key default gen_random_uuid(),
  role_id uuid not null references rbac.roles(id) on delete cascade,
  permission_id uuid not null references rbac.permissions(id) on delete cascade,
  unique (role_id, permission_id)
);

create table rbac.user_roles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null  references auth.users(id) on delete cascade, -- 直接 = auth.uid()
  role_id uuid not null references rbac.roles(id) on delete cascade,

  sort_order int not null default 0,
  is_disabled boolean not null default false,

  assigned_at timestamptz default now(),
  assigned_by uuid references auth.users(id) on delete set null,
  unique (user_id, role_id)
);

create index idx_user_roles_user_id on rbac.user_roles(user_id);
create index idx_user_roles_role_id on rbac.user_roles(role_id);


create table rbac.user_favorite_projects (
  id uuid primary key default gen_random_uuid(),

  user_id uuid not null
    references hr.employees(auth_id) on delete cascade,

  project_id uuid not null
    references proj.projects(id) on delete cascade,

  sort_order int not null default 0,
  is_disabled boolean not null default false,

  unique (user_id, project_id)

);



-- =====================================================
-- 3) INDEXES（生产必须）
-- =====================================================

create index if not exists idx_role_permissions_role
  on rbac.role_permissions(role_id);

create index if not exists idx_permissions_code
  on rbac.permissions(code);

  create index if not exists idx_post_roles_post
  on rbac.post_roles(post_id);

create index if not exists idx_post_roles_role
  on rbac.post_roles(role_id);





