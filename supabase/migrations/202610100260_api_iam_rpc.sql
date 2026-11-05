

-- =====================================================
-- API FUNCTION
-- =====================================================

create or replace function api.get_current_auth_context()
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select iam.get_current_auth_context();
$$;


create or replace function api.list_users(
  p_page integer default 1,
  p_page_size integer default 20,
  p_keyword text default null,
  p_role_id uuid default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_offset integer;
  v_keyword text;
  v_total bigint;
  v_items jsonb;
begin

  -- =========================================
  -- 1. 权限检查
  -- =========================================

  if auth.uid() is null
     or not coalesce(iam.has_permission('iam', 'read'), false)
  then
    raise exception '没有查看用户的权限'
      using errcode = '42501';
  end if;


  -- =========================================
  -- 2. 分页参数检查
  -- =========================================

  if p_page is null
     or p_page < 1
     or p_page_size is null
     or p_page_size < 1
     or p_page_size > 100
  then
    raise exception '无效的分页参数'
      using errcode = '22023';
  end if;

  if (p_page::bigint - 1) * p_page_size > 2147483647 then
    raise exception '分页偏移量超出范围'
      using errcode = '22023';
  end if;

  v_offset := (p_page - 1) * p_page_size;

  v_keyword := nullif(trim(p_keyword), '');


  -- =========================================
  -- 3. 查询总记录数
  -- =========================================

  select count(*)
  into v_total
  from auth.users u

  left join iam.user_profiles p
    on p.user_id = u.id

  where
    (
      v_keyword is null
      or u.email ilike '%' || v_keyword || '%'
      or p.display_name ilike '%' || v_keyword || '%'
    )

    and (
      p_role_id is null
      or exists (
        select 1
        from iam.user_roles ur
        join iam.roles r
          on r.id = ur.role_id
        where ur.user_id = u.id
          and ur.role_id = p_role_id
          and r.is_disabled = false
      )
    );


  -- =========================================
  -- 4. 查询分页用户及角色
  -- =========================================

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'id', t.id,
        'email', t.email,
        'displayName', t.display_name,
        'avatarPath', t.avatar_path,
        'createdAt', t.created_at,
        'lastSignInAt', t.last_sign_in_at,
        'roles', t.roles
      )
      order by t.created_at desc, t.id
    ),
    '[]'::jsonb
  )
  into v_items

  from (
    select
      u.id,
      u.email,
      p.display_name,
      p.avatar_path,
      u.created_at,
      u.last_sign_in_at,

      coalesce(
        (
          select jsonb_agg(
            jsonb_build_object(
              'id', r.id,
              'code', r.code,
              'name', r.name
            )
            order by r.sort_order, r.code
          )
          from iam.user_roles ur
          join iam.roles r
            on r.id = ur.role_id
          where ur.user_id = u.id
            and r.is_disabled = false
        ),
        '[]'::jsonb
      ) as roles

    from auth.users u

    left join iam.user_profiles p
      on p.user_id = u.id

    where
      (
        v_keyword is null
        or u.email ilike '%' || v_keyword || '%'
        or p.display_name ilike '%' || v_keyword || '%'
      )

      and (
        p_role_id is null
        or exists (
          select 1
          from iam.user_roles ur
          join iam.roles r
            on r.id = ur.role_id
          where ur.user_id = u.id
            and ur.role_id = p_role_id
            and r.is_disabled = false
        )
      )

    order by u.created_at desc, u.id
    limit p_page_size
    offset v_offset

  ) t;


  -- =========================================
  -- 5. 返回结果
  -- =========================================

  return jsonb_build_object(
    'items', v_items,
    'total', v_total
  );

end;
$$;

-- =========================================
-- 6. RPC 执行权限
-- =========================================

revoke all
on function api.list_users(integer, integer, text, uuid)
from public, anon, authenticated;

grant execute
on function api.list_users(integer, integer, text, uuid)
to authenticated;


create or replace function api.sync_user_roles(
  p_user_id uuid,
  p_role_ids uuid[]
)
returns void
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_role_ids uuid[];
  v_super_admin_id uuid;
  v_is_super_admin boolean;
  v_target_is_super_admin boolean;
  v_assign_super_admin boolean;
