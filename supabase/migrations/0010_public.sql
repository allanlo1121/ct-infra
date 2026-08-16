
-- =====================================================
-- GLOBAL SEARCH PATH
-- =====================================================

alter database postgres set search_path to public;

-- schema usage
grant usage on schema public to authenticated, service_role;

-- existing tables
grant select, insert, update, delete
on all tables in schema public
to authenticated, service_role;

-- existing sequences
grant usage, select
on all sequences in schema public
to authenticated, service_role;

-- future tables
alter default privileges for role postgres in schema public
grant select, insert, update, delete
on tables to authenticated, service_role;

-- future sequences
alter default privileges for role postgres in schema public
grant usage, select
on sequences to authenticated, service_role;

-- ==============================
-- 0010 MASTER TABLES
-- ==============================

create table public.master_definitions (
  id uuid  primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  description text,
  is_disabled boolean not null default false 

) TABLESPACE pg_default;



create table public.master_data (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  definition_id uuid not null references master_definitions(id) on delete restrict,
  name text not null,
  description text null,

  is_disabled boolean not null default false,

  constraint uq_master_data_def_code 
      unique (definition_id, code)

) TABLESPACE pg_default;


create index idx_master_data_definition
on public.master_data(definition_id);


create table public.countries (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,  -- ISO alpha-2

  name text not null,
  english_name text,
  alpha3_code text unique,
  numeric_code text unique,

  sort_order integer not null default 0,
  is_disabled boolean not null default false

);

create view public.v_master_options as
select
  d.id,
  d.code,
  d.name,
  d.description,
  def.id as definition_id,
  def.code as definition_code,
  def.name as definition_name
from public.master_data d
join public.master_definitions def
  on d.definition_id = def.id
where d.is_disabled = false
  and def.is_disabled = false;



create table public.admin_regions (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,  -- 国家统计局编码

  name text not null,
  short_name text,
  full_name text,

  level integer not null,
  parent_code text references public.admin_regions(code) on delete restrict,

  pinyin_code text,

  sort_order integer not null default 0,
  is_disabled boolean not null default false
);


create table public.import_batches (
  id uuid primary key default gen_random_uuid(),

  table_name text not null,

  total_count int not null,
  inserted_count int default 0,
  updated_count int default 0,
  skipped_count int default 0,
  failed_count int default 0,

  status text not null default 'processing', -- processing / success / failed

  started_at timestamptz default now(),
  finished_at timestamptz
);

create table public.import_records (
  id uuid primary key default gen_random_uuid(),

  batch_id uuid references import_batches(id),

  table_name text,

  raw jsonb,
  data jsonb,

  external_version int,

  status text, -- inserted / updated / skipped / error
  message text

);


create schema if not exists app;


-- schema
grant usage on schema app to anon;
grant usage on schema app to authenticated;