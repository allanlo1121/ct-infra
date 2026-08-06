
-- =====================================================
-- 0801 AUDIT SCHEMA PERMISSIONS
-- =====================================================

create schema if not exists audit;

-- schema usage
grant usage on schema audit to authenticated, service_role;

-- existing tables
grant select, insert, update, delete
on all tables in schema audit
to authenticated, service_role;

-- existing sequences
grant usage, select
on all sequences in schema audit
to authenticated, service_role;

-- future tables
alter default privileges for role postgres in schema audit
grant select, insert, update, delete
on tables to authenticated, service_role;

-- future sequences
alter default privileges for role postgres in schema audit
grant usage, select
on sequences to authenticated, service_role;

create type audit.action_type as enum (
  'INSERT',
  'UPDATE',
  'DELETE',
  'LOGIN',
  'LOGOUT',
  'CUSTOM'
);

create table audit.logs (
  id uuid primary key default gen_random_uuid(),

  -- 实体信息
  table_name text not null,
  entity_id uuid not null,

  -- 操作类型
  action audit.action_type not null,

  -- 数据快照
  old_data jsonb,
  new_data jsonb,
  changed_fields text[],

  -- 组织范围
  organization_id uuid,

  -- 操作人
  operated_by uuid
    references auth.users(id),

  -- 请求追踪
  request_id uuid,
  ip_address inet,
  user_agent text
);

create index idx_audit_entity
on audit.logs(table_name, entity_id);

create index idx_audit_operated_by
on audit.logs(operated_by);
