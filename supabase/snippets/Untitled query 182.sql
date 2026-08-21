drop table tbm.subsystems cascade;

create table tbm.subsystems (
  code text primary key,
  name text not null,
  description text,
  sort_order integer
);

comment on table tbm.subsystems is '盾构机子系统';

create table tbm.parameters (
  code text primary key, -- s050001001
  check (code ~ '^[a-z][0-9]{9}$'),
  name text not null,
  subsystem_code text not null references tbm.subsystems (code),
  -- boolean / integer / double
  data_type text not null check (
    data_type in ('boolean', 'integer', 'double', 'text')
  ),
  unit text,
  digits smallint not null default 2,
  is_disabled boolean not null default false,
  sort_order integer not null default 0,
  description text
);

comment on table tbm.parameters is '盾构机运行参数定义';

insert into
  tbm.parameters (code, name, subsystem_code, data_type, sort_order)
select
  v.code,
  v.name,
  ss.code,
  v.data_type,
  v.sort_order
from
  tbm.subsystems ss
  cross join (
    values
      ('b000000001', '推进模式启动', 'boolean', 100001),
      ('b000000002', '拼装模式启动', 'boolean', 100002)
  ) as v (code, name, data_type, sort_order)
where
  ss.code = 'b00'
on conflict (code) do nothing;

create table tbm.parameter_templates (
  id smallint generated always as identity primary key,
  code text not null unique,
  name text not null,
  tbm_type_id uuid not null references public.master_data (id),
  diameter double precision,
  is_default boolean not null default true,
  sort_order smallint not null default 0,
  is_disabled boolean not null default false,
  remark text
);

insert into
  tbm.parameter_templates (
    code,
    name,
    tbm_type_id,
    diameter,
    is_default,
    sort_order,
    is_disabled,
    remark
  )
select
  v.code,
  v.name,
  mt.id,
  v.diameter,
  v.is_default,
  v.sort_order,
  v.is_disabled,
  v.remark
from
  public.master_data mt
  cross join (
    values
      ('base', '基础模板', 6000, true, 0, true, null)
  ) as v (
    code,
    name,
    diameter,
    is_default,
    sort_order,
    is_disabled,
    remark
  )
where
  mt.code = '45000003'
on conflict (code) do nothing;

create table tbm.parameter_template_items (
  template_id smallint not null references tbm.parameter_templates (id),
  parameter_code text not null references tbm.parameters (code),
  sort_order integer not null default 0,
  is_required boolean not null default true,
  primary key (template_id, parameter_code)
);

insert into
  tbm.parameter_template_items (template_id, parameter_code, sort_order)
select
  t.id,
  v.parameter_code,
  v.sort_order
from
  tbm.parameter_templates t
  cross join (
    values
      ('b000000001', 1),
      ('b000000002', 2),
      ('s010102004', 3),
      ('s010109001', 4),
      ('s020901001', 5),
      ('s020901002', 6),
      ('s020901003', 7),
      ('s020901004', 8),
      ('s020901005', 9),
      ('s020901006', 10),
      ('s050001001', 11),
      ('s050001019', 12),
      ('s050001020', 13),
      ('s050001021', 14),
      ('s050001022', 15),
      ('s050006005', 17),
      ('s050006006', 16),
      ('s050006007', 18),
      ('s050006008', 19),
      ('s050009003', 20),
      ('s050109001', 21),
      ('s070102001', 22),
      ('s070109001', 23),
      ('s070301001', 26),
      ('s070606001', 24),
      ('s070606002', 25),
      ('s100100005', 27),
      ('s100100008', 28),
      ('s100111009', 29),
      ('s100111010', 30),
      ('s100206003', 31),
      ('s100206004', 32),
      ('s100206006', 33),
      ('s100206007', 34)
  ) as v (parameter_code, sort_order)
where
  t.code = 'base'
on conflict (template_id, parameter_code) do nothing;


create table tbm.tbm_parameters (

    id bigserial primary key,

    tbm_code text not null
        references tbm.tbms(code),

    parameter_code text not null
        references tbm.parameters(code),


    is_disabled boolean not null default false,

    custom_name text,
    custom_unit text,

    remark text,
    unique (
        tbm_code,
        parameter_code
    )
);

comment on table tbm.tbm_parameters
is 'TBM实际绑定参数';


