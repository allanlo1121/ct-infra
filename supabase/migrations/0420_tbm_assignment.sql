

create table tbm.tbm_assignments (

    id uuid primary key default gen_random_uuid(),

    tbm_id uuid not null
        references tbm.tbms(id),

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
on tbm.tbm_assignments(tbm_id)
where end_date is null;

-- 防止时间重叠
alter table tbm.tbm_assignments
add constraint uq_tbm_assignments_no_overlap
exclude using gist (
  tbm_id with =,
  daterange(start_date, coalesce(end_date, 'infinity')) with &&
);






