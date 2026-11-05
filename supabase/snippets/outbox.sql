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