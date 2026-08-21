
-- =========================================================
-- TBM SUBSYSTEMS
-- =========================================================

create table tbm.subsystems (
    code text primary key, --b00
    check (code ~ '^[a-z][0-9]{2}$'),

    name text not null,
    description text,

    sort_order integer
);

comment on table tbm.subsystems
is '盾构机子系统';

-- =========================================================
-- TBM RUNTIME PARAMETERS
-- =========================================================

create table tbm.parameters (  
   
    code text primary key,  -- s050001001
    check (
        code ~ '^[a-z][0-9]{9}$'
    ),
    name text not null,
    subsystem_code text not null
        references tbm.subsystems(code),
    -- boolean / integer / double
    data_type text not null
    check (
        data_type in (
            'boolean',
            'integer',
            'double',
            'text'
        )
    ),
    unit text,
    digits smallint not null default 2,
    is_disabled boolean not null default false,
    sort_order integer not null default 0,

    description text
);

comment on table tbm.parameters
is '盾构机运行参数定义';

-- =========================================================
-- TBM PARAMETER TEMPLATES
-- =========================================================

create table tbm.parameter_templates (

    id smallint generated always as identity primary key,

    code text not null unique,

    name text not null,

    tbm_type_id uuid not null
        references public.master_data(id),

    diameter double precision,

    is_default boolean not null default true,

    sort_order smallint not null default 0,
    is_disabled boolean not null default false,

    remark text
);

comment on table tbm.parameter_templates
is '盾构机参数模板';


-- =========================================================
-- TEMPLATE PARAMETERS 参数绑定模版
-- =========================================================

create table tbm.parameter_template_items (

    template_id smallint not null
        references tbm.parameter_templates(id),

    parameter_code text not null
        references tbm.parameters(code),

    sort_order integer not null default 0,

    is_required boolean not null default true,

    primary key (
        template_id,
        parameter_code
    )
);

comment on table tbm.parameter_template_items
is '模板参数绑定';


create table tbm.plc_tags (

    id bigserial primary key,

    tbm_code text not null
        references tbm.tbms(code),

    tag_name text not null,

    data_type text not null,

    unit text,

    internal text,

    bit integer,

    archive boolean not null default false,

    comment text,

    sort_order integer not null default 0,

    unique (
        tbm_code,
        tag_name
    )
);

-- =========================================================
-- TBM PARAMETER 
-- =========================================================

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




create or replace view tbm.v_parameters_list as
select
    p.code,
    p.name,
    p.subsystem_code,
    s.name as subsystem_name,
    p.data_type,
    p.unit,
    p.digits,
    p.sort_order,
    p.is_disabled
from tbm.parameters p
join tbm.subsystems s
  on s.code = p.subsystem_code;

create or replace view tbm.v_parameter_templates_list as
select
  t.id,
  t.code,
  t.name,
  t.tbm_type_id,
  md.code as tbm_type_code,
  md.name as tbm_type_name,
  t.is_default,
  t.is_disabled,
  t.diameter,
  t.sort_order,
  t.remark
from tbm.parameter_templates t
join public.master_data md
  on md.id = t.tbm_type_id;

create or replace view tbm.v_parameter_template_items as
select
    vp.* ,
    pti.template_id,
    pt.code as template_code,
    pt.name as template_name

from tbm.parameter_template_items pti
join tbm.parameter_templates pt
  on pt.id = pti.template_id
join tbm.v_parameters_list vp
  on vp.code = pti.parameter_code;

create or replace view tbm.v_parameters_picker as
select
    p.code,
    p.name,
    s.code as subsystem_code,
    s.name as subsystem_name
from tbm.parameters p
join tbm.subsystems s
  on s.code = p.subsystem_code
where p.is_disabled = false;

create or replace view tbm.v_tbm_parameters as
select
    tp.id,
    tp.tbm_code,
    tp.parameter_code,
    p.name as parameter_name,
    p.subsystem_code,
    s.name as subsystem_name,
    p.data_type,
    p.unit,
    p.digits,
    tp.is_disabled,
    tp.custom_name,
    tp.custom_unit,
    tp.remark
from tbm.tbm_parameters tp
join tbm.parameters p
  on p.code = tp.parameter_code
join tbm.subsystems s
    on s.code = p.subsystem_code;




-- =========================================================
-- INDEXES
-- =========================================================

create index idx_tbm_parameters
on tbm.tbm_parameters(tbm_code);

create index idx_tbm_parameters_parameter
on tbm.tbm_parameters(parameter_code);


create index idx_parameters_subsystem
on tbm.parameters(subsystem_code);



-- =========================================================
-- THRESHOLD RULES
-- =========================================================



create type tbm.threshold_type as enum (
    'upper',
    'lower',
    'deviation',
    'range'
);

create type tbm.alarm_severity as enum (
  'warning',
  'critical',
  'emergency'
);

create type tbm.tbm_phase_type as enum (
  'advance',
  'assembly',
  'stop',
  'fault',
  'unknown'
);



create table tbm.parameter_threshold_rules (

    id bigserial primary key,

    parameter_code text not null references tbm.parameters(code),

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


grant select
on tbm.v_parameter_threshold_rules_effective
to anon, authenticated, service_role;


grant select
on tbm.parameter_threshold_rules
to anon, authenticated, service_role;
