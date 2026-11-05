-- ============================================
-- IAM MINIMUM SEED
-- ============================================
-- 1️ 基础角色
insert into
  iam.roles (code, name, sort_order)
values
  ('SUPER_ADMIN', '超级管理员', 1),
  ('COMPANY_LEADER', '公司领导', 2),
  ('PROJECT_ADMIN', '项目管理员', 3),
  ('PROJECT_LEADER', '项目领导', 4),
  ('USER', '普通用户', 5)
on conflict (code) do nothing;

-- 2️ 基础权限
-- =========================================
-- 基础权限
-- =========================================
insert into
  iam.permissions (name, module, action, sort_order)
values
  ('查看角色权限', 'iam', 'read', 10),
  ('编辑角色权限', 'iam', 'write', 11),
  ('删除角色权限', 'iam', 'delete', 12),
  ('查看主数据', 'master_data', 'read', 50),
  ('编辑主数据', 'master_data', 'write', 51),
  ('删除主数据', 'master_data', 'delete', 52),
  ('查看人力资源', 'hrm', 'read', 100),
  ('编辑人力资源', 'hrm', 'write', 110),
  ('删除人力资源', 'hrm', 'delete', 120),
  ('查看工程项目', 'proj', 'read', 150),
  ('编辑工程项目', 'proj', 'write', 160),
  ('删除工程项目', 'proj', 'delete', 170),
  ('查看设备', 'equip', 'read', 200),
  ('编辑设备', 'equip', 'write', 210),
  ('删除设备', 'equip', 'delete', 220),
  ('查看TBM', 'tbm', 'read', 250),
  ('编辑TBM', 'tbm', 'write', 260),
  ('删除TBM', 'tbm', 'delete', 270),
  ('查看MQTT', 'mqtt', 'read', 300),
  ('编辑MQTT', 'mqtt', 'write', 310),
  ('删除MQTT', 'mqtt', 'delete', 320)
on conflict (module, action) do nothing;

-- 3️ 角色-权限绑定
-- SUPER_ADMIN 拥有全部权限
insert into
  iam.role_permissions (role_id, permission_id)
select
  r.id,
  p.id
from
  iam.roles r
  join iam.permissions p on true
where
  r.code = 'SUPER_ADMIN'
on conflict do nothing;
