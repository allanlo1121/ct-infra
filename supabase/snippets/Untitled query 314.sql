drop function if exists tbm.get_ring_progress(
  text[],
  timestamptz,
  timestamptz,
  uuid[]
);


-- ============================================================
-- RPC：统计盾构机指定时段内的完成环数
--
-- 统计维度：TBM + 隧道
-- 完成口径：最后一次管片拼装阶段结束
-- 时间范围：[p_start_time, p_end_time)
--
-- 支持：
--   1. 单台 TBM
--   2. 多台 TBM
--   3. 同一 TBM 跨项目、跨隧道施工
--
-- 注意：
--   管片拼装结束代表整环完成，是当前暂定业务规则
-- ============================================================


create function tbm.get_ring_progress(
  p_tbm_codes text[],
  p_start_time timestamptz,
  p_end_time timestamptz
)
returns table (
  tbm_code text,
  tbm_name text,
  project_name text,
  tunnel_name text,
  completed_rings bigint,
  first_ring integer,
  last_ring integer,
  first_completed_at timestamptz,
  last_completed_at timestamptz
)
language plpgsql
stable
security invoker
set search_path = ''
as $$
begin

  -- =========================================
  -- 1. 参数校验
  -- =========================================

  if p_tbm_codes is null
    or cardinality(p_tbm_codes) = 0
    or exists (
      select 1
      from unnest(p_tbm_codes) as c(code)
      where c.code is null
        or btrim(c.code) = ''
    )
  then
    raise exception 'p_tbm_codes cannot be empty';
  end if;

  if p_start_time is null
    or p_end_time is null
    or p_start_time >= p_end_time
  then
    raise exception 'Invalid time range';
  end if;

  -- =========================================
  -- 2. 统计完成环
  -- =========================================

  return query
  with completed_rings_cte as (

    -- 同一设备 + 隧道 + 环号只保留一条完成记录
    select
      r.tbm_code,
      r.tunnel_id,
      r.ring_no,
      max(r.ended_at) as completed_at

    from tbm.ring_phase_records r

    where
      r.tbm_code = any(p_tbm_codes)
      and r.tbm_phase_type = 'segment_erection'  

    group by
      r.tbm_code,
      r.tunnel_id,
      r.ring_no

    -- 未结束的拼装阶段不计入完成
    having bool_and(r.ended_at is not null)

  ),

  filtered_rings as (

    select
      r.tbm_code,
      r.tunnel_id,
      r.ring_no,
      r.completed_at

    from completed_rings_cte r

    where
      r.completed_at >= p_start_time
      and r.completed_at < p_end_time

  )

  select
    r.tbm_code::text,
    m.name::text as tbm_name,
    p.name::text as project_name,
    t.name::text as tunnel_name,

    count(*)::bigint as completed_rings,

    min(r.ring_no)::integer as first_ring,
    max(r.ring_no)::integer as last_ring,

    min(r.completed_at) as first_completed_at,
    max(r.completed_at) as last_completed_at

  from filtered_rings r

  join tbm.tbms m
    on m.code = r.tbm_code

  join proj.tunnels t
    on t.id = r.tunnel_id

  join proj.engineering_units eu
    on eu.id =t.engineering_unit_id

  join proj.projects p
    on p.id = eu.project_id

  group by
    r.tbm_code,
    m.name,
    p.id,
    p.name,
    t.id,
    t.name

  order by
    p.name,
    t.name,
    r.tbm_code;

end;
$$;

-- =========================================
-- 3. RPC 执行权限
-- =========================================

revoke execute on function tbm.get_ring_progress(
  text[],
  timestamptz,
  timestamptz
) from public, anon, authenticated;

grant execute on function tbm.get_ring_progress(
  text[],
  timestamptz,
  timestamptz
) to service_role;

-- =========================================
-- 4. 函数说明
-- =========================================

comment on function tbm.get_ring_progress(
  text[],
  timestamptz,
  timestamptz
) is
'统计指定盾构设备在时间范围内的完成环数。
按 TBM 和隧道分组，返回项目、隧道和设备名称。
暂以管片拼装最后结束时间作为整环完成时间。';



select *
from tbm.get_ring_progress(
  array['crec1137'],
  '2026-11-08 19:00:00+08',
  '2026-11-09 19:00:00+08'
);