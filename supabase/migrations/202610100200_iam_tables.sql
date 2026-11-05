-- =====================================================
-- 0010 IAM SCHEMA
-- =====================================================

create schema if not exists iam;

create type iam.permission_module as enum (
  'iam',
  'master_data',
  'hrm',
  'proj',
  'equip',
  'tbm',
  'mqtt'
);

create type iam.permission_action as enum (
  'read',
  'write',
  'delete'
);

-- =====================================================
-- 1. USER PROFILES
-- =====================================================

create table iam.user_profiles (
  user_id uuid primary key
    references auth.users(id) on delete cascade,

  display_name text,
  avatar_path text,

  created_at timestamptz not null default now(),
  updated_at timestamptz
);


-- =====================================================
-- 2. ROLES
-- =====================================================

create table iam.roles (
  id uuid primary key default gen_random_uuid(),

  code text not null unique,
  name text not null,
  description text,

  sort_order integer not null default 0,
  is_disabled boolean not null default false,

  created_at timestamptz not null default now(),
  updated_at timestamptz,

  created_by uuid
    default auth.uid()
    references auth.users(id) on delete set null,

  updated_by uuid
    references auth.users(id) on delete set null
);


-- =====================================================
-- 3. PERMISSIONS
-- =====================================================

create table iam.permissions (
  id uuid primary key default gen_random_uuid(),

  module iam.permission_module not null,
  action iam.permission_action not null,

  name text not null,
  description text,

  sort_order integer not null default 0,
  is_disabled boolean not null default false,

  created_at timestamptz not null default now(),
  updated_at timestamptz,

  created_by uuid
    default auth.uid()
    references auth.users(id) on delete set null,

  updated_by uuid
    references auth.users(id) on delete set null,

  unique (module, action)
);


-- =====================================================
-- 4. ROLE PERMISSIONS
-- =====================================================

create table iam.role_permissions (
  id uuid primary key default gen_random_uuid(),

  role_id uuid not null
    references iam.roles(id) on delete cascade,

  permission_id uuid not null
    references iam.permissions(id) on delete cascade,

  created_at timestamptz not null default now(),
  updated_at timestamptz,

  created_by uuid
    default auth.uid()
    references auth.users(id) on delete set null,

  updated_by uuid
    references auth.users(id) on delete set null,

  unique (role_id, permission_id)
);


-- =====================================================
-- 5. USER ROLES
-- =====================================================

create table iam.user_roles (
  id uuid primary key default gen_random_uuid(),

  user_id uuid not null
    references auth.users(id) on delete cascade,

  role_id uuid not null
    references iam.roles(id) on delete cascade,

  assigned_at timestamptz not null default now(),

  assigned_by uuid
    default auth.uid()
    references auth.users(id) on delete set null,


  unique (user_id, role_id)
);


-- =====================================================
-- 6. INDEXES
-- =====================================================

create index idx_role_permissions_permission_id
on iam.role_permissions(permission_id);

create index idx_user_roles_role_id
on iam.user_roles(role_id);