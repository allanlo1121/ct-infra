
-- =========================================
-- SYSTEM MENUS INITIALIZATION
-- =========================================

begin;

-- =========================================
-- 0. CLEAR EXISTING MENUS
-- =========================================

-- 如需清空旧菜单，取消下面的注释。
-- 注意检查菜单关联表和外键约束。
-- delete from system.menus;
TRUNCATE TABLE system.menus RESTART IDENTITY;

-- =========================================
-- 1. ROOT MENUS
-- =========================================

insert into
  system.menus (code, name, path_url, icon, sort_order)
values
  ('dashboard', '总览', '/', 'layout-dashboard', 10),

  -- 业务运行
  ('tbm-operation', 'TBM生产运行', '/tbm-operation', 'activity', 50),
  ('tbm-config', 'TBM运行配置', '/tbm-config', 'settings-2', 60),
  ('notification', '通知中心', '/notification', 'bell', 70),

  -- 业务资源
  ('hrm', '人力资源', '/hrm', 'square-user', 100),
  ('proj', '项目管理', '/proj', 'train-front-tunnel', 110),
  ('equip', '设备管理', '/equip', 'hard-drive', 120),

  -- 平台配置
  ('tbm-system', 'TBM系统配置', '/tbm-system', 'sliders-horizontal', 200),
  ('master-data', '主数据管理', '/master-data', 'database', 210),
  ('system', '系统设置', '/system', 'cog', 220);


-- =========================================
-- 2. TBM-OPERATION
-- TBM生产运行
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
      ('tbm-operation.overview', '运行总览', '/tbm-operation/overview', 'layout-dashboard', 10),
      ('tbm-operation.monitor', '实时监控', '/tbm-operation/monitor', 'monitor', 20),
      ('tbm-operation.connectivity', '连接状态', '/tbm-operation/connectivity', 'network', 30),
      ('tbm-operation.alarms', '报警管理', '/tbm-operation/alarms', 'bell', 40),
      ('tbm-operation.risks', '风险监控', '/tbm-operation/risks', 'shield-alert', 50),
      ('tbm-operation.daily-reports', '运行日报', '/tbm-operation/daily-reports', 'file-chart-column', 60),
      ('tbm-operation.analysis', '历史数据分析', '/tbm-operation/analysis', 'chart-no-axes-combined', 70)
  ) as child (code, name, path_url, icon, sort_order)
where
  parent.code = 'tbm-operation';


-- =========================================
-- 3. TBM-CONFIG
-- TBM运行配置
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
      ('tbm-config.assignments', '施工任务配置', '/tbm-config/assignments', 'route', 10),
      ('tbm-config.parameter-binding', '参数绑定', '/tbm-config/parameter-binding', 'sliders-horizontal', 20),
      ('tbm-config.thresholds', '报警阈值配置', '/tbm-config/thresholds', 'alert-triangle', 30),
      ('tbm-config.phase-status', '运行状态配置', '/tbm-config/phase-status', 'workflow', 40),
      ('tbm-config.notifications', '通知规则配置', '/tbm-config/notifications', 'bell-ring', 50)
  ) as child (code, name, path_url, icon, sort_order)
where
  parent.code = 'tbm-config';


-- =========================================
-- 4. NOTIFICATION
-- 通知中心
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
      -- 事件与消息
      ('notification.events', '通知事件', '/notification/events', 'radio-tower', 10),
      ('notification.outbox', '消息记录', '/notification/outbox', 'mail', 20),

      -- 通知配置
      ('notification.rules', '通知规则', '/notification/rules', 'workflow', 30),
      ('notification.subscriptions', '通知订阅', '/notification/subscriptions', 'bell-ring', 40),
      ('notification.templates', '通知模板', '/notification/templates', 'file-text', 50),

      -- 事件基础配置
      ('notification.event-types', '事件类型', '/notification/event-types', 'list-tree', 60),
      ('notification.source-types', '事件来源', '/notification/source-types', 'layers', 70)
  ) as child (code, name, path_url, icon, sort_order)
where
  parent.code = 'notification';


-- =========================================
-- 5. HRM
-- 人力资源
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
      ('hrm.organizations', '组织管理', '/hrm/organizations', 'building-2', 10),
      ('hrm.employees', '员工管理', '/hrm/employees', 'users', 20)
  ) as child (code, name, path_url, icon, sort_order)
where
  parent.code = 'hrm';


-- =========================================
-- 6. PROJ
-- 项目管理
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
      ('proj.projects', '项目管理', '/proj/projects', 'folder-kanban', 10),
      ('proj.units', '工程单元', '/proj/units', 'map-pin', 20),
      ('proj.tunnels', '隧道管理', '/proj/tunnels', 'train-front-tunnel', 30),
      ('proj.risks', '风险源管理', '/proj/risks', 'alert-circle', 40)
  ) as child (code, name, path_url, icon, sort_order)
where
  parent.code = 'proj';


-- =========================================
-- 7. EQUIP
-- 设备管理
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
      ('equip.devices', '设备台账', '/equip/devices', 'hard-drive', 10),
      ('equip.tbms', 'TBM设备', '/equip/tbms', 'cog', 20),
      ('equip.usage-history', '设备使用履历', '/equip/usage-history', 'history', 30),
      ('equip.transfers', '设备调拨记录', '/equip/transfers', 'arrow-left-right', 40)
  ) as child (code, name, path_url, icon, sort_order)
where
  parent.code = 'equip';


-- =========================================
-- 8. TBM-SYSTEM
-- TBM系统配置
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
      ('tbm-system.parameters', '参数定义', '/tbm-system/parameters', 'sliders-horizontal', 10),
      ('tbm-system.threshold-defaults', '通用阈值规则', '/tbm-system/threshold-defaults', 'shield-check', 20),
      ('tbm-system.mqtt-users', 'MQTT用户管理', '/tbm-system/mqtt-users', 'users', 30),
      ('tbm-system.mqtt-acls', 'MQTT ACL管理', '/tbm-system/mqtt-acls', 'lock-keyhole', 40)
  ) as child (code, name, path_url, icon, sort_order)
where
  parent.code = 'tbm-system';


-- =========================================
-- 9. MASTER-DATA
-- 主数据管理
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
      ('master-data.geological-types', '地质类型管理', '/master-data/geological-types', 'layers-3', 50)
  ) as child (code, name, path_url, icon, sort_order)
where
  parent.code = 'master-data';


-- =========================================
-- 10. SYSTEM
-- 系统设置
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
      ('system.roles', '角色管理', '/system/roles', 'shield-check', 20),
      ('system.permissions', '权限管理', '/system/permissions', 'key-round', 30),
      ('system.applications', '应用管理', '/system/applications', 'server-cog', 40),
      ('system.menus', '菜单管理', '/system/menus', 'square-menu', 50),
      ('system.settings', '系统设置', '/system/settings', 'settings', 60)
  ) as child (code, name, path_url, icon, sort_order)
where
  parent.code = 'system';


commit;


-- =========================================
-- VERIFY RESULT
-- =========================================

select
  parent.name as parent_name,
  m.code,
  m.name,
  m.path_url,
  m.icon,
  m.sort_order
from
  system.menus m
  left join system.menus parent
    on parent.id = m.parent_id
order by
  coalesce(parent.sort_order, m.sort_order),
  case when m.parent_id is null then 0 else 1 end,
  m.sort_order,
  m.code;
