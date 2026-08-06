do $$
begin
  if not exists (
    select 1
    from pg_roles
    where rolname = 'emqx_user'
  ) then
    create role emqx_user
      with login
      password 'CHANGE_ME_STRONG_PASSWORD';
  end if;
end
$$;

grant usage on schema eqp to emqx_user;

grant select on table eqp.mqtt_user to emqx_user;
grant select on table eqp.mqtt_acl to emqx_user;

alter default privileges in schema eqp
grant select on tables to emqx_user;



-- =========================================================
-- TBM WRITER
-- =========================================================

do $$
begin

  if not exists (
    select 1
    from pg_roles
    where rolname = 'tbm_writer'
  ) then

    create role tbm_writer
      with login
      password 'CHANGE_ME_STRONG_PASSWORD';

  end if;

end
$$;

grant usage
on schema eqp
to tbm_writer;

grant insert
on all tables in schema eqp
to tbm_writer;

alter default privileges in schema eqp
grant insert on tables to tbm_writer;