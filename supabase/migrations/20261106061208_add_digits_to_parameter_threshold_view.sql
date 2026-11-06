create or replace view tbm.v_parameter_threshold_list
with (security_invoker = true)
as
select
  -- 阈值
  t.*,
  di.name as severity_name,
  -- TBM 参数
  tp.tbm_code,
  tp.parameter_code,
  coalesce(nullif(trim(tp.custom_name), ''), p.name) as parameter_name,
  coalesce(nullif(trim(tp.custom_unit), ''), p.unit) as parameter_unit,
  tp.value_max,
  tp.value_min,

  -- 标准参数
  p.subsystem_code,
  p.data_type,
  -- 新增显示精度
  p.digits

from tbm.tbm_parameter_threshold_rules t
join tbm.tbm_parameters tp
  on tp.id = t.tbm_parameter_id
join tbm.parameters p
  on p.code = tp.parameter_code
left join master_data.dictionary_items di
  on di.code =t.severity_code;