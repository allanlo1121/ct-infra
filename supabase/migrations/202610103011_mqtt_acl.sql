-- ==============================
-- 3010  MQTT TABLES
-- ==============================
-- 1. TABLE
create table mqtt.acl (
  id integer generated always as identity primary key,
  username text not null references mqtt.users (username) on update cascade on delete cascade,
  permission text not null check (permission in ('allow', 'deny')),
  action text not null check (action in ('publish', 'subscribe', 'all')),
  topic text not null,
  sort_order integer not null default 0,
  is_disabled boolean not null default false,
  constraint uq_mqtt_acl unique (username, permission, action, topic)
);

comment on table mqtt.acl is 'MQTT ACL';

-- 2. AUDIT FIELDS
alter table mqtt.acl
add column created_at timestamptz not null default now();

alter table mqtt.acl
add column updated_at timestamptz;

alter table mqtt.acl
add column created_by uuid references auth.users (id) on delete set null;

alter table mqtt.acl
add column updated_by uuid references auth.users (id) on delete set null;

create trigger trg_mqtt_acl_audit_insert
before insert on mqtt.acl for each row
execute function system.audit_insert ();

create trigger trg_mqtt_acl_audit_update
before update on mqtt.acl for each row
execute function system.audit_update ();

create trigger trg_mqtt_acl_audit_delete
before delete on mqtt.acl for each row
execute function system.audit_delete ();

-- 3. INDEXES
-- MQTT ACL 用户索引
create index idx_mqtt_acl_username on mqtt.acl (username);

-- 4. TABLE PERMISSIONS
-- 撤销默认授权
revoke all on table mqtt.acl
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
update,
delete on table mqtt.acl to authenticated;

-- 服务端角色读写
grant
select
,
  insert,
update,
delete on table mqtt.acl to service_role;

-- 启用 RLS
alter table mqtt.acl enable row level security;

-- 5. POLICIES
create policy "mqtt_acl_read" on mqtt.acl for
select
  to authenticated using (true);

create policy "mqtt_acl_insert_authorized" on mqtt.acl for insert to authenticated
with
  check (
    (
      select
        iam.has_permission ('mqtt', 'write')
    )
  );

create policy "mqtt_acl_update_authorized" on mqtt.acl
for update
  to authenticated using (
    (
      select
        iam.has_permission ('mqtt', 'write')
    )
  )
with
  check (
    (
      select
        iam.has_permission ('mqtt', 'write')
    )
  );

create policy "mqtt_acl_delete_authorized" on mqtt.acl for delete to authenticated using (
  (
    select
      iam.has_permission ('mqtt', 'delete')
  )
);
