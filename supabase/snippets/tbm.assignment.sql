
drop table tbm.tbm_assignments cascade;

-- 1. TABLE
create table tbm.assignments (
  id uuid primary key default gen_random_uuid(),
  tbm_code text not null references tbm.tbms (code),
  tunnel_id uuid not null references proj.tunnels (id),

  -- 掘进方向：相对于里程增加方向
  advance_direction text not null
    check (
      advance_direction in (
        'increasing',
        'decreasing'
      )
    ),
  start_date date not null,
  end_date date,
  remark text,
  constraint chk_date_range check (
    end_date is null
    or end_date >= start_date
  )
);

-- 2. AUDIT FIELDS
alter table tbm.assignments
add column created_at timestamptz not null default now();

alter table tbm.assignments
add column updated_at timestamptz;

alter table tbm.assignments
add column created_by uuid references auth.users (id) on delete set null;

alter table tbm.assignments
add column updated_by uuid references auth.users (id) on delete set null;

create trigger trg_tbm_assignments_audit_insert
before insert on tbm.assignments for each row
execute function system.audit_insert ();

create trigger trg_tbm_assignments_audit_update
before update on tbm.assignments for each row
execute function system.audit_update ();

create trigger trg_tbm_assignments_audit_delete
before delete on tbm.assignments for each row
execute function system.audit_delete ();

-- 3. INDEXES

-- 当前唯一
create unique index uq_tbm_assignments_current
on tbm.assignments(tbm_code)
where end_date is null;

-- tbm 与 tunnel 唯一
create unique index uq_tbm_assignments_tunnel
on tbm.assignments(tbm_code,tunnel_id);

-- 防止时间重叠
alter table tbm.assignments
add constraint uq_tbm_assignments_no_overlap
exclude using gist (
  tbm_code with =,
  daterange(start_date, coalesce(end_date, 'infinity')) with &&
);


-- 开启实时订阅
alter publication supabase_realtime add table tbm.assignments;
-- DELETE 保留old 数据
alter table tbm.assignments replica identity full;


-- 4. TABLE PERMISSIONS
-- 撤销默认授权
revoke all on table tbm.assignments
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
delete on table tbm.assignments to authenticated;

-- 服务端角色读写
grant
select
,
  insert,
update,
delete on table tbm.assignments to service_role;

-- 启用 RLS
alter table tbm.assignments enable row level security;

-- 5. POLICIES
create policy "tbms_read" on tbm.assignments for
select
  to authenticated using (true);

create policy "tbms_insert_authorized" on tbm.assignments for insert to authenticated
with
  check (
    (
      select
        iam.has_permission ('tbm', 'write')
    )
  );

create policy "tbms_update_authorized" on tbm.assignments
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

create policy "tbms_delete_authorized" on tbm.assignments for delete to authenticated using (
  (
    select
      iam.has_permission ('tbm', 'delete')
  )
);

drop view tbm.v_tbm_assignments_list cascade;
create or replace view tbm.v_tbm_assignments_list
with (security_invoker = true)
as
select
  a.*,
  tt.name as tbm_name,
  ptu.name as tunnel_name,
  ptu.start_ring,
  ptu.end_ring,
  ptu.start_chainage,
  ptu.end_chainage,
  peu.full_name as section_name,
  pp.name as project_name

from tbm.assignments a
left join tbm.tbms tt
  on tt.code = a.tbm_code
left join proj.tunnels ptu
  on ptu.id = a.tunnel_id
left join proj.engineering_units peu  
  on peu.id=ptu.engineering_unit_id
left join proj.projects pp
  on pp.id = peu.project_id;

-- 允许 authenticated 使用 tbm schema
grant usage on schema tbm to authenticated;

-- 允许 authenticated 查询 View
grant select on tbm.v_tbm_assignments_list
to authenticated;


create or replace view tbm.v_current_assignments
with (security_invoker = true)
as
select
  a.id,
  a.tbm_code,
  a.tunnel_id,
  a.advance_direction,

  t.start_ring,
  t.end_ring,
  t.start_chainage,
  t.end_chainage

from tbm.assignments a

join proj.tunnels t
  on t.id = a.tunnel_id

where a.start_date <= current_date
  and a.end_date is null;

-- 允许 authenticated 使用 tbm schema
grant usage on schema tbm to authenticated;

-- 允许 authenticated 查询 View
grant select on tbm.v_current_assignments
to authenticated;


alter table tbm.parameter_alarms
add column tbm_code text
references tbm.tbms(code),
add column alert_severity_code text not null references master_data.dictionary_items (code);


-- 按设备查询历史告警
create index idx_parameter_alarms_tbm_started
on tbm.parameter_alarms(tbm_code, started_at desc);

-- 查询尚未恢复的告警
create index idx_parameter_alarms_active
on tbm.parameter_alarms(tbm_code, threshold_rule_id)
where ended_at is null;


drop table tbm.parameter_alarms cascade;



create table
    tbm.parameter_alarms (
      id bigint generated always as identity primary key,

      -- 告警所属设备
    tbm_code text not null   references tbm.tbms(code),

    -- 参数编码
    parameter_code text not null references tbm.parameters(code),

    -- 触发时的规则快照
    rule_snapshot jsonb not null,

    -- 告警级别
    severity_code text not null
    references master_data.dictionary_items(code),

    -- 告警数值
    alarm_value numeric not null,

    -- 告警发生时的施工信息
    ring_no integer,
    chainage numeric,


    -- 告警起止时间
    started_at timestamptz not null,
    ended_at timestamptz,
    -- 告警恢复时的数值
    recovery_value numeric,
    -- 审计
    created_at timestamptz not null default now (),
    updated_at timestamptz not null default now (),
    constraint chk_parameter_alarm_time check (
      ended_at is null
      or ended_at > started_at
    )
  );

