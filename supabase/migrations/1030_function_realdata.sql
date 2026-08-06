
--查询盾构机(本区间)实时数据的时间范围和环号范围
create or replace function tbm.fn_get_tbm_realdata_limits(
  p_tbm_id uuid
)
returns table (
  min_time timestamptz,
  max_time timestamptz,
  min_ring integer,
  max_ring integer
)
language plpgsql
security definer
set search_path = tbm,realdata, public
as $$
declare
  v_tbm_code text;
  v_table_name text;
begin
  select lower(t.code)
  into v_tbm_code
  from tbm.tbm_assignments a
  join tbm.tbms t on t.id = a.tbm_id
  where a.tbm_id = p_tbm_id
    and a.end_date is null
  limit 1;

  if v_tbm_code is null then
    raise exception 'TBM assignment not found for TBM: %', p_tbm_id;
  end if;

  v_tbm_code := regexp_replace(v_tbm_code, '[^a-z0-9_]', '_', 'g');
  v_table_name := 'shield_' || v_tbm_code;

  return query execute format(
    '
    select
      min(recorded_at) as min_time,
      max(recorded_at) as max_time,
      min(s100100008)::integer as min_ring,
      max(s100100008)::integer as max_ring
    from realdata.%I
    where tbm_id = $1
      and s100100008 is not null
    ',
    v_table_name
  )
  using p_tbm_id;
end;
$$;



-- 查询盾构机参数历史数据，按环号(所工作时间)查询，适用于需要展示环号范围内数据的场景
create or replace function tbm.fn_get_tbm_param_history_by_ring(
  p_tbm_id uuid,
  p_from_ring integer,
  p_to_ring integer,
  p_fields text[],
  p_work_mode text default null
)
returns table (
  ts timestamptz,
  ring integer,
  data jsonb
)
language plpgsql
security definer
set search_path = tbm, realdata,public
as $$
declare
  v_tbm_code text;
  v_table_name text;
  v_values_sql text;
  v_work_mode_sql text := '';
begin
  if p_from_ring is null or p_to_ring is null then
    raise exception '起始环号和结束环号不能为空';
  end if;

  if p_to_ring < p_from_ring then
    raise exception '结束环号必须大于或等于起始环号';
  end if;

  if array_length(p_fields, 1) is null then
    raise exception '请选择参数';
  end if;

  select lower(t.code)
  into v_tbm_code
  from tbm.tbm_assignments a
  join tbm.tbms t on t.id = a.tbm_id
  where a.tbm_id = p_tbm_id
    and a.end_date is null
  limit 1;

  if v_tbm_code is null then
    raise exception '未找到当前区间绑定的盾构机';
  end if;

  v_tbm_code := regexp_replace(v_tbm_code, '[^a-z0-9_]', '_', 'g');
  v_table_name := 'shield_' || v_tbm_code;

  if exists (
    select 1
    from unnest(p_fields) f(code)
    left join tbm.tbm_runtime_parameters p
      on p.code = f.code
    where p.id is null
       or p.is_chartable is not true
  ) then
    raise exception '包含不允许绘图的参数';
  end if;

  select string_agg(
    format('%L, %I', f.code, f.code),
    ', '
  )
  into v_values_sql
  from unnest(p_fields) f(code);

  if p_work_mode = 'advance' then
    v_work_mode_sql := ' and b000000001 = true';

  elsif p_work_mode = 'assembly' then
    v_work_mode_sql := ' and b000000002 = true';

  elsif p_work_mode = 'shutdown' then
    v_work_mode_sql := '
      and coalesce(b000000001, false) = false
      and coalesce(b000000002, false) = false
    ';

  else
    v_work_mode_sql := '';
  end if;

  return query execute format(
    '
    select
      recorded_at as ts,
      s100100008::integer as ring,
      jsonb_build_object(%s) as data
    from realdata.%I
    where tbm_id = $1
      and s100100008 is not null
      and s100100008 >= $2
      and s100100008 <= $3
      %s
    order by s100100008 asc, recorded_at asc
    ',
    v_values_sql,
    v_table_name,
    v_work_mode_sql
  )
  using p_tbm_id, p_from_ring, p_to_ring;
end;
$$;




-- 查询盾构机参数历史数据，按时间查询，适用于需要展示时间范围内数据的场景
create or replace function tbm.fn_get_tbm_param_history_by_time(
  p_tbm_id uuid,
  p_from timestamptz,
  p_to timestamptz,
  p_fields text[],
  p_work_mode text default null
)
returns table (
  ts timestamptz,
  ring integer,
  data jsonb
)
language plpgsql
security definer
set search_path = tbm,realdata,public
as $$
declare
  v_tbm_code text;
  v_table_name text;
  v_values_sql text;
  v_work_mode_sql text := '';
