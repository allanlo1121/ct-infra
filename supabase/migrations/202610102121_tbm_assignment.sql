-- ==============================
-- 2060 TBM ASSIGNMENTS TABLES
-- ==============================
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


