create or replace function app.fn_get_tbm_progress_period(
    p_start_date date default null,
    p_end_date date default null
)
returns table
(
    tunnel_id uuid,

    tbm_code text,
    tbm_name text,

    project_id uuid,
    project_name text,

    region_id uuid,
    region_name text,

    tunnel_name text,
    tunnel_full_name text,

    sort_order integer,

    start_work_date date,
    end_work_date date,

    completed_ring_count numeric,
    completed_advance_meter numeric,

    plan_ring_count numeric,
    plan_advance_meter numeric
)
language sql
stable
as
$$

with daily as (

    /*
     * 先计算 lag。
     *
     * 不能先过滤 p_start_date，
     * 否则区间第一天无法拿到上一天的数据。
     */
    select
        p.tbm_code,
        p.work_date,

        p.ring_end,
        p.chainage_end,

        lag(p.ring_end) over (
            partition by p.tbm_code
            order by p.work_date
        ) as ring_start,

        lag(p.chainage_end) over (
            partition by p.tbm_code
            order by p.work_date
        ) as chainage_start

    from runtime.tbm_daily_progress p

    where
        p_end_date is null
        or p.work_date <= p_end_date
),

progress as (

    /*
     * lag 计算完成后，
     * 再过滤统计开始日期。
     */
    select
        d.tbm_code,
        d.work_date,

        case
            when d.ring_start is null
              or d.ring_end is null
            then 0
            else abs(
                d.ring_end - d.ring_start
            )
        end as completed_ring_count,

        case
            when d.chainage_start is null
              or d.chainage_end is null
            then 0
            else abs(
                d.chainage_end - d.chainage_start
            )
        end as completed_advance_meter

    from daily d

    where
        p_start_date is null
        or d.work_date >= p_start_date
),

progress_summary as (

    /*
     * 实绩：
     * 按 TBM 汇总。
     */
    select
        p.tbm_code,

        min(p.work_date)
            as start_work_date,

        max(p.work_date)
            as end_work_date,

        sum(
            p.completed_ring_count
        )::numeric
            as completed_ring_count,

        sum(
            p.completed_advance_meter
        )::numeric
            as completed_advance_meter

    from progress p

    group by
        p.tbm_code
),

tbm_info as (

    /*
     * TBM 当前分配关系：
     *
     * tbm_code
     *      ↓
     * tunnel_id
     *
     * 这里作为 progress 和 plan 的桥梁。
     */
    select distinct on (ta.tbm_code)

        ta.tbm_code,

        tbm.name
            as tbm_name,

        t.id
            as tunnel_id,

        t.project_id,

        project.name
            as project_name,

        region.id
            as region_id,

        region.name
            as region_name,

        t.name
            as tunnel_name,

        t.full_name
            as tunnel_full_name,

        t.sort_order

    from tbm.tbm_assignments ta

    join tbm.tbms tbm
        on tbm.code = ta.tbm_code

    join proj.tunnels t
        on t.id = ta.tunnel_id

    left join proj.projects project
        on project.id = t.project_id

    left join master_data region
        on region.id = project.region_id

    order by
        ta.tbm_code,
        ta.start_date desc nulls last
),

plan_summary as (

    /*
     * 计划：
     * 按 tunnel_id 汇总。
     */
    select
        tp.tunnel_id,

        sum(
            dp.plan_ring_count
        )::numeric
            as plan_ring_count,

        sum(
            dp.plan_advance_meter
        )::numeric
            as plan_advance_meter

    from proj.tunnel_plans tp

    join proj.tunnel_plan_days dp
        on dp.plan_id = tp.id

    where
        tp.status = 'active'

        and (
            p_start_date is null
            or dp.work_date >= p_start_date
        )

        and (
            p_end_date is null
            or dp.work_date <= p_end_date
        )

    group by
        tp.tunnel_id
)

