-- ==============================
-- 3010  MQTT TABLES
-- ==============================
-- 1. TABLE
create table mqtt.users (
  id integer generated always as identity primary key,
  username text not null unique,
  password_hash text not null,
  salt text not null,
  is_superuser boolean not null default false,
  sort_order integer not null default 0,
  is_disabled boolean not null default false
);

comment on table mqtt.users is 'MQTT用户';



-- 2. AUDIT FIELDS
alter table mqtt.users
add column created_at timestamptz not null default now();

alter table mqtt.users
add column updated_at timestamptz;

alter table mqtt.users
add column created_by uuid references auth.users (id) on delete set null;

alter table mqtt.users
add column updated_by uuid references auth.users (id) on delete set null;

create trigger trg_mqtt_users_audit_insert
before insert on mqtt.users for each row
execute function system.audit_insert ();

create trigger trg_mqtt_users_audit_update
before update on mqtt.users for each row
execute function system.audit_update ();

create trigger trg_mqtt_users_audit_delete
before delete on mqtt.users for each row
execute function system.audit_delete ();

-- 3. INDEXES


-- 4. TABLE PERMISSIONS
-- 撤销默认授权
revoke all on table mqtt.users
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
delete on table mqtt.users to authenticated;
-- 服务端角色读写
grant
select
,
  insert,
update,
delete on table mqtt.users to service_role;

-- 启用 RLS
alter table mqtt.users enable row level security;

-- 5. POLICIES
create policy "mqtt_users_read" on mqtt.users for
select
  to authenticated using (true);

create policy "mqtt_users_insert_authorized" on mqtt.users for insert to authenticated
with
  check (
    (
      select
        iam.has_permission ('mqtt', 'write')
    )
  );

create policy "mqtt_users_update_authorized" on mqtt.users
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

create policy "mqtt_users_delete_authorized" on mqtt.users for delete to authenticated using (
  (
    select
      iam.has_permission ('mqtt', 'delete')
  )
);
