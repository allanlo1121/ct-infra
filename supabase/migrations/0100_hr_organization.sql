
-- =====================================================
-- 0101 HR SCHEMA PERMISSIONS
-- =====================================================

create schema if not exists hr;

-- schema usage
grant usage on schema hr to authenticated, service_role;

-- existing tables
grant select, insert, update, delete
on all tables in schema hr
to authenticated, service_role;

-- existing sequences
grant usage, select
on all sequences in schema hr
to authenticated, service_role;

-- future tables
alter default privileges for role postgres in schema hr
grant select, insert, update, delete
on tables to authenticated, service_role;

-- future sequences
alter default privileges for role postgres in schema hr
grant usage, select
on sequences to authenticated, service_role;

-- ==============================
-- 0102 HR.ORGANIZATION TABLES
-- ==============================

create table hr.organizations (
  id uuid primary key default gen_random_uuid(),

  parent_id uuid references hr.organizations(id) on delete restrict,
  node_key text NOT NULL,
  path ltree NOT NULL,
  level int GENERATED ALWAYS AS (nlevel(path)) STORED,
  is_leaf boolean not null default true,

  code text not null unique,
  name text not null,
  full_name text,
  description text,

  sort_order integer default 0,
  is_disabled boolean not null default false,

   -- 业务相关字段
  org_type_id uuid not null references public.master_data(id),
  org_category_id uuid references public.master_data(id),
  business_id uuid  references public.master_data(id),
  
  country_code text references public.countries(code),
  province_code text references public.admin_regions(code),
  city_code text references public.admin_regions(code),
  district_code text references public.admin_regions(code),
  address text,
  latitude numeric(10,6),
  longitude numeric(10,6),
 

  external_id text,
  external_version int,

  check (latitude between -90 and 90),
  check (longitude between -180 and 180),
  check (id <> parent_id)
);



-- 关键：部分唯一索引（只约束非空）
create unique index if not exists uniq_org_external_id
on hr.organizations (external_id)
where external_id is not null;

create unique index one_root_org
on hr.organizations ((parent_id is null))
where parent_id is null;

-- ltree 核心索引
create index idx_organizations_path on hr.organizations using gist(path);

-- parent_id
create index idx_organizations_parent on hr.organizations(parent_id);

-- node_key（可选）
-- create unique index idx_organizations_parent_node_key
-- on hr.organizations(parent_id, node_key)
-- where deleted_at is null;

