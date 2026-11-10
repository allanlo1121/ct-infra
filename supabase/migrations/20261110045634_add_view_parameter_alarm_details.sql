

create or replace view tbm.v_parameter_alarm_details
with
    (security_invoker = true) as
select
    a.id,
    a.tbm_code,
    a.parameter_code,
    tp.name as parameter_name,
    a.severity_code,
    di.name as severity_name,
    a.alarm_value,
    a.rule_snapshot,
    a.ring_no,
    a.chainage,
    a.occurred_at,
    m.name as tbm_name,
    p.name as project_name,
    eu.name as engineering_unit_name,
    t.full_name as tunnel_name
from
    tbm.parameter_alarms a
    join tbm.parameters tp on tp.code = a.parameter_code
    join master_data.dictionary_items di on di.code = a.severity_code
    join tbm.tbms m on m.code = a.tbm_code
    join proj.tunnels t on t.id = a.tunnel_id
    join proj.engineering_units eu on eu.id = t.engineering_unit_id
    join proj.projects p on p.id = eu.project_id;

-- 1. View 所在 Schema 的使用权限
grant usage on schema tbm to authenticated;

-- 2. View 查询权限
grant select on tbm.v_parameter_alarm_details
to authenticated;

-- 3. 底层业务表的查询权限
grant select on tbm.parameter_alarms
to authenticated;

grant select on tbm.parameters
to authenticated;

grant select on tbm.tbms
to authenticated;

grant select on master_data.dictionary_items
to authenticated;

grant select on proj.tunnels
to authenticated;

grant select on proj.engineering_units
to authenticated;

grant select on proj.projects
to authenticated;

-- 4. 底层 Schema 的使用权限
grant usage on schema master_data to authenticated;
grant usage on schema proj to authenticated;