


-- ==============================
-- 0010 MASTER TABLES
-- ==============================

create table master_data.dictionary_types( 
  code text primary key,
  name text not null,
  description text,
  is_disabled boolean not null default false 

);



create table master_data.dictionary_items (  
  code text primary key,
  dictionary_type_code text not null references master_data.dictionary_types(code) on delete restrict,
  name text not null,
  description text null,

  is_disabled boolean not null default false

); 

create index idx_dictionary_items_dictionary_type_code
on master_data.dictionary_items(dictionary_type_code);


create table master_data.countries (  
  code text primary key,  -- ISO alpha-2

  name text not null,
  full_name text,

  sort_order integer not null default 0,
  is_disabled boolean not null default false,

  constraint countries_code_check
  check (code ~ '^[A-Z]{2}$')

);



create table master_data.admin_regions ( 
  code text primary key,  -- 国家统计局编码

  name text not null,
  short_name text not null,
  full_name text not null,

  level integer not null,
  parent_code text references master_data.admin_regions(code) on delete restrict,

  pinyin_code text not null,
 
  is_disabled boolean not null default false
);



-- 行政区划编码格式
alter table master_data.admin_regions
add constraint admin_regions_code_check
check (code ~ '^[0-9]{6}$');

-- 禁止自己成为自己的父级
alter table master_data.admin_regions
add constraint admin_regions_parent_check
check (parent_code is null or parent_code <> code);

-- 父级查询索引
create index idx_admin_regions_parent_code
on master_data.admin_regions(parent_code);



-- Add audit fields to dictionary_types tables
alter table master_data.dictionary_types
add column created_at timestamptz not null default now();

alter table master_data.dictionary_types
add column updated_at timestamptz;


alter table master_data.dictionary_types
add column created_by uuid
references auth.users(id) on delete set null;

alter table master_data.dictionary_types
add column updated_by uuid
references auth.users(id) on delete set null;

-- Add audit fields to dictionary_items tables
alter table master_data.dictionary_items
add column created_at timestamptz not null default now();

alter table master_data.dictionary_items
add column updated_at timestamptz;

alter table master_data.dictionary_items
add column created_by uuid
references auth.users(id) on delete set null;

alter table master_data.dictionary_items
add column updated_by uuid
references auth.users(id) on delete set null;

-- Add audit fields to countries
alter table master_data.countries
add column created_at timestamptz not null default now();

alter table master_data.countries
add column updated_at timestamptz;

alter table master_data.countries
add column created_by uuid
references auth.users(id) on delete set null;

alter table master_data.countries
add column updated_by uuid
references auth.users(id) on delete set null;

-- Add audit fields to admin_regions
alter table master_data.admin_regions
add column created_at timestamptz not null default now();

alter table master_data.admin_regions
add column updated_at timestamptz;

alter table master_data.admin_regions
add column created_by uuid
references auth.users(id) on delete set null;

alter table master_data.admin_regions
add column updated_by uuid
references auth.users(id) on delete set null;



create table master_data.geological_types (
  code text primary key,

  -- 树形结构 
  parent_code text references master_data.geological_types(code)
    on delete restrict,

  -- 基础信息
  name text not null,
  
  remark text,

  is_disabled boolean not null default false,

  -- 审计字段
  created_at timestamptz not null default now(),
  updated_at timestamptz,
  created_by uuid references auth.users(id) on delete set null,
  updated_by uuid references auth.users(id) on delete set null,



  constraint geological_types_no_self_parent
    check (code <> parent_code)
);

-- 查询直接下级分类
create index idx_geological_types_parent_id
on master_data.geological_types(parent_code);


