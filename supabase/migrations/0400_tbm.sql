

-- =====================================================
-- 0301 EQUIPMENT SCHEMA PERMISSIONS
-- =====================================================

create schema if not exists tbm;

-- schema usage
grant usage on schema tbm to authenticated, service_role;

-- existing tables
grant select, insert, update, delete
on all tables in schema tbm
to authenticated, service_role;

-- existing sequences
grant usage, select
on all sequences in schema tbm
to authenticated, service_role;

-- future tables
alter default privileges for role postgres in schema tbm
grant select, insert, update, delete
on tables to authenticated, service_role;

-- future sequences
alter default privileges for role postgres in schema tbm
grant usage, select
on sequences to authenticated, service_role;

-- =====================================================
-- 0302 TBM TABLES
-- =====================================================

create table tbm.tbms ( 
  code text primary key
  check (
    code ~ '^[a-z]+[0-9]+$'
  ),
  name text not null,
  manage_code text,
  model text not null,
  tbm_type_id uuid not null references public.master_data(id) on delete restrict,
  manufacturer_id uuid not null references hr.customers(id) on delete restrict,
  serial_no text,                  -- 出厂序列号
  diameter numeric,
  power numeric,
  
  sort_order int not null default 0,
  is_disabled boolean not null default false,
  remark text,
  external_id text,
  external_version int
  );


-- 开启实时订阅
alter publication supabase_realtime add table tbm.tbms;


create table tbm.tbm_operation_modes (

    tbm_type_id uuid not null
        references public.master_data(id),

    operation_mode_id uuid not null
        references public.master_data(id),


    primary key (
        tbm_type_id,
        operation_mode_id
    )
);



create table tbm.tbm_assignments (

    id uuid primary key default gen_random_uuid(),

    tbm_code text not null
        references tbm.tbms(code),

    tunnel_id uuid not null
        references proj.tunnels(id),

    start_date date not null,
    end_date date,

    remark text,

    constraint chk_date_range
      check (end_date is null or end_date >= start_date)
);

-- 当前唯一
create unique index uq_tbm_assignments_current
on tbm.tbm_assignments(tbm_code)
where end_date is null;

-- tbm 与 tunnel 唯一
create unique index uq_tbm_assignments_tunnel
on tbm.tbm_assignments(tbm_code,tunnel_id);

-- 防止时间重叠
alter table tbm.tbm_assignments
add constraint uq_tbm_assignments_no_overlap
exclude using gist (
  tbm_code with =,
  daterange(start_date, coalesce(end_date, 'infinity')) with &&
);


-- 开启实时订阅
alter publication supabase_realtime add table tbm.tbm_assignments;
-- DELETE 保留old 数据
alter table tbm.tbm_assignmentsreplica identity full;
