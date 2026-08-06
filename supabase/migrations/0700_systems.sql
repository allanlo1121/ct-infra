
-- =====================================================
-- 0701 SYSTEM SCHEMA PERMISSIONS
-- =====================================================

create schema if not exists system;

-- schema usage
grant usage on schema system to authenticated, service_role;

-- existing tables
grant select, insert, update, delete
on all tables in schema system
to authenticated, service_role;

-- existing sequences
grant usage, select
on all sequences in schema system
to authenticated, service_role;

-- future tables
alter default privileges for role postgres in schema system
grant select, insert, update, delete
on tables to authenticated, service_role;

-- future sequences
alter default privileges for role postgres in schema system
grant usage, select
on sequences to authenticated, service_role;

-- ==============================
-- 0100 SYSTEM TABLES
-- ==============================

create table system.settings (
  id uuid primary key default gen_random_uuid(),
  key text not null unique,
  value jsonb not null,
  updated_at timestamptz default now(),
  updated_by uuid references auth.users(id)
);


create table system.jobs (
  id uuid primary key default gen_random_uuid(),
  job_type text not null,
  payload jsonb,
  status text default 'pending',
  started_at timestamptz,
  finished_at timestamptz,
  created_at timestamptz default now()
);

create table system.versions (
  id uuid primary key default gen_random_uuid(),
  version text not null,
  deployed_at timestamptz default now()
);

-- create table system.feature_flags (
--   key text primary key,
--   enabled boolean not null default false,
--   config jsonb
-- );

create table if not exists system.bootstrap_state (
  id uuid primary key default gen_random_uuid(),
  version text not null unique,
  completed boolean not null default false,
  executed_at timestamptz
);

create table system.menus (
  id uuid primary key default gen_random_uuid(),

  parent_id uuid
    references system.menus(id)
    on delete cascade,

  -- 树
  path ltree not null,
  node_key text not null,
  level int
    generated always as (nlevel(path)) stored,
  is_leaf boolean not null default true,

  -- 菜单
  code text not null unique,
  name text not null,
  label text not null,
  path_url text unique,
  icon text,

  menu_scope text not null default 'global'
    check (
      menu_scope in (
        'global',
        'admin',
        'workspace',
        'command_center',
        'tunnel_workspace',
        'tbm_workspace',
        'project_workspace'
      )
    ),

  sort_order int not null default 0,

  permission_code text
    references rbac.permissions(code),
  
  is_visible boolean not null default true,
  is_disabled boolean not null default false,

  unique(parent_id, node_key)
);

create index idx_menus_path
on system.menus
using gist(path);

create index idx_menus_parent
on system.menus(parent_id);

create index idx_menus_sort
on system.menus(sort_order);


create table public.stat_period_settings (
    id uuid primary key default gen_random_uuid(),

    code text not null,

    day_cutoff_time time not null default '19:00',

    week_start_dow smallint not null default 6,

    month_start_day smallint not null default 26,

    timezone text not null default 'Asia/Shanghai',

    effective_from date not null,

    effective_to date,

    created_at timestamptz not null default now(),

    unique(code, effective_from)
);




