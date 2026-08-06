create type tbm.alarm_severity as enum (
  'warning',
  'critical',
  'emergency'
);

drop table tbm.tbm_parameter_alarms cascade;

create table tbm.tbm_parameter_alarms (

    id uuid primary key default gen_random_uuid(),

    tbm_id uuid not null references tbm.tbms(id) on delete cascade,

    parameter_code text not null,

    ring_no bigint,

    chainage numeric,

    alarm_value numeric,

    severity tbm.alarm_severity not null,   

    created_at timestamptz default now(),
    updated_at timestamptz default now(),

    unique(
        tbm_id,
        parameter_code
    )
);


drop table tbm.tbm_parameter_alarm_history cascade;

create table tbm.tbm_parameter_alarm_history (

    id uuid primary key default gen_random_uuid(),

    alarm_id uuid not null,

    tbm_id uuid not null,

    parameter_code text not null,

    alarm_value numeric,

    severity tbm.alarm_severity not null,

    event_type text not null,

    occurred_at timestamptz not null,

    created_at timestamptz default now()
);


create or replace function tbm.fn_alarm_insert_history()
returns trigger
language plpgsql
as $$

begin

    insert into tbm.tbm_parameter_alarm_history
    (
        alarm_id,
        tbm_id,
        parameter_code,
        alarm_value,
        severity,
        event_type,
        occurred_at
    )
    values
    (
        new.id,
        new.tbm_id,
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

after insert on tbm.tbm_parameter_alarms

for each row

execute function tbm.fn_alarm_insert_history();


create or replace function tbm.fn_alarm_delete_history()
returns trigger
language plpgsql
as $$

begin

    insert into tbm.tbm_parameter_alarm_history
    (
        alarm_id,
        tbm_id,
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
        old.tbm_id,
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

before delete on tbm.tbm_parameter_alarms

for each row

execute function tbm.fn_alarm_delete_history();

create or replace function tbm.fn_alarm_update_history()
returns trigger
language plpgsql
as $$

begin

    insert into tbm.tbm_parameter_alarm_history
    (
        alarm_id,
        tbm_id,
        parameter_code,
        alarm_value,
        severity,
        event_type,
        occurred_at,
        created_at
    )
    values
    (
        new.id,
        new.tbm_id,
        new.parameter_code,
        new.alarm_value,
        new.severity,
        'updated',
        new.updated_at,
        new.created_at
    );


    return new;

end;

$$;


create trigger trg_alarm_update_history

after update on tbm.tbm_parameter_alarms

for each row

execute function tbm.fn_alarm_update_history();





