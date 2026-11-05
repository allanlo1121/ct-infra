drop table proj.tunnel_risks cascade;
create table proj.tunnel_risks (
  id uuid primary key default gen_random_uuid(),

  tunnel_id uuid not null
    references proj.tunnels(id)
    on delete cascade,

  name text not null,
  description text,
  risk_level integer not null,

  start_chainage numeric not null,
  end_chainage numeric not null,

  latitude numeric(10,6),
  longitude numeric(10,6),

  is_disabled boolean not null default false,

  created_at timestamptz not null default now(),
  updated_at timestamptz,

 
  created_by uuid
    references auth.users(id)
    on delete set null,

  updated_by uuid
    references auth.users(id)
    on delete set null,

  constraint chk_tunnel_risk_chainage
    check (start_chainage <= end_chainage)
);


create trigger trg_tunnel_risks_audit_insert
before insert on proj.tunnel_risks
for each row
execute function system.audit_insert();

create trigger trg_tunnel_risks_audit_update
before update on proj.tunnel_risks
for each row
execute function system.audit_update();

create trigger trg_tunnel_risks_audit_delete
before delete on proj.tunnel_risks
for each row
execute function system.audit_delete();

-- 3. INDEXES
-- 加速查询直属子机构
create index idx_tunnel_risks_tunnel_id
  on proj.tunnel_risks(tunnel_id);

-- 4. TABLE PERMISSIONS

-- 撤销默认授权
revoke all on table proj.tunnel_risks
from public, anon, authenticated;

-- 登录用户基本 CRUD 权限
grant select, insert, update, delete
on table proj.tunnel_risks
to authenticated;

-- 服务端角色读写
grant select, insert, update, delete
on table proj.tunnel_risks
to service_role;

-- 启用 RLS
alter table proj.tunnel_risks
enable row level security;




-- 5. POLICIES



create policy "tunnel_risks_read"
on proj.tunnel_risks
for select
to authenticated
using (true);


create policy "tunnel_risks_insert_authorized"
on proj.tunnel_risks
for insert
to authenticated
with check (
  (select iam.has_permission('proj','write')) 
);

create policy "tunnel_risks_update_authorized"
on proj.tunnel_risks
for update
to authenticated
using (
  (select iam.has_permission('proj','write'))
)
with check (
  (select iam.has_permission('proj','write')) 
);

create policy "tunnel_risks_delete_authorized"
on proj.tunnel_risks
for delete
to authenticated
using (
  (select iam.has_permission('proj','delete')) 
);



alter table equip.devices
add column is_disabled boolean not null default false;


-- 1. 移除 serial 原来的默认值
alter table tbm.tbm_parameters
  alter column id drop default;

-- 2. 删除旧序列（确认没有其他对象依赖）
drop sequence if exists tbm.tbm_parameters_id_seq;

-- 3. 改成 Identity 自增列
alter table tbm.tbm_parameters
  alter column id add generated always as identity;