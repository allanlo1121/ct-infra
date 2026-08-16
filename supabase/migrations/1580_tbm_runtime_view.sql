
create or replace view runtime.v_tunnel_runtime as
select
  t.id as tunnel_id,

  ta.tbm_code,
  tbm.name as tbm_name,
 

  t.project_id,
  p.name as project_name,

  p.organization_id,
  o.name as organization_name,

  region.id as region_id,
  region.name as region_name,

  t.name as tunnel_name,
  t.full_name as tunnel_full_name,
  t.prefix,

  t.start_chainage,
  t.end_chainage,

  t.advance_direction,

  t.start_ring,
  t.end_ring,

  t.actual_start_date,
  t.actual_end_date,

  tsv.schedule_start_date,
  tsv.schedule_end_date,

  t.longitude,
  t.latitude,

  t.sort_order,
  t.remark,

  ps.tunnel_status_id,
  s.name as tunnel_status_name



from proj.tunnels t

left join proj.projects p
  on p.id = t.project_id

left join master_data region
  on region.id = p.region_id

left join hr.organizations o
  on o.id = p.organization_id
 and o.deleted_at is null


left join proj.tunnel_status_timeline ps
  on ps.tunnel_id = t.id
 and ps.valid_to is null

left join master_data s
  on s.id = ps.tunnel_status_id


left join (
  select distinct on (tunnel_id)
    id,
    tunnel_id,
    version_no,
    schedule_start_date,
    schedule_end_date
  from proj.tunnel_schedule_versions
  order by tunnel_id, version_no desc
) tsv
  on tsv.tunnel_id = t.id


left join tbm.tbm_assignments ta
  on ta.tunnel_id = t.id

left join tbm.tbms tbm
  on tbm.code = ta.tbm_code

 and ta.end_date is null;


create or replace view runtime.v_tunnel_risk_states
with (security_invoker = true)
as

select

    rs.risk_id,
    rs.tbm_code,

    r.tunnel_id,
    t.name as tunnel_name,
    prj.id as project_id,
    prj.name as project_name,
    md.name as region_name,
    tbm.name as tbm_name,

    r.name as risk_name,
    r.risk_level,

    r.start_chainage,
    r.end_chainage,

    r.burial_depth,

    geo.layer as geo_class_layer,
    geo.name as geo_class_name,

    rock.name as geo_rock_class_name,

    r.description,

    r.created_at,
    r.updated_at


from runtime.tbm_risk_states rs

left join proj.tunnel_risks r
    on r.id = rs.risk_id

left join proj.tunnels t
    on t.id = r.tunnel_id

left join proj.projects prj
    on prj.id = t.project_id

left join public.master_data md
    on md.id = prj.region_id

left join tbm.tbms tbm
    on tbm.code = rs.tbm_code

left join proj.geo_classes geo
  on geo.id = r.geo_class_id


left join proj.geo_rock_classes rock
  on rock.id = r.geo_rock_class_id;



create or replace view runtime.v_tbm_runtime_state as

select

  t.*,

  heartbeat.is_online as heartbeat_is_online,
  heartbeat.last_seen_at as heartbeat_last_seen_at,

  realdata.is_online as realdata_is_online,
  realdata.last_seen_at as realdata_last_seen_at


from runtime.tbm_runtime_state_current t


left join runtime.tbm_connection_status heartbeat
  on heartbeat.tbm_code = t.tbm_code
 and heartbeat.type = 'heartbeat'


left join runtime.tbm_connection_status realdata
  on realdata.tbm_code = t.tbm_code
 and realdata.type = 'realdata';


create or replace view runtime.v_parameter_alarms
with (security_invoker = true)
as
select
    a.id,

    a.tbm_code,
    t.id as tunnel_id,
    t.name as tunnel_name,

    t.project_id,
    prj.name as project_name,

    prj.region_id,
    md.name as region_name,

    a.parameter_code,
    p.name as parameter_name,
    p.unit,

    a.ring_no,
    a.chainage,
    a.alarm_value,
    a.severity,

    a.updated_at

from runtime.parameter_alarms a

left join tbm.runtime_parameters p
    on p.code = a.parameter_code

left join tbm.tbm_assignments ta
    on ta.tbm_code = a.tbm_code
   and ta.end_date is null

left join proj.tunnels t
    on t.id = ta.tunnel_id

left join proj.projects prj
    on prj.id = t.project_id

left join public.master_data md
    on md.id = prj.region_id;





