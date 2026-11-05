create table system.notification_rules (
  id bigint generated always as identity primary key,

  name text not null,
  description text,

  -- 信息类型
  source_type_code text not null
    references system.notification_sources(code),

  event_type_code text not null
    references system.notification_event_types(code),

  -- 最低发送等级
  min_level text not null default 'info'
    check (
      min_level in ('info', 'warning', 'error', 'critical')
    ),

  -- 通知渠道
  channel text not null
    check (channel in ('wecom', 'sms', 'in_app')),

  -- 消息模板
  template_id bigint not null
    references system.notification_templates(id),

  -- 执行顺序
  sort_order integer not null default 0,

  is_disabled boolean not null default false
);
alter table system.notification_rules
add column created_at timestamptz not null default now();

alter table system.notification_rules
add column updated_at timestamptz;

alter table system.notification_rules
add column created_by uuid
references auth.users(id) on delete set null;

alter table system.notification_rules
add column updated_by uuid
references auth.users(id) on delete set null;

create trigger trg_notification_rules_audit_insert
before insert on system.notification_rules
for each row
execute function system.audit_insert();

create trigger trg_notification_rules_audit_update
before update on system.notification_rules
for each row
execute function system.audit_update();

create trigger trg_notification_rules_audit_delete
before delete on system.notification_rules
for each row
execute function system.audit_delete();

-- =========================================
-- 3. 启用 RLS
-- =========================================
alter table system.notification_rules enable row level security;


-- =========================================
-- 4. Schema 使用权限
-- =========================================
grant usage on schema system to authenticated,
service_role;

-- =========================================
-- 5. 清理默认访问权限
-- =========================================
revoke all on table system.notification_rules
from
  public,
  anon,
  authenticated;

-- =========================================
-- 6. 已登录用户只读
-- =========================================
grant
select
  on table system.notification_rules to authenticated;


-- =========================================
-- 7. 后端服务完整访问权限
-- =========================================
grant
select
,
  insert,
update,
delete on table system.notification_rules to service_role;


-- =========================================
-- 8. RLS 读取策略
-- =========================================
drop policy if exists "notification_rules_select" on system.notification_rules;

create policy "notification_rules_select" on system.notification_rules for
select
  to authenticated using (true);





  -- =========================================
-- 3. 启用 RLS
-- =========================================
alter table system.notification_attempts enable row level security;


-- =========================================
-- 4. Schema 使用权限
-- =========================================
grant usage on schema system to authenticated,
service_role;

-- =========================================
-- 5. 清理默认访问权限
-- =========================================
revoke all on table system.notification_attempts
from
  public,
  anon,
  authenticated;

-- =========================================
-- 6. 已登录用户只读
-- =========================================
grant
select
  on table system.notification_attempts to authenticated;


-- =========================================
-- 7. 后端服务完整访问权限
-- =========================================
grant
select
,
  insert,
update,
delete on table system.notification_attempts to service_role;


-- =========================================
-- 8. RLS 读取策略
-- =========================================
drop policy if exists "notification_attempts_select" on system.notification_attempts;

create policy "notification_attempts_select" on system.notification_attempts for
select
  to authenticated using (true);