-- ==============================
-- 1140 PROJ.TUNNEL SUBTABLES
-- ==============================
-- 1. TABLE
create table
  proj.tunnel_segments (
    id uuid primary key default gen_random_uuid (),
    -- 树形结构
    tunnel_id uuid not null references proj.tunnels (id) on delete restrict,
    -- 基本信息
    name text not null,
    start_ring integer not null,
    end_ring integer not null,
    -- 管片内径
    inner_diameter numeric(8, 3),
    -- 管片外径
    outer_diameter numeric(8, 3),
    -- 管片宽度
    ring_width numeric(8, 3),
    -- 管片厚度
    ring_thickness numeric(8, 3),
    sort_order integer not null default 0,
    is_disabled boolean not null default false
  );

-- 2. AUDIT FIELDS
alter table proj.tunnel_segments
add column created_at timestamptz not null default now ();

alter table proj.tunnel_segments
add column updated_at timestamptz;

alter table proj.tunnel_segments
add column created_by uuid references auth.users (id) on delete set null;

alter table proj.tunnel_segments
add column updated_by uuid references auth.users (id) on delete set null;

create trigger trg_tunnel_segments_audit_insert before insert on proj.tunnel_segments for each row execute function system.audit_insert ();

create trigger trg_tunnel_segments_audit_update before
update on proj.tunnel_segments for each row execute function system.audit_update ();

create trigger trg_tunnel_segments_audit_delete before delete on proj.tunnel_segments for each row execute function system.audit_delete ();

-- 3. INDEXES
-- 加速查询直属子机构
create index idx_tunnel_segments_tunnel_id on proj.tunnel_segments (tunnel_id);

-- 4. TABLE PERMISSIONS
-- 撤销默认授权
revoke all on table proj.tunnel_segments
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
delete on table proj.tunnel_segments to authenticated;

-- 服务端角色读写
grant
select
,
  insert,
update,
delete on table proj.tunnel_segments to service_role;

-- 启用 RLS
alter table proj.tunnel_segments enable row level security;

-- 5. POLICIES
create policy "tunnel_segments_read" on proj.tunnel_segments for
select
  to authenticated using (true);

create policy "tunnel_segments_insert_authorized" on proj.tunnel_segments for insert to authenticated
with
  check (
    (
      select
        iam.has_permission ('proj', 'write')
    )
  );

create policy "tunnel_segments_update_authorized" on proj.tunnel_segments for
update to authenticated using (
  (
    select
      iam.has_permission ('proj', 'write')
  )
)
with
  check (
    (
      select
        iam.has_permission ('proj', 'write')
    )
  );

create policy "tunnel_segments_delete_authorized" on proj.tunnel_segments for delete to authenticated using (
  (
    select
      iam.has_permission ('proj', 'delete')
  )
);

create table
  proj.tunnel_plans (
    id serial primary key,
    tunnel_id uuid not null references proj.tunnels (id) on delete cascade,
    plan_name text not null,
    status text not null,
    version integer not null default 1,
    remark text
  );

-- 2. AUDIT FIELDS
alter table proj.tunnel_plans
add column created_at timestamptz not null default now ();

alter table proj.tunnel_plans
add column updated_at timestamptz;

alter table proj.tunnel_plans
add column created_by uuid references auth.users (id) on delete set null;

alter table proj.tunnel_plans
add column updated_by uuid references auth.users (id) on delete set null;

create trigger trg_tunnel_plans_audit_insert before insert on proj.tunnel_plans for each row execute function system.audit_insert ();

create trigger trg_tunnel_plans_audit_update before
update on proj.tunnel_plans for each row execute function system.audit_update ();

create trigger trg_tunnel_plans_audit_delete before delete on proj.tunnel_plans for each row execute function system.audit_delete ();

-- 3. INDEXES
-- 加速查询直属子机构
create index idx_tunnel_plans_tunnel_id on proj.tunnel_plans (tunnel_id);

-- 4. TABLE PERMISSIONS
-- 撤销默认授权
revoke all on table proj.tunnel_plans
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
delete on table proj.tunnel_plans to authenticated;

-- 服务端角色读写
grant
select
,
  insert,
update,
delete on table proj.tunnel_plans to service_role;

-- 启用 RLS
alter table proj.tunnel_plans enable row level security;

-- 5. POLICIES
create policy "tunnel_plans_read" on proj.tunnel_plans for
select
  to authenticated using (true);

create policy "tunnel_plans_insert_authorized" on proj.tunnel_plans for insert to authenticated
with
  check (
    (
      select
        iam.has_permission ('proj', 'write')
    )
  );

