-- =====================================================
-- MASTER DATA SCHEMA PERMISSIONS
-- =====================================================

grant usage on schema master_data
to authenticated, service_role;


-- =====================================================
-- EXISTING TABLE PERMISSIONS
-- =====================================================

-- 撤销普通用户已有权限
revoke all on all tables in schema master_data
from public, anon, authenticated;

-- 普通登录用户只读
grant select, insert, update, delete
on
  master_data.dictionary_types,
  master_data.dictionary_items,
  master_data.countries,
  master_data.admin_regions,
  master_data.geological_types
to authenticated;

-- 服务端角色读写
grant select, insert, update, delete
on all tables in schema master_data
to service_role;


-- =====================================================
-- SEQUENCE PERMISSIONS
-- =====================================================

-- 服务端角色使用序列
grant usage, select
on all sequences in schema master_data
to service_role;


-- =====================================================
-- DEFAULT PRIVILEGES
-- =====================================================

-- 撤销先前对未来表的普通用户授权
alter default privileges for role postgres in schema master_data
revoke all on tables
from authenticated, anon, public;

-- 撤销先前对未来序列的普通用户授权
alter default privileges for role postgres in schema master_data
revoke all on sequences
from authenticated, anon, public;

-- 未来新表默认授权 service_role
alter default privileges for role postgres in schema master_data
grant select, insert, update, delete
on tables to service_role;

-- 未来新序列默认授权 service_role
alter default privileges for role postgres in schema master_data
grant usage, select
on sequences to service_role;


-- =====================================================
-- ROW LEVEL SECURITY
-- =====================================================

alter table master_data.dictionary_types
enable row level security;

alter table master_data.dictionary_items
enable row level security;

alter table master_data.countries
enable row level security;

alter table master_data.admin_regions
enable row level security;

alter table master_data.geological_types
enable row level security;



-- =====================================================
-- READ POLICIES
-- =====================================================

create policy "dictionary_types_authenticated_read"
on master_data.dictionary_types
for select
to authenticated
using (true);

create policy "dictionary_items_authenticated_read"
on master_data.dictionary_items
for select
to authenticated
using (true);

create policy "countries_authenticated_read"
on master_data.countries
for select
to authenticated
using (true);

create policy "admin_regions_authenticated_read"
on master_data.admin_regions
for select
to authenticated
using (true);

create policy "geological_types_authenticated_read"
on master_data.geological_types
for select
to authenticated
using (true);

create policy "dictionary_types_insert_authorized"
on master_data.dictionary_types
for insert
to authenticated
with check (
  (select iam.has_permission('master_data','write')) 
);



create policy "dictionary_types_update_authorized"
on master_data.dictionary_types
for update
to authenticated
using (
  (select iam.has_permission('master_data','write'))
)
with check (
  (select iam.has_permission('master_data','write')) 
);

create policy "dictionary_types_delete_authorized"
on master_data.dictionary_types
for delete
to authenticated
using (
  (select iam.has_permission('master_data','write')) 
);



create policy "dictionary_items_insert_authorized"
on master_data.dictionary_items
for insert
to authenticated

with check (
  (select iam.has_permission('master_data','write')) 
);

create policy "dictionary_items_update_authorized"
on master_data.dictionary_items
for update
to authenticated
using (
  (select iam.has_permission('master_data','write'))
)
with check (
  (select iam.has_permission('master_data','write')) 
);

create policy "dictionary_items_delete_authorized"
on master_data.dictionary_items
for delete
to authenticated
using (
  (select iam.has_permission('master_data','write')) 
);


create policy "countries_insert_authorized"
on master_data.countries
for insert
to authenticated

with check (
  (select iam.has_permission('master_data','write')) 
);

create policy "countries_update_authorized"
on master_data.countries
for update
to authenticated
using (
  (select iam.has_permission('master_data','write'))
)
with check (
  (select iam.has_permission('master_data','write')) 
);

create policy "countries_delete_authorized"
on master_data.countries
for delete
to authenticated
using (
  (select iam.has_permission('master_data','write')) 
);


create policy "admin_regions_insert_authorized"
on master_data.admin_regions
for insert
to authenticated

with check (
  (select iam.has_permission('master_data','write')) 
);

create policy "admin_regions_update_authorized"
on master_data.admin_regions
for update
to authenticated
using (
  (select iam.has_permission('master_data','write'))
)
with check (
  (select iam.has_permission('master_data','write')) 
);

create policy "admin_regions_delete_authorized"
on master_data.admin_regions
for delete
to authenticated
using (
  (select iam.has_permission('master_data','write')) 
);

create policy "geological_types_insert_authorized"
on master_data.geological_types
for insert
to authenticated

with check (
  (select iam.has_permission('master_data','write')) 
);

create policy "geological_types_update_authorized"
on master_data.geological_types
for update
to authenticated
using (
  (select iam.has_permission('master_data','write'))
)
with check (
  (select iam.has_permission('master_data','write')) 
);

create policy "geological_types_delete_authorized"
on master_data.geological_types
for delete
to authenticated
using (
  (select iam.has_permission('master_data','write')) 
);