
-- Add audit fields to master_definitions tables
alter table public.master_definitions
add column created_at timestamptz default now();

alter table public.master_definitions
add column updated_at timestamptz;


alter table public.master_definitions
add column created_by uuid
references hr.employees(id) on delete set null;

alter table public.master_definitions
add column updated_by uuid
references hr.employees(id) on delete set null;

-- Add audit fields to master_data tables
alter table public.master_data
add column created_at timestamptz default now();

alter table public.master_data
add column updated_at timestamptz;

alter table public.master_data
add column created_by uuid
references hr.employees(id) on delete set null;

alter table public.master_data
add column updated_by uuid
references hr.employees(id) on delete set null;

-- Add audit fields to countries
alter table public.countries
add column created_at timestamptz default now();

alter table public.countries
add column updated_at timestamptz;

alter table public.countries
add column created_by uuid
references hr.employees(id) on delete set null;

alter table public.countries
add column updated_by uuid
references hr.employees(id) on delete set null;

-- Add audit fields to admin_regions
alter table public.admin_regions
add column created_at timestamptz default now();

alter table public.admin_regions
add column updated_at timestamptz;

alter table public.admin_regions
add column created_by uuid
references hr.employees(id) on delete set null;

alter table public.admin_regions
add column updated_by uuid
references hr.employees(id) on delete set null;

--Add audit fields to Import_batches
alter table public.import_batches
add column created_at timestamptz default now();

alter table public.import_batches
add column updated_at timestamptz;

alter table public.import_batches
add column deleted_at timestamptz;

alter table public.import_batches
add column created_by uuid
references hr.employees(id) on delete set null;

alter table public.import_batches
add column updated_by uuid
references hr.employees(id) on delete set null;

alter table public.import_batches
add column deleted_by uuid
references hr.employees(id) on delete set null;

--Add audit fields to Import_records
alter table public.import_records
add column created_at timestamptz default now();

alter table public.import_records
add column updated_at timestamptz;

alter table public.import_records
add column deleted_at timestamptz;

alter table public.import_records
add column created_by uuid
references hr.employees(id) on delete set null;

alter table public.import_records
add column updated_by uuid
references hr.employees(id) on delete set null;

alter table public.import_records
add column deleted_by uuid
references hr.employees(id) on delete set null;


-- Add audit fields to organizations
alter table hr.organizations
add column created_at timestamptz default now();

alter table hr.organizations
add column updated_at timestamptz;

alter table hr.organizations
add column deleted_at timestamptz;

alter table hr.organizations
add column created_by uuid
references hr.employees(id) on delete set null;

alter table hr.organizations
add column updated_by uuid
references hr.employees(id) on delete set null;

alter table hr.organizations
add column deleted_by uuid
references hr.employees(id) on delete set null;

-- Add audit fields to cumstomers
alter table hr.customers
add column created_at timestamptz default now();

alter table hr.customers
add column updated_at timestamptz;

alter table hr.customers
add column deleted_at timestamptz;

alter table hr.customers
add column created_by uuid
references hr.employees(id) on delete set null;

alter table hr.customers
add column updated_by uuid
references hr.employees(id) on delete set null;

alter table hr.customers
add column deleted_by uuid
references hr.employees(id) on delete set null;

-- Add audit fields to employees
alter table hr.employees
add column created_at timestamptz default now();

alter table hr.employees
add column updated_at timestamptz;

alter table hr.employees
add column deleted_at timestamptz;

alter table hr.employees
add column created_by uuid
references hr.employees(id) on delete set null;

alter table hr.employees
add column updated_by uuid
references hr.employees(id) on delete set null;

alter table hr.employees
add column deleted_by uuid
references hr.employees(id) on delete set null;


-- Add audit fields to employees
alter table hr.posts
add column created_at timestamptz default now();

alter table hr.posts
add column updated_at timestamptz;

alter table hr.posts
add column deleted_at timestamptz;

alter table hr.posts
add column created_by uuid
references hr.employees(id) on delete set null;

alter table hr.posts
add column updated_by uuid
references hr.employees(id) on delete set null;

alter table hr.posts
add column deleted_by uuid
references hr.employees(id) on delete set null;



-- Add audit fields to educations
alter table hr.educations
add column created_at timestamptz default now();

alter table hr.educations
add column updated_at timestamptz;

alter table hr.educations
add column deleted_at timestamptz;

alter table hr.educations
add column created_by uuid
references hr.employees(id) on delete set null;

alter table hr.educations
add column updated_by uuid
references hr.employees(id) on delete set null;

alter table hr.educations
add column deleted_by uuid
references hr.employees(id) on delete set null;

-- Add audit fields to employee_assignments
alter table hr.employee_assignments
add column created_at timestamptz default now();

alter table hr.employee_assignments
add column updated_at timestamptz;

alter table hr.employee_assignments
add column deleted_at timestamptz;

alter table hr.employee_assignments
add column created_by uuid
references hr.employees(id) on delete set null;

alter table hr.employee_assignments
add column updated_by uuid
references hr.employees(id) on delete set null;

