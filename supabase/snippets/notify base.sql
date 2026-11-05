-- =====================================================
-- 0120 SYSTEM NOTIFICATION SCHEMA 
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

  level text not null default 'info'
    check (
      level in ('info', 'warning', 'error', 'critical')
    ),

  sort_order integer not null default 0,
  is_disabled boolean not null default false
);


-- =========================================
-- 3. 启用 RLS
-- =========================================

alter table system.notification_sources
enable row level security;

alter table system.notification_event_types
enable row level security;


-- =========================================
-- 4. Schema 使用权限
-- =========================================

grant usage on schema system
to authenticated, service_role;


-- =========================================
-- 5. 清理默认访问权限
-- =========================================

revoke all on table system.notification_sources
from public, anon, authenticated;

revoke all on table system.notification_event_types
from public, anon, authenticated;


-- =========================================
-- 6. 已登录用户只读
-- =========================================

grant select on table system.notification_sources
to authenticated;

grant select on table system.notification_event_types
to authenticated;


-- =========================================
-- 7. 后端服务完整访问权限
-- =========================================

grant select, insert, update, delete
on table system.notification_sources
to service_role;

grant select, insert, update, delete
on table system.notification_event_types
to service_role;


-- =========================================
-- 8. RLS 读取策略
-- =========================================

drop policy if exists "notification_sources_select"
on system.notification_sources;

create policy "notification_sources_select"
on system.notification_sources
for select
to authenticated
using (true);


drop policy if exists "notification_event_types_select"
on system.notification_event_types;

create policy "notification_event_types_select"
on system.notification_event_types
for select
to authenticated
using (true);



-- =========================================
-- 1. 通知来源类型
-- =========================================

insert into system.notification_sources (
  code,
  name,
  description,
  sort_order,
  is_disabled
)
values 
  (
    'tbm',
    'TBM 运行状态',
    '掘进、拼装、停机等运行状态变化',
    10,
    false
  ),
  (
    'system',
    '系统运行',
    '系统错误、维护及公告',
    60,
    false
  ),
  (
    'task',
    '任务管理',
    '任务创建、分配、完成及超期',
    70,
    false
  ),
  (
    'approval',
    '审批流程',
    '业务审批提交、通过与驳回',
    80,
    false
  )
on conflict (code) do update
set
  name = excluded.name,
  description = excluded.description,
  sort_order = excluded.sort_order;


-- =========================================
-- 2. 通知事件类型
-- =========================================

insert into system.notification_event_types (
  code,
  name,
  description,
  default_level,
  sort_order,
  is_disabled
)
values
  (
    'parameter_alarm',
    '参数报警',
    'TBM 参数阈值报警及恢复事件',
    'warning',
    10,
    false
  ), 
  (
    'fault',
    '设备故障',
    '机械、电气、PLC 等设备故障',
    'error',
    20,
    false
  ),
  (
    'error',
    '系统错误',
    '程序运行、数据库或数据处理异常',
    'error',
    30,
    false
  ),
  (
    'timeout',
    '超时',
    '通信、任务或接口响应超时',
    'warning',
    40,
    false
  ),
  (
    'status_changed',
    '状态变化',
    '设备、业务或系统运行状态发生变化',
    'info',
    50,
    false
  ),
  (
    'risk',
    '风险预警',
    '施工风险源或其他业务风险预警',
    'warning',
    60,
    false
  ),
  (
    'reminder',
    '提醒',
    '待办事项、任务到期等提醒',
    'info',
    70,
    false
  ),
  (
    'notice',
    '普通通知',
    '系统公告及一般业务信息',
    'info',
    80,
    false
  )
on conflict (code) do update
set
  name = excluded.name,
  description = excluded.description,
  default_level = excluded.default_level,
  sort_order = excluded.sort_order;


drop table system.notification_events cascade;
-- =========================================
-- 通知事件表
-- =========================================

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