-- =====================================================
-- IAM SCHEMA PERMISSIONS
-- =====================================================

revoke all on schema iam
from public, anon, authenticated;

grant usage on schema iam
to authenticated, service_role;


-- =====================================================
-- IAM TABLE PERMISSIONS
-- =====================================================

revoke all on all tables in schema iam
from public, anon, authenticated;

-- 角色管理
grant select, insert, update, delete
on iam.roles
to authenticated;

-- 权限定义：可读可写
grant select, insert, update, delete on iam.permissions
to authenticated;

-- 授权关系：只读
grant select on
  iam.role_permissions,
  iam.user_roles
to authenticated;

-- 用户资料：只读
grant select on iam.user_profiles
to authenticated;

grant insert (
  user_id,
  display_name,
  avatar_path
)
on iam.user_profiles
to authenticated;

grant update (
  user_id,
  display_name,
  avatar_path
)
on iam.user_profiles
to authenticated;

-- 服务端
grant select, insert, update, delete
on all tables in schema iam
to service_role;

grant usage, select
on all sequences in schema iam
to service_role;


-- =====================================================
-- ROW LEVEL SECURITY
-- =====================================================

alter table iam.roles enable row level security;
alter table iam.permissions enable row level security;
alter table iam.role_permissions enable row level security;
alter table iam.user_roles enable row level security;
alter table iam.user_profiles enable row level security;


-- =====================================================
-- USER_PROFILE POLICIES
-- =====================================================

-- 用户只能查看自己的资料
create policy "user_profiles_select_own"
on iam.user_profiles
for select
to authenticated
using (
  user_id = (select auth.uid())
);

-- 用户只能插入自己的资料
create policy "user_profiles_insert_own"
on iam.user_profiles
for insert
to authenticated
with check (
  user_id = (select auth.uid())
);

-- 用户只能更新自己的资料
create policy "user_profiles_update_own"
on iam.user_profiles
for update
to authenticated
using (
  user_id = (select auth.uid())
)
with check (
  user_id = (select auth.uid())
);

create policy "user_profiles_admin_select"
on iam.user_profiles
for select
to authenticated
using (
  (select iam.has_permission('iam','read'))
);

create policy "user_profiles_admin_insert"
on iam.user_profiles
for insert
to authenticated
with check (
  (select iam.has_permission('iam','write'))
);

create policy "user_profiles_admin_update"
on iam.user_profiles
for update
to authenticated
using (
  (select iam.has_permission('iam','write'))
)
with check (
  (select iam.has_permission('iam','write'))
);



-- =====================================================
-- ROLE POLICIES
-- =====================================================

create policy "roles_select_authorized"
on iam.roles
for select
to authenticated
using ( 
  (select iam.has_permission('iam','read'))
);

create policy "roles_insert_authorized"
on iam.roles
for insert
to authenticated
with check (
  (select iam.has_permission('iam','write'))
  and code <> 'SUPER_ADMIN'
);

create policy "roles_update_authorized"
on iam.roles
for update
to authenticated
using (
  (select iam.has_permission('iam','write'))
  and code <> 'SUPER_ADMIN'
)
with check (
  (select iam.has_permission('iam','write'))
  and code <> 'SUPER_ADMIN'
);

create policy "roles_delete_authorized"
on iam.roles
for delete
to authenticated
using (
  (select iam.has_permission('iam','delete'))
  and code <> 'SUPER_ADMIN'
);

-- =====================================================
-- PERMISSIONS POLICIES
-- =====================================================

-- 权限列表：查看权限或管理角色时需要
create policy "permissions_select_authorized"
on iam.permissions
for select
to authenticated
using (  
  (select iam.has_permission('iam','read'))
);

create policy "permissions_insert_authorized"
on iam.permissions
for insert
to authenticated
with check (
  (select iam.has_permission('iam','write')) 
);

create policy "permissions_update_authorized"
on iam.permissions
for update
to authenticated
using (
  (select iam.has_permission('iam','write'))  
)
with check (
  (select iam.has_permission('iam','write'))
);

create policy "permissions_delete_authorized"
on iam.permissions
for delete
to authenticated
using (
  (select iam.has_permission('iam','delete')) 
);

-- =====================================================
-- ROLE PERMISSIONS POLICIES
-- =====================================================

create policy "role_permissions_select_authorized"
on iam.role_permissions
for select
to authenticated
using (
  (select iam.has_permission('iam','read'))
);

revoke insert, update, delete
on iam.role_permissions
from public, anon, authenticated;

-- =====================================================
-- USER ROLES POLICIES
-- =====================================================

-- =====================================================
-- USER ROLES POLICIES
-- =====================================================

alter table iam.user_roles
enable row level security;

-- 本人或 IAM 管理员可以查看
create policy "user_roles_select_authorized"
on iam.user_roles
for select
to authenticated
using (
  user_id = (select auth.uid())
  or
  (select iam.has_permission('iam', 'read'))
);

-- 不创建 INSERT / UPDATE / DELETE Policy
revoke insert, update, delete
on iam.user_roles
from public, anon, authenticated;


-- 所有登录用户可读
create policy applications_select
on system.applications
for select
to authenticated
using (true);


-- 只有拥有管理权限的用户可以新增
create policy applications_insert
on system.applications
for insert
to authenticated
with check (
  iam.has_permission('iam','write')
);


-- 只有拥有管理权限的用户可以更新
create policy applications_update
on system.applications
for update
to authenticated
using (
  iam.has_permission('iam','write')
)
with check (
  iam.has_permission('iam','write')
);


-- 只有拥有管理权限的用户可以删除
create policy applications_delete
on system.applications
for delete
to authenticated
using (
  iam.has_permission('iam','write')
);
