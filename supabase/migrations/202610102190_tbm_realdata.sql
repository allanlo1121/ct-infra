create or replace function tbm.sync_realdata_table(
  p_tbm_code text
)
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_table_schema text := 'tbm';

  v_tbm_code text;
  v_table_name text;
  v_table_regclass regclass;

  r record;

begin

  ----------------------------------------------------------
  -- 1. 参数校验
  ----------------------------------------------------------

  if p_tbm_code is null
     or btrim(p_tbm_code) = '' then
    raise exception 'p_tbm_code cannot be null or empty';
  end if;


  ----------------------------------------------------------
  -- 2. 获取 TBM
  ----------------------------------------------------------

  select t.code
    into v_tbm_code
    from tbm.tbms t
   where t.code = p_tbm_code;

  if v_tbm_code is null then
    raise exception 'TBM not found: %', p_tbm_code;
  end if;


  ----------------------------------------------------------
  -- 3. 生成表名
  ----------------------------------------------------------

  v_table_name := 'shield_' || lower(v_tbm_code);


  ----------------------------------------------------------
  -- 4. 防止并发建表
  ----------------------------------------------------------

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(
      v_table_schema || '.' || v_table_name,
      0
    )
  );

  v_table_regclass := pg_catalog.to_regclass(
    format('%I.%I', v_table_schema, v_table_name)
  );


  ----------------------------------------------------------
  -- 5. 表不存在则创建
  ----------------------------------------------------------

  if v_table_regclass is null then

    execute format(
      '
      create table %I.%I (
        id bigint generated always as identity primary key,

        tbm_code text not null
          references tbm.tbms(code),

        sampled_at timestamptz not null,

        created_at timestamptz not null default now(),

        updated_at timestamptz
      )
      ',
      v_table_schema,
      v_table_name
    );

  end if;


  ----------------------------------------------------------
  -- 6. 同步 PLC 参数字段
  ----------------------------------------------------------

  for r in

    select
      tp.parameter_code,

      case p.data_type
        when 'boolean' then 'boolean'
        when 'integer' then 'integer'
        when 'double'  then 'double precision'
        when 'float'   then 'double precision'
        when 'numeric' then 'numeric'
        when 'text'    then 'text'
        else 'text'
      end as sql_type

    from tbm.tbm_parameters tp

    join tbm.parameters p
      on p.code = tp.parameter_code

    where tp.tbm_code = v_tbm_code
      and coalesce(tp.is_disabled, false) = false

    order by tp.parameter_code

  loop

    execute format(
      '
      alter table %I.%I
      add column if not exists %I %s
      ',
      v_table_schema,
      v_table_name,
      r.parameter_code,
      r.sql_type
    );

  end loop;


  ----------------------------------------------------------
  -- 7. 自动维护 updated_at
  ----------------------------------------------------------

  execute format(
    '
    create or replace trigger trg_set_updated_at
    before update on %I.%I
    for each row
    execute function system.touch_updated_at()
    ',
    v_table_schema,
    v_table_name
  );


  ----------------------------------------------------------
  -- 8. sampled_at 索引
  ----------------------------------------------------------

  execute format(
    '
    create index if not exists %I
    on %I.%I (sampled_at desc)
    ',
    'idx_' || lower(v_tbm_code) || '_sampled_at',
    v_table_schema,
    v_table_name
  );


  ----------------------------------------------------------
  -- 9. 环号索引
  -- s100100008 = 环号
  ----------------------------------------------------------

  if exists (
    select 1
    from information_schema.columns
    where table_schema = v_table_schema
      and table_name = v_table_name
      and column_name = 's100100008'
  ) then

    execute format(
      '
      create index if not exists %I
      on %I.%I (s100100008)
      ',
      'idx_' || lower(v_tbm_code) || '_ring_no',
      v_table_schema,
      v_table_name
    );

  end if;


  ----------------------------------------------------------
  -- 10. 返回表名
  ----------------------------------------------------------

  return format(
    '%I.%I',
    v_table_schema,
    v_table_name
  );

end;
$$;