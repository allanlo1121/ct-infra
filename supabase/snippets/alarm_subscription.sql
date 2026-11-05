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