

create or replace function system.audit_insert()
returns trigger
language plpgsql
as $$
begin
  if new.created_at is null then
    new.created_at := now();
  end if;

  if new.created_by is null then
    new.created_by := system.current_employee_id();
  end if;

  return new;
end;
$$;

create or replace function system.audit_update()
returns trigger
language plpgsql
as $$
begin

  if to_jsonb(new) ? 'updated_at' then
    new.updated_at := now();
  end if;

  if to_jsonb(new) ? 'updated_by' then
    new.updated_by := system.current_employee_id();
  end if;

  -- 先确认字段存在，再访问 new.deleted_at / old.deleted_at
  if to_jsonb(new) ? 'deleted_at' then

    if new.deleted_at is not null and old.deleted_at is null then

      if to_jsonb(new) ? 'deleted_by' then
        new.deleted_by := system.current_employee_id();
      end if;

    end if;

  end if;

  return new;

end;
$$;

create or replace function system.audit_delete()
returns trigger
language plpgsql
as $$
begin
  new.deleted_at := now();
  new.deleted_by := system.current_employee_id();
  return new;
end;
$$;

create or replace function system.attach_audit_triggers(p_table regclass)
returns void
language plpgsql
as $$
declare
  v_table text;
begin
  -- 表名（带 schema）
  v_table := p_table::text;

  -- INSERT trigger
  execute format('
    drop trigger if exists trg_%1$s_insert on %2$s;
    create trigger trg_%1$s_insert
    before insert on %2$s
    for each row
    execute function system.audit_insert();
  ',
    replace(v_table, '.', '_'), -- trigger 名
    v_table                     -- 表名
  );

  -- UPDATE trigger
  execute format('
    drop trigger if exists trg_%1$s_update on %2$s;
    create trigger trg_%1$s_update
    before update on %2$s
    for each row
    execute function system.audit_update();
  ',
    replace(v_table, '.', '_'),
    v_table
  );

end;
$$;


create or replace function system.soft_delete(
  p_table text,
  p_ids uuid[]
)
returns int
language plpgsql
security definer
as $$
declare
  v_count int;
begin

  -- ✅ 白名单（非常关键）
  if p_table not in (
    'organizations',
    'employees',
    'projects',
    'tbms'
  ) then
    raise exception 'table not allowed: %', p_table;
  end if;

  -- ✅ 执行软删除
  execute format(
    'update %I
     set deleted_at = now(),
         deleted_by = system.current_employee_id()
     where id = any($1)
       and deleted_at is null',
    p_table
  )
  using p_ids;

  get diagnostics v_count = row_count;

  return v_count;

end;
$$;