
--学历专业
create table hr.educations (
  id uuid primary key default gen_random_uuid(),

  employee_id uuid not null ,

  degree_id uuid references public.master_data(id) on delete set null,  -- 学历层次
  school text,

  education_level_id uuid references master_data(id) on delete set null,

  major_id uuid references public.master_data(id) on delete set null,   -- 学历专业

  start_date date,
  end_date date,


  constraint fk_education_employee
    foreign key (employee_id) references hr.employees(id) on delete cascade
);


--职称
create table hr.employee_titles (
  id uuid primary key default gen_random_uuid(),

  employee_id uuid not null,
  title_id uuid not null,

  obtained_date date,


  constraint fk_title_employee
    foreign key (employee_id) references hr.employees(id) on delete cascade
);

