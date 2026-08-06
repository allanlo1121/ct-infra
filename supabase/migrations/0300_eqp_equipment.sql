

-- =====================================================
-- 0301 EQUIPMENT SCHEMA PERMISSIONS
-- =====================================================

create schema if not exists eqp;

-- schema usage
grant usage on schema eqp to authenticated, service_role;

-- existing tables
grant select, insert, update, delete
on all tables in schema eqp
to authenticated, service_role;

-- existing sequences
grant usage, select
on all sequences in schema eqp
to authenticated, service_role;

-- future tables
alter default privileges for role postgres in schema eqp
grant select, insert, update, delete
on tables to authenticated, service_role;

-- future sequences
alter default privileges for role postgres in schema eqp
grant usage, select
on sequences to authenticated, service_role;

-- =====================================================
-- 0302 EQUIPMENT TABLES
-- =====================================================

create table eqp.equipments (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  manage_code text,
  model text not null,
  equip_type_id uuid not null references public.master_data(id) on delete restrict,
  manufacturer_id uuid not null references hr.customers(id) on delete restrict,
  serial_no text,                  -- 出厂序列号
  
  sort_order int not null default 0,
  is_disabled boolean not null default false,
  remark text,
  external_id text,
  external_version int
  );


