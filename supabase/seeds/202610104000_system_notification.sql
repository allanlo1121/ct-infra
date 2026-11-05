-- =========================================
-- 1. 通知来源类型
-- =========================================
insert into
  system.notification_sources (code, name, description, sort_order)
values
  ('tbm', 'TBM 运行状态', '掘进、拼装、停机等运行状态变化', 10),
  ('system', '系统运行', '系统错误、维护及公告', 60),
  ('task', '任务管理', '任务创建、分配、完成及超期', 70),
  ('approval', '审批流程', '业务审批提交、通过与驳回', 80)
on conflict (code) do update
set
  name = excluded.name,
  description = excluded.description,
  sort_order = excluded.sort_order;

-- =========================================
-- 2. 通知事件类型
-- =========================================
insert into
  system.notification_event_types (code, name, description, default_level, sort_order)
values
  ('parameter_alarm', '参数报警', 'TBM 参数阈值报警及恢复事件', 'warning', 10),
  ('fault', '设备故障', '机械、电气、PLC 等设备故障', 'error', 20),
  ('error', '系统错误', '程序运行、数据库或数据处理异常', 'error', 30),
  ('timeout', '超时', '通信、任务或接口响应超时', 'warning', 40),
  ('status_changed', '状态变化', '设备、业务或系统运行状态发生变化', 'info', 50),
  ('risk', '风险预警', '施工风险源或其他业务风险预警', 'warning', 60),
  ('reminder', '提醒', '待办事项、任务到期等提醒', 'info', 70),
  ('notice', '普通通知', '系统公告及一般业务信息', 'info', 80)
on conflict (code) do update
set
  name = excluded.name,
  description = excluded.description,
  default_level = excluded.default_level,
  sort_order = excluded.sort_order;

insert into
  system.notification_templates (name, channel, title_template, body_template, sort_order)
values
  (
    'TBM 参数报警',
    'sms',
    '| {{tbm_name}}盾构 {{severity_name}}',
    '项目：{{project_name}}
隧道：{{tunnel_name}}
参数：{{parameter_name}}
当前值：{{alarm_value}} {{parameter_unit}}
施工环号：{{ring_no}}
发生时间：{{occurred_at}}}',
10
  );

insert into
  system.notification_templates (name, channel, title_template, body_template, sort_order)
values
  (
    'TBM 参数报警',
    'wecom',
    '【{{project_name}}】参数报警',
    '隧道：{{tunnel_name}}
设备：{{tbm_name}}
参数：{{parameter_name}}
报警等级：{{severity_name}}
当前值：{{alarm_value}} {{parameter_unit}}
施工环号：{{ring_no}}
发生时间：{{occurred_at}}',
    20
  );