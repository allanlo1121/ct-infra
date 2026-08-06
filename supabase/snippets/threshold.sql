
create type tbm.threshold_type as enum (
    'upper',
    'lower',
    'deviation',
    'range'
);

drop table tbm.parameter_threshold_templates cascade;

create table tbm.parameter_threshold_templates (

    id bigserial primary key,

    parameter_id bigint not null references tbm.tbm_runtime_parameters(id) on delete cascade,

    severity tbm.alarm_severity not null,

    threshold_type tbm.threshold_type not null,

    reference_value double precision default 0,

    threshold_value double precision,

    min_value double precision,

    max_value double precision,

    remark text,

    unique(parameter_id,severity)
);

drop table tbm.parameter_threshold_overrides cascade;

create table tbm.parameter_threshold_overrides (

    id bigserial primary key,

    tbm_id uuid not null references tbm.tbms(id) on delete cascade,

    parameter_id bigint not null references tbm.tbm_runtime_parameters(id) on delete cascade,

    severity tbm.alarm_severity not null,

    threshold_type tbm.threshold_type not null,

    reference_value double precision default 0,

    threshold_value double precision,

    min_value double precision,

    max_value double precision,

    remark text,

    unique(tbm_id, parameter_id, severity)
);


INSERT INTO tbm.parameter_threshold_templates 
(
    parameter_id,
    threshold_type,
    severity,
    reference_value,
    threshold_value
)
VALUES
(896, 'deviation',  'warning', 0, 50),
(896, 'deviation', 'critical', 0, 80),

(897, 'deviation',  'warning', 0, 50),
(897, 'deviation', 'critical', 0, 80),

(898, 'deviation',  'warning', 0, 50),
(898, 'deviation', 'critical', 0, 80),

(899, 'deviation',  'warning', 0, 50),
(899, 'deviation', 'critical', 0, 80),

(900, 'deviation',  'warning', 0, 50),
(900, 'deviation', 'critical', 0, 80),

(901, 'deviation',  'warning', 0, 50),
(901, 'deviation', 'critical', 0, 80);


INSERT INTO tbm.parameter_threshold_overrides 
(
    tbm_id,
    parameter_id,
    threshold_type,
    severity,
    reference_value,
    threshold_value
)
VALUES
('df7dd9d0-090a-443b-ba15-75f989616e69'::uuid,896, 'deviation', 'warning', 0, 60),
('df7dd9d0-090a-443b-ba15-75f989616e69'::uuid,896, 'deviation', 'critical', 0, 90);


drop function if exists tbm.fn_get_parameter_threshold_rules(uuid);

create or replace function tbm.fn_get_parameter_threshold_rules(
    p_tbm_id uuid
)
returns table (
    parameter_id bigint,
    parameter_code text,
    severity tbm.alarm_severity,
    threshold_type tbm.threshold_type,
    reference_value double precision,
    threshold_value double precision,
    min_value double precision,
    max_value double precision,
    source_type text
)
language sql
stable
as $$

    select
        x.parameter_id,
        p.code as parameter_code,
        x.severity,
        x.threshold_type,
        x.reference_value,
        x.threshold_value,
        x.min_value,
        x.max_value,
        x.source_type

    from (

        -- TBM 单独配置 override
        select
            o.parameter_id,
            o.severity,
            o.threshold_type,
            o.reference_value,
            o.threshold_value,
            o.min_value,
            o.max_value,
            'override' as source_type,
            1 as priority

        from tbm.parameter_threshold_overrides o

        where o.tbm_id = p_tbm_id


        union all


        -- 参数模板配置
        select
            t.parameter_id,
            t.severity,
            t.threshold_type,
            t.reference_value,
            t.threshold_value,
            t.min_value,
            t.max_value,
            'template' as source_type,
            2 as priority

        from tbm.parameter_threshold_templates t


    ) x


    join tbm.tbm_runtime_parameters p
        on p.id = x.parameter_id


    where x.priority = (

        select min(y.priority)

        from (

            select
                o.parameter_id,
                o.severity,
                1 as priority

            from tbm.parameter_threshold_overrides o

            where o.tbm_id = p_tbm_id


            union all


            select
                t.parameter_id,
                t.severity,
                2 as priority

            from tbm.parameter_threshold_templates t


        ) y


        where y.parameter_id = x.parameter_id
          and y.severity = x.severity

    );

$$;


select *
from tbm.fn_get_parameter_threshold_rules(
    'df7dd9d0-090a-443b-ba15-75f989616e69'
);





-- (897, 'deviation', 1, 0, 50),
-- (897, 'deviation', 2, 0, 80),

-- (898, 'deviation', 1, 0, 50),
-- (898, 'deviation', 2, 0, 80),

-- (899, 'deviation', 1, 0, 50),
-- (899, 'deviation', 2, 0, 80),

-- (900, 'deviation', 1, 0, 50),
-- (900, 'deviation', 2, 0, 80),

-- (901, 'deviation', 1, 0, 50),
-- (901, 'deviation', 2, 0, 80);


create or replace function tbm.fn_get_parameter_threshold_rules_v2(
    p_tbm_id uuid
)
returns table (
    parameter_id bigint,
    parameter_code text,
    level smallint,
    threshold_type tbm.threshold_type,
    reference_value double precision,
    threshold_value double precision,
    min_value double precision,
    max_value double precision,
    source_type text
)
language sql
stable
as $$

select
    x.parameter_id,
    p.code as parameter_code,
    x.level,
    x.threshold_type,
    x.reference_value,
    x.threshold_value,
    x.min_value,
    x.max_value,
    x.source_type

from (

    -- override
    select
        o.parameter_id,
        o.level,
        o.threshold_type,
        o.reference_value,
        o.threshold_value,
        o.min_value,
        o.max_value,
        'override' as source_type,
        1 as priority

    from tbm.parameter_threshold_overrides o

    where o.tbm_id = p_tbm_id


    union all


    -- template
    select
        t.parameter_id,
        t.level,
        t.threshold_type,
        t.reference_value,
        t.threshold_value,
        t.min_value,
        t.max_value,
        'template' as source_type,
        2 as priority

    from tbm.parameter_threshold_templates t


) x


join tbm.tbm_runtime_parameters p
    on p.id = x.parameter_id


where x.priority = (

    select min(y.priority)

    from (

        select
            o.parameter_id,
            o.level,
            1 as priority

        from tbm.parameter_threshold_overrides o

        where o.tbm_id = p_tbm_id


        union all


        select
            t.parameter_id,
            t.level,
            2 as priority

        from tbm.parameter_threshold_templates t

    ) y


    where y.parameter_id = x.parameter_id
      and y.level = x.level

);

$$;