create or replace view tbm.v_parameters_picker as
select
    p.code,
    p.name,
    s.code as subsystem_code,
    s.name as subsystem_name
from tbm.parameters p
join tbm.subsystems s
  on s.code = p.subsystem_code
where p.is_disabled = false;


create or replace view tbm.v_parameters_list as
select
    p.code,
    p.name,
    p.subsystem_code,
    s.name as subsystem_name,
    p.data_type,
    p.unit,
    p.digits,
    p.sort_order,
    p.is_disabled
from tbm.parameters p
join tbm.subsystems s
  on s.code = p.subsystem_code;

create or replace view tbm.v_parameter_templates_list as
select
  t.id,
  t.code,
  t.name,
  t.tbm_type_id,
  md.code as tbm_type_code,
  md.name as tbm_type_name,
  t.is_default,
  t.is_disabled,
  t.diameter,
  t.sort_order,
  t.remark
from tbm.parameter_templates t
join public.master_data md
  on md.id = t.tbm_type_id;


create or replace view tbm.v_parameter_templates_list as
select
  t.id,
  t.code,
  t.name,
  t.tbm_type_id,
  md.code as tbm_type_code,
  md.name as tbm_type_name,
  t.is_default,
  t.is_disabled,
  t.diameter,
  t.sort_order,
  t.remark
from tbm.parameter_templates t
join public.master_data md
  on md.id = t.tbm_type_id;

create or replace view tbm.v_parameter_template_items as
select
    vp.* ,
    pti.template_id,
    pt.code as template_code,
    pt.name as template_name

from tbm.parameter_template_items pti
join tbm.parameter_templates pt
  on pt.id = pti.template_id
join tbm.v_parameters_list vp
  on vp.code = pti.parameter_code;


create or replace view tbm.v_tbm_parameters as
select
    tp.id,
    tp.tbm_code,
    tp.parameter_code,
    p.name as parameter_name,
    p.subsystem_code,
    s.name as subsystem_name,
    p.data_type,
    p.unit,
    p.digits,
    tp.is_disabled,
    tp.custom_name,
    tp.custom_unit,
    tp.remark
from tbm.tbm_parameters tp
join tbm.parameters p
  on p.code = tp.parameter_code
join tbm.subsystems s
    on s.code = p.subsystem_code;

select
  policyname,
  cmd,
  roles,
  qual,
  with_check
from pg_policies
where schemaname = 'tbm'
  and tablename = 'tbm_parameters';

alter table tbm.tbm_parameters
disable row level security;