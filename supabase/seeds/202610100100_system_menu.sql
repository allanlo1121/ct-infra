insert into
  system.applications (code, name, description, icon, base_url, sort_order)
values
  ('admin', '后台管理', '系统管理与业务配置', 'settings', '/admin', 10),
  ('dashboard', '数据大屏', '工程实时监控与数据展示', 'monitor', '/dashboard', 20),
  ('project', '项目管理', '项目业务管理', 'folder-kanban', '/project', 30);

-- =========================================
-- ROOT MENUS
-- =========================================
insert into
  system.menus (code, name, path_url, icon, sort_order)
values
  ('dashboard', '总览', '/', 'layout-dashboard', 10),
  ('hrm', '人力资源', '/hrm', 'square-user', 20),
  ('proj', '项目管理', '/proj', 'train-front-tunnel', 30),
  ('equip', '设备管理', '/equip', 'vault', 40),
  ('tbm-config', 'TBM系统配置', '/tbm-config', 'settings-2', 55),
  ('tbm-operation', 'TBM生产运行', '/tbm-operation', 'activity', 55),
  ('mqtt', 'MQTT管理', '/mqtt', 'server', 60),
  ('master-data', '主数据管理', '/master-data', 'database', 100),
  ('system', '系统设置', '/system', 'cog', 110);

-- =========================================
-- HRM
-- =========================================
insert into
  system.menus (parent_id, code, name, path_url, icon, sort_order)
select
  parent.id,
  child.code,
  child.name,
  child.path_url,
  child.icon,
  child.sort_order
from
  system.menus parent
  cross join (
    values
      ('hrm.organizations', '组织系统', '/hrm/organizations', 'building-2', 10),
      ('hrm.employees', '员工管理', '/hrm/employees', 'users', 20)
  ) as child (code, name, path_url, icon, sort_order)
where
  parent.code = 'hrm';

insert into
  system.menus (parent_id, code, name, path_url, icon, sort_order)
select
  parent.id,
  child.code,
  child.name,
  child.path_url,
  child.icon,
  child.sort_order
from
  system.menus parent
  cross join (
    values
      ('proj.projects', '项目管理', '/proj/projects', 'server', 10),
      ('proj.units', '工程单元', '/proj/units', 'map-pin', 20),
      ('proj.tunnels', '隧道管理', '/proj/tunnels', 'train-front-tunnel', 30)
  ) as child (code, name, path_url, icon, sort_order)
where
  parent.code = 'proj';

insert into
  system.menus (parent_id, code, name, path_url, icon, sort_order)
select
  parent.id,
  child.code,
  child.name,
  child.path_url,
  child.icon,
  child.sort_order
from
  system.menus parent
  cross join (
    values
      ('equip.devices', '设备管理', '/equip/devices', 'crosshair', 10),
      ('equip.tbms', 'TBM管理', '/equip/tbms', 'crosshair', 20),
      ('equip.assignments', 'TBM分配', '/equip/assignments', 'crosshair', 30),
  ) as child (code, name, path_url, icon, sort_order)
where
  parent.code = 'equip';

insert into
  system.menus (parent_id, code, name, path_url, icon, sort_order)
select
  parent.id,
  child.code,
  child.name,
  child.path_url,
  child.icon,
  child.sort_order
from
  system.menus parent
  cross join (
    values
      ('tbm-config.parameters', '参数管理', '/tbm-config/parameters', 'sliders-horizontal', 10),
      ('tbm-config.connections', '采集连接配置', '/tbm-config/connections', 'plug', 20),
      ('tbm-config.phase-status', '运行状态配置', '/tbm-config/phase-status', 'workflow', 30),
      ('tbm-config.notifications', '通知规则配置', '/tbm-config/notifications', 'bell-ring', 40)
  ) as child (code, name, path_url, icon, sort_order)
where
  parent.code = 'tbm-config';