create or replace view runtime.v_tunnel_progress_summary
as
with settings as (
  select *
  from public.stat_period_settings
  where code = 'tunnel_progress'
    and current_date >= effective_from
    and current_date < coalesce(effective_to, date '9999-12-31')
  order by effective_from desc
  limit 1
),

bounds as (
  select
    s.*,
    now() at time zone s.timezone as local_now,
    case
      when (now() at time zone s.timezone)::time >= s.day_cutoff_time
        then ((now() at time zone s.timezone)::date + 1)

      else (now() at time zone s.timezone)::date
    end as current_work_date
  from settings s
),

periods as (
  select
    current_work_date,
    current_work_date
      -
      (
        (
          extract(dow from current_work_date)::int
          -
          week_start_dow
          +
          7
        ) % 7
      )
      as week_start_work_date,

    case
      when extract(day from current_work_date)::int >= month_start_day
      then
        date_trunc(
          'month',
          current_work_date
        )::date
        +
        (month_start_day - 1)

      else
        (
          date_trunc(
            'month',
            current_work_date
          )::date
          -
          interval '1 month'
        )::date
        +
        (month_start_day - 1)
    end as month_start_work_date,

    -- 年开始日期
    date_trunc(
      'year',
      current_work_date
    )::date
    as year_start_work_date

  from bounds
),

/*
 日报去重
 一个TBM一天只保留最后一次更新
*/
daily as (
  select distinct on
  (
    tbm_code,
    work_date
  )

    tbm_code,
    work_date,
    ring_end,
    chainage_end,
    updated_at
  from runtime.tbm_daily_progress
  order by
    tbm_code,
    work_date,
    updated_at desc
),

/*
 计算每天完成量
*/
progress_base as (
  select
    d.*,
    greatest(
      d.ring_end
      -
      lag(d.ring_end)
      over
      (
        partition by d.tbm_code
        order by d.work_date
      ),
      0
    ) as daily_ring_count,

    abs(
      d.chainage_end
      -
      lag(d.chainage_end)
      over
      (
        partition by d.tbm_code
        order by d.work_date
      )
    ) as daily_advance_meter
  from daily d
),

/*
 最新完成位置
 不使用max，因为反向掘进时max错误
*/
latest_progress as (
  select distinct on (tbm_code)
    tbm_code,
    ring_end as latest_ring_no,
    chainage_end as latest_chainage,
    updated_at as latest_progress_updated_at
  from daily
  order by
    tbm_code,
    work_date desc
),

/*
 周期统计
*/
period_progress as (
  select
    pb.tbm_code,

    sum(pb.daily_ring_count)
      filter
      (
        where pb.work_date =
        p.current_work_date
      )
      as today_ring_count,

    sum(pb.daily_ring_count)
      filter
      (
        where pb.work_date between
          p.week_start_work_date
          and
          p.current_work_date
      )
      as week_ring_count,

    sum(pb.daily_ring_count)
      filter
      (
        where pb.work_date between
          p.month_start_work_date
          and
          p.current_work_date
      )
      as month_ring_count,

    sum(pb.daily_ring_count)
      filter
      (
        where pb.work_date between
          p.year_start_work_date
          and
          p.current_work_date
      )
      as year_ring_count,

    sum(pb.daily_advance_meter)
      filter
      (
        where pb.work_date =
        p.current_work_date
      )
      as today_advance_meter,

    sum(pb.daily_advance_meter)
      filter
      (
        where pb.work_date between
          p.week_start_work_date
          and
          p.current_work_date
      )
      as week_advance_meter,

    sum(pb.daily_advance_meter)
      filter
      (
        where pb.work_date between
          p.month_start_work_date
          and
          p.current_work_date
      )
      as month_advance_meter,

    sum(pb.daily_advance_meter)
      filter
      (
        where pb.work_date between
          p.year_start_work_date
          and
          p.current_work_date
      )
        as year_advance_meter

  from progress_base pb
  cross join periods p
  group by
    pb.tbm_code
),

plan_daily as (

  select
    ta.tbm_code,
    dp.work_date,
    dp.plan_ring_count,
    dp.plan_advance_meter

  from proj.tunnel_plan_days dp

  join proj.tunnel_plans tp
    on tp.id = dp.plan_id

  join tbm.tbm_assignments ta
    on ta.tunnel_id = tp.tunnel_id
    and ta.end_date is null

  where tp.status = 'active'
),