-- 3. INDEXES
-- 按设备查询历史告警
create index idx_parameter_alarms_tbm_started
on tbm.parameter_alarms(tbm_code, started_at desc);

-- 查询尚未恢复的告警
create index idx_parameter_alarms_active
on tbm.parameter_alarms(tbm_code, parameter_code)
where ended_at is null;

create unique index uq_parameter_alarms_active
on tbm.parameter_alarms (tbm_code, parameter_code)
where ended_at is null;

-- 5. TABLE PERMISSIONS for tbm_parameter_alarms
revoke all on table tbm.parameter_alarms
from   public,  anon,  authenticated;

grant select,  insert,update,delete on table tbm.parameter_alarms to authenticated;

grant select, insert, update, delete on table tbm.parameter_alarms to service_role;

alter table tbm.parameter_alarms enable row level security;

create policy "parameter_alarms_read" on tbm.parameter_alarms for select  to authenticated using (true);

create policy "parameter_alarms_insert_authorized" on tbm.parameter_alarms for insert to authenticated
with
  check (
    (select iam.has_permission ('tbm', 'write'))
  );

create policy "parameter_alarms_update_authorized" on tbm.parameter_alarms for
update to authenticated using (
  ( select  iam.has_permission ('tbm', 'write'))
)
with
  check (
    (select iam.has_permission ('tbm', 'write'))
  );

create policy "parameter_alarms_delete_authorized" on tbm.parameter_alarms for delete to authenticated using (
  (select iam.has_permission ('tbm', 'delete'))
);


create or replace function tbm.upsert_parameter_alarm(
  p_tbm_code text,
  p_parameter_code text,
  p_severity_code text,
  p_alarm_value numeric,
  p_rule_snapshot jsonb,
  p_started_at timestamptz,
  p_ring_no integer default null,
  p_chainage numeric default null
)
returns void
language plpgsql
set search_path = ''
as $$
declare
  v_active tbm.parameter_alarms%rowtype;
begin
  -- 同一设备、同一参数的操作串行化
  perform pg_advisory_xact_lock(
    hashtextextended(
      p_tbm_code || ':' || p_parameter_code,
      0
    )
  );

  select *
  into v_active
  from tbm.parameter_alarms
  where tbm_code = p_tbm_code
    and parameter_code = p_parameter_code
    and ended_at is null
  for update;

  -- 已有相同级别的活动告警
  if found and v_active.severity_code = p_severity_code then
    return;
  end if;

  -- 级别变化：先关闭旧告警
  if v_active.id is not null then
    update tbm.parameter_alarms
    set
      ended_at = p_started_at,
      recovery_value = p_alarm_value,
      updated_at = now()
    where id = v_active.id;
  end if;

  -- 创建新告警
  insert into tbm.parameter_alarms (
    tbm_code,
    parameter_code,
    severity_code,
    alarm_value,
    rule_snapshot,
    ring_no,
    chainage,
    started_at
  )
  values (
    p_tbm_code,
    p_parameter_code,
    p_severity_code,
    p_alarm_value,
    p_rule_snapshot,
    p_ring_no,
    p_chainage,
    p_started_at
  );
end;
$$;


alter table tbm.ring_records
drop constraint uq_tbm_ring;

alter table tbm.ring_records
add constraint uq_tbm_ring unique (tunnel_id, ring_no);


create or replace function tbm.upsert_ring_record(
  p_tbm_code text,
  p_tunnel_id uuid,
  p_ring_no integer,
  p_chainage numeric,
  p_recorded_at timestamptz
)
returns void
language sql
as $$
  insert into tbm.ring_records (
    tbm_code,
    tunnel_id,
    ring_no,
    start_chainage,
    end_chainage,
    started_at,
    ended_at
  )
  values (
    p_tbm_code,
    p_tunnel_id,
    p_ring_no,
    p_chainage,
    p_chainage,
    p_recorded_at,
    p_recorded_at
  )
  on conflict (tunnel_id, ring_no)
  do update set
    end_chainage = excluded.end_chainage,
    ended_at = excluded.ended_at
  where
    tbm.ring_records.ended_at is null
    or excluded.ended_at > tbm.ring_records.ended_at;
$$;


alter table tbm.ring_records
drop constraint if exists chk_ring_time;

alter table tbm.ring_records
add constraint chk_ring_time
check (
  ended_at is null
  or ended_at >= started_at
);


alter table tbm.ring_phase_records
add column  updated_at timestamptz;

create trigger trg_tbm_ring_phase_recoreds_audit_update
before update on tbm.ring_phase_records
for each row
execute function system.touch_updated_at();


create trigger trg_tbm_ring_recoreds_audit_update
before update on tbm.ring_records
for each row
execute function system.touch_updated_at();


create table tbm.ring_phase_status (
  tbm_code text primary key
    references tbm.tbms(code) on delete restrict,

  ring_no integer not null,

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

  started_at timestamptz not null
);
alter table tbm.ring_phase_status
add column  tunnel_id uuid not null
    references proj.tunnels(id) on delete restrict;
    
create table tbm.ring_phase_records (
  id bigint generated always as identity primary key,

  tbm_code text not null
    references tbm.tbms(code) on delete restrict,

  tunnel_id uuid not null
    references proj.tunnels(id) on delete restrict,

  ring_no integer not null,

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
  ended_at timestamptz not null,

  constraint chk_ring_phase_time
    check (ended_at >= started_at)
);


