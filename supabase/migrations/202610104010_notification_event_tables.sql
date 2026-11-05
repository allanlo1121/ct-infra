-- =====================================================
-- 0120 SYSTEM NOTIFICATION EVENT SCHEMA 
-- =====================================================


create table system.notification_events (
  id bigint generated always as identity primary key,

  -- 事件来源
  source_type_code text not null
    references system.notification_sources(code),

  source_id text not null,

  -- 事件类型
  event_type_code text not null
    references system.notification_event_types(code),

  -- 通知级别
  level text not null default 'info'
    check (
      level in ('info', 'warning', 'error', 'critical')
    ),
  -- 通知组织
  organization_id uuid references hrm.organizations(id)
    on delete set null,

  project_id uuid references proj.projects(id)
    on delete set null,

  -- 事件发生时的数据快照
  payload jsonb not null,

  occurred_at timestamptz not null,

  -- 事件分发状态
  processed_at timestamptz,
  processing_error text,
  retry_count integer not null default 0
    check (retry_count >= 0),

  -- 审计字段
  created_at timestamptz not null default now(),
  updated_at timestamptz,

  created_by uuid default auth.uid()
    references auth.users(id) on delete set null,

  updated_by uuid
    references auth.users(id) on delete set null
);

-- =========================================
-- 索引
-- =========================================

create index idx_notification_events_pending
on system.notification_events (
  created_at,
  id
)
where processed_at is null;


-- =========================================
-- 审计触发器
-- =========================================

create trigger trg_notification_event_audit_insert
before insert on system.notification_events
for each row
execute function system.audit_insert();

create trigger trg_notification_event_audit_update
before update on system.notification_events
for each row
execute function system.audit_update();

create trigger trg_notification_event_audit_delete
before delete on system.notification_events
for each row
execute function system.audit_delete();


-- =========================================
-- 访问权限
-- =========================================

grant usage on schema system
to service_role;

revoke all on table system.notification_events
from public, anon, authenticated;

grant select, insert, update, delete
on table system.notification_events
to service_role;

alter table system.notification_events
enable row level security;


