

insert into hr.employees (
    id,
    name,
    code  
)
select
  '00000000-0000-0000-0000-000000000001',
  '系统用户',
  'SYSTEM_USER'
on conflict (id) do nothing;