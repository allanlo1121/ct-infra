-- ==============================
-- 2060 TBM TBMS SUBTABLES
-- ==============================
-- 1. TABLE
create table tbm.connection_status (
  tbm_code text primary key references tbm.tbms (code) on delete cascade,
  -- 最近一次心跳接收时间
  last_heartbeat_at timestamptz,
  -- 最近一次有效实时数据接收时间
  last_realdata_at timestamptz,
  -- 最近一次实际采样时间
  last_sampled_at timestamptz,
  updated_at timestamptz not null default now()
);

create trigger trg_connection_status_updated_at
before update on tbm.connection_status for each row
execute function system.touch_updated_at ();

-- 3. INDEXES
-- 4. TABLE PERMISSIONS
-- 撤销默认授权
revoke all on table tbm.connection_status
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
delete on table tbm.connection_status to authenticated;

-- 服务端角色读写
grant
select
,
  insert,
update,
delete on table tbm.connection_status to service_role;

-- 启用 RLS
alter table tbm.connection_status enable row level security;

-- 5. POLICIES
create policy "connection_status_read" on tbm.connection_status for
select
  to authenticated using (true);

create policy "connection_status_insert_authorized" on tbm.connection_status for insert to authenticated
with
  check (
    (
      select
        iam.has_permission ('tbm', 'write')
    )
  );