begin
  if p_to <= p_from then
    raise exception '结束时间必须大于开始时间';
  end if;

  if p_to - p_from > interval '7 days' then
    raise exception '查询时间范围不能超过 7 天';
  end if;

  if array_length(p_fields, 1) is null then
    raise exception '请选择参数';
  end if;

  select lower(t.code)
  into v_tbm_code
  from tbm.tbm_assignments a
  join tbm.tbms t on t.id = a.tbm_id
  where a.tbm_id = p_tbm_id
    and a.end_date is null
  limit 1;

  if v_tbm_code is null then
    raise exception '未找到当前区间绑定的盾构机';
  end if;

  v_tbm_code := regexp_replace(v_tbm_code, '[^a-z0-9_]', '_', 'g');
  v_table_name := 'shield_' || v_tbm_code;

  if exists (
    select 1
    from unnest(p_fields) f(code)
    left join tbm.tbm_runtime_parameters p
      on p.code = f.code
    where p.id is null
       or p.is_chartable is not true
  ) then
    raise exception '包含不允许绘图的参数';
  end if;

  select string_agg(
    format('%L, %I', f.code, f.code),
    ', '
  )
  into v_values_sql
  from unnest(p_fields) f(code);

  if p_work_mode = 'advance' then
    v_work_mode_sql := ' and b000000001 = true';

  elsif p_work_mode = 'assembly' then
    v_work_mode_sql := ' and b000000002 = true';

  elsif p_work_mode = 'shutdown' then
    v_work_mode_sql := '
      and coalesce(b000000001, false) = false
      and coalesce(b000000002, false) = false
    ';

  else
    v_work_mode_sql := '';
  end if;

  return query execute format(
    '
    select
      recorded_at as ts,
      s100100008::integer as ring,
      jsonb_build_object(%s) as data
    from realdata.%I
    where tbm_id = $1
      and recorded_at >= $2
      and recorded_at <= $3
      %s
    order by recorded_at asc
    ',
    v_values_sql,
    v_table_name,
    v_work_mode_sql
  )
  using p_tbm_id, p_from, p_to;
end;
$$;


-- 查询时间段内的掘进机工作状态变化和环号变化，状态包括：advance、assembly、stop、offline（掉线）。环号变化单独成一段，类型为ring。掉线由两种情况触发：1）状态断点：相邻两条记录的时间差超过p_offline_gap_minutes；2）数据缺失：查询时间段内没有任何记录，或第一条记录距离查询开始时间超过p_offline_gap_minutes，或最后一条记录距离查询结束时间超过p_offline_gap_minutes。
create or replace function eqp.fn_get_tbm_work_timeline(
  p_tbm_id uuid,
  p_start_at timestamptz,
  p_end_at timestamptz,
  p_offline_gap_minutes integer default 5
)
returns table (
  id text,
  type text,
  value text,
  start_at timestamptz,
  end_at timestamptz,
  duration_seconds integer
)
language plpgsql
security definer
set search_path = tbm, realdata, public
as $$
declare
  v_tbm_code text;
  v_table_name text;
  v_table_regclass regclass;

  r record;

  v_has_prev boolean := false;
  v_prev_recorded_at timestamptz;

  v_current_type text;
  v_next_type text;
  v_segment_start timestamptz;

  v_current_ring_no text;
  v_ring_segment_start timestamptz;

  v_gap interval := make_interval(mins => p_offline_gap_minutes);
