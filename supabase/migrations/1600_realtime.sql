
create schema if not exists app;


-- schema
grant usage on schema app to anon;
grant usage on schema app to authenticated;


-- view/table
grant select on all tables in schema app to anon;
grant select on all tables in schema app to authenticated;


-- future view/table
alter default privileges in schema app
grant select on tables to anon;

alter default privileges in schema app
grant select on tables to authenticated;


-- sequence
grant usage, select on all sequences in schema app to anon;
grant usage, select on all sequences in schema app to authenticated;


alter default privileges in schema app
grant usage, select on sequences to anon;

alter default privileges in schema app
grant usage, select on sequences to authenticated;
