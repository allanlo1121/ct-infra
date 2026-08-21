create table runtime.parameter_alarms (

    id uuid primary key default gen_random_uuid(),

    tbm_code text not null references tbm.tbms(code),

    parameter_code text not null references tbm.parameters(code),

    ring_no bigint,

    chainage numeric,

    alarm_value numeric,

    severity tbm.alarm_severity not null,   

    created_at timestamptz default now(),
    updated_at timestamptz default now(),

    unique(
        tbm_code,
        parameter_code
    )
);



create table runtime.parameter_alarm_history (

    id uuid primary key default gen_random_uuid(),

    alarm_id uuid not null,

    tbm_code text not null references tbm.tbms(code),

    parameter_code text not null references tbm.parameters(code),

    alarm_value numeric,

    severity tbm.alarm_severity not null,

    event_type text not null,

    occurred_at timestamptz not null,

    created_at timestamptz default now()
);


create or replace function runtime.fn_alarm_insert_history()
returns trigger
language plpgsql
as $$

begin

    insert into runtime.parameter_alarm_history
    (
        alarm_id,
        tbm_code,
        parameter_code,
        alarm_value,
        severity,
        event_type,
        occurred_at
    )
    values
    (
        new.id,
        new.tbm_code,
        new.parameter_code,
        new.alarm_value,
        new.severity,
        'raised',
        new.created_at
    );


    return new;

end;

$$;


create trigger trg_alarm_insert_history
after insert on runtime.parameter_alarms
for each row
execute function runtime.fn_alarm_insert_history();




create or replace function runtime.fn_alarm_delete_history()
returns trigger
language plpgsql
as $$

begin

    insert into runtime.parameter_alarm_history
    (
        alarm_id,
        tbm_code,
        parameter_code,
        alarm_value,
        severity,
        event_type,
        occurred_at,
        created_at
    )
    values
    (
        old.id,
        old.tbm_code,
        old.parameter_code,
        old.alarm_value,
        old.severity,
        'recovered',
        now(),
        old.created_at
    );


    return old;

end;

$$;

create trigger trg_alarm_delete_history

before delete on runtime.parameter_alarms

for each row

execute function runtime.fn_alarm_delete_history();