
create table proj.project_catalog_std (

  id uuid primary key default gen_random_uuid(),

  parent_id uuid references proj.project_catalog_std(id),

  code text not null,
  name text not null,

  -- 树结构核心
  path ltree not null,
  node_key text not null,
  level int GENERATED ALWAYS AS (nlevel(path)) STORED,
  is_leaf boolean not null default true,  

  sort_order int not null default 0,
  is_disabled boolean not null default false,

  -- 业务字段
  qty_unit text,

  project_type_id uuid references public.master_data(id) on delete set null,
  major_type_id uuid references public.master_data(id) on delete set null,
  project_catalog_type_id uuid references public.master_data(id) on delete set null,

  remark text,

  external_id text,
  external_version int

);

create index idx_project_catalog_std_path on proj.project_catalog_std using gist (path);


create table proj.project_work_points (
  id uuid primary key default gen_random_uuid(),

  project_id uuid not null references proj.projects(id) on delete cascade,

  code text not null,
  name text not null,

  content text,

  sort_order int not null default 0,
  is_disabled boolean not null default false,
  remark text,

  external_id text,
  external_version int
);


CREATE TABLE proj.project_catalogs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    name TEXT NOT NULL,
    short_name TEXT,

    -- 树结构核心
    path ltree not null,
    node_key text not null,
    is_leaf boolean not null default true,
    level int GENERATED ALWAYS AS (nlevel(path)) STORED,


    project_id UUID NOT NULL REFERENCES proj.projects(id) ON DELETE CASCADE,

    parent_id UUID REFERENCES proj.project_catalogs(id) ON DELETE SET NULL,
    
    -- 工程分类（可选，例如 "区间", "车站", "附属", "道路改迁"）
    project_catalog_std_id UUID REFERENCES proj.project_catalog_std(id),
    project_work_point_id UUID REFERENCES proj.project_work_points(id),

    
    engineering_qty NUMERIC(18,3),   -- 工程量（设计量）    
    remarks TEXT,

    sort_order INT DEFAULT 0,
    is_disabled BOOLEAN NOT NULL DEFAULT FALSE,

    external_id text,
    external_version int

);

create index idx_project_catalogs_path on proj.project_catalogs using gist (path);