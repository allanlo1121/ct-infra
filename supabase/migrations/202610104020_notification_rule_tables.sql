-- =====================================================
-- 4020 SYSTEM NOTIFICATION RULE SCHEMA 
-- =====================================================
create table system.notification_subscriptions (
  id bigint generated always as identity primary key,
  -- 接收人员
  employee_id uuid not null references hrm.employees (id) on delete cascade,
  -- 信息类型
  source_type_code text not null references system.notification_sources (code),
  event_type_code text not null references system.notification_event_types (code),
  -- 最低接收等级
  min_level text not null default 'info' check (min_level in ('info', 'warning', 'error', 'critical')),
  -- 接收组织范围
  project_id uuid not null references proj.projects (id),
  is_disabled boolean not null default false,
  unique (employee_id, source_type_code, event_type_code, project_id)
);

-- 2. AUDIT FIELDS
alter table system.notification_subscriptions
add column created_at timestamptz not null default now();

alter table system.notification_subscriptions
add column updated_at timestamptz;

alter table system.notification_subscriptions
add column created_by uuid references auth.users (id) on delete set null;

alter table system.notification_subscriptions
add column updated_by uuid references auth.users (id) on delete set null;

create trigger trg_notification_subscriptions_audit_insert
before insert on system.notification_subscriptions for each row
execute function system.audit_insert ();

create trigger trg_notification_subscriptions_audit_update
before update on system.notification_subscriptions for each row
execute function system.audit_update ();

create trigger trg_notification_subscriptions_audit_delete
before delete on system.notification_subscriptions for each row
execute function system.audit_delete ();

-- =========================================
-- 3. 启用 RLS
-- =========================================
alter table system.notification_subscriptions enable row level security;

-- =========================================
-- 4. Schema 使用权限
-- =========================================
grant usage on schema system to authenticated,
service_role;

-- =========================================
-- 5. 清理默认访问权限
-- =========================================
revoke all on table system.notification_subscriptions
from
  public,
  anon,
  authenticated;

-- =========================================
-- 6. 已登录用户只读
-- =========================================
grant
select
  on table system.notification_subscriptions to authenticated;

-- =========================================
-- 7. 后端服务完整访问权限
-- =========================================
grant
select
,
  insert,
update,
delete on table system.notification_subscriptions to service_role;

-- =========================================
-- 8. RLS 读取策略
-- =========================================
drop policy if exists "notification_subscriptions_select" on system.notification_subscriptions;

create policy "notification_subscriptions_select" on system.notification_subscriptions for
select
  to authenticated using (true);

create table system.notification_templates (
  id bigint generated always as identity primary key,
  -- 模板基础信息
  name text not null,
  description text,
  -- 发送渠道
  channel text not null check (channel in ('wecom', 'sms', 'in_app')),
  -- 模板内容
  title_template text,
  body_template text not null,
  -- 管理字段
  sort_order integer not null default 0,
  is_disabled boolean not null default false
);

-- 2. AUDIT FIELDS
alter table system.notification_templates
add column created_at timestamptz not null default now();

alter table system.notification_templates
add column updated_at timestamptz;

alter table system.notification_templates
add column created_by uuid references auth.users (id) on delete set null;

alter table system.notification_templates
add column updated_by uuid references auth.users (id) on delete set null;

create trigger trg_notification_templates_audit_insert
before insert on system.notification_templates for each row
execute function system.audit_insert ();

create trigger trg_notification_templates_audit_update
before update on system.notification_templates for each row
execute function system.audit_update ();

create trigger trg_notification_templates_audit_delete
before delete on system.notification_templates for each row
execute function system.audit_delete ();

-- =========================================
-- 3. 启用 RLS
-- =========================================
alter table system.notification_templates enable row level security;

-- =========================================
-- 4. Schema 使用权限
-- =========================================
grant usage on schema system to authenticated,
service_role;

-- =========================================
-- 5. 清理默认访问权限
-- =========================================
revoke all on table system.notification_templates
from
  public,
  anon,
  authenticated;

-- =========================================
-- 6. 已登录用户只读
-- =========================================
grant
select
  on table system.notification_templates to authenticated;

