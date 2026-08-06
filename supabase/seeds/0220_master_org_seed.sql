-- ==========================================
-- 组织类别 ORG_CATEGORY
-- ==========================================

INSERT INTO public.master_definitions (name, code)
VALUES ('组织类别', 'ORG_TYPE')
ON CONFLICT (code) DO NOTHING;

INSERT INTO public.master_data (definition_id, code, name)
SELECT md.id, v.code, v.name
FROM public.master_definitions md
JOIN (
    VALUES 
    ('10230001', '集团公司'),
    ('10230002', '生产性子分公司'),
    ('10230003', '分公司'),
    ('10230004', '项目部'),
    ('10230005', '部门'),
    ('10230006', '局指'),
    ('10230007', '代局指'),
    ('10230008', '多元业务单位'),
    ('10230009', '分组（虚拟组织）'),
    ('10230010', '专业技术组'),
    ('10230011', '生产组织'),
    ('10230012', '区域指挥部'),
    ('10230013', '分公司（四级）'),
    ('10230014', '阶段性工作机构'),
    ('10230015', '科室'),
    ('10230016', '虚拟项目部'),
    ('10230017', '子公司区域指挥部'),
    ('10230018', '工程指挥部')
) AS v(code, name)
ON true
WHERE md.code = 'ORG_TYPE'
ON CONFLICT (definition_id, code) DO NOTHING;


-- ==========================================
-- 组织主要领导  ORG_ROLE_TYPE
-- ==========================================

INSERT INTO public.master_definitions (name, code)
VALUES ('组织领导', 'ORG_ROLE_TYPE')
ON CONFLICT (code) DO NOTHING;

INSERT INTO public.master_data (definition_id, code, name)
SELECT md.id, v.code, v.name
FROM public.master_definitions md
JOIN (
    VALUES 
    ('11190001', '包保领导'),
    ('11190002', '行政负责人'),
    ('11190003', '党组织负责人'),
    ('11190004', '纪检负责人'),
    ('11190005', '技术负责人'),
    ('11190006', '商务负责人'),
    ('11190007', '安全总监')    
) AS v(code, name)
ON true
WHERE md.code = 'ORG_ROLE_TYPE'
ON CONFLICT (definition_id, code) DO NOTHING;


-- ==========================================
-- 业务板块 BUSINESS
-- ==========================================

INSERT INTO public.master_definitions (name, code)
VALUES ('业务板块', 'ORG_BUSINESS')
ON CONFLICT (code) DO NOTHING;

INSERT INTO public.master_data (definition_id, code, name)
SELECT md.id, v.code, v.name
FROM public.master_definitions md
JOIN (
    VALUES 
    ('10100001', '基建建设'),
    ('10100002', '勘测设计'),
    ('10100003', '工业'),
    ('10100004', '房地产业'),
    ('10100005', '矿产资源'),
    ('10100006', '建筑业上游项目'),
    ('10100007', '技术咨询'),
    ('10100008', '工程监理'),
    ('10100009', '批发零售贸易'),
    ('10100010', '机械租赁'),
    ('10100011', '对外劳务合作'),
    ('10100012', '其他外经外贸业务'),
    ('10100013', '其他')
) AS v(code, name)
ON true
WHERE md.code = 'ORG_BUSINESS'
ON CONFLICT (definition_id, code) DO NOTHING;

-- ==========================================
-- 客商性质 CUSTOMER_NATURE
-- ==========================================

INSERT INTO public.master_definitions (name, code)
VALUES ('客商性质', 'CUSTOMER_NATURE')
ON CONFLICT (code) DO NOTHING;

INSERT INTO public.master_data (definition_id, code, name)
SELECT md.id, v.code, v.name
FROM public.master_definitions md
JOIN (
    VALUES 
    ('10050001', '地方政府'),
    ('10050002', '国资委管理的中央企业'),
    ('10050003', '中国国家铁路集团有限公司'),
    ('10050004', '中央部门管理的企业（不含中国国家铁路集团有限公司）'),
    ('10050005', '地方政府融资平台'),
    ('10050006', '地方国有企业（不含地方政府融资平台）'),
    ('10050007', '民营企业（不含民营房地产开发企业）'),
    ('10050008', '海外企业/政府'),
    ('10050009', '中央政府'),
    ('10050010', '民营房地产开发企业'),
    ('10050011', '部队客商'),
    ('10050012', '其他'),
    ('10050013', '设备厂家')
) AS v(code, name)
ON true
WHERE md.code = 'CUSTOMER_NATURE'
ON CONFLICT (definition_id, code) DO NOTHING;

-- ==========================================
-- 所属区域 REGION
-- ==========================================

INSERT INTO public.master_definitions (name, code)
VALUES ('所属区域', 'REGION')
ON CONFLICT (code) DO NOTHING;

INSERT INTO public.master_data (definition_id, code, name)
SELECT md.id, v.code, v.name
FROM public.master_definitions md
JOIN (
    VALUES 
    ('10090001', '京津冀区域'),
    ('10090002', '北方区域'),
    ('10090003', '晋鲁豫区域'),
    ('10090004', '西部区域'),
    ('10090005', '华东区域'),
    ('10090006', '华南区域'),
    ('10090007', '中南区域'),
    ('10090008', '西南区域'),
    ('10090009', '川渝区域'),
    ('10090010', '海外区域')
) AS v(code, name)
ON true
WHERE md.code = 'REGION'
ON CONFLICT (definition_id, code) DO NOTHING;


-- ==========================================
-- 组织类别 ORG_CATEGORY
-- ==========================================

INSERT INTO public.master_definitions (name, code)
VALUES ('组织类别', 'ORG_CATEGORY')
ON CONFLICT (code) DO NOTHING;

INSERT INTO public.master_data (definition_id, code, name)
SELECT md.id, v.code, v.name
FROM public.master_definitions md
JOIN (
    VALUES 
    ('10250001', '生产型'),
    ('10250002', '综合生产'),
    ('10250003', '专业生产'),
    ('10250004', '设计勘探'),
    ('10250005', '地产开发'),
    ('10250006', '物资贸易'),
    ('10250007', '典当'),
    ('10250008', '文化传媒'),
    ('10250009', '餐饮娱乐'),
    ('10250010', '其他多元')
) AS v(code, name)
ON true
WHERE md.code = 'ORG_CATEGORY'
ON CONFLICT (definition_id, code) DO NOTHING;


-- ==========================================
-- 客商类别 CUSTOMER_CATEGORY
-- ==========================================

INSERT INTO public.master_definitions (name, code)
VALUES ('客商类别', 'CUSTOMER_CATEGORY')
ON CONFLICT (code) DO NOTHING;

INSERT INTO public.master_data (definition_id, code, name)
SELECT md.id, v.code, v.name
FROM public.master_definitions md
JOIN (
    VALUES 
    ('10500001', '业主'),
    ('10500002', '设计单位'),
    ('10500003', '勘察单位'),
    ('10500004', '监理单位'),
    ('10500005', '施工单位'),
    ('10500006', '分包单位'),
    ('10500007', '供应商'),
    ('10500008', '盾构厂家'),
    ('10500009', '设备厂家'),
    ('10500010', '其他')
) AS v(code, name)
ON true
WHERE md.code = 'CUSTOMER_CATEGORY'
ON CONFLICT (definition_id, code) DO NOTHING;