alter table hr.employee_assignments
add column deleted_by uuid
references hr.employees(id) on delete set null;


-- Add audit fields to organization_role_assignments
alter table hr.organization_role_assignments
add column created_at timestamptz default now();

alter table hr.organization_role_assignments
add column updated_at timestamptz;

alter table hr.organization_role_assignments
add column deleted_at timestamptz;

alter table hr.organization_role_assignments
add column created_by uuid
references hr.employees(id) on delete set null;

alter table hr.organization_role_assignments
add column updated_by uuid
references hr.employees(id) on delete set null;

alter table hr.organization_role_assignments
add column deleted_by uuid
references hr.employees(id) on delete set null;


-- Add audit fields to employee_titles
alter table hr.employee_titles
add column created_at timestamptz default now();

alter table hr.employee_titles
add column updated_at timestamptz;

alter table hr.employee_titles
add column deleted_at timestamptz;

alter table hr.employee_titles
add column created_by uuid
references hr.employees(id) on delete set null;

alter table hr.employee_titles
add column updated_by uuid
references hr.employees(id) on delete set null;

alter table hr.employee_titles
add column deleted_by uuid
references hr.employees(id) on delete set null;



--- Add audit fields to projects
alter table proj.projects
add column created_at timestamptz default now();

alter table proj.projects
add column updated_at timestamptz;

alter table proj.projects
add column deleted_at timestamptz;

alter table proj.projects
add column created_by uuid
references hr.employees(id) on delete set null;

alter table proj.projects
add column updated_by uuid
references hr.employees(id) on delete set null;

alter table proj.projects
add column deleted_by uuid
references hr.employees(id) on delete set null;

--- Add audit fields to project_status_timeline
alter table proj.project_status_timeline
add column created_at timestamptz default now();

alter table proj.project_status_timeline
add column updated_at timestamptz;

alter table proj.project_status_timeline
add column created_by uuid
references hr.employees(id) on delete set null;

alter table proj.project_status_timeline
add column updated_by uuid
references hr.employees(id) on delete set null;

alter table proj.project_status_timeline
add column deleted_by uuid
references hr.employees(id) on delete set null;


alter table proj.project_risk_level_timeline
add column updated_at timestamptz;

alter table proj.project_risk_level_timeline
add column created_by uuid
references hr.employees(id) on delete set null;

alter table proj.project_risk_level_timeline
add column updated_by uuid
references hr.employees(id) on delete set null;


--add audit fields to project_attention_level_timeline
alter table proj.project_attention_level_timeline
add column created_at timestamptz default now();

alter table proj.project_attention_level_timeline
add column updated_at timestamptz;

alter table proj.project_attention_level_timeline
add column created_by uuid
references hr.employees(id) on delete set null;

alter table proj.project_attention_level_timeline
add column updated_by uuid
references hr.employees(id) on delete set null;


--add audit fields to project_control_levle_timeline
alter table proj.project_control_level_timeline
add column created_at timestamptz default now();

alter table proj.project_control_level_timeline   
add column updated_at timestamptz;

alter table proj.project_control_level_timeline
add column created_by uuid
references hr.employees(id) on delete set null;

alter table proj.project_control_level_timeline
add column updated_by uuid
references hr.employees(id) on delete set null;



--- Add audit fields to project_attention_type_timeline
alter table proj.project_attention_type_timeline
add column created_at timestamptz default now();

alter table proj.project_attention_type_timeline
add column updated_at timestamptz;

alter table proj.project_attention_type_timeline
add column created_by uuid
references hr.employees(id) on delete set null;

alter table proj.project_attention_type_timeline
add column updated_by uuid
references hr.employees(id) on delete set null;


-- add audit fields to project_contracts
alter table proj.project_contracts
add column created_at timestamptz default now();

alter table proj.project_contracts
add column updated_at timestamptz;

alter table proj.project_contracts
add column deleted_at timestamptz;

alter table proj.project_contracts
add column created_by uuid
references hr.employees(id) on delete set null;

alter table proj.project_contracts
add column updated_by uuid
references hr.employees(id) on delete set null;

alter table proj.project_contracts
add column deleted_by uuid
references hr.employees(id) on delete set null;

-- add audit fields to project_contract_versions
alter table proj.project_contract_versions
add column created_at timestamptz default now();

alter table proj.project_contract_versions
add column updated_at timestamptz;

alter table proj.project_contract_versions
add column deleted_at timestamptz;

alter table proj.project_contract_versions
add column created_by uuid
references hr.employees(id) on delete set null;

alter table proj.project_contract_versions
add column updated_by uuid
references hr.employees(id) on delete set null;

alter table proj.project_contract_versions
add column deleted_by uuid
references hr.employees(id) on delete set null;

-- add audit fields to project_schedule_versions
alter table proj.project_schedule_versions
add column created_at timestamptz default now();

alter table proj.project_schedule_versions
add column updated_at timestamptz;

alter table proj.project_schedule_versions
add column deleted_at timestamptz;

alter table proj.project_schedule_versions
add column created_by uuid
references hr.employees(id) on delete set null;

