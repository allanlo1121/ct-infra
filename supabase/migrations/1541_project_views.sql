create or replace view proj.v_project_contract_module as
select
  p.id as project_id,

  -- 当前合同
  (
    select jsonb_build_object(
      'contract_id', pc.id,
      'contract_code', pc.contract_code,

      'version_no', pcv.version_no,

      'contract_amount', pcv.contract_amount,

      'start_date', pcv.contract_start_date,
      'end_date', pcv.contract_end_date,

      'commissioning_date', pcv.commissioning_date
    )
    from proj.project_contracts pc

    left join lateral (
      select *
      from proj.project_contract_versions v
      where v.contract_id = pc.id
      order by v.version_no desc
      limit 1
    ) pcv on true

    where pc.project_id = p.id

    order by pc.sign_date desc

    limit 1
  ) as contract_current,

  -- 历史
  (
    select jsonb_agg(
      jsonb_build_object(
        'contract_id', pc.id,
        'contract_code', pc.contract_code,

        'version_no', pcv.version_no,

        'contract_amount', pcv.contract_amount,

        'start_date', pcv.contract_start_date,
        'end_date', pcv.contract_end_date,

        'commissioning_date', pcv.commissioning_date,

        'created_at', pcv.created_at
      )

      order by
        pc.sign_date,
        pcv.version_no
    )

    from proj.project_contracts pc

    join proj.project_contract_versions pcv
      on pcv.contract_id = pc.id

    where pc.project_id = p.id
  ) as contract_history

from proj.projects p;


create or replace view proj.v_project_schedule_module as
select
  p.id as project_id,

  -- 当前计划
  (
    select jsonb_build_object(
      'version_no', psv.version_no,

      'schedule_start_date', psv.schedule_start_date,
      'schedule_end_date', psv.schedule_end_date,

      'created_at', psv.created_at
    )

    from proj.project_schedule_versions psv

    where psv.project_id = p.id

    order by psv.version_no desc

    limit 1
  ) as schedule_current,

  -- 历史
  (
    select jsonb_agg(
      jsonb_build_object(
        'version_no', psv.version_no,

        'schedule_start_date', psv.schedule_start_date,
        'schedule_end_date', psv.schedule_end_date,

        'created_at', psv.created_at
      )

      order by psv.version_no
    )

    from proj.project_schedule_versions psv

    where psv.project_id = p.id
  ) as schedule_history

from proj.projects p;



create or replace view proj.v_project_list as
select
  -- ===== 基本信息 =====
  p.id,
  p.name,
  p.full_name,
  p.code,
  p.external_id,
  p.external_version,

  -- ===== 组织 =====  
  p.organization_id,
  org.name as organization_name,

  -- ===== 主数据（管理/类型/状态）=====
  pm.id as project_management_mode_id,
  pm.name  as project_management_mode_name,
  
  prl.project_risk_level_id,
  prl_md.name  as project_risk_level_name,
  
  pt.id as project_type_id,
  pt.name  as project_type_name,
  spt.id as project_sub_type_id,
  spt.name as project_sub_type_name,
  
  s.id as project_status_id,
  s.name  as project_status_name,
  ss.id as project_sub_status_id,
  ss.name as project_sub_status_name,

  pal.project_attention_level_id,
  pcl.project_control_level_id,
  pal_md.name  as project_attention_level_name,
  pcl_md.name  as project_control_level_name,

  -- ===== 负责人 =====
  v_posl.employee_id as project_oversight_leader_id,
  v_posl.employee_name as project_oversight_leader_name,

  v_pm.employee_id as project_manager_id,
  v_pm.employee_name as project_manager_name,

  v_pps.employee_id as project_party_secretary_id,
  v_pps.employee_name as project_party_secretary_name,

  v_pce.employee_id as project_chief_engineer_id,
  v_pce.employee_name as project_chief_engineer_name,

  v_pdi.employee_id as project_discipline_inspection_id,
  v_pdi.employee_name as project_discipline_inspection_name,

  v_pcm.employee_id as project_commercial_manager_id,
  v_pcm.employee_name as project_commercial_manager_name,

  v_psd.employee_id as project_safety_director_id,
  v_psd.employee_name as project_safety_director_name,



  -- ===== 地理信息 ===== 
  country.name  as country_name,  
  region.name   as region_name,  
  province.name as province_name,
 
  city.name     as city_name,
  district.name as district_name,

  p.address,
  p.longitude,
  p.latitude,

  p.sort_order,

  -- ===== 时间 =====
  p.actual_start_date,
  p.actual_end_date,
  psv.schedule_start_date,
  psv.schedule_end_date,
  pcv.contract_start_date,
  pcv.contract_end_date,
  pcv.commissioning_date,
  pcv.contract_amount



