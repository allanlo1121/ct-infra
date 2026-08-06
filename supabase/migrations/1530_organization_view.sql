create or replace view hr.v_organization_detail as
select
  o.id,
  o.code,
  o.name,
  o.full_name,
  o.description,

  p.name as parent_org_name,

  t.name as org_type_name,
  c.name as org_category_name,
  b.name as business_name,

  ct.name as country_name,
  ap.name as province_name,
  ac.name as city_name,
  ad.name as district_name,

  o.address,
  o.latitude,
  o.longitude,

  o.is_disabled,
  (o.deleted_at is not null) as is_deleted,
  o.external_id,
  o.external_version,
  o.created_at,
  o.updated_at

from hr.organizations o
left join hr.organizations p on p.id = o.parent_id
left join public.master_data t on t.id = o.org_type_id
left join public.master_data c on c.id = o.org_category_id
left join public.master_data b on b.id = o.business_id
left join public.countries ct on ct.code = o.country_code
left join public.admin_regions ap on ap.code = o.province_code
left join public.admin_regions ac on ac.code = o.city_code
left join public.admin_regions ad on ad.code = o.district_code;


create or replace view hr.v_organization_list as
select
  o.id,
  o.name,
  o.parent_id,
  p.name as parent_org_name,
  o.path,
  nlevel(o.path) as level,
  o.sort_order,
  o.is_disabled,
  (o.deleted_at is not null) as is_deleted,
  o.created_at,
  o.updated_at,
  t.name as org_type_name,
  c.name as org_category_name,
  b.name as business_name,
  ct.name as country_name,
  ap.name as province_name,
  ac.name as city_name,
  ad.name as district_name

from hr.organizations o
left join hr.organizations p on p.id = o.parent_id
left join public.master_data t on t.id = o.org_type_id
left join public.master_data c on c.id = o.org_category_id
left join public.master_data b on b.id = o.business_id
left join public.countries ct on ct.code = o.country_code
left join public.admin_regions ap on ap.code = o.province_code
left join public.admin_regions ac on ac.code = o.city_code
left join public.admin_regions ad on ad.code = o.district_code;






create or replace view hr.v_organization_picker as
select
  o.id,
  o.name,
  o.parent_id,
  p.name as parent_org_name,
  o.sort_order,
  t.name as org_type_name, 
  ap.name as province_name,
  ac.name as city_name

from hr.organizations o
left join hr.organizations p on p.id = o.parent_id
left join public.master_data t on t.id = o.org_type_id
left join public.admin_regions ap on ap.code = o.province_code
left join public.admin_regions ac on ac.code = o.city_code
where o.deleted_at is null;
