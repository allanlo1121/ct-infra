-- 4. TABLE PERMISSIONS

-- 撤销默认授权
revoke all on table tbm.tbm_parameter_threshold_rules
from public, anon, authenticated;

-- 登录用户基本 CRUD 权限
grant select, insert, update, delete
on table tbm.tbm_parameter_threshold_rules
to authenticated;

-- 服务端角色读写
grant select, insert, update, delete
on table tbm.tbm_parameter_threshold_rules
to service_role;

-- 启用 RLS
alter table tbm.tbm_parameter_threshold_rules
enable row level security;


-- 5. POLICIES

create policy "tbm_parameter_threshold_rules_read"
on tbm.tbm_parameter_threshold_rules
for select
to authenticated
using (true);

create policy "tbm_parameter_threshold_rules_insert_authorized"
on tbm.tbm_parameter_threshold_rules
for insert
to authenticated
with check (
  (select iam.has_permission('tbm','write')) 
);

create policy "tbm_parameter_threshold_rules_update_authorized"
on tbm.tbm_parameter_threshold_rules
for update
to authenticated
using (
  (select iam.has_permission('tbm','write'))
)
with check (
  (select iam.has_permission('tbm','write')) 
);

create policy "tbm_parameter_threshold_rules_delete_authorized"
on tbm.tbm_parameter_threshold_rules
for delete
to authenticated
using (
  (select iam.has_permission('tbm','delete')) 
);


-- 允许 authenticated 使用 tbm schema
grant usage on schema tbm to authenticated;

-- 允许 authenticated 查询 View
grant select on tbm.v_parameter_threshold_list
to authenticated;


create or replace function system.touch_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

create trigger trg_connection_status_updated_at
before update on tbm.connection_status
for each row
execute function system.touch_updated_at();


create or replace function tbm.record_runtime_state_history()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  insert into tbm.runtime_state_history (
    tbm_code,
    ring_no,
    chainage,
    tbm_phase_type_code,
    thrust_speed,
    thrust_pressure,
    thrust_cylinder_stroke,
    cutter_speed,
    cutter_torque,
    penetration_rate,
    total_thrust,
    sampled_at
  )
  values (
    new.tbm_code,
    new.ring_no,
    new.chainage,
    new.tbm_phase_type_code,
    new.thrust_speed,
    new.thrust_pressure,
    new.thrust_cylinder_stroke,
    new.cutter_speed,
    new.cutter_torque,
    new.penetration_rate,
    new.total_thrust,
    new.sampled_at
  );

  return new;
end;
$$;

create trigger trg_runtime_state_history
after insert or update
on tbm.runtime_state_current
for each row
execute function tbm.record_runtime_state_history();




-- ==========================================
-- 安全风险类型 SAFE  Type
-- ==========================================

--RISK CATEGORY
INSERT INTO master_data.dictionary_types (code,name)
VALUES ('5001', '风险类别')
ON CONFLICT (code) DO NOTHING;

INSERT INTO master_data.dictionary_items (dictionary_type_code, code, name)
VALUES 
    ('5001', '50010001', '常规风险'),
    ('5001', '50010002', '周边环境风险'),
    ('5001', '50010003', '工程自身风险'),
    ('5001', '50010004', '施工作业特色风险')
ON CONFLICT (code) DO NOTHING;

-- ==========================================
-- 风险隐患等级 RISK LEVEL
-- ==========================================

INSERT INTO master_data.dictionary_types (code,name)
VALUES ('5002', '风险隐患等级')
ON CONFLICT (code) DO NOTHING;

INSERT INTO master_data.dictionary_items (dictionary_type_code, code, name)
VALUES 
    ('5002', '50020001', 'I'),
    ('5002', '50020002', 'II'),
    ('5002', '50020003', 'III'),
    ('5002', '50020004', 'IV')
ON CONFLICT (code) DO NOTHING;


-- ==========================================
-- 警告级别 ALERT_SEVERITY
-- ==========================================

INSERT INTO master_data.dictionary_types (code,name)
VALUES ('5201', '警告级别')
ON CONFLICT (code) DO NOTHING;

INSERT INTO master_data.dictionary_items (dictionary_type_code, code, name)
VALUES 
    ('5201', '52010001', '一般告警'),
    ('5201', '52010002', '严重告警'),
    ('5201', '52010003', '紧急告警')
ON CONFLICT (code) DO NOTHING;


drop view tbm.v_parameter_threshold_list cascade;
create or replace view tbm.v_parameter_threshold_list
with (security_invoker = true)
as
select
  -- 阈值
  t.*,

  -- TBM 参数
  tp.tbm_code,
  tp.parameter_code,
  tp.custom_name,
  tp.custom_unit,
  tp.value_max,
  tp.value_min,

  -- 标准参数
  p.subsystem_code,
  p.name,
  p.unit,
  p.data_type

from tbm.tbm_parameter_threshold_rules t
join tbm.tbm_parameters tp
  on tp.id = t.tbm_parameter_id
join tbm.parameters p
  on p.code = tp.parameter_code;

-- 允许 authenticated 使用 tbm schema
grant usage on schema tbm to authenticated;

-- 允许 authenticated 查询 View
grant select on tbm.v_parameter_threshold_list
to authenticated;


create table
  tbm.tbm_parameter_threshold_rules (
    id integer generated always as identity primary key,
    -- 盾构机参数
    tbm_parameter_id integer not null references tbm.tbm_parameters (id) on delete restrict,
    -- 所属隧道（NULL 表示不限定隧道）
    tunnel_id uuid references proj.tunnels (id) on delete restrict,
    -- 适用环号范围
    start_ring integer not null,
    end_ring integer not null,
    -- 阈值类型
    threshold_type text not null check (threshold_type in ('upper', 'lower', 'deviation')),
    -- 告警级别（5201）
    alert_severity_code text not null references master_data.dictionary_items (code),
    -- 阈值参数
    reference_value numeric,
    threshold_value numeric not null,
    min_record_delta numeric not null default 0
    check (min_record_delta >= 0),
  min_record_interval_ms integer not null default 0
    check (min_record_interval_ms >= 0);
    -- 状态
    is_disabled boolean not null default false,
    remark text,
    -- 审计
    created_at timestamptz not null default now (),
    updated_at timestamptz,
    created_by uuid references auth.users (id) on delete set null,
    updated_by uuid references auth.users (id) on delete set null,
    -- 环号范围检查
    constraint chk_ring_range check (start_ring <= end_ring),
    -- 偏差类型必须配置参考值，且允许偏差不能为负数
    constraint chk_threshold_config check (
      threshold_type <> 'deviation'
      or (
        reference_value is not null
        and threshold_value >= 0
      )
    )
  );

  alter table tbm.tbm_parameter_threshold_rules
  add column min_record_delta numeric not null default 0
    check (min_record_delta >= 0),

  add column min_record_interval_ms integer not null default 0
    check (min_record_interval_ms >= 0);