select

    info.tunnel_id,

    info.tbm_code,
    info.tbm_name,

    info.project_id,
    info.project_name,

    info.region_id,
    info.region_name,

    info.tunnel_name,
    info.tunnel_full_name,

    info.sort_order,

    ps.start_work_date,
    ps.end_work_date,

    ps.completed_ring_count,
    ps.completed_advance_meter,

    coalesce(
        plan.plan_ring_count,
        0
    )::numeric
        as plan_ring_count,

    coalesce(
        plan.plan_advance_meter,
        0
    )::numeric
        as plan_advance_meter

from progress_summary ps

join tbm_info info
    on info.tbm_code = ps.tbm_code

left join plan_summary plan
    on plan.tunnel_id = info.tunnel_id

order by
    info.sort_order nulls last,
    info.tunnel_name,
    info.tbm_name;

$$;


select *
from app.fn_get_tbm_progress_period(
    '2026-08-10',
    '2026-08-20'
);


create or replace view runtime.v_tbm_daily_progress as
with progress_assignment as (
  select
    p.id,
    p.tbm_code,
    p.work_date,
    p.ring_end,
    p.chainage_end

  from runtime.tbm_daily_progress p
),

progress_calculated as (
  select
    p.*,

    lag(p.ring_end) over (
      partition by p.tbm_code
      order by p.work_date
    ) as ring_start,

    lag(p.chainage_end) over (
      partition by p.tbm_code
      order by p.work_date
    ) as chainage_start

  from progress_assignment p
)

select
  p.id,

  p.tbm_code,
  p.work_date,
  p.ring_start,
  p.ring_end,

  case
    when p.ring_start is null then 0
    else greatest(p.ring_end - p.ring_start, 0)
  end as completed_ring_count,

  p.chainage_start,
  p.chainage_end,

  case
    when p.chainage_start is null then 0
    else greatest(p.chainage_end - p.chainage_start, 0)
  end as completed_length

from progress_calculated p;



grant usage on schema runtime to authenticated;

grant select
on all tables in schema runtime
to authenticated;


grant usage on schema runtime to authenticated;

grant select
on runtime.v_tunnel_progress_summary
to authenticated;


grant usage on schema runtime
to anon, authenticated, service_role;

grant select
on runtime.v_tunnel_progress_summary
to anon, authenticated, service_role;


grant select
on runtime.v_tunnel_risk_states
to anon, authenticated, service_role;




create or replace view runtime.v_tunnel_risk_states
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

    rs.enter_distance,
    rs.exit_distance,

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






  v_parameter_alarms


grant select
on runtime. v_parameter_alarms
to anon, authenticated, service_role;


create view tbm.v_tbm_assignment_list as
select
    a.id,

    a.tbm_code,
    tb.name as tbm_name,
    

    a.tunnel_id,
    t.name as tunnel_name,

    p.id as project_id,
    p.name as project_name,    

    a.start_date,
    a.end_date,

    a.remark

from tbm.tbm_assignments a

join tbm.tbms tb
    on tb.code = a.tbm_code

join proj.tunnels t
    on t.id = a.tunnel_id

left join proj.projects p
    on p.id = t.project_id;


grant select
on runtime.v_tbm_assignments
to anon, authenticated, service_role;


notify pgrst, 'reload schema';



create or replace view runtime.v_tbm_assignments as
select
  t.id as tunnel_id,

  ta.tbm_code,
  tbm.name as tbm_name,
  tbm_type.name as tbm_type_name,

  t.project_id,
  p.name as project_name,

  p.organization_id,
  o.name as organization_name,

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

  t.longitude,
  t.latitude,

  t.sort_order,

  ps.tunnel_status_id,
  s.name as tunnel_status_name

from tbm.tbm_assignments ta

left join tbm.tbms tbm
  on tbm.code = ta.tbm_code

left join public.master_data tbm_type
  on tbm_type.id = tbm.tbm_type_id

left join proj.tunnels t
  on ta.tunnel_id = t.id

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

 and ta.end_date is null;



 grant select
on runtime.v_tunnel_progress_summary
to anon, authenticated, service_role;

grant usage on schema runtime to anon, authenticated, service_role;
