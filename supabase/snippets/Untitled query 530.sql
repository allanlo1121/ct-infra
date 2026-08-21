drop table runtime.tbm_phase_records cascade;

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