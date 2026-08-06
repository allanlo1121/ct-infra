

-- =========================================
-- ROOT MENUS
-- =========================================

insert into system.menus (
  code,
  name,
  label,
  node_key,
  path_url,
  icon,
  menu_scope,
  sort_order,
  permission_code
)
values
(
  'dashboard',
  'dashboard',
  '总览',
  'dashboard',
  '/dashboard',  
  'LayoutDashboard',
  'admin',
  0,
  'dashboard.read'
),
(
  'hrm',
  'HumanResourceManagement',
  '组织管理',
  'hrm',
  null,
  'TrainFrontTunnel',
  'admin',
  1,
  'hrm.read'
),
(
  'proj',
  'ProjectManagement',
  '项目管理',
  'project',
  null,
  'FolderKanban',
  'admin',
  2,
  'proj.read'
),
(
  'equip',
  'EquipmentManagement',
  '设备管理',
  'equip',
  null,
  'FolderKanban',
  'admin',
  3,
  'equip.read'
),
(
  'workspace',
  'WorkspaceManagement',
  '工作区管理',
  'workspace',
  null,
  'HardHat',
  'workspace',
  4,
  'hrm.read'
),
(
  'system',
  'SystemManagement',
  '系统设置',
  'system',
  null,
  'Settings',
  'admin',
  5,
  'system.admin'
);


-- =========================================
-- HRM
-- =========================================

insert into system.menus (
  parent_id,
  code,
  name,
  label,
  node_key,
  path_url,
  icon,
  menu_scope,
  sort_order,
  permission_code
)
select
   parent.id,
   child.code,
   child.name,
   child.label,
   child.node_key,
   child.path_url,
   child.icon,
   'admin',
   child.sort_order,
   child.permission_code
from system.menus parent
cross join (
  values
    (
      'hrm.organizations',
      'organizations',
      '组织系统',
      'organizations',
      '/hrm/organizations',
      'Building2',
      0,
      'organization.read'
    ),
    (
      'hrm.employees',
      'employees',
      '员工管理',
      'employees',
      '/hrm/employees',
      'Users',
      1,
      'employee.read'
    )
  ) as child(
  code,
  name,
  label,
  node_key,
  path_url,
  icon,
  sort_order,
  permission_code
  )
where parent.code = 'hrm';


insert into system.menus (
  parent_id,
  code,
  name,
  label,
  node_key,
  path_url,
  icon,
  menu_scope,
  sort_order,
  permission_code
)
select
   parent.id,
   child.code,
   child.name,
   child.label,
   child.node_key,
   child.path_url,
   child.icon,
   'admin',
   child.sort_order,
   child.permission_code
from system.menus parent
cross join (
  values
    (
      'proj.projects',
      'projects',
      '项目管理',
      'projects',
      '/proj/projects',
      'FolderKanban',
      0,
      'project.read'
    ),
    (
      'proj.tunnels',
      'tunnels',
      '隧道管理',
      'tunnels',
      '/proj/tunnels',
      'TrainFrontTunnel',
      1,
      'tunnel.read'
    )
  ) as child(
  code,
  name,
  label,
  node_key,
  path_url,
  icon,
  sort_order,
  permission_code
  )
where parent.code = 'proj';



insert into system.menus (
  parent_id,
  code,
  name,
  label,
  node_key,
  path_url,
  icon,
  menu_scope,
  sort_order,
  permission_code
)
select
   parent.id,
   child.code,
   child.name,
   child.label,
   child.node_key,
   child.path_url,
   child.icon,
   'admin',
   child.sort_order,
   child.permission_code
from system.menus parent
cross join (
  values
    (
      'equip.tbms',
      'tbms',
      '盾构机管理',
      'tbms',
      '/equip/tbms',
      'TrainFrontTunnel',
      0,
      'tbm.read'
    )
  ) as child(
  code,
  name,
  label,
  node_key,
  path_url,
  icon,
  sort_order,
  permission_code
  )