create policy "connection_status_update_authorized" on tbm.connection_status
for update
  to authenticated using (
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

create policy "connection_status_delete_authorized" on tbm.connection_status for delete to authenticated using (
  (
    select
      iam.has_permission ('tbm', 'delete')
  )
);

create table tbm.connection_status_history (
  id bigint generated always as identity primary key,
  tbm_code text not null references tbm.tbms (code) on delete cascade,
  -- 状态类型
  type text not null check (type in ('heartbeat', 'realdata')),
  -- 在线状态
  status text not null check (status in ('online', 'offline')),
  -- 状态持续时间
  start_at timestamptz not null,
  end_at timestamptz,
  -- 状态来源
  source text not null default 'auto',
  remark text,
  created_at timestamptz not null default now(),
  updated_at timestamptz,
  constraint chk_connection_history_time check (
    end_at is null
    or end_at > start_at
  )
);

-- 3. INDEXES
create index idx_tbm_connection_history_lookup on tbm.connection_status_history (tbm_code, type, start_at desc);

create unique index uq_tbm_connection_history_active on tbm.connection_status_history (tbm_code, type)
where
  end_at is null;

-- 4. TABLE PERMISSIONS
-- 撤销默认授权
revoke all on table tbm.connection_status_history
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
delete on table tbm.connection_status_history to authenticated;

-- 服务端角色读写
grant
select
,
  insert,
update,
delete on table tbm.connection_status_history to service_role;

-- 启用 RLS
alter table tbm.connection_status_history enable row level security;

-- 5. POLICIES
create policy "tbm_connection_history_read" on tbm.connection_status_history for
select
  to authenticated using (true);

create policy "tbm_connection_history_insert_authorized" on tbm.connection_status_history for insert to authenticated
with
  check (
    (
      select
        iam.has_permission ('tbm', 'write')
    )
  );

create policy "tbm_connection_history_update_authorized" on tbm.connection_status_history
for update
  to authenticated using (
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

create policy "tbm_connection_history_delete_authorized" on tbm.connection_status_history for delete to authenticated using (
  (
    select
      iam.has_permission ('tbm', 'delete')
  )
);

create table tbm.ring_phase_records (
  id bigint generated always as identity primary key,

  tbm_code text not null
    references tbm.tbms(code) on delete restrict,

  tunnel_id uuid not null
    references proj.tunnels(id) on delete restrict,

  ring_no integer not null,

  start_chainage numeric,
  end_chainage numeric,

  tbm_phase_type text not null check (
    tbm_phase_type in (
      'excavation',
      'segment_erection',
      'waiting',
      'stopped',
      'fault',
      'cutter_change',
      'maintenance',
      'unknown'
    )
  ),

  started_at timestamptz not null,
  ended_at timestamptz,

  -- 审计信息
  created_at timestamptz not null default now(),
  created_by uuid,
  updated_at timestamptz,
  updated_by uuid,

  constraint chk_ring_phase_time
    check (ended_at is null or ended_at >= started_at)
);

create trigger trg_tbm_ring_phase_records_audit_insert
before insert on tbm.ring_phase_records
for each row
execute function system.audit_insert();

create trigger trg_tbm_ring_phase_records_audit_update
before update on tbm.ring_phase_records
for each row
execute function system.audit_update();

create trigger trg_tbm_ring_phase_records_audit_delete
before delete on tbm.ring_phase_records
for each row
execute function system.audit_delete();

-- 一台 TBM 最多只有一个当前阶段
create unique index uq_ring_phase_active
on tbm.ring_phase_records (tbm_code)
where ended_at is null;

-- 按隧道、环号查询阶段
create index idx_ring_phase_tunnel_ring
on tbm.ring_phase_records (
  tunnel_id,
  ring_no,
  started_at
);



-- 4. TABLE PERMISSIONS for ring_phase_records
revoke all on table tbm.ring_phase_records
from
  public,
  anon,
  authenticated;

grant
select
,
  insert,
update,
delete on table tbm.ring_phase_records to authenticated;

grant
select
,
  insert,
update,
delete on table tbm.ring_phase_records to service_role;

alter table tbm.ring_phase_records enable row level security;

create policy "tbm_ring_phase_records_read" on tbm.ring_phase_records for
select
  to authenticated using (true);

create policy "tbm_ring_phase_records_insert_authorized" on tbm.ring_phase_records for insert to authenticated
with
  check (
    (
      select
        iam.has_permission ('tbm', 'write')
    )
  );

create policy "tbm_ring_phase_records_update_authorized" on tbm.ring_phase_records
for update
  to authenticated using (
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

create policy "tbm_ring_phase_records_delete_authorized" on tbm.ring_phase_records for delete to authenticated using (
  (
    select
      iam.has_permission ('tbm', 'delete')
  )
);


create table tbm.parameter_alarms (
  id bigint generated always as identity primary key,

  tbm_code text not null references tbm.tbms(code),
  tunnel_id uuid not null references proj.tunnels(id),
  parameter_code text not null references tbm.parameters(code),

  severity_code text not null
    references master_data.dictionary_items(code),

  rule_snapshot jsonb not null,
  alarm_value numeric not null,

  ring_no integer,
  chainage numeric,

  occurred_at timestamptz not null,

  created_at timestamptz not null default now(),
  created_by uuid default auth.uid()
    references auth.users(id) on delete set null
);



-- =========================================
-- 5. TABLE PERMISSIONS for tbm_parameter_alarms
-- =========================================


-- =========================================
-- 2. 撤销原有权限
-- =========================================

revoke all on table tbm.parameter_alarms
from public, anon, authenticated, service_role;


-- =========================================
-- 3. 普通用户只读
-- =========================================

grant select on table tbm.parameter_alarms
to authenticated;


-- =========================================
-- 4. Pulse 服务端允许读取、插入
-- =========================================

grant select, insert on table tbm.parameter_alarms
to service_role;


-- =========================================
-- 5. 启用 RLS
-- =========================================

alter table tbm.parameter_alarms
enable row level security;


-- =========================================
-- 6. 只允许已登录用户读取
-- =========================================

create policy "parameter_alarms_read"
on tbm.parameter_alarms
for select
to authenticated
using (true);

create policy "parameter_alarms_insert_authorized" on tbm.parameter_alarms for insert to authenticated
with
  check (
    (
      select
        iam.has_permission ('tbm', 'write')
    )
  );

create policy "parameter_alarms_update_authorized" on tbm.parameter_alarms
for update
  to authenticated using (
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

create policy "parameter_alarms_delete_authorized" on tbm.parameter_alarms for delete to authenticated using (
  (
    select
      iam.has_permission ('tbm', 'delete')
  )
);

-- 报警日志核实表
create table tbm.parameter_alarm_verifications (
  id bigint generated always as identity primary key,

  alarm_id bigint not null
    references tbm.parameter_alarms(id),

  previous_status text not null,
  new_status text not null,

  remark text,

  verified_at timestamptz not null default now(),
  verified_by uuid not null references auth.users(id)
);
