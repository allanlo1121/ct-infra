create table system.notification_events (
  id bigint generated always as identity primary key,

  source_type text not null,
  source_id text not null,
  event_type text not null,

  -- 事件发生时的数据快照
  payload jsonb not null,

  occurred_at timestamptz not null,
  created_at timestamptz not null default now()
);

alter table system.notification_events
add column  organization_id uuid references hrm.organizations(id)
    on delete set null,
add column   project_id uuid references proj.projects(id)
    on delete set null;

add column processed_at timestamptz,
add column processing_error text,
add column retry_count integer not null default 0;

create index idx_notification_events_pending
on system.notification_events (created_at, id)
where processed_at is null;

-- 1. 撤销普通用户访问权限
revoke all on table system.notification_events
from public, anon, authenticated;

-- 2. 服务端角色访问权限
grant select, insert, update, delete
on table system.notification_events
to service_role;

-- 3. 启用 RLS
alter table system.notification_events
enable row level security;

grant usage on schema system to service_role;

drop table system.notification_outbox cascade;
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

create or replace function system.dispatch_notification_event(
  p_event_id bigint,
  p_tasks jsonb
)
returns boolean
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_event system.notification_events%rowtype;
begin
  -- 校验任务数据
  if p_tasks is null
     or pg_catalog.jsonb_typeof(p_tasks) <> 'array' then
    raise exception 'Tasks must be a JSON array'
      using errcode = '22023';
  end if;

  -- 锁定事件，防止多个 Worker 重复处理
  select *
  into v_event
  from system.notification_events
  where id = p_event_id
  for update;

  if not found then
    raise exception 'Notification event % not found', p_event_id
      using errcode = '22023';
  end if;

  -- 已处理，直接返回
  if v_event.processed_at is not null then
    return false;
  end if;

  -- 创建具体发送任务
  insert into system.notification_outbox (
    event_id,
    channel,
    recipient,
    title,
    content
  )
  select
    p_event_id,
    t.channel,
    t.recipient,
    t.title,
    t.content
  from pg_catalog.jsonb_to_recordset(p_tasks) as t(
    channel text,
    recipient text,
    title text,
    content text
  );

  -- 标记事件处理完成
  update system.notification_events
  set
    processed_at = now(),
    processing_error = null
  where id = p_event_id;

  return true;
end;
$$;


create or replace function system.fail_notification_event(
  p_event_id bigint,
  p_error text
)
returns void
language plpgsql
security invoker
set search_path = ''
as $$
begin
  update system.notification_events
  set
    retry_count = retry_count + 1,
    processing_error = left(p_error, 2000)
  where id = p_event_id
    and processed_at is null;
end;
$$;



create table system.notification_attempts (
  id bigint generated always as identity primary key,

  outbox_id bigint not null
    references system.notification_outbox(id),

  attempt_no integer not null check (attempt_no >= 1),

  status text not null
    check (status in ('sending', 'success', 'failed')),

  provider_message_id text,
  response_code text,
  error_message text,

  started_at timestamptz not null default now(),
  finished_at timestamptz,

  constraint uq_notification_attempt
    unique (outbox_id, attempt_no)
);