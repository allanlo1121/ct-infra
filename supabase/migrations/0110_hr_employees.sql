

-- =========================================
-- 员工主表（employees）
-- =========================================

create table hr.employees (
    id                  uuid primary key default gen_random_uuid(),

    auth_id uuid unique references auth.users(id) on delete set null,   

    name                text not null,
    code text unique not null,

    gender_id uuid  references master_data(id),

    birth_date date,
    id_card text,
    phone text,
    email text,
    
    organization_id uuid references hr.organizations(id) on delete set null,
    employment_status_id uuid references master_data(id) on delete set null,
    employment_type_id uuid references master_data(id) on delete set null,

    hire_date           date,
    entry_date          date,
    leave_date          date,

    sort_order          int default 0,
    is_disabled         boolean default false,

    external_id           text, -- 外部系统 ID
    external_version        int,  -- 外部系统版本号（乐观锁）

    remark              text
);


create table hr.posts (
  id uuid primary key default gen_random_uuid(),

  code text unique not null,     -- 原 master_data.code
  name text not null,            -- 原 master_data.name
 
  grade int,                     -- 可选：级别（用于排序/层级）

  sort_order int not null default 0,   -- 用于自定义排序
  is_disabled boolean not null default false

);

-- =========================================
-- 任职关系（employee_assignments）
-- =========================================
create table hr.employee_assignments (
  id uuid primary key default gen_random_uuid(),

  employee_id uuid not null,

  -- ✅ 核心：组织归属（精确到部门）
  organization_id uuid not null
    references hr.organizations(id) on delete restrict,

  -- ✅ 可选：岗位（允许为空，兼容导入）
  post_id uuid
    references hr.posts(id) on delete set null,
 
  -- ✅ 是否主任职（主岗）
  is_primary boolean default false,

  -- ✅ 任职时间（支持历史）
  start_date date default current_date,
  end_date date,

  -- =========================
  -- 外键
  -- =========================
  constraint fk_assignment_employee
    foreign key (employee_id)
    references hr.employees(id)
    on delete cascade,

  -- =========================
  -- 唯一约束（防重复）
  -- =========================
  constraint uq_employee_assignment
    unique (employee_id, organization_id, post_id, start_date)
);

-- =========================================
-- 每人仅一个“当前主岗”
-- =========================================
create unique index uq_employee_primary_assignment
on hr.employee_assignments(employee_id)
where is_primary = true
  and end_date is null;

-- =========================================
-- 主岗必须有岗位（关键约束）
-- =========================================
alter table hr.employee_assignments
add constraint chk_primary_post_not_null
check (
  is_primary = false or post_id is not null
);

-- =========================================
-- 当前任职索引（高频查询）
-- =========================================
create index idx_employee_assignments_current
on hr.employee_assignments(employee_id)
where end_date is null;

-- =========================================
-- 按组织查询（权限 / 列表）
-- =========================================
create index idx_employee_assignments_org
on hr.employee_assignments(organization_id)
where end_date is null;

-- =========================================
-- 岗位查询（可选）
-- =========================================
create index idx_employee_assignments_post
on hr.employee_assignments(post_id)
where end_date is null;



create table hr.organization_role_assignments (
  id uuid primary key default gen_random_uuid(),

  organization_id uuid not null references hr.organizations(id) on delete restrict,
  employee_id uuid not null references hr.employees(id) on delete cascade,
  

  role_type_id uuid not null references master_data(id), -- //角色类型（如项目领导、行政负责人等，来自 master_data）


  start_date date not null,
  end_date date,

  unique (employee_id, organization_id, role_type_id, start_date)
);


create index idx_org_role_assignments_current
on hr.organization_role_assignments(employee_id)
where end_date is null;
