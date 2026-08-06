

-- ==========================================
-- 盾构机类型 TBM Type
-- ==========================================

INSERT INTO public.master_definitions (name, code)
VALUES ('盾构机类型', 'TBM_TYPE')
ON CONFLICT (code) DO NOTHING;

INSERT INTO public.master_data (definition_id, code, name)
SELECT md.id, v.code, v.name
FROM public.master_definitions md
JOIN (
    VALUES 
    ('45000001', '敞开式TBM'),
    ('45000002', '双护盾TBM'),
    ('45000003', '土压平衡盾构'),
    ('45000004', '泥水盾构'),
    ('45000005', '顶管机'),
    ('45000006', '矿用TBM'),
    ('45000007', '土压泥水双模'),
    ('45000008', '土压敞开双模'),
    ('45000009', '单护盾TBM'),
    ('45000010', '抽水蓄能TBM')
) AS v(code, name)
ON true
WHERE md.code = 'TBM_TYPE'
ON CONFLICT (definition_id, code) DO NOTHING;

-- ==========================================
-- 盾构机作业模式 TBM Operation Mode
-- ==========================================

INSERT INTO public.master_definitions (name, code)
VALUES ('盾构机作业模式', 'TBM_OPERATION_MODE')
ON CONFLICT (code) DO NOTHING;

INSERT INTO public.master_data (definition_id, code, name)
SELECT md.id, v.code, v.name
FROM public.master_definitions md
JOIN (
    VALUES 
    ('45100001', '土压平衡'),
    ('45100002', '敞开式'),
    ('45100003', '泥水平衡'),
    ('45100004', '混合模式')

) AS v(code, name)
ON true
WHERE md.code = 'TBM_OPERATION_MODE'
ON CONFLICT (definition_id, code) DO NOTHING;


-- ==========================================
-- 盾构机厂家
-- ==========================================

insert into hr.customers (
  code,
  name,
  full_name,
  customer_category_id
)
select
  v.code,
  v.name,
  v.full_name,
  md.id
from public.master_data md
join (
  values
    ('75000001', '中铁装备','中铁装备集团有限公司'),
    ('75000002', '中交天和','中交天和集团有限公司'),
    ('75000003', '铁建重工','中国铁建重工集团有限公司'),
    ('75000004', '上海隧道','上海隧道工程有限公司'),
    ('75000005', '三三工业', '辽宁三三工业有限公司'),
    ('75000006', '北方重工', '北方重工集团有限公司'),
    ('75000007', '海瑞克','德国海瑞克'),
    ('75000008', '日本奥村','日本奥村集团有限公司'),
    ('75000009', '罗宾斯','美国罗宾斯公司'),
    ('75000010', '力行', '上海力行奥村机械有限公司')
) as v(code, name, full_name)
  on true
where md.code = '10500009'
on conflict (code) do nothing;