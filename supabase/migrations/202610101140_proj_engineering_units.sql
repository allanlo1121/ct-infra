

-- ==============================
-- 1140 PROJ.ENGINEERING_UNITS TABLES
-- ==============================

-- 1. TABLE
create table proj.engineering_units (
  id uuid primary key default gen_random_uuid(),

  -- 树形结构
  project_id uuid not null references proj.projects(id)
    on delete restrict,

  -- 基本信息

  name text not null,
  full_name text,
  overview text,

  sort_order integer not null default 0,
  is_disabled boolean not null default false,

  -- 业务相关字段 2072
  engineering_unit_type_code text not null references master_data.dictionary_items(code),


  -- 地址信息
  province_code text references master_data.admin_regions(code),
  city_code text references master_data.admin_regions(code),
  district_code text references master_data.admin_regions(code),
  address text,
  latitude numeric(10,6),
  longitude numeric(10,6),


  -- 约束

  constraint engineering_units_latitude_check
    check (latitude between -90 and 90),

  constraint engineering_units_longitude_check
    check (longitude between -180 and 180)
);

-- 2. AUDIT FIELDS
alter table proj.engineering_units
add column created_at timestamptz not null default now();

alter table proj.engineering_units
add column updated_at timestamptz;

alter table proj.engineering_units
add column created_by uuid
references auth.users(id) on delete set null;

alter table proj.engineering_units
add column updated_by uuid
references auth.users(id) on delete set null;

create trigger trg_engineering_units_audit_insert
before insert on proj.engineering_units
for each row
execute function system.audit_insert();

create trigger trg_engineering_units_audit_update
before update on proj.engineering_units
for each row
execute function system.audit_update();

create trigger trg_engineering_units_audit_delete
before delete on proj.engineering_units
for each row
execute function system.audit_delete();

-- 3. INDEXES
-- 加速查询直属子机构
create index idx_engineering_units_project_id
  on proj.engineering_units(project_id);

-- 4. TABLE PERMISSIONS

-- 撤销默认授权
revoke all on table proj.engineering_units
from public, anon, authenticated;

-- 登录用户基本 CRUD 权限
grant select, insert, update, delete
on table proj.engineering_units
to authenticated;

-- 服务端角色读写
grant select, insert, update, delete
on table proj.engineering_units
to service_role;

-- 启用 RLS
alter table proj.engineering_units
enable row level security;


-- 5. POLICIES

create policy "engineering_units_read"
on proj.engineering_units
for select
to authenticated
using (true);


create policy "engineering_units_insert_authorized"
on proj.engineering_units
for insert
to authenticated
with check (
  (select iam.has_permission('proj','write')) 
);

create policy "engineering_units_update_authorized"
on proj.engineering_units
for update
to authenticated
using (
  (select iam.has_permission('proj','write'))
)
with check (
  (select iam.has_permission('proj','write')) 
);

create policy "engineering_units_delete_authorized"
on proj.engineering_units
for delete
to authenticated
using (
  (select iam.has_permission('proj','delete')) 
);



