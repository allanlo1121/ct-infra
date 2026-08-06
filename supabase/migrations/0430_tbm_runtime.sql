
create type tbm.phase_type as enum (
  'advance',
  'assembly',
  'stop',
  'fault',
  'unknown'
);


create table if not exists tbm.tbm_runtime_state_current (
  tbm_id uuid primary key references tbm.tbms(id),

  ring_no int null,
  chainage numeric null,

  phase_type tbm.phase_type not null,

  thrust_speed numeric null,
  thrust_pressure numeric null,
  thrust_cylinder_stroke numeric null,
  cutter_speed numeric null,
  cutter_torque numeric null,
  total_thrust numeric null,

  recorded_at timestamptz not null

);


create table tbm.tbm_phase_records (

  id uuid primary key default gen_random_uuid(),

  tbm_id uuid not null references tbm.tbms(id),

  ring_no integer null,
  start_chainage numeric null,
  end_chainage numeric null,

  phase_type tbm.phase_type not null,

  start_at timestamptz not null,

  end_at timestamptz null
);