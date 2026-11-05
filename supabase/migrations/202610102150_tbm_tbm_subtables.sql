-- ==============================
-- 2060 TBM TBMS SUBTABLES
-- ==============================
-- 1. TABLE
create table
  tbm.subsystems (
    -- 盾构机唯一业务编码
    code text primary key,
    -- 盾构机基础信息
    name text not null,
    description text,
    -- 状态
    is_disabled boolean not null default false
  );

-- 2. AUDIT FIELDS
alter table tbm.subsystems
add column created_at timestamptz not null default now ();

alter table tbm.subsystems
add column updated_at timestamptz;

alter table tbm.subsystems
add column created_by uuid references auth.users (id) on delete set null;

alter table tbm.subsystems
add column updated_by uuid references auth.users (id) on delete set null;

create trigger trg_subsystems_audit_insert before insert on tbm.subsystems for each row execute function system.audit_insert ();

create trigger trg_subsystems_audit_update before
update on tbm.subsystems for each row execute function system.audit_update ();

create trigger trg_subsystems_audit_delete before delete on tbm.subsystems for each row execute function system.audit_delete ();

-- 3. INDEXES
-- 4. TABLE PERMISSIONS
-- 撤销默认授权
revoke all on table tbm.subsystems
from
  public,
  anon,
  authenticated;

-- 登录用户基本 CRUD 权限
grant
select
,
  insert,
update,
delete on table tbm.subsystems to authenticated;

-- 服务端角色读写
grant
select
,
  insert,
update,
delete on table tbm.subsystems to service_role;

-- 启用 RLS
alter table tbm.subsystems enable row level security;

-- 5. POLICIES
create policy "subsystems_read" on tbm.subsystems for
select
  to authenticated using (true);

create policy "subsystems_insert_authorized" on tbm.subsystems for insert to authenticated
with
  check (
    (
      select
        iam.has_permission ('tbm', 'write')
    )
  );

create policy "subsystems_update_authorized" on tbm.subsystems for
update to authenticated using (
  (
    select
      iam.has_permission ('tbm', 'write')
  )
)
with
  check (
    (
      select
        iam.has_permission ('tbm', 'write')
    )
  );

create policy "subsystems_delete_authorized" on tbm.subsystems for delete to authenticated using (
  (
    select
      iam.has_permission ('tbm', 'delete')
  )
);

create table
  tbm.parameters (
    code text primary key,
    name text not null,
    subsystem_code text not null references tbm.subsystems (code) on delete restrict,
    data_type text not null check (data_type in ('double', 'boolean', 'integer')),
    description text,
    digits int,
    unit text,
    is_disabled boolean not null default false,
    --audit fields
    created_at timestamptz not null default now (),
    updated_at timestamptz,
    created_by uuid references auth.users (id) on delete set null,
    updated_by uuid references auth.users (id) on delete set null
  );

create trigger trg_parameters_audit_insert before insert on tbm.parameters for each row execute function system.audit_insert ();

create trigger trg_parameters_audit_update before
update on tbm.parameters for each row execute function system.audit_update ();

create trigger trg_parameters_audit_delete before delete on tbm.parameters for each row execute function system.audit_delete ();

-- 3. INDEXES
-- 4. TABLE PERMISSIONS
-- 撤销默认授权
revoke all on table tbm.parameters
from
  public,
  anon,
  authenticated;

-- 登录用户基本 CRUD 权限
grant
select
,
  insert,
update,
delete on table tbm.parameters to authenticated;

-- 服务端角色读写
grant
select
,
  insert,
update,
delete on table tbm.parameters to service_role;

-- 启用 RLS
alter table tbm.parameters enable row level security;

-- 5. POLICIES
create policy "parameters_read" on tbm.parameters for
select
  to authenticated using (true);

create policy "parameters_insert_authorized" on tbm.parameters for insert to authenticated
with
  check (
    (
      select
        iam.has_permission ('tbm', 'write')
    )
  );

create policy "parameters_update_authorized" on tbm.parameters for
update to authenticated using (
  (
    select
      iam.has_permission ('tbm', 'write')
  )
)
with
  check (
    (
      select
        iam.has_permission ('tbm', 'write')
    )
  );

create policy "parameters_delete_authorized" on tbm.parameters for delete to authenticated using (
  (
    select
      iam.has_permission ('tbm', 'delete')
  )
);