begin

  -- 1. 权限检查
  if not iam.has_permission('iam', 'write') then
    raise exception '没有修改用户角色的权限'
      using errcode = '42501';
  end if;

  if p_user_id is null or p_role_ids is null then
    raise exception '用户ID或角色列表不能为空'
      using errcode = '22023';
  end if;

  -- 串行化通过此函数进行的角色变更，避免并发撤销最后一个超级管理员
  perform pg_catalog.pg_advisory_xact_lock(86240101::bigint);

  -- 2. 确认用户存在
  if not exists (
    select 1
    from auth.users
    where id = p_user_id
  ) then
    raise exception '用户不存在'
      using errcode = 'P0002';
  end if;

  -- 3. 角色ID去重
  select coalesce(array_agg(distinct role_id), array[]::uuid[])
  into v_role_ids
  from unnest(p_role_ids) as t(role_id)
  where role_id is not null;

  -- 4. 验证角色是否全部有效
  if (
    select count(*)
    from iam.roles
    where id = any(v_role_ids)
      and is_disabled = false
  ) <> cardinality(v_role_ids) then
    raise exception '存在无效或已禁用的角色'
      using errcode = '22023';
  end if;

  -- 5. 获取超级管理员角色
  select id
  into v_super_admin_id
  from iam.roles
  where code = 'SUPER_ADMIN'
    and is_disabled = false;

  -- 6. 判断操作者是否为超级管理员
  select exists (
    select 1
    from iam.user_roles ur
    join iam.roles r on r.id = ur.role_id
    where ur.user_id = (select auth.uid())
      and r.code = 'SUPER_ADMIN'
      and r.is_disabled = false
  )
  into v_is_super_admin;

  -- 7. 判断目标用户当前是否为超级管理员
  select exists (
    select 1
    from iam.user_roles
    where user_id = p_user_id
      and role_id = v_super_admin_id
  )
  into v_target_is_super_admin;

  v_assign_super_admin :=
    coalesce(v_super_admin_id = any(v_role_ids), false);

  -- 8. 保护超级管理员角色
  if not v_is_super_admin
     and (v_target_is_super_admin or v_assign_super_admin) then
    raise exception '只有超级管理员可以修改超级管理员角色'
      using errcode = '42501';
  end if;

  -- 9. 禁止撤销最后一个超级管理员
  if v_target_is_super_admin
     and not v_assign_super_admin
     and (
       select count(distinct ur.user_id)
       from iam.user_roles ur
       where ur.role_id = v_super_admin_id
     ) <= 1 then
    raise exception '不能撤销最后一个超级管理员'
      using errcode = '23514';
  end if;

  -- 10. 删除未选中的角色
  delete from iam.user_roles
  where user_id = p_user_id
    and not (role_id = any(v_role_ids));

  -- 11. 新增选中的角色（忽略已有关系）
  insert into iam.user_roles (
    user_id,
    role_id
  )
  select
    p_user_id,
    role_id
  from unnest(v_role_ids) as t(role_id)
  on conflict (user_id, role_id) do nothing;

end;
$$;


revoke all
on function api.sync_user_roles(uuid, uuid[])
from public, anon, authenticated;

grant execute
on function api.sync_user_roles(uuid, uuid[])
to authenticated;


-- =====================================================
-- SYNC ROLE PERMISSIONS
-- =====================================================

create or replace function api.sync_role_permissions(
  p_role_id uuid,
  p_permission_ids uuid[]
)
returns void
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_permission_ids uuid[];
begin
  -- 1. 参数校验
  if p_role_id is null or p_permission_ids is null then
    raise exception '角色ID或权限列表不能为空'
      using errcode = '22023';
  end if;

  -- 2. 仅允许超级管理员修改角色权限
  if not exists (
    select 1
    from iam.user_roles ur
    join iam.roles r on r.id = ur.role_id
    where ur.user_id = (select auth.uid())
      and r.code = 'SUPER_ADMIN'
      and r.is_disabled = false
  ) then
    raise exception '没有修改角色权限的权限'
      using errcode = '42501';
  end if;

  -- 3. 验证目标角色，并禁止修改超级管理员
  if not exists (
    select 1
    from iam.roles r
    where r.id = p_role_id
      and r.is_disabled = false
      and r.code <> 'SUPER_ADMIN'
  ) then
    raise exception '角色不存在、已禁用或不允许修改'
      using errcode = '22023';
  end if;

  -- 4. 权限ID去重
  select coalesce(
    array_agg(distinct t.permission_id),
    array[]::uuid[]
  )
  into v_permission_ids
  from pg_catalog.unnest(p_permission_ids)
    as t(permission_id)
  where t.permission_id is not null;

  -- 5. 禁止 NULL 元素
  if cardinality(v_permission_ids) <>
     cardinality(p_permission_ids)
     - (
       select count(*) - count(distinct x.permission_id)
       from pg_catalog.unnest(p_permission_ids) as x(permission_id)
       where x.permission_id is not null
     ) then
    raise exception '权限列表不能包含空ID'
      using errcode = '22023';
  end if;

  -- 6. 验证所有权限均存在且未禁用
  if (
    select count(*)
    from iam.permissions p
    where p.id = any(v_permission_ids)
      and p.is_disabled = false
  ) <> cardinality(v_permission_ids) then
    raise exception '存在无效或已禁用的权限'
      using errcode = '22023';
  end if;

  -- 7. 删除取消选中的权限
  delete from iam.role_permissions rp
  where rp.role_id = p_role_id
    and not (rp.permission_id = any(v_permission_ids));

  -- 8. 插入新增权限，已有关系不重复插入
  insert into iam.role_permissions (
    role_id,
    permission_id
  )
  select
    p_role_id,
    t.permission_id
  from pg_catalog.unnest(v_permission_ids)
    as t(permission_id)
  on conflict (role_id, permission_id) do nothing;
end;
$$;


revoke all
on function api.sync_role_permissions(uuid, uuid[])
from public, anon, authenticated;

grant execute
on function api.sync_role_permissions(uuid, uuid[])
to authenticated;