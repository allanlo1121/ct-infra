
-- =========================================================
-- TBM SUBSYSTEMS
-- =========================================================

create table tbm.tbm_subsystems (

    id smallint generated always as identity primary key,

    -- s01 / s05 / s10
    code text not null unique
    check (
        code ~ '^[a-z][0-9]{2}$'
    ),

    name text not null,

    is_configurable boolean not null default true,

    sort_order smallint not null default 0,
    is_disabled boolean not null default false,

    remark text
);

comment on table tbm.tbm_subsystems
is '盾构机子系统';

-- =========================================================
-- TBM RUNTIME PARAMETERS
-- =========================================================

create table tbm.tbm_runtime_parameters (

    id integer generated always as identity primary key,
    -- s050001001
    code text not null unique
    check (
        code ~ '^[a-z][0-9]{9}$'
    ),
    name text not null,
    subsystem_id smallint not null
        references tbm.tbm_subsystems(id),
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
    is_alarm boolean not null default false,
    is_virtual boolean not null default false,
    is_group boolean not null default false,
    is_trendable boolean not null default true,
    is_reportable boolean not null default true,
    is_chartable boolean not null default true,
    is_disabled boolean not null default false,
    sort_order integer not null default 0,

    remark text
);

comment on table tbm.tbm_runtime_parameters
is '盾构机运行参数定义';

-- =========================================================
-- TBM PARAMETER TEMPLATES
-- =========================================================

create table tbm.tbm_parameter_templates (

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

comment on table tbm.tbm_parameter_templates
is '盾构机参数模板';

create or replace view tbm.v_tbm_parameter_templates_list as
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
from tbm.tbm_parameter_templates t
join public.master_data md
  on md.id = t.tbm_type_id;

-- =========================================================
-- TEMPLATE PARAMETERS
-- =========================================================

create table tbm.tbm_parameter_template_parameters (

    template_id smallint not null
        references tbm.tbm_parameter_templates(id),

    parameter_id integer not null
        references tbm.tbm_runtime_parameters(id),

    sort_order integer not null default 0,

    is_required boolean not null default true,

    primary key (
        template_id,
        parameter_id
    )
);

comment on table tbm.tbm_parameter_template_parameters
is '模板参数绑定';

create table tbm.plc_tags (

    id bigserial primary key,

    tbm_id uuid not null
        references tbm.tbms(id),

    tag_name text not null,

    data_type text not null,

    unit text,

    internal text,

    bit integer,

    archive boolean not null default false,

    comment text,

    sort_order integer not null default 0,

    unique (
        tbm_id,
        tag_name
    )
);

-- =========================================================
-- TBM PARAMETER CONFIGURATIONS
-- =========================================================

create table tbm.tbm_parameter_configs (

    id bigserial primary key,

    tbm_id uuid not null
        references tbm.tbms(id),

    parameter_id integer not null
        references tbm.tbm_runtime_parameters(id),

    plc_tag_id bigint
        references tbm.plc_tags(id),

    scale numeric not null default 1,

    value_offset numeric not null default 0,

    is_disabled boolean not null default false,

    custom_name text,
    custom_unit text,

    remark text,
    unique (
        tbm_id,
        parameter_id
    )
);

comment on table tbm.tbm_parameter_configs
is 'TBM实际运行参数';



-- =========================================================
-- THRESHOLD RULES
-- =========================================================

create table tbm.tbm_parameter_threshold_rules (
    id bigserial primary key,

    binding_id bigserial not null
        references tbm.tbm_parameter_configs(id)
        on delete cascade,

    level smallint not null
        check (level in (1, 2, 3)),

    min_value double precision,
    max_value double precision,

    is_enabled boolean not null default true,

    remark text,

    unique (binding_id, level),

    check (
        min_value is not null
        or max_value is not null
    ),

    check (
        min_value is null
        or max_value is null
        or min_value <= max_value
    )
);

comment on table tbm.tbm_parameter_threshold_rules
is 'TBM参数报警规则';


create table tbm.tbm_parameter_template_threshold_rules (

    id bigserial primary key,

    template_id smallint not null
        references tbm.tbm_parameter_templates(id),

    parameter_id integer not null
        references tbm.tbm_runtime_parameters(id),

    level smallint not null,

    direction text not null
    check (
        direction in (
            'HIGH',
            'LOW',
            'ABS'
        )
    ),

    min_value double precision,

    max_value double precision,

    recover_value double precision,

    duration_ms integer not null default 0,

    color text,

    severity text
    check (
        severity in (
            'INFO',
            'WARNING',
            'CRITICAL'
        )
    ),

    message text,

    is_active boolean not null default true
);

comment on table tbm.tbm_parameter_template_threshold_rules
is 'TBM参数模板报警规则';





create or replace view tbm.v_tbm_runtime_parameters_list as
select
    p.id,
    p.code,
    p.name,
    p.subsystem_id,
    s.code as subsystem_code,
    s.name as subsystem_name,
    p.data_type,
    p.unit,
    p.digits,
    p.is_alarm,
    p.is_chartable,
    p.sort_order,
    p.is_disabled
from tbm.tbm_runtime_parameters p
join tbm.tbm_subsystems s
  on s.id = p.subsystem_id;

create or replace view tbm.v_tbm_runtime_parameters_picker as
select
    p.id,
    p.code,
    p.name,
    s.code as subsystem_code,
    s.name as subsystem_name,
    p.is_chartable
from tbm.tbm_runtime_parameters p
join tbm.tbm_subsystems s
  on s.id = p.subsystem_id
where p.is_disabled = false;




-- =========================================================
-- INDEXES
-- =========================================================

create index idx_tbm_parameter_configs_tbm
on tbm.tbm_parameter_configs(tbm_id);

create index idx_tbm_parameter_configs_parameter
on tbm.tbm_parameter_configs(parameter_id);

create index idx_tbm_parameter_threshold_rules_binding
on tbm.tbm_parameter_threshold_rules(binding_id);

create index idx_tbm_runtime_parameters_subsystem
on tbm.tbm_runtime_parameters(subsystem_id);