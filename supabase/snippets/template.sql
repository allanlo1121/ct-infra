
create table system.notification_templates (
  id bigint generated always as identity primary key,

  -- 模板基础信息
  code text not null unique,
  name text not null,
  description text,

  -- 发送渠道
  channel text not null
    check (channel in ('wecom', 'sms', 'in_app')),

  -- 模板内容
  title_template text,
  body_template text not null,

  -- 管理字段
  sort_order integer not null default 0,
  is_disabled boolean not null default false,

  -- 审计字段
  created_at timestamptz not null default now(),
  updated_at timestamptz,

  created_by uuid default auth.uid()
    references auth.users(id) on delete set null,

  updated_by uuid
    references auth.users(id) on delete set null
);
create trigger trg_notification_templates_audit_insert
before insert on system.notification_templates
for each row
execute function system.audit_insert();

create trigger trg_notification_templates_audit_update
before update on system.notification_templates
for each row
execute function system.audit_update();

create trigger trg_notification_templates_audit_delete
before delete on system.notification_templates
for each row
execute function system.audit_delete();


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



insert into system.notification_templates (
  name,
  channel,
  title_template,
  body_template
)
values (
  'TBM 参数报警',
  'sms',
  '【{{tbm_name}}】盾构 {{severity_name}}',
  '项目：{{project_name}}
隧道：{{tunnel_name}}
参数：{{parameter_name}}
当前值：{{current_value}} {{unit}}
施工环号：{{ring_no}}
发生时间：{{occurred_at}}}'
);



INSERT INTO "system"."notification_templates" ( "name", "description", "channel", "title_template", "body_template", "sort_order") VALUES ( 'TBM 参数报警', null, 'wecom', '【{{project_name}}】参数报警', '隧道：{{tunnel_name}}
设备：{{tbm_name}}
参数：{{parameter_name}}
报警等级：{{severity_name}}
当前值：{{alarm_value}}
施工环号：{{ring_no}}
发生时间：{{occurred_at}}', 2);