from proj.projects p
left join hr.organizations org on org.id = p.organization_id

left join master_data pm on pm.id = p.project_management_mode_id
left join master_data pt on pt.id = p.project_type_id
left join master_data spt on spt.id =p.project_sub_type_id

left join  proj.project_risk_level_timeline prl
  on prl.project_id = p.id
 and prl.valid_to is null
left join master_data prl_md on prl_md.id = prl.project_risk_level_id

left join proj.project_status_timeline ps
  on ps.project_id = p.id
 and ps.valid_to is null

left join master_data s
  on s.id = ps.project_status_id

left join master_data ss
  on ss.id = ps.project_sub_status_id

left join proj.project_attention_level_timeline pal
  on pal.project_id = p.id
 and pal.valid_to is null
left join master_data pal_md on pal_md.id = pal.project_attention_level_id

left join proj.project_control_level_timeline pcl
  on pcl.project_id = p.id
 and pcl.valid_to is null
left join master_data pcl_md on pcl_md.id = pcl.project_control_level_id

left join hr.v_org_responsibles v_posl
  on v_posl.organization_id = p.organization_id
 and v_posl.role_type_code = '11190001'

left join hr.v_org_responsibles v_pm
  on v_pm.organization_id = p.organization_id
 and v_pm.role_type_code = '11190002'

left join hr.v_org_responsibles v_pps
  on v_pps.organization_id = p.organization_id
 and v_pps.role_type_code = '11190003'

left join hr.v_org_responsibles v_pdi
  on v_pdi.organization_id = p.organization_id
 and v_pdi.role_type_code = '11190004'

left join hr.v_org_responsibles v_pce
  on v_pce.organization_id = p.organization_id
 and v_pce.role_type_code = '11190005'

left join hr.v_org_responsibles v_pcm
  on v_pcm.organization_id = p.organization_id
 and v_pcm.role_type_code = '11190006'

left join hr.v_org_responsibles v_psd
  on v_psd.organization_id = p.organization_id
 and v_psd.role_type_code = '11190007'


-- 取最新的计划进度版本
left join (
  select distinct on (project_id)
    *
  from proj.project_schedule_versions
  order by project_id, version_no desc
) psv
  on psv.project_id = p.id

left join lateral (
  select pcv.*
  from proj.project_contracts pc
  join proj.project_contract_versions pcv
    on pcv.contract_id = pc.id
  where pc.project_id = p.id
  order by
    pc.sign_date desc,
    pcv.version_no desc
  limit 1
) pcv on true


left join countries country  on country.code  = p.country_code
left join master_data region   on region.id   = p.region_id
left join admin_regions province on province.code = p.province_code
left join admin_regions city     on city.code     = p.city_code
left join admin_regions district on district.code = p.district_code;

create or replace view proj.v_project_picker as
select
  p.id,
  p.name,
  p.full_name,
  org.name as organization_name,
  region.name as region_name,
  status.name as status_name

from proj.projects p

left join hr.organizations org
  on org.id = p.organization_id

left join public.master_data region
  on region.id = p.region_id

left join proj.project_status_timeline ps
  on ps.project_id = p.id
 and ps.valid_to is null

left join master_data status
  on status.id = ps.project_status_id

where p.deleted_at is null;


create or replace view proj.v_project_detail as
select
  pl.*,

  cm.contract_current,
  cm.contract_history,

  sm.schedule_current,
  sm.schedule_history

from proj.v_project_list pl

left join proj.v_project_contract_module cm
  on cm.project_id = pl.id

left join proj.v_project_schedule_module sm
  on sm.project_id = pl.id;
