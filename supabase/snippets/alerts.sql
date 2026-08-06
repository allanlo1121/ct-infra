


drop function tbm.fn_alarm_update_history() cascade;
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