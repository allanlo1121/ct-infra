-- 1. 允许 project_id 为 NULL，表示订阅所有项目
alter table system.notification_subscriptions
  alter column project_id drop not null;

-- 2. 删除旧的唯一约束
alter table system.notification_subscriptions
  drop constraint if exists uq_notification_subscriptions;

-- 3. 创建新的唯一约束
-- NULLS NOT DISTINCT 确保同一员工不能重复订阅所有项目
alter table system.notification_subscriptions
  add constraint uq_notification_subscriptions
  unique nulls not distinct (
    employee_id,
    project_id,
    source_type_code,
    event_type_code
  );