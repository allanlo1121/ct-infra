-- =====================================================
-- 0700 ACESS SCHEMA PERMISSIONS
-- =====================================================

create schema if not exists access;

grant usage on schema  access
to anon, authenticated;

create or replace function access.can_read_employee(p_org_id uuid)
returns boolean
language sql
stable
as $$
  select
      rbac.has_permission('employee.read')
      OR p_org_id in (select system.allowed_org_ids())    
$$;

create or replace function access.can_write_employee(p_org_id uuid)
returns boolean
language sql
stable
as $$
  select
      rbac.has_permission('employee.write')
      OR p_org_id in (select system.allowed_org_ids())
  $$;


create or replace function access.can_read_project(p_org_id uuid)
returns boolean
language sql
stable
as $$
  select
      rbac.has_permission('project.read')
      OR p_org_id in (select system.allowed_org_ids())
  $$;


create or replace function access.can_write_project(p_org_id uuid)
returns boolean
language sql
stable
as $$
  select
      rbac.has_permission('project.write')
      OR p_org_id in (select system.allowed_org_ids())
  $$;


create or replace function access.can_read_tunnel(
  p_project_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from proj.projects p
    where p.id = p_project_id
      and (
        rbac.is_super_admin()
        or access.can_read_project(p.organization_id)
      )
  );
$$;

create or replace function access.can_write_tunnel(
  p_project_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from proj.projects p
    where p.id = p_project_id
      and (
        rbac.is_super_admin()
        or access.can_write_project(p.organization_id)
      )
  );
$$;



-- create or replace function access.can_read_tbm(p_org_id uuid)
-- returns boolean
-- language sql
-- stable
-- as $$
--   select
--       rbac.has_permission('tbm.read')
--       OR p_org_id in (select system.allowed_org_ids())    
-- $$;

-- create or replace function access.can_write_tbm(p_org_id uuid)
-- returns boolean
-- language sql
-- stable
-- as $$
--   select
--       rbac.has_permission('tbm.write')
--       OR p_org_id in (select system.allowed_org_ids())
--   $$;
