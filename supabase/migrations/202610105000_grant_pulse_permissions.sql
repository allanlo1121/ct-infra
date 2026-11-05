-- 创建 Pulse 专用数据库角色
create role ct_pulse
with login password 'Ctgs2026';

-- Schema 访问权限
grant usage on schema tbm, proj to ct_pulse;

-- =========================================
-- 1. 基础数据：只读
-- =========================================
grant select on
    tbm.tbms,
    tbm.tbm_parameters,
    tbm.tbm_parameter_threshold_rules,
    proj.tunnel_risks
to ct_pulse;

-- =========================================
-- 2. 当前状态：读取、新增、更新
-- =========================================
grant select, insert, update on
    tbm.connection_status,
    tbm.ring_phase_records
to ct_pulse;

-- =========================================
-- 3. 报警记录：读取、新增、更新
-- =========================================
grant select, insert, update on
    tbm.parameter_alarms
to ct_pulse;


-- mqtt 数据库用户

do $$
begin
  if not exists (
    select 1
    from pg_roles
    where rolname = 'emqx_user'
  ) then
    create role emqx_user
      with login
      password 'Ctgs2026';
  end if;
end
$$;

grant usage on schema mqtt to emqx_user;

grant select on table mqtt.users to emqx_user;
grant select on table mqtt.acl to emqx_user;

alter default privileges in schema tbm
grant select on tables to emqx_user;

create policy mqtt_users_read_emqx
on mqtt.users
for select
to emqx_user
using (true);

create policy mqtt_acl_read_emqx
on mqtt.acl
for select
to emqx_user
using (true);