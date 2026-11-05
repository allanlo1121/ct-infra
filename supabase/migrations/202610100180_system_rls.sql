-- =====================================================
-- SYSTEM SCHEMA PERMISSIONS
-- =====================================================

create schema if not exists system;

-- 默认不向普通 API 角色开放
revoke all on schema system
from public, anon, authenticated;

-- 登录用户允许访问 Schema
grant usage on schema system
to authenticated;

-- 服务端特权角色
grant usage on schema system
to service_role;


-- =====================================================
-- SYSTEM TABLE PERMISSIONS
-- =====================================================

-- 登录用户仅允许读取菜单
grant select on system.menus
to authenticated;

-- 服务端角色读写
grant select, insert, update, delete
on all tables in schema system
to service_role;


-- =========================================
-- SYSTEM APPLICATIONS PERMISSIONS
-- =========================================


-- 普通数据库登录角色可以读取
grant select on system.applications
to authenticated;

-- 允许发起写操作，最终由 RLS 判断
grant insert, update, delete
on system.applications
to authenticated;


-- =========================================
-- ROW LEVEL SECURITY
-- =========================================

alter table system.applications
enable row level security;


