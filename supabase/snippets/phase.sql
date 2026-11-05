drop table tbm.ring_phase_records cascade;

create table tbm.ring_phase_records (
  id bigint generated always as identity primary key,

  tbm_code text not null
    references tbm.tbms(code) on delete restrict,

  tunnel_id uuid not null
    references proj.tunnels(id) on delete restrict,

  ring_no integer not null,

  start_chainage numeric,
  end_chainage numeric,

  tbm_phase_type text not null check (
    tbm_phase_type in (
      'excavation',
      'segment_erection',
      'waiting',
      'stopped',
      'fault',
      'cutter_change',
      'maintenance',
      'unknown'
    )
  ),

  started_at timestamptz not null,
  ended_at timestamptz,

  -- 审计信息
  created_at timestamptz not null default now(),
  created_by uuid,
  updated_at timestamptz,
  updated_by uuid,

  constraint chk_ring_phase_time
    check (ended_at is null or ended_at >= started_at)
);

create trigger trg_tbm_ring_phase_records_audit_insert
before insert on tbm.ring_phase_records
for each row
execute function system.audit_insert();

create trigger trg_tbm_ring_phase_records_audit_update
before update on tbm.ring_phase_records
for each row
execute function system.audit_update();

create trigger trg_tbm_ring_phase_records_audit_delete
before delete on tbm.ring_phase_records
for each row
execute function system.audit_delete();

-- 一台 TBM 最多只有一个当前阶段
create unique index uq_ring_phase_active
on tbm.ring_phase_records (tbm_code)
where ended_at is null;

-- 按隧道、环号查询阶段
create index idx_ring_phase_tunnel_ring
on tbm.ring_phase_records (
  tunnel_id,
  ring_no,
  started_at
);



-- 4. TABLE PERMISSIONS for ring_phase_records
revoke all on table tbm.ring_phase_records
from
  public,
  anon,
  authenticated;

grant
select
,
  insert,
update,
delete on table tbm.ring_phase_records to authenticated;

grant
select
,
  insert,
update,
delete on table tbm.ring_phase_records to service_role;

alter table tbm.ring_phase_records enable row level security;

create policy "tbm_ring_phase_records_read" on tbm.ring_phase_records for
select
  to authenticated using (true);

create policy "tbm_ring_phase_records_insert_authorized" on tbm.ring_phase_records for insert to authenticated
with
  check (
    (
      select
        iam.has_permission ('tbm', 'write')
    )
  );

create policy "tbm_ring_phase_records_update_authorized" on tbm.ring_phase_records
for update
  to authenticated using (
    (
      select
        iam.has_permission ('tbm', 'write')
    )
  )
with
  check (
    (
      select
        iam.has_permission ('tbm', 'write')
    )
  );

create policy "tbm_ring_phase_records_delete_authorized" on tbm.ring_phase_records for delete to authenticated using (
  (
    select
      iam.has_permission ('tbm', 'delete')
  )
);


alter table tbm.ring_phase_records
add column   start_chainage numeric,
add column   end_chainage numeric;





-- 注意：新增参数会形成一个新的函数签名。
-- 部署前应先删除旧签名，避免 Supabase RPC 重载歧义。
drop function if exists tbm.apply_ring_phase(
  text, uuid, integer, text, timestamptz,numeric
);

create or replace function tbm.apply_ring_phase(
  p_tbm_code text,
  p_tunnel_id uuid,
  p_ring_no integer,
  p_phase_type text,
  p_started_at timestamptz,
  p_chainage numeric
)
returns jsonb
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_current tbm.ring_phase_records%rowtype;

  v_ring_changed boolean;
  v_phase_changed boolean;
  v_ring_difference bigint;
  v_change_type text;
  v_warning text := null;
