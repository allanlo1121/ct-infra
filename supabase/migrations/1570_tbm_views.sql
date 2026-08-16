

create view tbm.v_tbm_list as
select
  t.code,
  t.name,
  t.manage_code,
  t.model,  
  t.diameter,
  t.power,
  t.serial_no,
  t.sort_order,
  t.is_disabled,
 

  t.tbm_type_id,
  mt.name as tbm_type_name,
  t.manufacturer_id,
  mf.name as manufacturer_name
from tbm.tbms t
left join public.master_data mt on t.tbm_type_id = mt.id
left join hr.customers mf on t.manufacturer_id = mf.id
where t.deleted_at is null;

create view tbm.v_tbm_picker as
select
  t.code,
  t.name,
  t.manage_code,
  t.diameter,
  mt.name as tbm_type_name,
  cus.name as manufacturer_name
from tbm.tbms t
left join public.master_data mt on t.tbm_type_id = mt.id
left join hr.customers cus on t.manufacturer_id = cus.id
where t.deleted_at is null;

create or replace view tbm.v_tbm_detail as
select
  t.code,
  t.name,
  t.manage_code,
  t.model,
  t.tbm_type_id,
  t.diameter,
  t.power,
  t.serial_no,
  t.sort_order,
  t.is_disabled,
  t.remark,
  t.external_id,
  t.external_version,

  mt.name as tbm_type_name,
  mf.name as manufacturer_name,
  t.created_at,
  t.updated_at,
  t.created_by,
  t.updated_by,
  t.deleted_at,
  t.deleted_by
from tbm.tbms t
left join public.master_data mt on t.tbm_type_id = mt.id
left join hr.customers mf on t.manufacturer_id = mf.id;

create or replace view tbm.v_tbm_type_counts as
select
  tbm_type_id,
  count(*)::int as tbm_count
from tbm.tbms
where deleted_at is null
group by tbm_type_id;

create or replace view tbm.v_tbm_manufacturer_counts as
select
  manufacturer_id,
  count(*)::int as tbm_count
from tbm.tbms
where deleted_at is null
group by manufacturer_id;

create or replace view tbm.v_tbm_bound_parameters as
select

  bpc.id as config_id,

  bpc.tbm_code,

  bpc.parameter_id,
  bpc.plc_tag_id,

  bpc.scale,
  bpc.value_offset, 

  -- subsystem
  s.id as subsystem_id,
  s.code as subsystem_code,
  s.name as subsystem_name,
  s.sort_order as subsystem_sort_order,

  -- platform parameter
  p.code as parameter_code,
  p.name as parameter_name,
  p.unit as parameter_unit,
  p.digits as parameter_digits,
  p.data_type as parameter_data_type,
  p.sort_order as parameter_sort_order,
  p.is_alarm,
  p.is_chartable,
  p.is_disabled as parameter_is_disabled,

  -- plc tag
  t.tag_name,
  t.comment as tag_comment,
  t.internal,
  t.bit,

  t.data_type as plc_data_type,
  t.unit as plc_unit,

  t.archive,
  t.sort_order as plc_sort_order

from tbm.parameter_configs bpc

join tbm.runtime_parameters p
  on p.id = bpc.parameter_id

join tbm.subsystems s
  on s.id = p.subsystem_id

join tbm.plc_tags t
  on t.id = bpc.plc_tag_id;


create view tbm.v_tbm_assignment_list as
select
    a.id,

    a.tbm_code,
    tb.name as tbm_name,
  
    a.tunnel_id,
    t.name as tunnel_name,
    t.full_name as tunnel_full_name,

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