create policy "tunnel_plans_update_authorized" on proj.tunnel_plans for
update to authenticated using (
  (
    select
      iam.has_permission ('proj', 'write')
  )
)
with
  check (
    (
      select
        iam.has_permission ('proj', 'write')
    )
  );

create policy "tunnel_plans_delete_authorized" on proj.tunnel_plans for delete to authenticated using (
  (
    select
      iam.has_permission ('proj', 'delete')
  )
);

create table
  proj.tunnel_plan_days (
    id serial primary key,
    plan_id int not null references proj.tunnel_plans (id) on delete cascade,
    work_date date,
    plan_advance_meter numeric,
    plan_ring_count int not null,
    remark text
  );

alter table proj.tunnel_plan_days
add column created_at timestamptz not null default now ();

alter table proj.tunnel_plan_days
add column updated_at timestamptz;

alter table proj.tunnel_plan_days
add column created_by uuid references auth.users (id) on delete set null;

alter table proj.tunnel_plan_days
add column updated_by uuid references auth.users (id) on delete set null;

create trigger trg_tunnel_plan_days_audit_insert before insert on proj.tunnel_plan_days for each row execute function system.audit_insert ();

create trigger trg_tunnel_plan_days_audit_update before
update on proj.tunnel_plan_days for each row execute function system.audit_update ();

create trigger trg_tunnel_plan_days_audit_delete before delete on proj.tunnel_plan_days for each row execute function system.audit_delete ();

-- 启用 RLS
alter table proj.tunnel_plan_days enable row level security;

-- 5. POLICIES
create policy "tunnel_plan_days_read" on proj.tunnel_plan_days for
select
  to authenticated using (true);

create policy "tunnel_plan_days_insert_authorized" on proj.tunnel_plan_days for insert to authenticated
with
  check (
    (
      select
        iam.has_permission ('proj', 'write')
    )
  );

create policy "tunnel_plan_days_update_authorized" on proj.tunnel_plan_days for
update to authenticated using (
  (
    select
      iam.has_permission ('proj', 'write')
  )
)
with
  check (
    (
      select
        iam.has_permission ('proj', 'write')
    )
  );

create policy "tunnel_plan_days_delete_authorized" on proj.tunnel_plan_days for delete to authenticated using (
  (
    select
      iam.has_permission ('proj', 'delete')
  )
);

create table
  proj.tunnel_risks (
    id uuid primary key default gen_random_uuid (),
    tunnel_id uuid not null references proj.tunnels(id) on delete cascade,
    name text not null,
    description text,
    -- 风险等级 5002
    risk_level_code text not null references  master_data.dictionary_items (code) on delete restrict,
    start_chainage numeric not null,
    end_chainage numeric not null,
    latitude numeric(10, 6),
    longitude numeric(10, 6),
    is_disabled boolean not null default false,
    created_at timestamptz not null default now (),
    updated_at timestamptz,
    created_by uuid references auth.users (id) on delete set null,
    updated_by uuid references auth.users (id) on delete set null,
    constraint chk_tunnel_risk_chainage check (start_chainage <= end_chainage)
  );

create trigger trg_tunnel_risks_audit_insert before insert on proj.tunnel_risks for each row execute function system.audit_insert ();

create trigger trg_tunnel_risks_audit_update before
update on proj.tunnel_risks for each row execute function system.audit_update ();

create trigger trg_tunnel_risks_audit_delete before delete on proj.tunnel_risks for each row execute function system.audit_delete ();

-- 3. INDEXES
-- 加速查询直属子机构
create index idx_tunnel_risks_tunnel_id on proj.tunnel_risks (tunnel_id);

-- 4. TABLE PERMISSIONS
-- 撤销默认授权
revoke all on table proj.tunnel_risks
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
delete on table proj.tunnel_risks to authenticated;

-- 服务端角色读写
grant
select
,
  insert,
update,
delete on table proj.tunnel_risks to service_role;

-- 启用 RLS
alter table proj.tunnel_risks enable row level security;

-- 5. POLICIES
create policy "tunnel_risks_read" on proj.tunnel_risks for
select
  to authenticated using (true);

create policy "tunnel_risks_insert_authorized" on proj.tunnel_risks for insert to authenticated
with
  check (
    (
      select
        iam.has_permission ('proj', 'write')
    )
  );

create policy "tunnel_risks_update_authorized" on proj.tunnel_risks for
update to authenticated using (
  (
    select
      iam.has_permission ('proj', 'write')
  )
)
with
  check (
    (
      select
        iam.has_permission ('proj', 'write')
    )
  );

create policy "tunnel_risks_delete_authorized" on proj.tunnel_risks for delete to authenticated using (
  (
    select
      iam.has_permission ('proj', 'delete')
  )
);