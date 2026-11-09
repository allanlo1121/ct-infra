drop function if exists tbm.get_ring_progress(
  text[],
  timestamptz,
  timestamptz
);


-- ============================================================
-- RPC：统计盾构机指定时段内的完成环数
--
-- 统计维度：TBM + 隧道-- 
-- 时间范围：[p_start_time, p_end_time)
--
-- 支持：
--   1. 单台 TBM
--   2. 多台 TBM
--   3. 同一 TBM 跨项目、跨隧道施工
--
-- 返回:ringNumbers: number[] 出现的环号集合
--
-- ============================================================


create or replace function tbm.get_ring_progress(
  p_tbm_codes text[],
  p_start_time timestamptz,
  p_end_time timestamptz
)
returns table (
  tbm_code text,
  tbm_name text,
  project_name text,
  tunnel_name text,

  ring_numbers integer[],
  first_ring integer,
  last_ring integer,
  observed_ring_count integer,
  ring_span integer
)
language plpgsql
stable
security invoker
set search_path = ''
as $$
begin
  -- 参数验证
  if p_tbm_codes is null
     or cardinality(p_tbm_codes) = 0 then
    raise exception 'p_tbm_codes cannot be empty';
  end if;

  if p_start_time is null
     or p_end_time is null
     or p_start_time >= p_end_time then
    raise exception 'Invalid time range';
  end if;

  return query
  with ring_data as (
    select distinct
      r.tbm_code,
      r.tunnel_id,
      r.ring_no

    from tbm.ring_phase_records r

    where r.tbm_code = any(p_tbm_codes)
      and r.ring_no is not null

      -- 阶段记录与查询时间范围有交集
      and r.started_at < p_end_time
      and coalesce(r.ended_at, now()) > p_start_time
  ),

  ring_summary as (
    select
      r.tbm_code,
      r.tunnel_id,

      array_agg(
        r.ring_no
        order by r.ring_no
      ) as ring_numbers,

      min(r.ring_no) as first_ring,
      max(r.ring_no) as last_ring,

      count(*)::integer as observed_ring_count,

      (
        max(r.ring_no) - min(r.ring_no) + 1
      )::integer as ring_span

    from ring_data r

    group by
      r.tbm_code,
      r.tunnel_id
  )

  select
    s.tbm_code,
    t.name as tbm_name,
    p.name as project_name,
    tu.name as tunnel_name,

    s.ring_numbers,
    s.first_ring,
    s.last_ring,
    s.observed_ring_count,
    s.ring_span

  from ring_summary s

  join tbm.tbms t
    on t.code = s.tbm_code

  join proj.tunnels tu
    on tu.id = s.tunnel_id

  join proj.engineering_units eu
    on eu.id =tu.engineering_unit_id

  join proj.projects p
    on p.id = eu.project_id

  order by
    s.tbm_code,
    p.name,
    tu.name;

end;
$$;


select
  conname as constraint_name,
  pg_get_constraintdef(oid) as definition
from pg_constraint
where conrelid = 'system.notification_subscriptions'::regclass
  and contype = 'u';