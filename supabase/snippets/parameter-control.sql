create table tbm.parameter_control_schemes (
  id uuid primary key default gen_random_uuid(),

  tunnel_id uuid not null
    references proj.tunnels(id),

  name text not null,
  version integer not null default 1,

  start_ring integer,
  end_ring integer,

  description text,

  status text not null default 'draft'
    check (status in (
      'draft',
      'active',
      'archived'
    )),

  effective_at timestamptz,

  created_at timestamptz not null default now(),

  check (
    start_ring is null
    or end_ring is null
    or start_ring <= end_ring
  )
);


create table tbm.parameter_control_items (
  id bigint generated always as identity primary key,

  scheme_id uuid not null
    references tbm.parameter_control_schemes(id)
    on delete cascade,

  parameter_code text,

  name text not null,
  unit text,

  target_value numeric,

  min_value numeric,
  max_value numeric,

  description text,

  sort_order integer not null default 0,

  check (
    min_value is null
    or max_value is null
    or min_value <= max_value
  )
);




with new_scheme as (
  insert into tbm.parameter_control_schemes (
    tunnel_id,
    name,
    version,
    start_ring,
    end_ring,
    description,
    status
  )
  values (
    'de299a8d-7c82-4f38-839d-bc1b3844a196'::uuid,
    '民明左线75-150环盾构掘进施工参数控制方案',
    1,
    null,
    null,
    '盾构掘进施工主要技术参数控制标准',
    'draft'
  )
  returning id
)
insert into tbm.parameter_control_items (
  scheme_id,
  parameter_code,
  name,
  unit,
  target_value,
  min_value,
  max_value,
  description,
  sort_order
)
select
  s.id,
  v.parameter_code,
  v.name,
  v.unit,
  v.target_value,
  v.min_value,
  v.max_value,
  v.description,
  v.sort_order
from new_scheme s
cross join (
  values
    ('s020901001', '顶部压力', 'bar',
      null, 2.4, 2.6, null, 3),

    ('s050001001', '总推力', 't',
      2300, 2000, 2600, '2300±300t', 4),

    ('s050109001', '贯入度', 'mm/r',
      null, 5, 10, null, 5),

    ('s050009003', '推进速度', 'mm/min',
      null, 10, 15, null, 6),

    ('s010109001', '刀盘转速', 'r/min',
      1.5, null, null, null, 7),

    ('s010102004', '刀盘扭矩', 'kN·m',
      2800, 2500, 3100, '2800±300kN·m', 8)
) as v (
  parameter_code,
  name,
  unit,
  target_value,
  min_value,
  max_value,
  description,
  sort_order
);
