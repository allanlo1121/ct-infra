-- 子系统排序
alter table tbm.subsystems
add column sort_order integer not null default 0;

-- 参数排序
alter table tbm.parameters
add column sort_order integer not null default 0;