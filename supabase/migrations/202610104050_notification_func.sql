create or replace function system.dispatch_notification_event (p_event_id bigint, p_tasks jsonb) returns boolean language plpgsql security invoker
set
  search_path = '' as $$
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

create or replace function system.fail_notification_event (p_event_id bigint, p_error text) returns void language plpgsql security invoker
set
  search_path = '' as $$
begin
  update system.notification_events
  set
    retry_count = retry_count + 1,
    processing_error = left(p_error, 2000)
  where id = p_event_id
    and processed_at is null;
end;
$$;



create or replace function system.claim_notification_outbox(
  p_limit integer
)
returns setof system.notification_outbox
language plpgsql
security invoker
set search_path = ''
as $$
begin
  return query
  with pending_tasks as (
    select id
    from system.notification_outbox
    where status = 'pending'
      and (
        next_retry_at is null
        or next_retry_at <= now()
      )
    order by next_retry_at nulls first, created_at, id
    for update skip locked
    limit greatest(0, least(p_limit, 100))
  )
  update system.notification_outbox o
  set
    status = 'processing',
    processing_at = now(),
    attempt_count = o.attempt_count + 1,
    updated_at = now()
  from pending_tasks p
  where o.id = p.id
  returning o.*;
end;
$$;


-- 1. 撤销默认的 PUBLIC 执行权限
revoke all on function system.claim_notification_outbox(integer)
from public;

-- 2. 禁止普通用户调用
revoke all on function system.claim_notification_outbox(integer)
from anon, authenticated;

-- 3. 授权后台服务
grant execute on function system.claim_notification_outbox(integer)
to service_role;