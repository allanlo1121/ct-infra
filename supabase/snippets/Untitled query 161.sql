create table tbm.parameter_anomaly_rules (
  id bigint generated always as identity primary key,

  name text not null,
  rule_type text not null,
  config jsonb not null default '{}'::jsonb,

  is_enabled boolean not null default true,
  remark text,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_anomaly_rule_config
    check (jsonb_typeof(config) = 'object')
);

alter table tbm.parameters
  add column anomaly_rule_id bigint
    references tbm.parameter_anomaly_rules(id)
    on delete set null;

insert into tbm.parameter_anomaly_rules (
  name,
  rule_type,
  config,
  remark
)
values (
  '3分钟尖峰异常检测',
  'spike',
  '{
    "window_ms": 180000,
    "min_spike_delta": 20,
    "recovery_tolerance": 10
  }'::jsonb,
  '突变超过20，3分钟内恢复至原基准±10时，标记疑似异常'
);