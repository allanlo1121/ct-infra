

-- ==============================
-- 1010 HRM.EMPLOYEE TABLES
-- ==============================

-- 1. TABLE
create table hrm.employees (
  id uuid primary key default gen_random_uuid(),

  auth_id uuid unique references auth.users(id) on delete set null,   

  name                text not null,
  code text unique not null,

  gender_code text  references master_data.dictionary_items(code),

  birth_date date,
  id_card text,
  phone text,
  email text,
  
  organization_id uuid references hrm.organizations(id) on delete set null,
  status_code text references master_data.dictionary_items(code) on delete set null,
  employment_type_code text references master_data.dictionary_items(code) on delete set null,

  hire_date           date,
  entry_date          date,
  leave_date          date,

  sort_order          int default 0,
  is_disabled         boolean default false,

  -- 外部系统集成
  external_id text,
  external_version int,

  -- 约束
  constraint employees_no_self_parent
    check (id <> organization_id)
);

-- 2. AUDIT FIELDS
alter table hrm.employees
add column created_at timestamptz not null default now();

alter table hrm.employees
add column updated_at timestamptz;

alter table hrm.employees
add column created_by uuid
references auth.users(id) on delete set null;

alter table hrm.employees
add column updated_by uuid
references auth.users(id) on delete set null;

create trigger trg_employees_audit_insert
before insert on hrm.employees
for each row
execute function system.audit_insert();

create trigger trg_employees_audit_update
before update on hrm.employees
for each row
execute function system.audit_update();

create trigger trg_employees_audit_delete
before delete on hrm.employees
for each row
execute function system.audit_delete();

-- 3. INDEXES
-- 加速查询直属子机构
create index idx_employees_organization_id
  on hrm.employees(organization_id);


create unique index one_root_employee
on hrm.employees ((organization_id is null))
where organization_id is null;



-- 4. TABLE PERMISSIONS

-- 撤销默认授权
revoke all on table hrm.employees
from public, anon, authenticated;

-- 登录用户基本 CRUD 权限
grant select, insert, update, delete
on table hrm.employees
to authenticated;

-- 服务端角色读写
grant select, insert, update, delete
on table hrm.employees
to service_role;

-- 启用 RLS
alter table hrm.employees
enable row level security;


-- 5. POLICIES

create policy "employees_read"
on hrm.employees
for select
to authenticated
using (true);


create policy "employees_insert_authorized"
on hrm.employees
for insert
to authenticated
with check (
  (select iam.has_permission('hrm','write')) 
);

create policy "employees_update_authorized"
on hrm.employees
for update
to authenticated
using (
  (select iam.has_permission('hrm','write'))
)
with check (
  (select iam.has_permission('hrm','write')) 
);

create policy "employees_delete_authorized"
on hrm.employees
for delete
to authenticated
using (
  (select iam.has_permission('hrm','delete')) 
);



