

create table proj.project_contracts (
  id uuid primary key default gen_random_uuid(),

  project_id uuid not null references proj.projects(id) on delete cascade,

  contract_code text,
  contract_name text,

  contract_type text,  -- 主合同 / 补充协议 / 分包等

  sign_date date,

  sort_order int default 0,
  is_disabled boolean not null default false,

  owner_unit text

);


create table proj.project_contract_versions (
  id uuid primary key default gen_random_uuid(),

  contract_id uuid not null references proj.project_contracts(id) on delete cascade,

  version_no int not null,   -- 1,2,3...

  -- 💰 金额
  contract_amount numeric,
  change_amount numeric,

  -- 📅 时间（重点）
  contract_start_date date,
  contract_end_date date,
  commissioning_date date,


  -- 变更信息
  change_reason text,
  source text,  -- import / manual

  unique (contract_id, version_no)

);


