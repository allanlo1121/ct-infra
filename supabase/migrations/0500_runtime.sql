-- =====================================================
-- 0501 RUNTIME SCHEMA PERMISSIONS
-- =====================================================

create schema if not exists runtime;

-- schema usage
grant usage on schema runtime to anon, authenticated, service_role;

-- existing tables
grant select, insert, update, delete
on all tables in schema runtime
to authenticated, service_role;

-- existing sequences
grant usage, select
on all sequences in schema runtime
to authenticated, service_role;

-- future tables
alter default privileges for role postgres in schema runtime
grant select, insert, update, delete
on tables to authenticated, service_role;

-- future sequences
alter default privileges for role postgres in schema runtime
grant usage, select
on sequences to authenticated, service_role;





create table if not exists runtime.tbm_runtime_state_current (
  tbm_code text primary key references tbm.tbms(code),

  ring_no int null,
  chainage numeric null,

  phase_type tbm.tbm_phase_type not null,

  thrust_speed numeric null,
  thrust_pressure numeric null,
  thrust_cylinder_stroke numeric null,
  cutter_speed numeric null,
  cutter_torque numeric null,
  penetration_rate numeric null,
  total_thrust numeric null,

  created_at timestamptz not null default now(),
  updated_at timestamptz

);


create table runtime.tbm_phase_records (

  id uuid primary key default gen_random_uuid(),

  tbm_code text not null references tbm.tbms(code),

  ring_no integer,
  chainage numeric,

  phase_type tbm.tbm_phase_type not null,

  started_at timestamptz not null,

  created_at timestamptz not null default now()
);

create index idx_tbm_phase_records_tbm_started_at
  on runtime.tbm_phase_records (
    tbm_code,
    started_at desc
  );


create table runtime.tbm_risk_states (
    tbm_code text not null references tbm.tbms(code),
    risk_id uuid not null references proj.tunnel_risks(id),

    ring_no integer not null,
    chainage numeric not null,

    enter_distance numeric not null,
    exit_distance numeric not null,

    updated_at timestamptz not null default now(),

    primary key (tbm_code, risk_id)
);





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


create or replace function runtime.fn_alarm_update_history()
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
        new.id,
        new.tbm_code,
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

after update on runtime.parameter_alarms

for each row
execute function runtime.fn_alarm_update_history();


create table runtime.tbm_connection_status (
  tbm_code text not null references tbm.tbms(code),

  type text not null check (
    type in ('heartbeat', 'realdata')
  ),

  last_seen_at timestamptz not null,

  is_online boolean not null default false,

  created_at timestamptz not null default now(),

  updated_at timestamptz,

  primary key (tbm_code, type)
);



create table runtime.tbm_connection_status_history (
  id uuid primary key default gen_random_uuid(),

  tbm_code text not null references tbm.tbms(code),

  type text not null check (
    type in ('heartbeat', 'realdata')
  ),

  status text not null check (
    status in ('online', 'offline')
  ),

  start_at timestamptz not null,
  end_at timestamptz,

  source text not null default 'auto',
  remark text,

  created_at timestamptz not null default now(),
  updated_at timestamptz,

  constraint connection_status_history_time_check
    check (
      end_at is null
      or end_at > start_at
    )
);


create table runtime.tbm_daily_progress (
  id uuid primary key default gen_random_uuid(),

  tbm_code text not null references tbm.tbms(code),

  work_date date not null,

  ring_end integer not null,
  chainage_end numeric,

  unique (tbm_code, work_date)
);



  -- 开启实时订阅
 

  alter publication supabase_realtime add table runtime.tbm_runtime_state_current;
  alter publication supabase_realtime add table runtime.tbm_phase_records;
  alter publication supabase_realtime add table runtime.tbm_risk_states;
  alter publication supabase_realtime add table runtime.parameter_alarms;
  alter publication supabase_realtime add table runtime.tbm_connection_status;
  alter publication supabase_realtime add table runtime.tbm_daily_progress;