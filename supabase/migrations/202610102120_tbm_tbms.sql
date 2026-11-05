

-- ==============================
-- 2060 TBM TBMS TABLES
-- ==============================

-- 1. TABLE
create table tbm.tbms (
  -- 盾构机唯一业务编码
  code text primary key,

  -- 关联设备台账（可选）
  device_id uuid unique
    references equip.devices(id)
    on delete set null,

  -- 盾构机基础信息
  name text not null,

  -- 盾构机专业信息
  tbm_type_code text not null references master_data.dictionary_items(code) on delete restrict,
  diameter numeric(10, 3),

  sort_order integer not null default 0,

  -- 状态
  is_disabled boolean not null default false

);

-- 2. AUDIT FIELDS
alter table tbm.tbms
add column created_at timestamptz not null default now();

alter table tbm.tbms
add column updated_at timestamptz;

alter table tbm.tbms
add column created_by uuid
references auth.users(id) on delete set null;

alter table tbm.tbms
add column updated_by uuid
references auth.users(id) on delete set null;

create trigger trg_tbms_audit_insert
before insert on tbm.tbms
for each row
execute function system.audit_insert();

create trigger trg_tbms_audit_update
before update on tbm.tbms
for each row
execute function system.audit_update();

create trigger trg_tbms_audit_delete
before delete on tbm.tbms
for each row
execute function system.audit_delete();

-- 3. INDEXES
-- 加速查询设备编号
create index idx_tbms_code
  on tbm.tbms(code);

-- 4. TABLE PERMISSIONS

-- 撤销默认授权
revoke all on table tbm.tbms
from public, anon, authenticated;

-- 登录用户基本 CRUD 权限
grant select, insert, update, delete
on table tbm.tbms
to authenticated;

-- 服务端角色读写
grant select, insert, update, delete
on table tbm.tbms
to service_role;

-- 启用 RLS
alter table tbm.tbms
enable row level security;


-- 5. POLICIES

create policy "tbms_read"
on tbm.tbms
for select
to authenticated
using (true);


create policy "tbms_insert_authorized"
on tbm.tbms
for insert
to authenticated
with check (
  (select iam.has_permission('tbm','write')) 
);

create policy "tbms_update_authorized"
on tbm.tbms
for update
to authenticated
using (
  (select iam.has_permission('tbm','write'))
)
with check (
  (select iam.has_permission('tbm','write')) 
);

create policy "tbms_delete_authorized"
on tbm.tbms
for delete
to authenticated
using (
  (select iam.has_permission('tbm','delete')) 
);



