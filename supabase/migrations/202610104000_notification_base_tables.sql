-- =====================================================
-- 0120 SYSTEM BASE NOTIFICATION SCHEMA 
-- =====================================================
create table system.notification_sources (
  code text primary key,
  name text not null,
  description text,
  sort_order integer not null default 0,
  is_disabled boolean not null default false
);

create table system.notification_event_types (
  code text primary key,
  name text not null,
  description text,
  default_level text not null default 'info' check (default_level in ('info', 'warning', 'error', 'critical')),
  sort_order integer not null default 0,
  is_disabled boolean not null default false
);


-- =========================================
-- 3. 启用 RLS
-- =========================================
alter table system.notification_sources enable row level security;

alter table system.notification_event_types enable row level security;

-- =========================================
-- 4. Schema 使用权限
-- =========================================
grant usage on schema system to authenticated,
service_role;

-- =========================================
-- 5. 清理默认访问权限
-- =========================================
revoke all on table system.notification_sources
from
  public,
  anon,
  authenticated;

revoke all on table system.notification_event_types
from
  public,
  anon,
  authenticated;

-- =========================================
-- 6. 已登录用户只读
-- =========================================
grant
select
  on table system.notification_sources to authenticated;

grant
select
  on table system.notification_event_types to authenticated;

-- =========================================
-- 7. 后端服务完整访问权限
-- =========================================
grant
select
,
  insert,
update,
delete on table system.notification_sources to service_role;

grant
select
,
  insert,
update,
delete on table system.notification_event_types to service_role;

-- =========================================
-- 8. RLS 读取策略
-- =========================================
drop policy if exists "notification_sources_select" on system.notification_sources;

create policy "notification_sources_select" on system.notification_sources for
select
  to authenticated using (true);

drop policy if exists "notification_event_types_select" on system.notification_event_types;

create policy "notification_event_types_select" on system.notification_event_types for
select
  to authenticated using (true);

