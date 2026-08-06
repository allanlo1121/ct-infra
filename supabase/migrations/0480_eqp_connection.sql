-- =========================================================
-- MQTT USERS
-- =========================================================

create table eqp.mqtt_user (

    id uuid primary key default gen_random_uuid(),

    user_type text not null
    check (
        user_type in (
            'tbm',
            'platform',
            'monitor',
            'service'
        )
    ),

    tbm_id uuid
        references tbm.tbms(id),

    username text not null unique,

    password_hash text not null,

    salt text not null,

    is_superuser boolean not null default false,

    topic_prefix text not null,

    is_enabled boolean not null default true,

    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),

    check (
        (
            user_type = 'tbm'
            and tbm_id is not null
        )
        or
        (
            user_type <> 'tbm'
            and tbm_id is null
        )
    )
);

comment on table eqp.mqtt_user
is 'MQTT用户';

-- =========================================================
-- MQTT ACL
-- =========================================================

create table eqp.mqtt_acl (

    id uuid primary key default gen_random_uuid(),

    username text not null
        references eqp.mqtt_user(username)
        on delete cascade,

    permission text not null
    check (
        permission in (
            'allow',
            'deny'
        )
    ),

    action text not null
    check (
        action in (
            'publish',
            'subscribe',
            'all'
        )
    ),

    topic text not null
);

comment on table eqp.mqtt_acl
is 'MQTT ACL';



create table eqp.mqtt_user_status (

    mqtt_user_id uuid primary key
        references eqp.mqtt_user(id),

    -- 当前连接client
    client_id text,

    -- 是否在线
    is_online boolean not null default false,

    -- 最近一次连接时间
    connected_at timestamptz,

    -- 最近一次心跳
    last_seen_at timestamptz,

    -- 最近一次断开时间
    disconnected_at timestamptz,

    -- 最近一次断开原因
    disconnect_reason text,

    -- 最近连接IP
    remote_ip inet,

    -- 当前session
    session_id text,

    updated_at timestamptz not null default now()
);

create table eqp.mqtt_connection_sessions (
  id uuid primary key default gen_random_uuid(),

  mqtt_user_id uuid not null
    references eqp.mqtt_user(id),

  client_id text,
  connected_at timestamptz not null default now(),
  disconnected_at timestamptz,
  disconnect_reason text,

  remote_ip inet,
  session_id text
);

create or replace function eqp.sync_mqtt_connection_sessions()
returns trigger
language plpgsql
as $$
begin

  -- offline -> online
  if
    old.is_online = false
    and new.is_online = true
  then

    insert into eqp.mqtt_connection_sessions (
      mqtt_user_id,
      client_id,
      connected_at,
      remote_ip,
      session_id
    )
    values (
      new.mqtt_user_id,
      new.client_id,
      coalesce(new.connected_at, now()),
      new.remote_ip,
      new.session_id
    );

  end if;

  -- online -> offline
  if
    old.is_online = true
    and new.is_online = false
  then

    update eqp.mqtt_connection_sessions
    set
      disconnected_at = coalesce(new.disconnected_at, now()),
      disconnect_reason = new.disconnect_reason
    where mqtt_user_id = new.mqtt_user_id
      and disconnected_at is null;

  end if;

  return new;

end;
$$;

create or replace view eqp.v_mqtt_users as
select
    mu.id,
    mu.tbm_id,
    mu.username,
    mu.user_type,
    mu.topic_prefix,
    mu.is_superuser,
    mu.is_enabled,
    mu.created_at,
    mu.updated_at,

    mus.client_id,
    coalesce(mus.is_online, false) as is_online,
    mus.connected_at,
    mus.last_seen_at,
    mus.disconnected_at,
    mus.disconnect_reason,
    mus.remote_ip,
    mus.session_id,

    last_session.connected_at as last_connected_at,
    last_session.disconnected_at as last_disconnected_at,
    last_session.disconnect_reason as last_disconnect_reason,

    coalesce(
        jsonb_agg(
            jsonb_build_object(
                'id', ma.id,
                'permission', ma.permission,
                'action', ma.action,
                'topic', ma.topic
            )
            order by ma.id
        ) filter (where ma.id is not null),
        '[]'::jsonb
    ) as acl

from eqp.mqtt_user mu

left join eqp.mqtt_user_status mus
    on mus.mqtt_user_id = mu.id

left join lateral (
    select
        s.connected_at,
        s.disconnected_at,
        s.disconnect_reason
    from eqp.mqtt_connection_sessions s
    where s.mqtt_user_id = mu.id
    order by s.connected_at desc
    limit 1
) last_session on true

left join eqp.mqtt_acl ma
    on ma.username = mu.username

group by
    mu.id,
    mu.tbm_id,
    mu.username,
    mu.user_type,
    mu.topic_prefix,
    mu.is_superuser,
    mu.is_enabled,
    mu.created_at,
    mu.updated_at,

    mus.client_id,
    mus.is_online,
    mus.connected_at,
    mus.last_seen_at,
    mus.disconnected_at,
    mus.disconnect_reason,
    mus.remote_ip,
    mus.session_id,

    last_session.connected_at,
    last_session.disconnected_at,
    last_session.disconnect_reason;




create table tbm.tbm_connection_status (
  tbm_id uuid not null references tbm.tbms(id),

  type text not null check (
    type in ('heartbeat', 'realdata')
  ),

  last_seen_at timestamptz not null,

  is_online boolean not null default false,

  updated_at timestamptz not null default now(),

  primary key (tbm_id, type)
);



create table tbm.tbm_connection_status_history (
  id uuid primary key default gen_random_uuid(),

  tbm_id uuid not null references tbm.tbms(id),

  type text not null check (
    type in ('heartbeat', 'realdata')
  ),

  status text not null check (
    status in ('online', 'offline')
  ),

  start_at timestamptz not null,
  end_at timestamptz,

  source text not null default 'auto',
  remark text,

  created_at timestamptz not null default now(),

  constraint tbm_connection_status_history_time_check
    check (
      end_at is null
      or end_at > start_at
    )
);