begin
  -- 1. 参数校验
  if p_tbm_code is null
     or p_tunnel_id is null
     or p_ring_no is null
     or p_phase_type is null
     or p_started_at is null then
    raise exception 'Ring phase arguments cannot be null'
      using errcode = '22004';
  end if;

  -- 2. 同一 TBM 串行处理
  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(p_tbm_code, 0)
  );

  -- 3. 查询当前活动阶段
  select *
  into v_current
  from tbm.ring_phase_records
  where tbm_code = p_tbm_code
    and ended_at is null
  for update;

  -- 4. 首次初始化
  if not found then
    insert into tbm.ring_phase_records (
      tbm_code,
      tunnel_id,
      ring_no,
      tbm_phase_type,
      started_at,
      start_chainage
    )
    values (
      p_tbm_code,
      p_tunnel_id,
      p_ring_no,
      p_phase_type,
      p_started_at,
      p_chainage
    );

    return pg_catalog.jsonb_build_object(
      'changed', true,
      'changeType', 'initialized',
      'warning', null,
      'tbmCode', p_tbm_code,
      'tunnelId', p_tunnel_id,
      'previousRing', null,
      'currentRing', p_ring_no,
      'ringDifference', null,
      'previousPhase', null,
      'currentPhase', p_phase_type,
      'startedAt', p_started_at,
      'chainage', p_chainage
    );
  end if;

  -- 5. 隧道一致性校验
  if v_current.tunnel_id <> p_tunnel_id then
    raise exception
      'TBM % tunnel mismatch: current %, incoming %',
      p_tbm_code,
      v_current.tunnel_id,
      p_tunnel_id
      using errcode = '22023';
  end if;

  -- 6. 过期数据判断：只比较当前阶段开始时间
  if p_started_at <= v_current.started_at then
    return pg_catalog.jsonb_build_object(
      'changed', false,
      'changeType', 'stale',
      'warning', null,
      'tbmCode', p_tbm_code,
      'tunnelId', p_tunnel_id,
      'previousRing', v_current.ring_no,
      'currentRing', p_ring_no,
      'ringDifference', null,
      'previousPhase', v_current.tbm_phase_type,
      'currentPhase', p_phase_type,
      'startedAt', p_started_at,
      'chainage', p_chainage
    );
  end if;

  -- 7. 判断环号、阶段变化
  v_ring_changed :=
    v_current.ring_no is distinct from p_ring_no;

  v_phase_changed :=
    v_current.tbm_phase_type is distinct from p_phase_type;

  v_ring_difference :=
    p_ring_no::bigint - v_current.ring_no::bigint;

  -- 8. 环号回退：拒绝更新
  if v_ring_difference < 0 then
    return pg_catalog.jsonb_build_object(
      'changed', false,
      'changeType', 'rejected',
      'warning', 'ring_rollback',
      'tbmCode', p_tbm_code,
      'tunnelId', p_tunnel_id,
      'previousRing', v_current.ring_no,
      'currentRing', p_ring_no,
      'ringDifference', v_ring_difference,
      'previousPhase', v_current.tbm_phase_type,
      'currentPhase', p_phase_type,
      'startedAt', p_started_at,
      'chainage', p_chainage
    );
  end if;

  -- 9. 环号跳跃超过 3：允许更新并警告
  if v_ring_difference > 3 then
    v_warning := 'ring_jump';
  end if;

  -- 10. 状态没有变化：不写数据库
  if not (v_ring_changed or v_phase_changed) then
    return pg_catalog.jsonb_build_object(
      'changed', false,
      'changeType', 'unchanged',
      'warning', null,
      'tbmCode', p_tbm_code,
      'tunnelId', p_tunnel_id,
      'previousRing', v_current.ring_no,
      'currentRing', p_ring_no,
      'ringDifference', 0,
      'previousPhase', v_current.tbm_phase_type,
      'currentPhase', p_phase_type,
      'startedAt', p_started_at,
      'chainage', p_chainage
    );
  end if;

  -- 11. 判断变化类型
  v_change_type := case
    when v_ring_changed and v_phase_changed then 'both_changed'
    when v_ring_changed then 'ring_changed'
    else 'phase_changed'
  end;

  -- 12. 结束上一阶段
  update tbm.ring_phase_records
  set
    ended_at = p_started_at,
    end_chainage = p_chainage
  where id = v_current.id;

  -- 13. 创建新的当前阶段
  insert into tbm.ring_phase_records (
    tbm_code,
    tunnel_id,
    ring_no,
    tbm_phase_type,
    started_at,
    start_chainage
  )
  values (
    p_tbm_code,
    p_tunnel_id,
    p_ring_no,
    p_phase_type,
    p_started_at,
    p_chainage
  );

  -- 14. 返回结果
  return pg_catalog.jsonb_build_object(
    'changed', true,
    'changeType', v_change_type,
    'warning', v_warning,
    'tbmCode', p_tbm_code,
    'tunnelId', p_tunnel_id,
    'previousRing', v_current.ring_no,
    'currentRing', p_ring_no,
    'ringDifference', v_ring_difference,
    'previousPhase', v_current.tbm_phase_type,
    'currentPhase', p_phase_type,
    'startedAt', p_started_at,
    'chainage', p_chainage
  );
end;
$$;
