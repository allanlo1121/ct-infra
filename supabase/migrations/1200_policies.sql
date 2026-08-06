

-- =====================================================
-- 为 organizations 表启用 RLS
-- =====================================================
alter table hr.organizations enable row level security;
alter table hr.organizations force row level security;


create policy "organizations_select"
on hr.organizations
for select
to authenticated
using (
  rbac.is_super_admin()
  OR exists (
    select 1 from system.allowed_org_ids() a
    where a = organizations.id
  )
);

create policy "organizations_insert"
on hr.organizations
for insert
to authenticated
with check (rbac.is_super_admin());

create policy "organizations_update"
on hr.organizations
for update
to authenticated
using (rbac.is_super_admin())
with check (rbac.is_super_admin());

create policy "organizations_delete"
on hr.organizations
for delete
to authenticated
using (rbac.is_super_admin());


-- =====================================================
-- 为 employees 表启用 RLS
-- =====================================================
alter table hr.employees enable row level security;
alter table hr.employees force row level security;

-- SELECT
create policy "employees_select"
on hr.employees
for select
to authenticated
using (
  rbac.is_super_admin()
  OR access.can_read_employee(organization_id)
);

-- INSERT
create policy "employees_insert"
on hr.employees
for insert
to authenticated
with check (
  rbac.is_super_admin()
  OR (
    organization_id is not null
    AND access.can_write_employee(organization_id)
  )
);

-- UPDATE
create policy "employees_update"
on hr.employees
for update
to authenticated
using (
  rbac.is_super_admin()
  OR access.can_write_employee(organization_id)
)
with check (
  rbac.is_super_admin()
  OR access.can_write_employee(organization_id)
);

-- DELETE
create policy "employees_delete"
on hr.employees
for delete
to authenticated
using (
  rbac.is_super_admin()
  OR access.can_write_employee(organization_id)
);

-- =====================================================
-- 为 projects 表启用 RLS
-- =====================================================

alter table proj.projects enable row level security;
alter table proj.projects force row level security;

create policy "projects_select"
on proj.projects
for select
to authenticated
using (
  rbac.is_super_admin()
  OR access.can_read_project(organization_id)
);

create policy "projects_insert"
on proj.projects
for insert
to authenticated
with check (
  rbac.is_super_admin()
  OR access.can_write_project(organization_id)
);

create policy "projects_update"
on proj.projects
for update
to authenticated
using (
  rbac.is_super_admin()
  OR access.can_write_project(organization_id)
)
with check (
  rbac.is_super_admin()
  OR access.can_write_project(organization_id)
);

create policy "projects_delete"
on proj.projects
for delete
to authenticated
using (
  rbac.is_super_admin()
  OR access.can_write_project(organization_id)
);

-- =====================================================
-- 为 tunnels 表启用 RLS
-- =====================================================
alter table proj.tunnels enable row level security;
alter table proj.tunnels force row level security;

create policy "tunnels_select"
on proj.tunnels
for select
to authenticated
using (
  access.can_read_tunnel(project_id)
);

create policy "tunnels_insert"
on proj.tunnels
for insert
to authenticated
with check (
  access.can_write_tunnel(project_id)
);

create policy "tunnels_update"
on proj.tunnels
for update
to authenticated
using (
  access.can_write_tunnel(project_id)
)
with check (
  access.can_write_tunnel(project_id)
);

create policy "tunnels_delete"
on proj.tunnels
for delete
to authenticated
using (
  access.can_write_tunnel(project_id)
);

-- =====================================================
-- 为 tbms 表启用 RLS
-- =====================================================
-- alter table tbm.tbms enable row level security;
-- alter table tbm.tbms force row level security;

-- -- SELECT
-- create policy "tbms_select"
-- on tbm.tbms
-- for select
-- to authenticated
-- using (
--   rbac.is_super_admin()
--   OR access.can_read_tbm(organization_id)
-- );

-- -- INSERT
-- create policy "tbms_insert"
-- on tbm.tbms
-- for insert
-- to authenticated
-- with check (
--   rbac.is_super_admin()
--   OR (
--     organization_id is not null
--     AND access.can_write_tbm(organization_id)
--   )
-- );

-- -- UPDATE
-- create policy "tbms_update"
-- on tbm.tbms
-- for update
-- to authenticated
-- using (
--   rbac.is_super_admin()
--   OR access.can_write_tbm(organization_id)
-- )
-- with check (
--   rbac.is_super_admin()
--   OR access.can_write_tbm(organization_id)
-- );

-- -- DELETE
-- create policy "tbms_delete"
-- on tbm.tbms
-- for delete
-- to authenticated
-- using (
--   rbac.is_super_admin()
--   OR access.can_write_tbm(organization_id)
-- );



-- =====================================================
-- 为 audit.logs 表启用 RLS
-- =====================================================

-- alter table audit.logs enable row level security;

-- create policy "audit_no_delete"
-- on audit.logs
-- for delete
-- using (false);


-- =====================================================
-- 为 system.menus 表启用 RLS
-- =====================================================

-- alter table system.menus enable row level security;

-- create policy "menu_select_policy"
-- on system.menus
-- for select
-- using (
--   is_visible = true
--   and (
--     permission_code is null
--     or rbac.has_permission(permission_code)
--   )
-- );

-- create policy "menu_admin_policy"
-- on system.menus
-- for all
-- using (
--   system.is_super_admin()
-- )
-- with check (
--   system.is_super_admin()
-- );


