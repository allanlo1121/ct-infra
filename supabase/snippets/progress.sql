create or replace view app.v_tbm_daily_progress as

with progress_calculated as (
  select
    p.*,

    lag(p.ring_end) over (
      partition by p.tbm_id
      order by p.work_date
    ) as ring_start,

    lag(p.chainage_end) over (
      partition by p.tbm_id
      order by p.work_date
    ) as chainage_start

  from tbm.tbm_daily_progress p
)

select
  p.id,

  p.tbm_id,

  p.work_date,

  p.ring_start,
  p.ring_end,

  case
    when p.ring_start is null then 0
    else greatest(
      p.ring_end - p.ring_start,
      0
    )
  end as completed_ring_count,


  p.chainage_start,
  p.chainage_end,

  case
    when p.chainage_start is null then 0
    else greatest(
      p.chainage_end - p.chainage_start,
      0
    )
  end as completed_length

from progress_calculated p;


grant usage on schema app to authenticated;

grant select
on app.v_tunnel_runtime
to authenticated;

alter default privileges
in schema app
grant select on tables to authenticated;

grant select
on all tables in schema app
to authenticated;