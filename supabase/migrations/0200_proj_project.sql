
-- =====================================================
-- 0201 PROJECT SCHEMA PERMISSIONS
-- =====================================================

create schema if not exists proj;

-- schema usage
grant usage on schema proj to authenticated, service_role;

-- existing tables
grant select, insert, update, delete
on all tables in schema proj
to authenticated, service_role;

-- existing sequences
grant usage, select
on all sequences in schema proj
to authenticated, service_role;

-- future tables
alter default privileges for role postgres in schema proj
grant select, insert, update, delete
on tables to authenticated, service_role;

-- future sequences
alter default privileges for role postgres in schema proj
grant usage, select
on sequences to authenticated, service_role;


-- =====================================================
-- 0202 PROJECT TABLES
-- =====================================================

CREATE TABLE proj.projects (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),

--基本信息
  name                    TEXT NOT NULL,                 -- 项目全称
  full_name                TEXT,                         -- 项目简称
  code                    TEXT NOT NULL,                 -- 项目编码
  project_overview        TEXT,                          -- 项目描述
  project_key_points      TEXT,                          -- 项目要点
  project_scope           TEXT,                          -- 项目范围  

--工程管理信息
  organization_id              UUID REFERENCES hr.organizations(id), -- 负责该项目的组织机构
  project_management_mode_id   UUID REFERENCES master_data(id),       -- 管理模式（如“自管”、“托管”）
  project_type_id              UUID REFERENCES master_data(id),       -- 工程类型（如“铁路工程”、“公路工程”）
  project_sub_type_id   UUID REFERENCES master_data(id),             -- 子工程类型（如“高铁”、“客专”）
 

--进度信息时间
  actual_start_date      DATE,                                       -- 实际开工日期
  actual_end_date        DATE,                                       -- 实际竣工日期



--位置信息
  country_code            text REFERENCES countries(code),             -- 国家（如“中国”） 
  region_id             UUID REFERENCES master_data(id),             -- 大区（如“华东区”、“华北区”）
  province_code           text REFERENCES admin_regions(code),             -- 省份（如“上海市”、“北京市”）
  city_code               text REFERENCES admin_regions(code),             -- 城市（如“上海”、“北京”）  
  district_code           text REFERENCES admin_regions(code),             -- 区/县（如“浦东新区”、“朝阳区”）
  address               TEXT,                                        -- 详细地址（如“世纪大道100号”）
  longitude             DECIMAL(10, 6),                              -- 经度
  latitude              DECIMAL(10, 6),                              -- 纬度

  sort_order          INT,                                         -- 排序
  is_disabled         BOOLEAN NOT NULL DEFAULT FALSE,                -- 是否禁用
  remark               TEXT,                                        -- 备注


--外部标识
  external_id    text,                        -- 外部全局唯一标识
  external_version    int,                                        -- 外部来源系统标识

  check (latitude between -90 and 90),
  check (longitude between -180 and 180)


);


create table proj.project_status_timeline(
  id uuid primary key default gen_random_uuid(),

  -- 🔥 通用对象
  project_id uuid not null references proj.projects(id) on delete cascade,

  -- 状态
  project_status_id uuid references master_data(id),
  project_sub_status_id uuid references master_data(id),

  -- ✅ 业务时间（核心）
  valid_from timestamptz not null,
  valid_to timestamptz,


  -- 来源 
  change_type text,   -- normal / correction / auto

  -- 备注
  remark text
);

alter table proj.project_status_timeline
add constraint no_overlap_status
exclude using gist (
  project_id with =,
  tstzrange(valid_from, coalesce(valid_to, 'infinity')) with &&
);

create table proj.project_risk_level_timeline(
  id uuid primary key default gen_random_uuid(),

  -- 🔥 通用对象
  project_id uuid not null references proj.projects(id) on delete cascade,

  -- 状态
  project_risk_level_id uuid references master_data(id), 

  -- ✅ 业务时间（核心）
  valid_from timestamptz not null,
  valid_to timestamptz,


  -- 来源 
  change_type text,   -- normal / correction / auto

  -- 备注
  remark text
);

alter table proj.project_risk_level_timeline
add constraint no_overlap_risk_level
exclude using gist (
  project_id with =,
  tstzrange(valid_from, coalesce(valid_to, 'infinity')) with &&
);

create table proj.project_control_level_timeline(
  id uuid primary key default gen_random_uuid(),

  -- 🔥 通用对象
  project_id uuid not null references proj.projects(id) on delete cascade,

  -- 状态
  project_control_level_id uuid references master_data(id),

  -- ✅ 业务时间（核心）
  valid_from timestamptz not null,
  valid_to timestamptz,


  -- 来源 
  change_type text,   -- normal / correction / auto

  -- 备注
  remark text
);

alter table proj.project_control_level_timeline
add constraint no_overlap_control_level
exclude using gist (
  project_id with =,
  tstzrange(valid_from, coalesce(valid_to, 'infinity')) with &&
);

create table proj.project_attention_level_timeline(
  id uuid primary key default gen_random_uuid(),

  -- 🔥 通用对象
  project_id uuid not null references proj.projects(id) on delete cascade,

  -- 状态
  project_attention_level_id uuid references master_data(id),

  -- ✅ 业务时间（核心）
  valid_from timestamptz not null,
  valid_to timestamptz,


  -- 来源 
  change_type text,   -- normal / correction / auto

  -- 备注
  remark text
);

alter table proj.project_attention_level_timeline
add constraint no_overlap_attention_level
exclude using gist (
  project_id with =,
  tstzrange(valid_from, coalesce(valid_to, 'infinity')) with &&
);


create table proj.project_attention_type_timeline (
  id uuid primary key default gen_random_uuid(),

  project_id uuid not null references proj.projects(id) on delete cascade,

  attention_type_id uuid not null references master_data(id),

  -- 时间区间
  valid_from timestamptz not null,
  valid_to timestamptz,

  -- 来源
  source text,
  change_type text default 'normal'
);

alter table proj.project_attention_type_timeline
add constraint no_overlap_same_type
exclude using gist (
  project_id with =,
  attention_type_id with =,
  tstzrange(valid_from, coalesce(valid_to, 'infinity')) with &&
);


create table proj.project_schedule_versions (
  id uuid primary key default gen_random_uuid(),

  project_id uuid not null references proj.projects(id) on delete cascade,

  version_no int not null,   -- 1,2,3...

  -- 只放会“业务调整”的
  schedule_start_date date,
  schedule_end_date date,
  commissioning_date date,

  -- 变更信息
  change_reason text,
  source text,
  remark text,

  unique (project_id, version_no)
);


