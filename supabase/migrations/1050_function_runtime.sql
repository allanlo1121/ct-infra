create or replace function runtime.fn_get_tunnel_progress_period(
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
security definer
set search_path = ''
as
$$

with daily as (

    /*
     * 先计算 lag。
     * 不能先按 p_start_date 过滤，
     * 否则统计区间第一天拿不到上一天的 ring_end / chainage_end。
     */
    select
        p.id,
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
     * lag 完成后，再过滤开始日期。
     */
    select
        d.tbm_code,
        d.work_date,

        d.ring_start,
        d.ring_end,

        case
            when d.ring_start is null
              or d.ring_end is null
            then 0
            else abs(
                d.ring_end - d.ring_start
            )
        end as completed_ring_count,

        d.chainage_start,
        d.chainage_end,

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

plan_summary as (

    select
        ta.tbm_code,

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
    left join tbm.tbm_assignments ta
        on ta.tunnel_id = tp.tunnel_id

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
        ta.tbm_code
),

tbm_info as (

    select distinct on (ta.tbm_code)

        t.id
            as tunnel_id,

        ta.tbm_code,

        tbm.name
            as tbm_name,

        tbm.code
            as tbm_code,

        t.project_id,

        p.name
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

    left join proj.projects p
        on p.id = t.project_id

     left join public.master_data region
    on region.id = p.region_id

    order by
        ta.tbm_code,
        ta.start_date desc nulls last
)

select

    info.tunnel_id,

    ps.tbm_code,
    info.tbm_name,
    info.tbm_code,

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

left join plan_summary plan
    on plan.tbm_code = ps.tbm_code

left join tbm_info info
    on info.tbm_code = ps.tbm_code

order by
    info.sort_order nulls last,
    info.tunnel_name,
    info.tbm_name;

$$;