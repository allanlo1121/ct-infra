

create table hr.customers (

  id uuid primary key default gen_random_uuid(),

  code text not null unique,
  name text not null,
  full_name text not null,
  customer_category_id  uuid not null references public.master_data(id) on delete restrict,

  sort_order int not null default 0,
  is_disabled boolean not null default false,
  remark text

);