alter table proj.project_schedule_versions
add column updated_by uuid
references hr.employees(id) on delete set null;

alter table proj.project_schedule_versions
add column deleted_by uuid
references hr.employees(id) on delete set null;


-- add audit fields to tunnels
alter table proj.tunnels
add column created_at timestamptz default now();

alter table proj.tunnels
add column updated_at timestamptz;

alter table proj.tunnels
add column deleted_at timestamptz;

alter table proj.tunnels
add column created_by uuid
references hr.employees(id) on delete set null;

alter table proj.tunnels
add column updated_by uuid
references hr.employees(id) on delete set null;

alter table proj.tunnels
add column deleted_by uuid
references hr.employees(id) on delete set null;

-- add audit fields to tunnel_status_timeline
alter table proj.tunnel_status_timeline
add column created_at timestamptz default now();

alter table proj.tunnel_status_timeline
add column updated_at timestamptz;

alter table proj.tunnel_status_timeline
add column created_by uuid
references hr.employees(id) on delete set null;

alter table proj.tunnel_status_timeline
add column updated_by uuid
references hr.employees(id) on delete set null;



-- add audit fields to tunnel_schedule_versions
alter table proj.tunnel_schedule_versions
add column created_at timestamptz default now();

alter table proj.tunnel_schedule_versions
add column updated_at timestamptz;

alter table proj.tunnel_schedule_versions
add column deleted_at timestamptz;

alter table proj.tunnel_schedule_versions
add column created_by uuid
references hr.employees(id) on delete set null;

alter table proj.tunnel_schedule_versions
add column updated_by uuid
references hr.employees(id) on delete set null;

alter table proj.tunnel_schedule_versions
add column deleted_by uuid
references hr.employees(id) on delete set null;

--add audit fields to project_catalog_std
alter table proj.project_catalog_std
add column created_at timestamptz default now();

alter table proj.project_catalog_std
add column updated_at timestamptz;

alter table proj.project_catalog_std
add column deleted_at timestamptz;

alter table proj.project_catalog_std
add column created_by uuid
references hr.employees(id) on delete set null;

alter table proj.project_catalog_std
add column updated_by uuid
references hr.employees(id) on delete set null;

alter table proj.project_catalog_std
add column deleted_by uuid
references hr.employees(id) on delete set null;

--add audit fields to tbms
alter table tbm.tbms
add column created_at timestamptz default now();

alter table tbm.tbms
add column updated_at timestamptz;

alter table tbm.tbms
add column deleted_at timestamptz;

alter table tbm.tbms
add column created_by uuid
references hr.employees(id) on delete set null; 

alter table tbm.tbms
add column updated_by uuid
references hr.employees(id) on delete set null;

alter table tbm.tbms
add column deleted_by uuid
references hr.employees(id) on delete set null;


--add audit fields to tbm_assignments
alter table tbm.tbm_assignments
add column created_at timestamptz default now();

alter table tbm.tbm_assignments
add column updated_at timestamptz;

alter table tbm.tbm_assignments
add column deleted_at timestamptz;

alter table tbm.tbm_assignments
add column created_by uuid
references hr.employees(id) on delete set null; 

alter table tbm.tbm_assignments
add column updated_by uuid
references hr.employees(id) on delete set null;

alter table tbm.tbm_assignments
add column deleted_by uuid
references hr.employees(id) on delete set null;

--add audit fields to tbm.tbm_daily_progress
alter table tbm.tbm_daily_progress
add column created_at timestamptz default now();

alter table tbm.tbm_daily_progress
add column updated_at timestamptz;

alter table tbm.tbm_daily_progress
add column deleted_at timestamptz;

alter table tbm.tbm_daily_progress
add column created_by uuid
references hr.employees(id) on delete set null;

alter table tbm.tbm_daily_progress
add column updated_by uuid
references hr.employees(id) on delete set null;

alter table tbm.tbm_daily_progress
add column deleted_by uuid
references hr.employees(id) on delete set null;


--Add audit fields to audit_logs
alter table audit.logs
add column created_at timestamptz default now();


-- Add audit fields to permissions
alter table rbac.permissions
add column created_at timestamptz default now();

alter table rbac.permissions
add column updated_at timestamptz;


alter table rbac.permissions
add column created_by uuid
references hr.employees(id) on delete set null;

alter table rbac.permissions
add column updated_by uuid
references hr.employees(id) on delete set null;


-- Add audit fields to roles
alter table rbac.roles
add column created_at timestamptz default now();

alter table rbac.roles
add column updated_at timestamptz;

alter table rbac.roles
add column created_by uuid
references hr.employees(id) on delete set null;

alter table rbac.roles
add column updated_by uuid
references hr.employees(id) on delete set null;



-- Add audit fields to system.menus
alter table system.menus
add column created_at timestamptz default now();

alter table system.menus
add column updated_at timestamptz;


alter table system.menus
add column created_by uuid
references hr.employees(id) on delete set null;

alter table system.menus
add column updated_by uuid
references hr.employees(id) on delete set null;








