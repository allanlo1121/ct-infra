create table tbm.parameter_thresholds (
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
    severity_code text not null references master_data.dictionary_items (code),
    -- 阈值参数
    reference_value numeric,
    threshold_value numeric not null,
    min_record_delta numeric not null default 0 check (min_record_delta >= 0),
    min_record_interval_seconds integer not null default 0 check (min_record_interval_seconds >= 0),
    -- 状态
    is_disabled boolean not null default false,
    remark text,
    -- 审计
    created_at timestamptz not null default now(),
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

-- 2. AUDIT FIELDS
create trigger trg_tbm_parameter_thresholds_audit_insert
before insert on tbm.parameter_thresholds for each row
execute function system.audit_insert ();

create trigger trg_tbm_parameter_thresholds_audit_update
before update on tbm.parameter_thresholds for each row
execute function system.audit_update ();

create trigger trg_tbm_parameter_thresholds_audit_delete
before delete on tbm.parameter_thresholds for each row
execute function system.audit_delete ();

/* sql-formatter-disable */
-- 4. TABLE PERMISSIONS
-- 撤销默认授权
revoke all on table tbm.parameter_thresholds
from public, anon, authenticated;

-- 登录用户基本 CRUD 权限

grant select, insert, update, delete
on table tbm.parameter_thresholds
to authenticated;

-- 服务端角色读写
grant select, insert, update, delete
on table tbm.parameter_thresholds
to service_role;

-- 启用 RLS
alter table tbm.parameter_thresholds enable row level security;

-- 5. POLICIES
create policy "parameter_thresholds_read"
on tbm.parameter_thresholds
for select
to authenticated
using (true);

create policy "parameter_thresholds_insert_authorized"
on tbm.parameter_thresholds
for insert
to authenticated
with check (
  (select iam.has_permission('tbm', 'write'))
);

create policy "parameter_thresholds_update_authorized" 
on tbm.parameter_thresholds 
for update 
to authenticated 
using (
    (select iam.has_permission ('tbm', 'write'))
)
with check (
    (select iam.has_permission ('tbm', 'write'))
);

create policy "parameter_thresholds_delete_authorized"
on tbm.parameter_thresholds 
for delete 
to authenticated 
using (
  (select iam.has_permission ('tbm', 'delete'))
);

/* sql-formatter-enable */
create table tbm.parameter_threshold_defaults (
    id integer generated always as identity primary key,
    parameter_code text not null references tbm.parameters (code),
    -- 阈值类型
    threshold_type text not null check (threshold_type in ('upper', 'lower', 'deviation')),
    -- 告警级别（5201）
    severity_code text not null references master_data.dictionary_items (code),
    reference_value numeric,
    threshold_value numeric not null,
    min_record_delta numeric not null default 0 check (min_record_delta >= 0),
    min_record_interval_seconds integer not null default 0 check (min_record_interval_seconds >= 0),
    -- 状态
    is_disabled boolean not null default false,
    remark text,
    -- 审计
    created_at timestamptz not null default now(),
    updated_at timestamptz,
    created_by uuid references auth.users (id) on delete set null,
    updated_by uuid references auth.users (id) on delete set null,
    constraint uq_parameter_threshold_defaults unique (parameter_code, severity_code)
);

-- 2. AUDIT FIELDS
create trigger trg_tbm_parameter_threshold_defaults_audit_insert
before insert on tbm.parameter_thresholds for each row
execute function system.audit_insert ();

create trigger trg_tbm_parameter_threshold_defaults_audit_update
before update on tbm.parameter_threshold_defaults for each row
execute function system.audit_update ();

create trigger trg_tbm_parameter_threshold_defaults_audit_delete
before delete on tbm.parameter_threshold_defaults for each row
execute function system.audit_delete ();

/* sql-formatter-disable */
-- 4. TABLE PERMISSIONS
-- 撤销默认授权
revoke all on table tbm.parameter_threshold_defaults
from public, anon, authenticated;

-- 登录用户基本 CRUD 权限

grant select, insert, update, delete
on table tbm.parameter_threshold_defaults
to authenticated;

-- 服务端角色读写
grant select, insert, update, delete
on table tbm.parameter_threshold_defaults
to service_role;

-- 启用 RLS
alter table tbm.parameter_threshold_defaults enable row level security;

-- 5. POLICIES
create policy "parameter_threshold_defaults_read"
on tbm.parameter_threshold_defaults
for select
to authenticated
using (true);

create policy "parameter_threshold_defaults_insert_authorized"
on tbm.parameter_threshold_defaults
for insert
to authenticated
with check (
  (select iam.has_permission('tbm', 'write'))
);

create policy "parameter_threshold_defaults_update_authorized" 
on tbm.parameter_threshold_defaults 
for update 
to authenticated 
using (
    (select iam.has_permission ('tbm', 'write'))
)
with check (
    (select iam.has_permission ('tbm', 'write'))
);

create policy "parameter_threshold_defaults_delete_authorized"
on tbm.parameter_threshold_defaults 
for delete 
to authenticated 
using (
  (select iam.has_permission ('tbm', 'delete'))
);


/* sql-formatter-enable */
create or replace view tbm.v_parameter_threshold_rules
with
    (security_invoker = true) as
select
    -- TBM parameter 参数
    tp.tbm_code,
    tp.parameter_code,
    p.subsystem_code,
    coalesce(nullif(trim(tp.custom_name), ''), p.name) as parameter_name,
    coalesce(nullif(trim(tp.custom_unit), ''), p.unit) as parameter_unit,
    tp.value_max,
    tp.value_min,
    p.data_type,
    p.digits,
    -- 阈值
    t.severity_code,
    di.name as severity_name,
    t.start_ring,
    t.end_ring,
    t.threshold_type,
    t.reference_value,
    t.threshold_value,
    t.min_record_delta,
    t.min_record_interval_seconds
from
    tbm.parameter_thresholds t
    join tbm.tbm_parameters tp on tp.id = t.tbm_parameter_id
    join tbm.parameters p on p.code = tp.parameter_code
    left join master_data.dictionary_items di on di.code = t.severity_code
union all
-- 默认规则
select
    -- TBM parameter 参数
    tp.tbm_code,
    tp.parameter_code,
    p.subsystem_code,
    coalesce(nullif(trim(tp.custom_name), ''), p.name) as parameter_name,
    coalesce(nullif(trim(tp.custom_unit), ''), p.unit) as parameter_unit,
    tp.value_max,
    tp.value_min,
    p.data_type,
    p.digits,
    -- 阈值
    pd.severity_code,
    di.name as severity_name,
    null::integer as start_ring,
    null::integer as end_ring,
    pd.threshold_type,
    pd.reference_value,
    pd.threshold_value,
    pd.min_record_delta,
    pd.min_record_interval_seconds
from
    tbm.parameter_threshold_defaults pd
    join tbm.tbm_parameters tp on tp.parameter_code = pd.parameter_code
    join tbm.parameters p on p.code = tp.parameter_code
    left join master_data.dictionary_items di on di.code = pd.severity_code;

/* sql-formatter-disable */
-- 允许 authenticated 使用 tbm schema
grant usage on schema tbm to authenticated;

-- 允许 authenticated 查询 View
grant select
on tbm.v_parameter_threshold_rules
to authenticated;