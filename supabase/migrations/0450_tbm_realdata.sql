create schema if not exists realdata;

create or replace function tbm.sync_realdata_table(p_tbm_id uuid)
returns text
language plpgsql
security definer
set search_path = tbm, realdata, public
as $$
declare
  v_table_schema text := 'realdata';
  v_table_name text;
  v_table_regclass regclass;
  v_tbm_code text;
  r record;
  v_seq_name text;
  v_null_count int;
begin
  if p_tbm_id is null then
    raise exception 'p_tbm_id cannot be null';
  end if;

  -- 获取 TBM code
  select lower(code)
    into v_tbm_code
    from tbm.tbms
   where id = p_tbm_id;

  if v_tbm_code is null then
    raise exception 'TBM not found: %', p_tbm_id;
  end if;

  v_tbm_code := regexp_replace(v_tbm_code, '[^a-z0-9_]', '_', 'g');
  v_table_name := 'shield_' || v_tbm_code;

  -- 检查表是否存在
  v_table_regclass := to_regclass(format('%I.%I', v_table_schema, v_table_name));

  if v_table_regclass is null then
    -- 表不存在，创建基础表
    execute format(
      'create table %I.%I (
         id bigint generated always as identity primary key,
         recorded_at timestamptz not null,
         tbm_id uuid not null
       )',
      v_table_schema,
      v_table_name
    );
  else
    -- 表已存在，保证基础列存在
    execute format(
      'alter table %I.%I add column if not exists id bigint generated always as identity',
      v_table_schema,
      v_table_name
    );

    execute format(
      'alter table %I.%I add column if not exists recorded_at timestamptz not null',
      v_table_schema,
      v_table_name
    );

    execute format(
      'alter table %I.%I add column if not exists tbm_id uuid',
      v_table_schema,
      v_table_name
    );

    -- 设置 tbm_id NOT NULL 前先检查是否有 NULL
    execute format(
      'select count(*) from %I.%I where tbm_id is null',
      v_table_schema,
      v_table_name
    )
    into v_null_count;

    if v_null_count = 0 then
      execute format(
        'alter table %I.%I alter column tbm_id set not null',
        v_table_schema,
        v_table_name
      );
    end if;
  end if;

  -- 添加 TBM 参数字段
  for r in
    select
      p.code,
      case p.data_type
        when 'boolean' then 'boolean'
        when 'integer' then 'integer'
        when 'double' then 'double precision'
        when 'float' then 'double precision'
        when 'numeric' then 'numeric'
        when 'text' then 'text'
        else 'text'
      end as sql_type
    from tbm.tbm_parameter_configs tp
    join tbm.tbm_runtime_parameters p
      on p.id = tp.parameter_id
    where tp.tbm_id = p_tbm_id
      and coalesce(p.is_disabled, false) = false
    order by p.sort_order, p.code
  loop
    execute format(
      'alter table %I.%I add column if not exists %I %s',
      v_table_schema,
      v_table_name,
      r.code,
      r.sql_type
    );
  end loop;

  -- 创建索引
  execute format(
    'create index if not exists %I on %I.%I(recorded_at desc)',
    'idx_' || v_tbm_code || '_time',
    v_table_schema,
    v_table_name
  );

  execute format(
    'create index if not exists %I on %I.%I(tbm_id, recorded_at desc)',
    'idx_' || v_tbm_code || '_tbm_time',
    v_table_schema,
    v_table_name
  );

  -- 针对环号 s100100008 建索引，如果列存在
  if exists (
    select 1
      from information_schema.columns
     where table_schema = v_table_schema
       and table_name = lower(v_table_name)
       and column_name = 's100100008'
  ) then
    execute format(
      'create index if not exists %I on %I.%I(tbm_id, s100100008)',
      'idx_' || v_tbm_code || '_tbm_ring',
      v_table_schema,
      v_table_name
    );
  end if;

  -- 授权 tbm_writer
  execute format(
    'grant insert, select on %I.%I to tbm_writer',
    v_table_schema,
    v_table_name
  );

  -- 授权序列
  select sequence_name
    into v_seq_name
    from information_schema.sequences
   where sequence_schema = v_table_schema
     and sequence_name = format('%I_id_seq', v_table_name);

  if v_seq_name is not null then
    execute format(
      'grant usage, select on %I.%I to tbm_writer',
      v_table_schema,
      v_seq_name
    );
  end if;

  return format('%I.%I', v_table_schema, v_table_name);
end;
$$;