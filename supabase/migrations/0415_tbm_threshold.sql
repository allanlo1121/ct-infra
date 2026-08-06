
create type tbm.threshold_type as enum (
    'upper',
    'lower',
    'deviation',
    'range'
);


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



