create or replace function tbm.sync_realdata_table(
  p_tbm_code text
)
returns text
language plpgsql
security definer
set search_path = tbm, realdata, public
as $$
declare
  v_table_schema text := 'realdata';

  v_tbm_code text;
  v_table_code text;
  v_table_name text;
  v_table_regclass regclass;

  v_seq_name text;

  v_null_count bigint;

  v_constraint_name text;

  r record;
begin
  ------------------------------------------------------------
  -- 1. 参数校验
  ------------------------------------------------------------

  if p_tbm_code is null or btrim(p_tbm_code) = '' then
    raise exception 'p_tbm_code cannot be null or empty';
  end if;


  ------------------------------------------------------------
  -- 2. 获取 TBM
  ------------------------------------------------------------

  select code
    into v_tbm_code
    from tbm.tbms
   where code = p_tbm_code;

  if v_tbm_code is null then
    raise exception 'TBM not found: %', p_tbm_code;
  end if;


  ------------------------------------------------------------
  -- 3. 生成 realdata 表名
  --
  -- 如果 tbm.code 已经限制为 [a-z0-9_]
  -- 可以直接使用 lower(v_tbm_code)
  --
  -- 这里仍然保留转换，避免非法表名字符
  ------------------------------------------------------------

  v_table_code := lower(v_tbm_code);

  v_table_name :=
    'shield_' || v_table_code;


  ------------------------------------------------------------
  -- 4. 检查表是否存在
  ------------------------------------------------------------

  v_table_regclass :=
    to_regclass(
      format(
        '%I.%I',
        v_table_schema,
        v_table_name
      )
    );


  ------------------------------------------------------------
  -- 5. 表不存在：创建基础表
  ------------------------------------------------------------

  if v_table_regclass is null then

    execute format(
      '
      create table %I.%I (
        id bigint generated always as identity primary key,

        recorded_at timestamptz not null,

        tbm_code text not null
          references tbm.tbms(code)
      )
      ',
      v_table_schema,
      v_table_name
    );


  ------------------------------------------------------------
  -- 6. 表已存在：同步基础字段
  ------------------------------------------------------------

  else

    ----------------------------------------------------------
    -- id
    ----------------------------------------------------------

    execute format(
      '
      alter table %I.%I
      add column if not exists
        id bigint generated always as identity
      ',
      v_table_schema,
      v_table_name
    );


    ----------------------------------------------------------
    -- recorded_at
    --
    -- 已有数据时不能直接 ADD COLUMN ... NOT NULL
    ----------------------------------------------------------

    execute format(
      '
      alter table %I.%I
      add column if not exists
        recorded_at timestamptz
      ',
      v_table_schema,
      v_table_name
    );


    ----------------------------------------------------------
    -- tbm_code
    ----------------------------------------------------------

    execute format(
      '
      alter table %I.%I
      add column if not exists
        tbm_code text
      ',
      v_table_schema,
      v_table_name
    );


    ----------------------------------------------------------
    -- 7. 回填历史 tbm_code
    --
    -- 一张 realdata 表只属于一个 TBM，
    -- 因此这里可以安全回填。
    ----------------------------------------------------------

    execute format(
      '
      update %I.%I
         set tbm_code = $1
       where tbm_code is null
      ',
      v_table_schema,
      v_table_name
    )
    using v_tbm_code;


    ----------------------------------------------------------
    -- 8. 验证 tbm_code
    --
    -- 防止已有数据中存在错误的其它 TBM code
    ----------------------------------------------------------

    execute format(
      '
      select count(*)
        from %I.%I
       where tbm_code is distinct from $1
      ',
      v_table_schema,
      v_table_name
    )
    into v_null_count
    using v_tbm_code;

    if v_null_count > 0 then
      raise exception
        'Table %.% contains % rows with invalid tbm_code, expected: %',
        v_table_schema,
        v_table_name,
        v_null_count,
        v_tbm_code;
    end if;


    ----------------------------------------------------------
    -- 9. tbm_code 设置 NOT NULL
    ----------------------------------------------------------

    execute format(
      '
      alter table %I.%I
      alter column tbm_code set not null
      ',
      v_table_schema,
      v_table_name
    );


    ----------------------------------------------------------
    -- 10. recorded_at
    --
    -- 如果历史数据没有 NULL，则设置 NOT NULL。
    -- 如果存在 NULL，不擅自填充时间。
    ----------------------------------------------------------

    execute format(
      '
      select count(*)
        from %I.%I
       where recorded_at is null
      ',
      v_table_schema,
      v_table_name
    )
    into v_null_count;

    if v_null_count = 0 then

      execute format(
        '
        alter table %I.%I
        alter column recorded_at set not null
        ',
        v_table_schema,
        v_table_name
      );

    end if;


    ----------------------------------------------------------
    -- 11. 保证 tbm_code 外键存在
    ----------------------------------------------------------

    v_constraint_name :=
      'fk_' || v_table_code || '_tbm_code';

    if not exists (
      select 1
        from pg_constraint c
        join pg_class t
          on t.oid = c.conrelid
        join pg_namespace n
          on n.oid = t.relnamespace
       where n.nspname = v_table_schema
         and t.relname = v_table_name
         and c.contype = 'f'
         and pg_get_constraintdef(c.oid)
               like '%FOREIGN KEY (tbm_code)%REFERENCES tbm.tbms(code)%'
    ) then

      execute format(
        '
        alter table %I.%I
        add constraint %I
        foreign key (tbm_code)
        references tbm.tbms(code)
        ',
        v_table_schema,
        v_table_name,
        v_constraint_name
      );

    end if;


    ----------------------------------------------------------
    -- 12. 保证 id 主键
    --
    -- 只有不存在主键时才创建。
    ----------------------------------------------------------

    if not exists (
      select 1
        from pg_constraint c
        join pg_class t
          on t.oid = c.conrelid
        join pg_namespace n
          on n.oid = t.relnamespace
       where n.nspname = v_table_schema
         and t.relname = v_table_name
         and c.contype = 'p'
    ) then

      --------------------------------------------------------
      -- 先检查 id 是否存在 NULL / 重复
      --------------------------------------------------------

      execute format(
        '
        select count(*)
        from %I.%I
        where id is null
        ',
        v_table_schema,
        v_table_name
      )
      into v_null_count;

      if v_null_count > 0 then
        raise exception
          'Cannot create primary key on %.%: id contains % NULL rows',
          v_table_schema,
          v_table_name,
          v_null_count;
      end if;


      execute format(
        '
        select count(*)
          from (
            select id
              from %I.%I
             group by id
            having count(*) > 1
          ) t
        ',
        v_table_schema,
        v_table_name
      )
      into v_null_count;

      if v_null_count > 0 then
        raise exception
          'Cannot create primary key on %.%: id contains duplicate values',
          v_table_schema,
          v_table_name;
      end if;


      execute format(
        '
        alter table %I.%I
        add primary key (id)
        ',
        v_table_schema,
        v_table_name
      );

    end if;

  end if;


  ------------------------------------------------------------
  -- 13. 同步 TBM 参数字段
  ------------------------------------------------------------

  for r in
    select
      tp.parameter_code,

      case p.data_type
        when 'boolean'
          then 'boolean'

        when 'integer'
          then 'integer'

        when 'double'
          then 'double precision'

        when 'float'
          then 'double precision'

        when 'numeric'
          then 'numeric'

        when 'text'
          then 'text'

        else 'text'
      end as sql_type

    from tbm.tbm_parameters tp

    join tbm.parameters p
      on p.code = tp.parameter_code

    where tp.tbm_code = v_tbm_code

    order by
      p.sort_order nulls last,
      tp.parameter_code

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


  ------------------------------------------------------------
  -- 14. recorded_at 索引
  ------------------------------------------------------------

  execute format(
    '
    create index if not exists %I
    on %I.%I (recorded_at desc)
    ',
    'idx_' || v_table_code || '_recorded_at',
    v_table_schema,
    v_table_name
  );


  ------------------------------------------------------------
  -- 15. 环号索引
  --
  -- s100100008 = 环号
  ------------------------------------------------------------

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
      'idx_' || v_table_code || '_ring_no',
      v_table_schema,
      v_table_name
    );

  end if;


  ------------------------------------------------------------
  -- 16. 授权 tbm_writer
  ------------------------------------------------------------

  execute format(
    '
    grant select, insert
    on table %I.%I
    to tbm_writer
    ',
    v_table_schema,
    v_table_name
  );


  ------------------------------------------------------------
  -- 17. identity sequence 授权
  ------------------------------------------------------------

  select pg_get_serial_sequence(
    format(
      '%I.%I',
      v_table_schema,
      v_table_name
    ),
    'id'
  )
  into v_seq_name;

  if v_seq_name is not null then

    execute format(
      '
      grant usage, select
      on sequence %s
      to tbm_writer
      ',
      v_seq_name
    );

  end if;


  ------------------------------------------------------------
  -- 18. 返回实际表名
  ------------------------------------------------------------

  return format(
    '%I.%I',
    v_table_schema,
    v_table_name
  );

end;
$$;



select tbm.sync_realdata_table('xre423');