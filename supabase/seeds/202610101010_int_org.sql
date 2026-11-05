
  insert into hrm.organizations (
    code,
    name,
    full_name,
    parent_id,
    org_type_code,
    org_category_code,
    country_code,
    province_code,
    city_code,
    district_code,
    external_id,
    external_version
  )
 VALUES (
    '0-001-003-006-036',
    '城通公司',
    '中铁二局城通公司',
    null,
    '10230002',
    '10250001',
    'CN',
    '510000',
    '510100',
    '510106',
    '20200805215458816-2834-7FA5B74BA',
    5
  )
  on conflict (code) do nothing;