-- =========================================
-- 7. 后端服务完整访问权限
-- =========================================
grant
select
,
  insert,
update,
delete on table system.notification_templates to service_role;

-- =========================================
-- 8. RLS 读取策略
-- =========================================
drop policy if exists "notification_templates_select" on system.notification_templates;

create policy "notification_templates_select" on system.notification_templates for
select
  to authenticated using (true);

create table system.notification_rules (
  id bigint generated always as identity primary key,
  name text not null,
  description text,
  -- 信息类型
  source_type_code text not null references system.notification_sources (code),
  event_type_code text not null references system.notification_event_types (code),
  -- 最低发送等级
  min_level text not null default 'info' check (min_level in ('info', 'warning', 'error', 'critical')),
  -- 通知渠道
  channel text not null check (channel in ('wecom', 'sms', 'in_app')),
  -- 消息模板
  template_id bigint not null references system.notification_templates (id),
  -- 执行顺序
  sort_order integer not null default 0,
  is_disabled boolean not null default false
);

-- 2. AUDIT FIELDS
alter table system.notification_rules
add column created_at timestamptz not null default now();

alter table system.notification_rules
add column updated_at timestamptz;

alter table system.notification_rules
add column created_by uuid references auth.users (id) on delete set null;

alter table system.notification_rules
add column updated_by uuid references auth.users (id) on delete set null;

create trigger trg_notification_rules_audit_insert
before insert on system.notification_rules for each row
execute function system.audit_insert ();

create trigger trg_notification_rules_audit_update
before update on system.notification_rules for each row
execute function system.audit_update ();

create trigger trg_notification_rules_audit_delete
before delete on system.notification_rules for each row
execute function system.audit_delete ();

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

create table system.parameter_alarm_subscriptions (
  id uuid primary key default gen_random_uuid(),
  employee_id uuid not null references hrm.employees (id) on delete cascade,
  tbm_code text not null references tbm.tbms (code),
  parameter_code text not null,
  -- 订阅等级，可为空表示全部等级
  severity_code text references master_data.dictionary_items(code),
  -- 冷却时间，单位分钟
  cooldown_minutes integer not null default 60 check (cooldown_minutes >= 0),
  -- 通知渠道 
  is_disabled boolean not null default false
);


-- 2. AUDIT FIELDS
alter table system.parameter_alarm_subscriptions
add column created_at timestamptz not null default now();

alter table system.parameter_alarm_subscriptions
add column updated_at timestamptz;

alter table system.parameter_alarm_subscriptions
add column created_by uuid references auth.users (id) on delete set null;

alter table system.parameter_alarm_subscriptions
add column updated_by uuid references auth.users (id) on delete set null;

create trigger trg_parameter_alarm_subscriptions_audit_insert
before insert on system.parameter_alarm_subscriptions for each row
execute function system.audit_insert ();

create trigger trg_parameter_alarm_subscriptions_audit_update
before update on system.parameter_alarm_subscriptions for each row
execute function system.audit_update ();

create trigger trg_parameter_alarm_subscriptions_audit_delete
before delete on system.parameter_alarm_subscriptions for each row
execute function system.audit_delete ();

-- =========================================
-- 3. 启用 RLS
-- =========================================
alter table system.parameter_alarm_subscriptions enable row level security;

-- =========================================
-- 4. Schema 使用权限
-- =========================================
grant usage on schema system to authenticated,
service_role;

-- =========================================
-- 5. 清理默认访问权限
-- =========================================
revoke all on table system.parameter_alarm_subscriptions
from
  public,
  anon,
  authenticated;

-- =========================================
-- 6. 已登录用户只读
-- =========================================
grant
select
  on table system.parameter_alarm_subscriptions to authenticated;

-- =========================================
-- 7. 后端服务完整访问权限
-- =========================================
grant
select
,
  insert,
update,
delete on table system.parameter_alarm_subscriptions to service_role;

-- =========================================
-- 8. RLS 读取策略
-- =========================================
drop policy if exists "parameter_alarm_subscriptions_select" on system.parameter_alarm_subscriptions;

create policy "parameter_alarm_subscriptions_select" on system.parameter_alarm_subscriptions for
select
  to authenticated using (true);