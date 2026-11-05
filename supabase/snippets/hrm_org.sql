

-- ==============================
-- 1010 HRM.ORGANIZATION TABLES
-- ==============================

-- 1. TABLE
create table hrm.organizations (
  id uuid primary key default gen_random_uuid(),

  -- 树形结构
  parent_id uuid references hrm.organizations(id)
    on delete restrict,

  -- 基本信息
  code text not null unique,
  name text not null,
  full_name text,
  description text,

  sort_order integer not null default 0,
  is_disabled boolean not null default false,

  -- 业务相关字段
  org_type_code text not null references master_data.dictionary_items(code),
  org_category_code text references master_data.dictionary_items(code),
  business_code text references master_data.dictionary_items(code),

  -- 地址信息
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
  constraint organizations_no_self_parent
    check (id <> parent_id),

  constraint organizations_latitude_check
    check (latitude between -90 and 90),

  constraint organizations_longitude_check
    check (longitude between -180 and 180)
);

-- 2. AUDIT FIELDS
alter table hrm.organizations
add column created_at timestamptz not null default now();

alter table hrm.organizations
add column updated_at timestamptz;

alter table hrm.organizations
add column created_by uuid
references auth.users(id) on delete set null;

alter table hrm.organizations
add column updated_by uuid
references auth.users(id) on delete set null;

create trigger trg_organizations_audit_insert
before insert on hrm.organizations
for each row
execute function system.audit_insert();

create trigger trg_organizations_audit_update
before update on hrm.organizations
for each row
execute function system.audit_update();

create trigger trg_organizations_audit_delete
before delete on hrm.organizations
for each row
execute function system.audit_delete();

-- 3. INDEXES
-- 加速查询直属子机构
create index idx_organizations_parent_id
  on hrm.organizations(parent_id);


create unique index one_root_org
on hrm.organizations ((parent_id is null))
where parent_id is null;



-- 4. TABLE PERMISSIONS

-- 撤销默认授权
revoke all on table hrm.organizations
from public, anon, authenticated;

-- 登录用户基本 CRUD 权限
grant select, insert, update, delete
on table hrm.organizations
to authenticated;

-- 服务端角色读写
grant select, insert, update, delete
on table hrm.organizations
to service_role;

-- 启用 RLS
alter table hrm.organizations
enable row level security;


-- 5. POLICIES

create policy "organizations_read"
on hrm.organizations
for select
to authenticated
using (true);


create policy "organizations_insert_authorized"
on hrm.organizations
for insert
to authenticated
with check (
  (select iam.has_permission('hrm','write')) 
);

create policy "organizations_update_authorized"
on hrm.organizations
for update
to authenticated
using (
  (select iam.has_permission('hrm','write'))
)
with check (
  (select iam.has_permission('hrm','write')) 
);

create policy "organizations_delete_authorized"
on hrm.organizations
for delete
to authenticated
using (
  (select iam.has_permission('hrm','delete')) 
);

  insert into hrm.organizations (
    code,
    name,
    full_name,
    parent_id,
    org_type_code,
    business_code,    
    external_id
  )
 VALUES (
    '0-001-003',
    '集团公司',
    '中铁二局集团有限公司',
    null,
    '10230001',
    null,
    '20181127101355650-A278-632689E5E'
  )
  on conflict (code) do nothing;



  -- 虚拟机构
with
root_org as (
  select id
  from hrm.organizations
  where code = '0-001-003'
  limit 1
)
insert into hrm.organizations (
  code,
  name,
  full_name,
  parent_id,
  org_type_code,
  business_code,
  external_id
)
select
  '0-001-003-006',
  '子(分)公司',
  '中铁二局集团子(分)公司',
  r.id,
  '10230009',
  null,
  '20181127101433134-3D54-B309C4374'
from root_org r
on conflict (code) do nothing;



  insert into hrm.organizations (
    code,
    name,
    full_name,
    parent_id,
    org_type_code,
    org_category_code,
    country_code,
    province_code,
    city_code,
    district_code,
    external_id,
    external_version
  )
 VALUES (
    '0-001-003-006-036',
    '城通公司',
    '中铁二局城通公司',
    null,
    '10230002',
    '10250001',
    'CN',    
    '510000',
    '510100',
    '510106',
    '20200805215458816-2834-7FA5B74BA',
    5
  )
  on conflict (code) do nothing;