grant usage on schema hrm
to authenticated, service_role;


-- =====================================================
-- HRM DEFAULT TABLE PRIVILEGES
-- =====================================================

-- 撤销 postgres 在 hrm 下先前设置的
-- Schema 级默认表授权
alter default privileges for role postgres in schema hrm
revoke all on tables
from authenticated, anon, public;

-- 未来新表默认授权 service_role
alter default privileges for role postgres in schema hrm
grant select, insert, update, delete
on tables to service_role;


-- =====================================================
-- HRM DEFAULT SEQUENCE PRIVILEGES
-- =====================================================

-- 撤销先前设置的 Schema 级默认序列授权
alter default privileges for role postgres in schema hrm
revoke all on sequences
from authenticated, anon, public;

-- 未来新序列默认授权 service_role
alter default privileges for role postgres in schema hrm
grant usage, select
on sequences to service_role;