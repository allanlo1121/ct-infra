create or replace function audit.log_changes()
returns trigger
language plpgsql
security definer
as $$
declare
  v_user uuid;
  v_changed_fields text[];
  v_org uuid;
begin

  v_user := auth.uid();

  if (tg_op = 'INSERT') then

    v_org := (to_jsonb(new)->>'organization_id')::uuid;

    insert into audit.logs (
      table_name,
      entity_id,
      action,
      new_data,
      operated_by,
      organization_id
    )
    values (
      tg_table_name,
      new.id,
      'INSERT',
      to_jsonb(new),
      v_user,
      v_org
    );

    return new;
  end if;

  if (tg_op = 'UPDATE') then

    select array_agg(key)
    into v_changed_fields
    from jsonb_each(to_jsonb(new))
    where to_jsonb(new)->key is distinct from to_jsonb(old)->key;

    v_org := coalesce(
      (to_jsonb(new)->>'organization_id')::uuid,
      (to_jsonb(old)->>'organization_id')::uuid
    );

    insert into audit.logs (
      table_name,
      entity_id,
      action,
      old_data,
      new_data,
      changed_fields,
      operated_by,
      organization_id
    )
    values (
      tg_table_name,
      new.id,
      'UPDATE',
      to_jsonb(old),
      to_jsonb(new),
      v_changed_fields,
      v_user,
      v_org
    );

    return new;
  end if;

  if (tg_op = 'DELETE') then

    v_org := (to_jsonb(old)->>'organization_id')::uuid;

    insert into audit.logs (
      table_name,
      entity_id,
      action,
      old_data,
      operated_by,
      organization_id
    )
    values (
      tg_table_name,
      old.id,
      'DELETE',
      to_jsonb(old),
      v_user,
      v_org
    );

    return old;
  end if;

  return null;
end;
$$;


