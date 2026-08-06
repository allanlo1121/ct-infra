
create or replace function hr.sync_employee_primary_org()
returns trigger
language plpgsql
as $$
begin
  -- 如果是主岗
  if new.is_primary = true and new.end_date is null then
    update hr.employees
    set organization_id = new.organization_id
    where id = new.employee_id;
  end if;

  -- 如果主岗被取消
  if old.is_primary = true and (new.is_primary = false or new.end_date is not null) then
    update hr.employees
    set organization_id = null
    where id = old.employee_id;
  end if;

  return new;
end;
$$;


create trigger trg_sync_employee_primary_org
after insert or update on hr.employee_assignments
for each row
execute function hr.sync_employee_primary_org();