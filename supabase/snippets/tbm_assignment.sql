create or replace function tbm.get_organization_context(
  p_tbm_code text
)
returns table (
  tbm_code text,
  tunnel_id uuid,
  engineering_unit_id uuid,
  project_id uuid,
  organization_id uuid
)
language sql
stable
security invoker
set search_path = ''
as $$
  select
    a.tbm_code,
    a.tunnel_id,
    eu.id as engineering_unit_id,
    p.id as project_id,
    p.organization_id
  from tbm.assignments a
  join proj.tunnels t
    on t.id = a.tunnel_id
  join proj.engineering_units eu
    on eu.id = a.tunnel_id
  join proj.projects p
    on p.id = eu.project_id
  join hrm.organizations o
    on o.id = p.organization_id
  where a.tbm_code = p_tbm_code
    -- 当前有效绑定
    and a.start_date <= current_date
    and a.end_date is null
    -- 必须存在所属组织
    and p.organization_id is not null
  limit 1;
$$;


revoke all
on function tbm.get_organization_context(text)
from public, anon, authenticated;

grant execute
on function tbm.get_organization_context(text)
to service_role;

grant usage on schema tbm
to service_role;


drop view tbm.v_current_assignments cascade;

create or replace view tbm.v_current_assignments
with (security_invoker = true)
as
select
  a.id,
  a.tbm_code,
  s.name as tbm_name,
  a.tunnel_id,
  t.name as tunnel_name,
  t.engineering_unit_id,
  eu.name as engineering_unit_name,
  eu.project_id,
  p.name as project_name,
  p.organization_id,
  o.name as organization_name,

  a.advance_direction,

  t.start_ring,
  t.end_ring,
  t.start_chainage,
  t.end_chainage

from tbm.assignments a

join tbm.tbms s
  on s.code = a.tbm_code
join proj.tunnels t
  on t.id = a.tunnel_id
join proj.engineering_units eu  
  on eu.id=t.engineering_unit_id
join proj.projects p
  on p.id = eu.project_id
left join hrm.organizations o
    on o.id = p.organization_id
    
where a.start_date <= current_date
  and a.end_date is null;

-- 允许 authenticated 使用 tbm schema
grant usage on schema tbm to authenticated;

-- 允许 authenticated 查询 View
grant select on tbm.v_current_assignments
to authenticated;