
create table tbm.tbm_daily_progress (
  id uuid primary key default gen_random_uuid(),

  tbm_id uuid not null references tbm.tbms(id),

  work_date date not null,

  ring_end integer not null,
  chainage_end numeric,

  plan_ring_count integer,


  unique (tbm_id, work_date)
);