insert into system.menus (
  parent_id,
  code,
  name,
  path_url,
  icon,
  sort_order
)
select
  parent.id,
  child.code,
  child.name,
  child.path_url,
  child.icon,
  child.sort_order
from system.menus parent
cross join (
  values
    (
      'tbm-operation.overview',
      '运行总览',
      '/tbm-operation/overview',
      'layout-dashboard',
      10
    ),
    (
      'tbm-operation.monitor',
      '实时监控',
      '/tbm-operation/monitor',
      'monitor',
      20
    ),
    (
      'tbm-operation.parameter-binding',
      '参数配置',
      '/tbm-operation/parameter-binding',
      'sliders-horizontal',
      30
    ),
    (
      'tbm-operation.connectivity',
      '连接状态',
      '/tbm-operation/connectivity',
      'network',
      40
    ),
    (
      'tbm-operation.alarms',
      '告警管理',
      '/tbm-operation/alarms',
      'bell',
      50
    ),
    (
      'tbm-operation.risks',
      '风险管理',
      '/tbm-operation/risks',
      'shield-alert',
      60
    ),
    (
      'tbm-operation.daily-reports',
      '运行日报',
      '/tbm-operation/daily-reports',
      'file-chart-column',
      70
    ),
    (
      'tbm-operation.analysis',
      '历史数据分析',
      '/tbm-operation/analysis',
      'chart-no-axes-combined',
      80
    )
) as child(
  code,
  name,
  path_url,
  icon,
  sort_order
)
where parent.code = 'tbm-operation';

insert into
  system.menus (parent_id, code, name, path_url, icon, sort_order)
select
  parent.id,
  child.code,
  child.name,
  child.path_url,
  child.icon,
  child.sort_order
from
  system.menus parent
  cross join (
    values
      ('mqtt.users', '用户管理', '/mqtt/users', 'server', 10),
      ('mqtt.acls', 'ACL管理', '/mqtt/acls', 'map-pin', 20),
      ('mqtt.brokers', 'Broker管理', '/mqtt/brokers', 'server', 30)
  ) as child (code, name, path_url, icon, sort_order)
where
  parent.code = 'mqtt';

-- =========================================
-- 100 Master Data
-- =========================================
insert into
  system.menus (parent_id, code, name, path_url, icon, sort_order)
select
  parent.id,
  child.code,
  child.name,
  child.path_url,
  child.icon,
  child.sort_order
from
  system.menus parent
  cross join (
    values
      ('master-data.dictionary-types', '字典类型', '/master-data/dictionary-types', 'book-marked', 10),
      ('master-data.dictionary-items', '字典数据项', '/master-data/dictionary-items', 'table-properties', 20),
      ('master-data.countries', '国家管理', '/master-data/countries', 'globe', 30),
      ('master-data.admin-regions', '行政区管理', '/master-data/admin-regions', 'map', 40),
      ('master-data.geological-types', '地质类型管理', '/master-data/geological-types', 'currency', 50)
  ) as child (code, name, path_url, icon, sort_order)
where
  parent.code = 'master-data';

-- =========================================
-- SYSTEM
-- =========================================
insert into
  system.menus (parent_id, code, name, path_url, icon, sort_order)
select
  parent.id,
  child.code,
  child.name,
  child.path_url,
  child.icon,
  child.sort_order
from
  system.menus parent
  cross join (
    values
      ('system.users', '用户管理', '/system/users', 'contact', 10),
      ('system.roles', '角色管理', '/system/roles', 'contact', 20),
      ('system.permissions', '权限管理', '/system/permissions', 'contact', 30),
      ('system.applications', '菜单管理', '/system/applications', 'server-cog', 40),
      ('system.menus', '菜单管理', '/system/menus', 'square-menu', 50),
      ('system.settings', '系统设置', '/system/settings', 'settings', 60)
  ) as child (code, name, path_url, icon, sort_order)
where
  parent.code = 'system';
