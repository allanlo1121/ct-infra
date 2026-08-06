


create or replace view system.v_tree_nodes as

-- =========================================
-- organizations
-- =========================================

select
  'organizations'::text as tree_key,
  o.id,
  o.parent_id,
  o.code,
  o.name,
  o.name as label,
  o.node_key,
  o.path::text as path,
  o.level,
  o.sort_order,
  o.is_leaf,
  not o.is_leaf as has_children,
  not o.is_disabled as is_enabled,
  'organization'::text as entity_type

from hr.organizations o
where o.deleted_at is null

union all

-- =========================================
-- project_catalog_std
-- =========================================

select
  'project_catalog_std'::text as tree_key,
  r.id,
  r.parent_id,
  r.code,
  r.name,
  r.name as label,
  r.node_key,
  r.path::text as path,
  r.level,
  r.sort_order,
  r.is_leaf,
  not r.is_leaf as has_children,
  not r.is_disabled as is_enabled,
  'project_catalog_std'::text as entity_type

from proj.project_catalog_std r
where r.deleted_at is null;






--统一树结构的触发器函数，适用于所有使用 ltree 存储树结构的表
--生成插入nodekey及ltree路径，更新时自动调整子节点路径
create or replace function system.tree_before_insert_update()
returns trigger
language plpgsql
as $$
declare
  v_parent_path ltree;
  v_next_key int;
  v_old_path ltree;
begin

  -- =====================================================
  -- 1️⃣ ID
  -- =====================================================

  if new.id is null then
    new.id := gen_random_uuid();
  end if;

  -- =====================================================
  -- 2️⃣ NODE KEY
  -- =====================================================

  if new.node_key is null then

    -- 根节点
    if new.parent_id is null then

      execute format(
        '
        select coalesce(max(node_key::int), 0) + 1
        from %I.%I
        where parent_id is null
        ',
        tg_table_schema,
        tg_table_name
      )
      into v_next_key;

    else

      execute format(
        '
        select coalesce(max(node_key::int), 0) + 1
        from %I.%I
        where parent_id = $1
        ',
        tg_table_schema,
        tg_table_name
      )
      into v_next_key
      using new.parent_id;

    end if;

    new.node_key := lpad(v_next_key::text, 3, '0');

  end if;

  -- =====================================================
  -- 3️⃣ PATH
  -- =====================================================

  if new.parent_id is null then

    new.path := text2ltree(new.node_key);

  else

    execute format(
      '
      select path
      from %I.%I
      where id = $1
      ',
      tg_table_schema,
      tg_table_name
    )
    into v_parent_path
    using new.parent_id;

    if v_parent_path is null then
      raise exception 'Parent path not found: %', new.parent_id;
    end if;

    new.path := v_parent_path || text2ltree(new.node_key);

  end if;

  -- =====================================================
  -- 4️⃣ UPDATED_AT
  -- =====================================================

  new.updated_at := now();

  -- =====================================================
  -- 5️⃣ UPDATE SUBTREE
  -- =====================================================

  if tg_op = 'UPDATE'
     and old.path is distinct from new.path
  then

    v_old_path := old.path;

    execute format(
      '
      update %I.%I
      set path = $1 || subpath(path, nlevel($2))
      where path <@ $2
        and id <> $3
      ',
      tg_table_schema,
      tg_table_name
    )
    using new.path, old.path, new.id;

  end if;

  return new;

end;
$$;

---树结构写操作后触发器，维护父节点的叶子状态
create or replace function system.tree_after_write()
returns trigger
language plpgsql
as $$
begin

  -- 父节点变成非叶子
  if new.parent_id is not null then

    execute format(
      '
      update %I.%I
      set is_leaf = false
      where id = $1
      ',
      tg_table_schema,
      tg_table_name
    )
    using new.parent_id;

  end if;

  -- 删除后重新检查旧父节点
  if tg_op = 'DELETE'
     and old.parent_id is not null
  then

    execute format(
      '
      update %I.%I p
      set is_leaf = not exists (
        select 1
        from %I.%I c
        where c.parent_id = p.id
          and c.deleted_at is null
      )
      where p.id = $1
      ',
      tg_table_schema,
      tg_table_name,
      tg_table_schema,
      tg_table_name
    )
    using old.parent_id;

  end if;

  return null;

end;
$$;

create trigger trg_organizations_tree_before
before insert or update
on hr.organizations
for each row
execute function system.tree_before_insert_update();

create trigger trg_organizations_tree_after
after insert or delete
on hr.organizations
for each row
execute function system.tree_after_write();

create trigger trg_project_catalog_std_tree_before
before insert or update
on proj.project_catalog_std
for each row
execute function system.tree_before_insert_update();

create trigger trg_project_catalog_std_tree_after
after insert or delete
on proj.project_catalog_std
for each row
execute function system.tree_after_write();

create trigger trg_project_catalogs_tree_before
before insert or update
on proj.project_catalogs
for each row
execute function system.tree_before_insert_update();

create trigger trg_project_catalogs_tree_after
after insert or delete
on proj.project_catalogs
for each row
execute function system.tree_after_write();

create trigger trg_menus_tree_before
before insert or update
on system.menus
for each row
execute function system.tree_before_insert_update();

create trigger trg_menus_tree_after
after insert or delete
on system.menus
for each row
execute function system.tree_after_write();