where parent.code = 'equip';


-- =========================================
-- SYSTEM
-- =========================================

insert into system.menus (
  parent_id,
  code,
  name,
  label,
  node_key,
  path_url,
  icon,
  menu_scope,
  sort_order
)
select
   parent.id,
   child.code,
   child.name,
   child.label,
   child.node_key,
   child.path_url,
   child.icon,
   'admin',
   child.sort_order
from system.menus parent
cross join (
  values
    (
      'system.master',
      'master',
      '主数据管理',
      'master',
      '/system/master',
      'BookMarked',
      0
    ),
    (
      'system.project',
      'project',
      '项目分类标准',
      'project',
      '/system/project',
      'Folders',
      1
    ),
    (
      'system.tbm',
      'tbm',
      '盾构机管理',
      'tbm',
      '/system/tbm',
      'Folders',
      2
    )
  ) as child(
  code,
  name,
  label,
  node_key,
  path_url,
  icon,
  sort_order
  )
where parent.code = 'system';

insert into system.menus (
  parent_id,
  code,
  name,
  label,
  node_key,
  path_url,
  icon,
  menu_scope,
  sort_order
)
select
   parent.id,
   child.code,
   child.name,
   child.label,
   child.node_key,
   child.path_url,
   child.icon,
   'admin',
   child.sort_order
from system.menus parent
cross join (
  values
    (
      'system.master.master_data',
      'master_data',
      '主数据管理',
      'master_data',
      '/system/master/master-data',
      'BookMarked',
      0
    ),
    (
      'system.master.countries',
      'countries',
      '国家管理',
      'countries',
      '/system/master/countries',
      'Globe',
      1
    ),
    (
      'system.master.admin_regions',
      'admin_regions',
      '行政区管理',
      'admin_regions',
      '/system/master/admin-regions',
      'Map',
      2
    )
  ) as child(
  code,
  name,
  label,
  node_key,
  path_url, 
  icon,
  sort_order
  )
where parent.code = 'system.master';





insert into system.menus (
  parent_id,
  code,
  name,
  label,
  node_key,
  path_url,
  icon,
  menu_scope,
  sort_order
)
select
   parent.id,
   child.code,
   child.name,
   child.label,
   child.node_key,
   child.path_url,
   child.icon,
   'admin',
   child.sort_order
from system.menus parent
cross join (
  values
    (
      'system.project.project_catalog_std',
      'project_catalog_std',
      '项目分类标准',
      'project_catalog_std',
      '/system/project/project-catalog-std',
      'Folders',
      0
    )
  ) as child(   
    code,
    name,
    label,
    node_key,
    path_url,
    icon,
    sort_order
  )
where parent.code = 'system.project';





insert into system.menus (
  parent_id,
  code,
  name,
  label,
  node_key,
  path_url,
  icon,
  menu_scope,
  sort_order
)
select
   parent.id,
   child.code,
   child.name,
   child.label,
   child.node_key,
   child.path_url,
   child.icon,
   'admin',
   child.sort_order
from system.menus parent
cross join (
  values
    (
      'system.tbm.tbm',
      'tbm',
      '盾构机管理',
      'tbm',
      '/system/tbm/tbm',
      'Folders',
      0
    ),
    (
      'system.tbm.parameter',
      'parameter',
      '参数管理',
      'parameter',
      '/system/tbm/parameter',
      'Folders',
      1
    ),
    (
      'system.tbm.parameter_template',
      'parameter_template',
      '参数模板管理',
      'parameter_template',
      '/system/tbm/parameter-template',
      'Folders',
      2
    ),
    (
      'system.tbm.mqtt',
      'mqtt',
      'MQTT管理',
      'mqtt',
      '/system/tbm/mqtt',
      'Folders',
      3
    )
  ) as child(
  code,
  name,
  label,
  node_key,
  path_url,
  icon,
  sort_order
  )
where parent.code = 'system.tbm';