plan_progress as (

  select

    dp.tbm_code,

    sum(dp.plan_ring_count)
      filter(
        where dp.work_date =
        p.current_work_date
      )
      as today_plan_ring_count,

    sum(dp.plan_advance_meter)
      filter(
        where dp.work_date =
        p.current_work_date
      )
      as today_plan_advance_meter,

    sum(dp.plan_ring_count)
      filter(
        where dp.work_date between
        p.week_start_work_date
        and
        p.current_work_date
      )
      as week_plan_ring_count,

    sum(dp.plan_advance_meter)
      filter(
        where dp.work_date between
        p.week_start_work_date
        and
        p.current_work_date
      )
      as week_plan_advance_meter,

    sum(dp.plan_ring_count)
      filter(
        where dp.work_date between
        p.month_start_work_date
        and
        p.current_work_date
      )
      as month_plan_ring_count,

    sum(dp.plan_advance_meter)
      filter(
        where dp.work_date between
        p.month_start_work_date
        and
        p.current_work_date
      )
      as month_plan_advance_meter,

    sum(dp.plan_ring_count)
      filter(
        where dp.work_date between
        p.year_start_work_date
        and
        p.current_work_date
      )
      as year_plan_ring_count,
    sum(dp.plan_advance_meter)
      filter(
        where dp.work_date between
        p.year_start_work_date
        and
        p.current_work_date
      )
      as year_plan_advance_meter


  from plan_daily dp

  cross join periods p

  group by
    dp.tbm_code
),



/*
 隧道基础信息
*/
tunnel_runtime as (

  select

    t.id as tunnel_id,
    ta.tbm_code,
    tbm.name as tbm_name,
    t.project_id,
    p.name as project_name,
    region.id as region_id,
    region.name as region_name,
    t.name as tunnel_name,
    t.full_name as tunnel_full_name,
    t.start_chainage,
    t.end_chainage,
    t.advance_direction,
    t.start_ring,
    t.end_ring,
    t.actual_start_date,
    t.actual_end_date,
    tsv.schedule_start_date,
    tsv.schedule_end_date,
    t.sort_order,
    ps.tunnel_status_id,
    s.name as tunnel_status_name

  from proj.tunnels t

  left join tbm.tbm_assignments ta
    on ta.tunnel_id = t.id
   and ta.end_date is null

  left join tbm.tbms tbm
    on tbm.code = ta.tbm_code

  left join proj.projects p
    on p.id = t.project_id

  left join master_data region
    on region.id = p.region_id

  left join hr.organizations o
    on o.id = p.organization_id
   and o.deleted_at is null

  left join proj.tunnel_status_timeline ps
    on ps.tunnel_id = t.id
   and ps.valid_to is null

  left join master_data s
    on s.id = ps.tunnel_status_id
  left join
  (
    select distinct on(tunnel_id)
      tunnel_id,
      version_no,
      schedule_start_date,
      schedule_end_date
    from proj.tunnel_schedule_versions
    order by
      tunnel_id,
      version_no desc
  ) tsv
    on tsv.tunnel_id = t.id

)

select
  tr.*,
  lp.latest_ring_no,
  lp.latest_chainage,

  /*
    已完成环数
  */
  lp.latest_ring_no - tr.start_ring as completed_ring_count,

  /*
    已完成长度
  */
  case
    when tr.advance_direction = 'chainage_increase'
    then
      lp.latest_chainage - tr.start_chainage
    when tr.advance_direction = 'chainage_decrease'
    then
      tr.end_chainage - lp.latest_chainage
    else null
  end as completed_length,

  pp.today_ring_count, 
  pp.today_advance_meter, 
  pp.week_ring_count,  
  pp.week_advance_meter,
  pp.month_ring_count,
  pp.month_advance_meter,
  pp.year_ring_count,
  pp.year_advance_meter,

  plp.today_plan_ring_count, 
  plp.today_plan_advance_meter, 
  plp.week_plan_ring_count,  
  plp.week_plan_advance_meter,
  plp.month_plan_ring_count,
  plp.month_plan_advance_meter,
  plp.year_plan_ring_count,
  plp.year_plan_advance_meter,

  p.current_work_date,
  p.week_start_work_date,
  p.month_start_work_date,

  lp.latest_progress_updated_at as progress_updated_at,
  now() as refreshed_at

from tunnel_runtime tr

left join latest_progress lp
  on lp.tbm_code = tr.tbm_code

left join period_progress pp
  on pp.tbm_code = tr.tbm_code
left join plan_progress plp
  on plp.tbm_code = tr.tbm_code

cross join periods p;