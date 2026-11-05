
create table system.notification_subscriptions (
  id bigint generated always as identity primary key,

  -- 接收人员
  person_id uuid not null
    references hrm.employees(id) on delete cascade,

  -- 信息类型
  source_type_code text not null
    references system.notification_sources(code),

  event_type_code text not null
    references system.notification_event_types(code),

  -- 最低接收等级
  min_level text not null default 'info'
    check (
      min_level in ('info', 'warning', 'error', 'critical')
    ),

  -- 接收组织范围
  organization_id uuid not null
    references hrm.organizations(id),

  scope_type text not null default 'self'
    check (
      scope_type in ('self', 'subtree')
    ),

  is_disabled boolean not null default false,

  created_at timestamptz not null default now(),

  unique (
    person_id,
    source_type_code,
    event_type_code,
    organization_id,
    scope_type
  )
);


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

alter table system.notification_subscriptions
add column created_at timestamptz not null default now();

alter table system.notification_subscriptions
add column updated_at timestamptz;

alter table system.notification_subscriptions
add column created_by uuid
references auth.users(id) on delete set null;

alter table system.notification_subscriptions
add column updated_by uuid
references auth.users(id) on delete set null;

create trigger trg_notification_subscriptions_audit_insert
before insert on system.notification_subscriptions
for each row
execute function system.audit_insert();

create trigger trg_notification_subscriptions_audit_update
before update on system.notification_subscriptions
for each row
execute function system.audit_update();

create trigger trg_notification_subscriptions_audit_delete
before delete on system.notification_subscriptions
for each row
execute function system.audit_delete();




-- 1. 添加 project_id 字段
alter table system.notification_subscriptions
add column project_id uuid 
  references proj.projects(id) on delete cascade;

-- 2. 删除 organization_id 字段
alter table system.notification_subscriptions
drop column organization_id;

-- 3. 删除不再需要的 scope_type 字段
alter table system.notification_subscriptions
drop column scope_type;

-- 4. 添加新的唯一约束
alter table system.notification_subscriptions
add constraint uq_notification_subscriptions
unique (
  employee_id,
  project_id,
  source_type_code,
  event_type_code
);