insert into tbm.tbm_parameters(tbm_code,parameter_code)
values
      ('xre423','b000000001'),
      ('xre423','b000000002'),
      ('xre423','s010102004'),
      ('xre423','s010109001'),
      ('xre423','s020901001'),
      ('xre423','s020901002'),
      ('xre423','s020901003'),
      ('xre423','s020901004'),
      ('xre423','s020901005'),
      ('xre423','s020901006'),
      ('xre423','s050001001'),
      ('xre423','s050001019'),
      ('xre423','s050001020'),
      ('xre423','s050001021'),
      ('xre423','s050001022'),
      ('xre423','s050006005'),
      ('xre423','s050006006'),
      ('xre423','s050006007'),
      ('xre423','s050006008'),
      ('xre423','s050009003'),
      ('xre423','s050109001'),
      ('xre423','s070102001'),
      ('xre423','s070109001'),
      ('xre423','s070301001'),
      ('xre423','s070606001'),
      ('xre423','s070606002'),
      ('xre423','s100100005'),
      ('xre423','s100100008'),
      ('xre423','s100111009'),
      ('xre423','s100111010'),
      ('xre423','s100206003'),
      ('xre423','s100206004'),
      ('xre423','s100206006'),
      ('xre423','s100206007');


create table tbm.parameter_threshold_rules (

    id bigserial primary key,

    parameter_code text not null references tbm.parameters(),

    severity tbm.alarm_severity not null,

    threshold_type tbm.threshold_type not null,

    reference_value double precision default 0,

    threshold_value double precision,

    min_value double precision,

    max_value double precision,

    remark text,

    unique(parameter_code,severity)
);


create table tbm.tbm_parameter_threshold_rules (

    id bigserial primary key,

    tbm_code text not null references tbm.tbms(code),

    parameter_code text not null references tbm.parameters(code),

    severity tbm.alarm_severity not null,

    threshold_type tbm.threshold_type not null,

    reference_value double precision default 0,

    threshold_value double precision,

    min_value double precision,

    max_value double precision,

    remark text,

    unique(tbm_code, parameter_code, severity)
);










INSERT INTO tbm.parameter_threshold_rules
(
    parameter_code,
    threshold_type,
    severity,
    reference_value,
    threshold_value
)
VALUES
('s100206003', 'deviation', 'warning', 0, 50),
('s100206003', 'deviation', 'critical', 0, 80),

('s100206004', 'deviation', 'warning', 0, 50),
('s100206004', 'deviation', 'critical', 0, 80),

('s100206006', 'deviation', 'warning', 0, 50),
('s100206006', 'deviation', 'critical', 0, 80),

('s100206007', 'deviation', 'warning', 0, 50),
('s100206007', 'deviation', 'critical', 0, 80),

('s100206009', 'deviation', 'warning', 0, 50),
('s100206009', 'deviation', 'critical', 0, 80),

('s100206010', 'deviation', 'warning', 0, 50),
('s100206010', 'deviation', 'critical', 0, 80);


create or replace view tbm.v_parameter_threshold_rules_effective
as

-- 1. 全局规则，对每台 TBM 展开；
--    如果存在对应 tbm_rule，则使用 tbm_rule
select
    ta.tbm_code,

    r.parameter_code,
    r.severity,
    r.threshold_type,

    coalesce(tr.reference_value, r.reference_value) as reference_value,
    coalesce(tr.threshold_value, r.threshold_value) as threshold_value,
    coalesce(tr.min_value, r.min_value) as min_value,
    coalesce(tr.max_value, r.max_value) as max_value,
    coalesce(tr.remark, r.remark) as remark,

    r.id as rule_id,
    tr.id as tbm_rule_id,

    case
        when tr.id is not null then 'tbm_rule'
        else 'default'
    end as rule_source

from tbm.tbm_assignments ta

cross join tbm.parameter_threshold_rules r

left join tbm.tbm_parameter_threshold_rules tr
    on tr.tbm_code = ta.tbm_code
   and tr.parameter_code = r.parameter_code
   and tr.severity = r.severity
   and tr.threshold_type = r.threshold_type


union all


-- 2. 仅某台 TBM 存在的专属规则
select
    tr.tbm_code,

    tr.parameter_code,
    tr.severity,
    tr.threshold_type,

    tr.reference_value,
    tr.threshold_value,
    tr.min_value,
    tr.max_value,
    tr.remark,

    null::bigint as rule_id,
    tr.id as tbm_rule_id,

    'tbm_rule_only'::text as rule_source

from tbm.tbm_parameter_threshold_rules tr

where not exists (
    select 1
    from tbm.parameter_threshold_rules r
    where r.parameter_code = tr.parameter_code
      and r.severity = tr.severity
      and r.threshold_type = tr.threshold_type
);