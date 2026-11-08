INSERT INTO
    tbm.parameter_threshold_defaults (parameter_code, threshold_type, severity_code, reference_value, threshold_value,min_record_delta,min_record_interval_seconds)
VALUES
    ('s100206003', 'deviation', '52010001', '0','50','10','600'),
    ('s100206004', 'deviation', '52010001', '0','50','10','600'),
    ('s100206006', 'deviation', '52010001', '0','50','10','600'),
    ('s100206007', 'deviation', '52010001', '0','50','10','600'),
    ('s100206009', 'deviation', '52010001', '0','50','10','600'),
    ('s100206010', 'deviation', '52010001', '0','50','10','600'), 
    ('s100206003', 'deviation', '52010002', '0','80','10','600'),
    ('s100206004', 'deviation', '52010002', '0','80','10','600'),
    ('s100206006', 'deviation', '52010002', '0','80','10','600'),
    ('s100206007', 'deviation', '52010002', '0','80','10','600'),
    ('s100206009', 'deviation', '52010002', '0','80','10','600'),
    ('s100206010', 'deviation', '52010002', '0','80','10','600')    
ON CONFLICT (parameter_code,severity_code) DO NOTHING;


insert into system.menus (
  parent_id,
  code,
  name,
  path_url,
  icon,
  sort_order
)
values
  (
    null,
    'tbm-config',
    'TBM系统配置',
    '/tbm-config',
    'settings-2',
    55
  ),
  (
    null,
    'tbm-operation',
    'TBM生产运行',
    '/tbm-operation',
    'activity',
    55
  );

  insert into system.menus (
  parent_id,
  code,
  name,
  path_url,
  icon,
  sort_order
)
select
  parent.id,
  child.code,
  child.name,
  child.path_url,
  child.icon,
  child.sort_order
from system.menus parent
cross join (
  values
    (
      'tbm-config.parameters',
      '参数管理',
      '/tbm-config/parameters',
      'sliders-horizontal',
      10
    ),
    (
      'tbm-config.connections',
      '采集连接配置',
      '/tbm-config/connections',
      'plug',
      20
    ),
    (
      'tbm-config.phase-status',
      '运行状态配置',
      '/tbm-config/phase-status',
      'workflow',
      30
    ),
    (
      'tbm-config.notifications',
      '通知规则配置',
      '/tbm-config/notifications',
      'bell-ring',
      40
    )
) as child(
  code,
  name,
  path_url,
  icon,
  sort_order
)
where parent.code = 'tbm-config';


insert into system.menus (
  parent_id,
  code,
  name,
  path_url,
  icon,
  sort_order
)
select
  parent.id,
  child.code,
  child.name,
  child.path_url,
  child.icon,
  child.sort_order
from system.menus parent
cross join (
  values
    (
      'tbm-operation.overview',
      '运行总览',
      '/tbm-operation/overview',
      'layout-dashboard',
      10
    ),
    (
      'tbm-operation.monitor',
      '实时监控',
      '/tbm-operation/monitor',
      'monitor',
      20
    ),
    (
      'tbm-operation.parameter-binding',
      '参数配置',
      '/tbm-operation/parameter-binding',
      'sliders-horizontal',
      30
    ),
    (
      'tbm-operation.connectivity',
      '连接状态',
      '/tbm-operation/connectivity',
      'network',
      40
    ),
    (
      'tbm-operation.alarms',
      '告警管理',
      '/tbm-operation/alarms',
      'bell',
      50
    ),
    (
      'tbm-operation.risks',
      '风险管理',
      '/tbm-operation/risks',
      'shield-alert',
      60
    ),
    (
      'tbm-operation.daily-reports',
      '运行日报',
      '/tbm-operation/daily-reports',
      'file-chart-column',
      70
    ),
    (
      'tbm-operation.analysis',
      '历史数据分析',
      '/tbm-operation/analysis',
      'chart-no-axes-combined',
      80
    )
) as child(
  code,
  name,
  path_url,
  icon,
  sort_order
)
where parent.code = 'tbm-operation';

create unique index uq_tbm_assignments_active_tunnel
on tbm.assignments (tunnel_id)
where end_date is null;


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

select
  con.conname as constraint_name,
  con.conrelid::regclass as source_table,
  con.confrelid::regclass as target_table,
  pg_get_constraintdef(con.oid) as definition
from pg_constraint con
where con.contype = 'f'
  and con.conrelid = 'tbm.assignments'::regclass;

select rolname, rolconfig
from pg_roles
where rolname = 'authenticator';

notify pgrst, 'reload schema';


      ('tbm.tbms', 'TBM管理', '/tbm/tbms', 'crosshair', 10),
      ('tbm.assignments', 'TBM分配', '/tbm/assignments', 'crosshair', 20),

insert into
  system.menus (parent_id, code, name, path_url, icon, sort_order)
select
  parent.id,
  child.code,
  child.name,
  child.path_url,
  child.icon,
  child.sort_order
from
  system.menus parent
  cross join (
    values  
      ('equip.tbms', 'TBM管理', '/equip/tbms', 'crosshair', 20),
      ('equip.assignments', 'TBM分配', '/equip/assignments', 'crosshair', 30)
  ) as child (code, name, path_url, icon, sort_order)
where
  parent.code = 'equip';

do $$
begin
  -- 1. 删除 TBM 下级菜单
  delete from system.menus
  where parent_id = (
    select id
    from system.menus
    where code = 'tbm'
  );

  -- 2. 删除 TBM 上级菜单
  delete from system.menus
  where code = 'tbm';
end;
$$;

--6. 订阅开启
alter publication supabase_realtime
add table tbm.parameter_thresholds;

alter publication supabase_realtime
add table tbm.parameter_threshold_defaults;