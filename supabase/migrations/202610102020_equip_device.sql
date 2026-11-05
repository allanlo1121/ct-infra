

-- ==============================
-- 1110 PROJ PROJECT TABLES
-- ==============================

-- 1. TABLE
create table equip.devices (
  id uuid primary key default gen_random_uuid(),

  -- 设备标识
  device_number text not null unique,
  qr_code text,
  license_number text,

  -- 设备基本信息
  name text not null,
  spec text,
  model text,
  unit text,

  -- 设备来源、状态
  source_code text,
  state_code text,

  sort_order integer not null default 0,

  is_disabled boolean not null default false

);

-- 2. AUDIT FIELDS
alter table equip.devices
add column created_at timestamptz not null default now();

alter table equip.devices
add column updated_at timestamptz;

alter table equip.devices
add column created_by uuid
references auth.users(id) on delete set null;

alter table equip.devices
add column updated_by uuid
references auth.users(id) on delete set null;

create trigger trg_devices_audit_insert
before insert on equip.devices
for each row
execute function system.audit_insert();

create trigger trg_devices_audit_update
before update on equip.devices
for each row
execute function system.audit_update();

create trigger trg_devices_audit_delete
before delete on equip.devices
for each row
execute function system.audit_delete();

-- 3. INDEXES
-- 加速查询设备编号
create index idx_devices_device_number
  on equip.devices(device_number);

-- 4. TABLE PERMISSIONS

-- 撤销默认授权
revoke all on table equip.devices
from public, anon, authenticated;

-- 登录用户基本 CRUD 权限
grant select, insert, update, delete
on table equip.devices
to authenticated;

-- 服务端角色读写
grant select, insert, update, delete
on table equip.devices
to service_role;

-- 启用 RLS
alter table equip.devices
enable row level security;


-- 5. POLICIES

create policy "devices_read"
on equip.devices
for select
to authenticated
using (true);


create policy "devices_insert_authorized"
on equip.devices
for insert
to authenticated
with check (
  (select iam.has_permission('proj','write')) 
);

create policy "devices_update_authorized"
on equip.devices
for update
to authenticated
using (
  (select iam.has_permission('proj','write'))
)
with check (
  (select iam.has_permission('proj','write')) 
);

create policy "devices_delete_authorized"
on equip.devices
for delete
to authenticated
using (
  (select iam.has_permission('proj','delete')) 
);



