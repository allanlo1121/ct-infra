-- ==============================
-- 1140 PROJ.TUNNEL TABLES
-- ==============================
-- 1. TABLE
create table proj.tunnels (
  id uuid primary key default gen_random_uuid(),
  -- 所属工点
  engineering_unit_id uuid not null references proj.engineering_units (id) on delete restrict,
  -- 基本信息
  name text not null,
  full_name text,
  overview text,
  -- 里程前缀
  chainage_prefix text not null default 'DK',
  -- 起点里程（m）
  start_chainage numeric(12, 3) not null,
  -- 终点里程（m）
  end_chainage numeric(12, 3) not null,
  -- 长短链调整（m）
  -- 正数：长链；负数：短链
  chainage_adjustment numeric(12, 3) not null default 0,
  start_ring integer not null,
  end_ring integer not null,
  -- 设计开挖直径（m）
  excavation_diameter numeric(8, 3),
  -- 通用字段
  sort_order integer not null default 0,
  is_disabled boolean not null default false,
  -- 约束
  constraint tunnels_engineering_unit_name_unique unique (engineering_unit_id, name),
  constraint tunnels_excavation_diameter_positive check (
    excavation_diameter is null
    or excavation_diameter > 0
  )
);

-- 2. AUDIT FIELDS
alter table proj.tunnels
add column created_at timestamptz not null default now();

alter table proj.tunnels
add column updated_at timestamptz;

alter table proj.tunnels
add column created_by uuid references auth.users (id) on delete set null;

alter table proj.tunnels
add column updated_by uuid references auth.users (id) on delete set null;

create trigger trg_tunnels_audit_insert
before insert on proj.tunnels for each row
execute function system.audit_insert ();

create trigger trg_tunnels_audit_update
before update on proj.tunnels for each row
execute function system.audit_update ();

create trigger trg_tunnels_audit_delete
before delete on proj.tunnels for each row
execute function system.audit_delete ();

-- 3. INDEXES
-- 加速查询直属子机构
create index idx_tunnels_engineering_unit_id on proj.tunnels (engineering_unit_id);

-- 4. TABLE PERMISSIONS
-- 撤销默认授权
revoke all on table proj.tunnels
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
delete on table proj.tunnels to authenticated;

-- 服务端角色读写
grant
select
,
  insert,
update,
delete on table proj.tunnels to service_role;

-- 启用 RLS
alter table proj.tunnels enable row level security;

-- 5. POLICIES
create policy "tunnels_read" on proj.tunnels for
select
  to authenticated using (true);

create policy "tunnels_insert_authorized" on proj.tunnels for insert to authenticated
with
  check (
    (
      select
        iam.has_permission ('proj', 'write')
    )
  );

create policy "tunnels_update_authorized" on proj.tunnels
for update
  to authenticated using (
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

create policy "tunnels_delete_authorized" on proj.tunnels for delete to authenticated using (
  (
    select
      iam.has_permission ('proj', 'delete')
  )
);