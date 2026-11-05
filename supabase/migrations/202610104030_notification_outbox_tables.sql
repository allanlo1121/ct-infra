-- =====================================================
-- 4030 SYSTEM NOTIFICATION EVENT SCHEMA 
-- =====================================================



create table system.notification_outbox (
  id bigint generated always as identity primary key,

  -- 关联来源
  event_id bigint not null
    references system.notification_events(id),

  rule_id bigint references system.notification_rules(id)
  on delete set null,

  -- 发送信息
  channel text not null,
  recipient text not null,
  title text not null default '',
  content text not null,

  -- 幂等控制
  dedup_key text not null unique,

  -- 发送状态
  status text not null default 'pending'
    check (status in (
      'pending',
      'processing',
      'sent',
      'failed'
    )),

  -- 重试管理
  attempt_count integer not null default 0
    check (attempt_count >= 0),

  next_retry_at timestamptz,
  last_error text,

  -- 发送过程
  processing_at timestamptz,
  sent_at timestamptz,
  provider_message_id text,

  -- 审计
  created_at timestamptz not null default now(),
  updated_at timestamptz
);



create trigger trg_notification_outbox_audit_update
before update on system.notification_outbox
for each row
execute function system.touch_updated_at();

-- Worker 查询待发送任务
create index idx_notification_outbox_pending
on system.notification_outbox (
  next_retry_at,
  created_at,
  id
)
where status = 'pending';

-- 查找超时未完成的任务
create index idx_notification_outbox_processing
on system.notification_outbox (processing_at)
where status = 'processing';

-- 按事件查询发送记录
create index idx_notification_outbox_event
on system.notification_outbox (event_id);


-- 1. 撤销普通用户访问权限
revoke all on system.notification_outbox
from anon, authenticated;

-- 2. 授权后台服务
grant select, insert, update, delete
on system.notification_outbox
to service_role;

-- 3. 授权 Identity 序列
grant usage, select
on sequence system.notification_outbox_id_seq
to service_role;

-- 4. 启用 RLS
alter table system.notification_outbox
enable row level security;




create table system.notification_attempts (
  id bigint generated always as identity primary key,
  outbox_id bigint not null references system.notification_outbox (id),
  attempt_no integer not null,
  status text not null check (status in ('sending', 'success', 'failed')),
  provider_message_id text,
  response_code text,
  error_message text,
  started_at timestamptz not null default now(),
  finished_at timestamptz,
  constraint uq_notification_attempt unique (outbox_id, attempt_no)
);


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




