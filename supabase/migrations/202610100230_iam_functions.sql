
create or replace function iam.get_current_auth_context()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(

    -- 当前用户
    'user', jsonb_build_object(
      'userId', u.id,
      'email', u.email,
      'displayName', coalesce(up.display_name, ''),
      'avatarUrl', up.avatar_path
    ),

    -- 当前用户角色
    'roles', coalesce(
      (
        select jsonb_agg(distinct r.code)
        from iam.user_roles ur
        join iam.roles r
          on r.id = ur.role_id
        where ur.user_id = u.id
          and r.is_disabled = false
      ),
      '[]'::jsonb
    ),

    -- 当前用户权限
    'permissions', coalesce(
      (
        select jsonb_agg(
          distinct jsonb_build_object(
            'module', p.module,
            'action', p.action
          )
        )
        from iam.user_roles ur
        join iam.roles r
          on r.id = ur.role_id
        join iam.role_permissions rp
          on rp.role_id = r.id
        join iam.permissions p
          on p.id = rp.permission_id
        where ur.user_id = u.id
          and r.is_disabled = false
          and p.is_disabled = false
      ),
      '[]'::jsonb
    )

  )
  from auth.users u
  left join iam.user_profiles up
    on up.user_id = u.id
  where u.id = (select auth.uid());
$$;


create or replace function iam.has_permission(
  p_module iam.permission_module,
  p_action iam.permission_action
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select
    exists (
      select 1
      from iam.user_roles ur
      join iam.roles r
        on r.id = ur.role_id
      where ur.user_id = (select auth.uid())
        and r.is_disabled = false
        and r.code = 'SUPER_ADMIN'
    )
    or
    exists (
      select 1
      from iam.user_roles ur
      join iam.roles r
        on r.id = ur.role_id
      join iam.role_permissions rp
        on rp.role_id = r.id
      join iam.permissions p
        on p.id = rp.permission_id
      where ur.user_id = (select auth.uid())
        and r.is_disabled = false
        and p.is_disabled = false
        and p.module = p_module
        and p.action = p_action
    );
$$;