begin
  if p_tbm_id is null then
    raise exception 'p_tbm_id cannot be null';
  end if;

  if p_start_at is null or p_end_at is null then
    raise exception 'p_start_at and p_end_at cannot be null';
  end if;

  if p_end_at <= p_start_at then
    raise exception 'p_end_at must be greater than p_start_at';
  end if;

  select t.code
  into v_tbm_code
  from tbm.tbm_assignments a
  join tbm.tbms t on t.id = a.tbm_id
  where a.tbm_id = p_tbm_id
    and a.end_date is null
  order by a.start_date desc nulls last
  limit 1;

  if v_tbm_code is null then
    return query
    select
      gen_random_uuid()::text,
      'offline'::text,
      null::text,
      p_start_at,
      p_end_at,
      extract(epoch from p_end_at - p_start_at)::integer;
    return;
  end if;

  v_table_name := 'shield_' || regexp_replace(lower(v_tbm_code), '[^a-z0-9_]', '_', 'g');
  v_table_regclass := to_regclass(format('realdata.%I', v_table_name));

  if v_table_regclass is null then
    return query
    select
      gen_random_uuid()::text,
      'offline'::text,
      null::text,
      p_start_at,
      p_end_at,
      extract(epoch from p_end_at - p_start_at)::integer;
    return;
  end if;

  for r in execute format(
    $sql$
      select
        recorded_at,
        s100100008,
        b000000001,
        b000000002
      from %s
      where recorded_at >= $1
        and recorded_at < $2
      order by recorded_at asc
    $sql$,
    v_table_regclass
  )
  using p_start_at, p_end_at
  loop
    v_next_type :=
      case
        when coalesce(r.b000000001, false) then 'advance'
        when coalesce(r.b000000002, false) then 'assembly'
        else 'stop'
      end;

    if not v_has_prev then
      if r.recorded_at > p_start_at then
        return query
        select
          gen_random_uuid()::text,
          'offline'::text,
          null::text,
          p_start_at,
          r.recorded_at,
          extract(epoch from r.recorded_at - p_start_at)::integer;
      end if;

      v_current_type := v_next_type;
      v_segment_start := r.recorded_at;

      v_current_ring_no := r.s100100008::text;
      v_ring_segment_start := r.recorded_at;

      v_prev_recorded_at := r.recorded_at;
      v_has_prev := true;

      continue;
    end if;

    -- 状态断点：掉线
    if r.recorded_at - v_prev_recorded_at > v_gap then
      return query
      select
        gen_random_uuid()::text,
        v_current_type,
        null::text,
        v_segment_start,
        v_prev_recorded_at,
        extract(epoch from v_prev_recorded_at - v_segment_start)::integer
      where v_prev_recorded_at > v_segment_start;

      return query
      select
        gen_random_uuid()::text,
        'offline'::text,
        null::text,
        v_prev_recorded_at,
        r.recorded_at,
        extract(epoch from r.recorded_at - v_prev_recorded_at)::integer;

      -- 环号断点：掉线前的环号段收尾
      return query
      select
        gen_random_uuid()::text,
        'ring'::text,
        v_current_ring_no::text,
        v_ring_segment_start,
        v_prev_recorded_at,
        extract(epoch from v_prev_recorded_at - v_ring_segment_start)::integer
      where v_current_ring_no is not null
        and v_prev_recorded_at > v_ring_segment_start;

      v_current_type := v_next_type;
      v_segment_start := r.recorded_at;

      v_current_ring_no := r.s100100008::text;
      v_ring_segment_start := r.recorded_at;

      v_prev_recorded_at := r.recorded_at;
      continue;
    end if;

    -- 状态变化
    if v_next_type <> v_current_type then
      return query
      select
        gen_random_uuid()::text,
        v_current_type,
        null::text,
        v_segment_start,
        r.recorded_at,
        extract(epoch from r.recorded_at - v_segment_start)::integer
      where r.recorded_at > v_segment_start;

      v_current_type := v_next_type;
      v_segment_start := r.recorded_at;
    end if;

    -- 环号变化
    if r.s100100008::text is distinct from v_current_ring_no then
      return query
      select
        gen_random_uuid()::text,
        'ring'::text,
        v_current_ring_no::text,
        v_ring_segment_start,
        v_prev_recorded_at,
        extract(epoch from v_prev_recorded_at - v_ring_segment_start)::integer
      where v_current_ring_no is not null
        and v_prev_recorded_at > v_ring_segment_start;

      v_current_ring_no := r.s100100008::text;
      v_ring_segment_start := r.recorded_at;
    end if;

    v_prev_recorded_at := r.recorded_at;
  end loop;

  if not v_has_prev then
    return query
    select
      gen_random_uuid()::text,
      'offline'::text,
      null::text,
      p_start_at,
      p_end_at,
      extract(epoch from p_end_at - p_start_at)::integer;
    return;
  end if;

  -- 最后一段状态
  return query
  select
    gen_random_uuid()::text,
    v_current_type,
    null::text,
    v_segment_start,
    v_prev_recorded_at,
    extract(epoch from v_prev_recorded_at - v_segment_start)::integer
  where v_prev_recorded_at > v_segment_start;

  -- 最后一段环号
  return query
  select
    gen_random_uuid()::text,
    'ring'::text,
    v_current_ring_no::text,
    v_ring_segment_start,
    v_prev_recorded_at,
    extract(epoch from v_prev_recorded_at - v_ring_segment_start)::integer
  where v_current_ring_no is not null
    and v_prev_recorded_at > v_ring_segment_start;

  -- 结尾补掉线
  if v_prev_recorded_at < p_end_at then
    return query
    select
      gen_random_uuid()::text,
      'offline'::text,
      null::text,
      v_prev_recorded_at,
      p_end_at,
      extract(epoch from p_end_at - v_prev_recorded_at)::integer;
  end if;
end;
$$;