create or replace view tbm.v_assignable_tunnels
with (security_invoker = true)
as
select
  t.id,
  t.name,
  eu.project_id,
  t.engineering_unit_id,
  eu.full_name as engineering_unit_name,
  p.name as project_name
from proj.tunnels t
join proj.engineering_units eu
  on eu.id = t.engineering_unit_id
join proj.projects p
  on p.id = eu.project_id
where not exists (
  select 1
  from tbm.assignments a
  where a.tunnel_id = t.id
    and a.end_date is null
);

create unique index uq_tbm_assignments_active_tunnel
on tbm.assignments (tunnel_id)
where end_date is null;

-- 1. 允许 authenticated 使用 tbm schema
grant usage on schema tbm to authenticated;

-- 2. 允许查询 View
grant select on tbm.v_assignable_tunnels to authenticated;

-- 3. 允许读取底层表
grant select on proj.tunnels to authenticated;
grant select on tbm.assignments to authenticated;