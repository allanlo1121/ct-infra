
-- ============================================
-- RBAC MINIMUM SEED
-- ============================================

-- 1️⃣ 基础角色
insert into rbac.roles (code, name)
values
  ('SUPER_ADMIN', '超级管理员'),
  ('COMPANY_LEADER', '公司领导'),
  ('PROJECT_ADMIN', '项目管理员'),
  ('PROJECT_LEADER', '项目领导'),
  ('USER', '普通用户')
on conflict (code) do nothing;



-- 2️⃣ 基础权限
-- =========================================
-- 基础权限
-- =========================================

insert into rbac.permissions (
  code,
  name,
  module,
  action
)
values

-- =========================================
-- DASHBOARD
-- =========================================

(
  'dashboard.read',
  '查看仪表盘',
  'dashboard',
  'read'
),

-- =========================================
-- 导航模块
-- =========================================

(
  'operations.read',
  '访问工程业务模块',
  'operations',
  'read'
),

(
  'system.read',
  '访问系统设置模块',
  'system',
  'read'
),

-- =========================================
-- ORGANIZATION
-- =========================================
(
  'hrm.read',
  '查看组织架构',
  'hrm',
  'read'
),

(
  'organization.read',
  '查看组织架构',
  'organization',
  'read'
),

(
  'organization.write',
  '编辑组织架构',
  'organization',
  'write'
),

(
  'organization.delete',
  '删除组织架构',
  'organization',
  'delete'
),

-- =========================================
-- EMPLOYEE
-- =========================================

(
  'employee.read',
  '查看员工',
  'employee',
  'read'
),

(
  'employee.write',
  '编辑员工',
  'employee',
  'write'
),

(
  'employee.delete',
  '删除员工',
  'employee',
  'delete'
),

(
  'employee.import',
  '导入员工',
  'employee',
  'import'
),

(
  'employee.export',
  '导出员工',
  'employee',
  'export'
),

-- =========================================
-- PROJECT
-- =========================================
(
  'proj.read',
  '查看项目管理',
  'proj',
  'read'
),

(
  'project.read',
  '查看项目',
  'project',
  'read'
),

(
  'project.write',
  '编辑项目',
  'project',
  'write'
),

(
  'project.delete',
  '删除项目',
  'project',
  'delete'
),

(
  'project.import',
  '导入项目',
  'project',
  'import'
),

(
  'equip.read',
  '查看设备',
  'equip',
  'read'
),

(
  'project.export',
  '导出项目',
  'project',
  'export'
),

-- =========================================
-- TUNNEL
-- =========================================

(
  'tunnel.read',
  '查看隧道',
  'tunnel',
  'read'
),

(
  'tunnel.write',
  '编辑隧道',
  'tunnel',
  'write'
),

-- =========================================
-- TBM
-- =========================================

(
  'tbm.read',
  '查看盾构机',
  'tbm',
  'read'
),

(
  'tbm.write',
  '编辑盾构机',
  'tbm',
  'write'
),

(
  'tbm.monitor',
  '查看盾构监控',
  'tbm',
  'monitor'
),

-- =========================================
-- MASTER DATA
-- =========================================

(
  'master_data.read',
  '查看主数据',
  'master_data',
  'read'
),

(
  'master_data.write',
  '编辑主数据',
  'master_data',
  'write'
),

-- =========================================
-- SYSTEM
-- =========================================

(
  'system.admin',
  '系统管理',
  'system',
  'admin'
)

on conflict (code) do nothing;



-- 3️⃣ 角色-权限绑定

-- SUPER_ADMIN 拥有全部权限
insert into rbac.role_permissions (role_id, permission_id)
select r.id, p.id
from rbac.roles r
join rbac.permissions p on true
where r.code = 'SUPER_ADMIN'
on conflict do nothing;


-- PROJECT_ADMIN 拥有项目权限
insert into rbac.role_permissions (role_id, permission_id)
select r.id, p.id
from rbac.roles r
join rbac.permissions p 
  on p.code in ('project.read', 'project.write')
where r.code = 'PROJECT_ADMIN'
on conflict do nothing;


-- USER 只读权限
insert into rbac.role_permissions (role_id, permission_id)
select r.id, p.id
from rbac.roles r
join rbac.permissions p 
  on p.code in ('employee.read', 'project.read', 'organization.read')
where r.code = 'USER'
on conflict do nothing;