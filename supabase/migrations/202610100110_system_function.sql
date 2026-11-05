
create or replace function system.audit_insert()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  -- 创建时间
  new.created_at := coalesce(new.created_at, now());

  -- 当前认证用户
  -- 系统任务无用户上下文时保持 NULL
  new.created_by := auth.uid();

  return new;
end;
$$;

create or replace function system.audit_update()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  new.updated_at := now();
  new.updated_by := auth.uid();

  -- 禁止普通 UPDATE 改写创建审计信息
  new.created_at := old.created_at;
  new.created_by := old.created_by;

  return new;
end;
$$;

create or replace function system.audit_delete()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  -- 禁止普通 DELETE 改写创建审计信息
  return old;
end;
$$;

create or replace function system.touch_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;