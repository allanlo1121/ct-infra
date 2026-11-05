-- =====================================================
-- 0100 SYSTEM SCHEMA 
-- =====================================================


create table system.settings (
  key text primary key,
  value jsonb not null,
  description text,

  created_at timestamptz not null default now(),
  updated_at timestamptz,

  created_by uuid references auth.users(id) on delete set null,
  updated_by uuid references auth.users(id) on delete set null
);

create table system.applications (
  code text primary key,
  name text not null,

  description text,
  icon text,

  -- 应用入口地址
  base_url text not null,

  sort_order integer not null default 0,

  is_visible boolean not null default true,
  is_disabled boolean not null default false,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid default auth.uid()
    references auth.users(id) on delete set null,

  updated_by uuid 
    references auth.users(id) on delete set null
);


create table system.menus (
  id uuid primary key default gen_random_uuid(),

  parent_id uuid references system.menus(id),

  code text not null unique,
  name text not null,

  path_url text,
  icon text,

  app_code text not null  default 'admin'
  references system.applications(code),

  sort_order integer not null default 999,

  is_visible boolean not null default true,
  is_disabled boolean not null default false,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  created_by uuid default auth.uid()
    references auth.users(id) on delete set null,

  updated_by uuid 
    references auth.users(id) on delete set null,
  
  unique (app_code, code)
);

create index idx_menus_parent
on system.menus(parent_id);
