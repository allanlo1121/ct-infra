create or replace view system.v_menu_tree as

select
  m.id,

  m.parent_id,
  m.code,
  m.name,
  m.label,

  m.node_key,
  m.path::text as path,
  subpath(
    m.path,
    0,
    nlevel(m.path) - 1
  )::text as parent_path,

  subpath(
    m.path,
    0,
    1
  )::text as root_key,

  m.menu_scope,

  m.level,
  m.sort_order,
  m.is_leaf,
  not m.is_leaf as has_children,

  m.path_url,
  m.icon,

  m.permission_code,
  m.is_visible,
  m.is_disabled


from system.menus m

where
  m.is_visible = true
  and m.is_disabled = false

order by
  m.level,
  m.sort_order,
  m.node_key;