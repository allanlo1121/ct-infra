

-- ==============================
-- 1110 PROJ PROJECT TABLES
-- ==============================

-- 1. TABLE
create table proj.projects (
  id uuid primary key default gen_random_uuid(),

  -- 树形结构
  organization_id uuid references hrm.organizations(id)
    on delete set null,

  -- 基本信息
  code text not null unique,
  name text not null,
  full_name text,
  overview text,
  key_points text, 

  sort_order integer not null default 0,
  is_disabled boolean not null default false,

  -- 业务相关字段
  management_mode_code text not null references master_data.dictionary_items(code),
  project_type_code text not null references master_data.dictionary_items(code),
  project_sub_type_code text references master_data.dictionary_items(code),

  -- 地址信息
  region_code text references master_data.dictionary_items(code),
  country_code text references master_data.countries(code),
  province_code text references master_data.admin_regions(code),
  city_code text references master_data.admin_regions(code),
  district_code text references master_data.admin_regions(code),
  address text,
  latitude numeric(10,6),
  longitude numeric(10,6),

  -- 外部系统集成
  external_id text,
  external_version int,

  -- 约束

  constraint projects_latitude_check
    check (latitude between -90 and 90),

  constraint projects_longitude_check
    check (longitude between -180 and 180)
);

-- 2. AUDIT FIELDS
alter table proj.projects
add column created_at timestamptz not null default now();

alter table proj.projects
add column updated_at timestamptz;

alter table proj.projects
add column created_by uuid
references auth.users(id) on delete set null;

alter table proj.projects
add column updated_by uuid
references auth.users(id) on delete set null;

create trigger trg_projects_audit_insert
before insert on proj.projects
for each row
execute function system.audit_insert();

create trigger trg_projects_audit_update
before update on proj.projects
for each row
execute function system.audit_update();

create trigger trg_projects_audit_delete
before delete on proj.projects
for each row
execute function system.audit_delete();

-- 3. INDEXES
-- 加速查询直属子机构
create index idx_projects_organization_id
  on proj.projects(organization_id);

-- 4. TABLE PERMISSIONS

-- 撤销默认授权
revoke all on table proj.projects
from public, anon, authenticated;

-- 登录用户基本 CRUD 权限
grant select, insert, update, delete
on table proj.projects
to authenticated;

-- 服务端角色读写
grant select, insert, update, delete
on table proj.projects
to service_role;

-- 启用 RLS
alter table proj.projects
enable row level security;


-- 5. POLICIES

create policy "projects_read"
on proj.projects
for select
to authenticated
using (true);


create policy "projects_insert_authorized"
on proj.projects
for insert
to authenticated
with check (
  (select iam.has_permission('proj','write')) 
);

create policy "projects_update_authorized"
on proj.projects
for update
to authenticated
using (
  (select iam.has_permission('proj','write'))
)
with check (
  (select iam.has_permission('proj','write')) 
);

create policy "projects_delete_authorized"
on proj.projects
for delete
to authenticated
using (
  (select iam.has_permission('proj','delete')) 
);