create table
  tbm.tbm_parameters (
    id integer generated always as identity primary key,
    tbm_code text not null references tbm.tbms (code) on delete restrict,
    parameter_code text not null references tbm.parameters (code) on delete restrict,
    custom_name text,
    custom_unit text,
    is_disabled boolean not null default false,
    remark text,
    value_max numeric,
    value_min numeric,
    -- audit fields
    created_at timestamptz not null default now (),
    updated_at timestamptz,
    created_by uuid references auth.users (id) on delete set null,
    updated_by uuid references auth.users (id) on delete set null
  );

-- 3. INDEXES
-- 4. TABLE PERMISSIONS
-- 撤销默认授权
revoke all on table tbm.tbm_parameters
from
  public,
  anon,
  authenticated;

-- 登录用户基本 CRUD 权限
grant
select
,
  insert,
update,
delete on table tbm.tbm_parameters to authenticated;

-- 服务端角色读写
grant
select
,
  insert,
update,
delete on table tbm.tbm_parameters to service_role;

-- 启用 RLS
alter table tbm.tbm_parameters enable row level security;

-- 5. POLICIES
create policy "tbm_parameters_read" on tbm.tbm_parameters for
select
  to authenticated using (true);

create policy "tbm_parameters_insert_authorized" on tbm.tbm_parameters for insert to authenticated
with
  check (
    (
      select
        iam.has_permission ('tbm', 'write')
    )
  );

create policy "tbm_parameters_update_authorized" on tbm.tbm_parameters for
update to authenticated using (
  (
    select
      iam.has_permission ('tbm', 'write')
  )
)
with
  check (
    (
      select
        iam.has_permission ('tbm', 'write')
    )
  );

create policy "tbm_parameters_delete_authorized" on tbm.tbm_parameters for delete to authenticated using (
  (
    select
      iam.has_permission ('tbm', 'delete')
  )
);

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
    severity_code text not null references master_data.dictionary_items (code),
    -- 阈值参数
    reference_value numeric,
    threshold_value numeric not null,
    min_record_delta numeric not null default 0
    check (min_record_delta >= 0),
    min_record_interval_ms integer not null default 0
    check (min_record_interval_ms >= 0),
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

-- 2. AUDIT FIELDS
create trigger trg_tbm_parameter_threshold_rules_audit_insert before insert on tbm.tbm_parameter_threshold_rules for each row execute function system.audit_insert ();

create trigger trg_tbm_parameter_threshold_rules_audit_update before
update on tbm.tbm_parameter_threshold_rules for each row execute function system.audit_update ();

create trigger trg_tbm_parameter_threshold_rules_audit_delete before delete on tbm.tbm_parameter_threshold_rules for each row execute function system.audit_delete ();

-- 4. TABLE PERMISSIONS
-- 撤销默认授权
revoke all on table tbm.tbm_parameter_threshold_rules
from
  public,
  anon,
  authenticated;

-- 登录用户基本 CRUD 权限
grant
select
,
  insert,
update,
delete on table tbm.tbm_parameter_threshold_rules to authenticated;

-- 服务端角色读写
grant
select
,
  insert,
update,
delete on table tbm.tbm_parameter_threshold_rules to service_role;

-- 启用 RLS
alter table tbm.tbm_parameter_threshold_rules enable row level security;

-- 5. POLICIES
create policy "tbm_parameter_threshold_rules_read" on tbm.tbm_parameter_threshold_rules for
select
  to authenticated using (true);

create policy "tbm_parameter_threshold_rules_insert_authorized" on tbm.tbm_parameter_threshold_rules for insert to authenticated
with
  check (
    (
      select
        iam.has_permission ('tbm', 'write')
    )
  );

create policy "tbm_parameter_threshold_rules_update_authorized" on tbm.tbm_parameter_threshold_rules for
update to authenticated using (
  (
    select
      iam.has_permission ('tbm', 'write')
  )
)
with
  check (
    (
      select
        iam.has_permission ('tbm', 'write')
    )
  );

create policy "tbm_parameter_threshold_rules_delete_authorized" on tbm.tbm_parameter_threshold_rules for delete to authenticated using (
  (
    select
      iam.has_permission ('tbm', 'delete')
  )
);