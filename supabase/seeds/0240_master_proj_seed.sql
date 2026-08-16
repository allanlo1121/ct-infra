-- ==========================================
-- 项目状态 PROJECT_STATUS
-- ==========================================

INSERT INTO public.master_definitions (name, code)
VALUES ('项目状态', 'PROJECT_STATUS')
ON CONFLICT (code) DO NOTHING;

INSERT INTO public.master_data (definition_id, code, name)
SELECT md.id, v.code, v.name
FROM public.master_definitions md
JOIN (
    VALUES 
    ('10200001', '未开工'),
    ('10200002', '在建'),
    ('10200003', '收尾'),
    ('10200004', '竣工')
) AS v(code, name)
ON true
WHERE md.code = 'PROJECT_STATUS'
ON CONFLICT (definition_id, code) DO NOTHING;


-- ==========================================
-- 项目性质 PROJECT_NATURE
-- ==========================================

INSERT INTO public.master_definitions (name, code)
VALUES ('项目性质', 'PROJECT_NATURE')
ON CONFLICT (code) DO NOTHING;

INSERT INTO public.master_data (definition_id, code, name)
SELECT md.id, v.code, v.name
FROM public.master_definitions md
JOIN (
    VALUES 
    ('10210001', '局指'),
    ('10210002', '局指参建项目'),
    ('10210003', '代局指'),
    ('10210004', '代局指主责项目'),
    ('10210005', '代局指非主责项目'),
    ('10210006', '授权管理项目'),
    ('10210007', '（子）公司自管项目'),
    ('10210008', '虚拟指挥部')
) AS v(code, name)
ON true
WHERE md.code = 'PROJECT_NATURE'
ON CONFLICT (definition_id, code) DO NOTHING;


-- ==========================================
-- 工号类型 PROJECT_CATALOG_TYPE
-- ==========================================

INSERT INTO public.master_definitions (name, code)
VALUES ('工号类型', 'PROJECT_CATALOG_TYPE')
ON CONFLICT (code) DO NOTHING;

INSERT INTO public.master_data (definition_id, code, name)
SELECT md.id, v.code, v.name
FROM public.master_definitions md
JOIN (
    VALUES 
    ('10010001', '工程类型'),
    ('10010002', '专业类型'),
    ('10010003', '单位工程'),
    ('10010004', '子单位工程'),
    ('10010005', '分部工程'),
    ('10010006', '子分部工程'),
    ('10010007', '分项工程'),
    ('10010008', '单项工程')
) AS v(code, name)
ON true
WHERE md.code = 'PROJECT_CATALOG_TYPE'
ON CONFLICT (definition_id, code) DO NOTHING;


-- ==========================================
-- 工程专业 PROJECT_MAJOR
-- ==========================================

INSERT INTO public.master_definitions (name, code)
VALUES ('工程专业', 'PROJECT_MAJOR')
ON CONFLICT (code) DO NOTHING;

INSERT INTO public.master_data (definition_id, code, name)
SELECT md.id, v.code, v.name
FROM public.master_definitions md
JOIN (
    VALUES 
    ('10030001', '迁改工程'),
    ('10030002', '前期工程'),
    ('10030003', '临建工程'),
    ('10030004', '路基专业'),
    ('10030005', '路面专业'),
    ('10030006', '桥涵专业'),
    ('10030007', '隧道专业'),
    ('10030008', '房建专业'),
    ('10030009', '站场专业'),
    ('10030010', '轨道专业'),
    ('10030011', '附属工程'),
    ('10030012', '交通专业'),
    ('10030013', '绿化专业'),
    ('10030014', '给排水专业'),
    ('10030015', '土建专业'),
    ('10030016', '安装专业'),
    ('10030017', '园林专业'),
    ('10030018', '水利专业'),
    ('10030019', '水电专业'),
    ('10030020', '通信专业'),
    ('10030021', '信号专业'),
    ('10030022', '信息专业'),
    ('10030023', '电力专业'),
    ('10030024', '电力牵引供电专业'),
    ('10030025', '机电专业')
) AS v(code, name)
ON true
WHERE md.code = 'PROJECT_MAJOR'
ON CONFLICT (definition_id, code) DO NOTHING;

-- ==========================================
-- 承包模式 CONTRACT_CODE
-- ==========================================

INSERT INTO public.master_definitions (name, code)
VALUES ('承包模式', 'CONTRACT_CODE')
ON CONFLICT (code) DO NOTHING;

INSERT INTO public.master_data (definition_id, code, name)
SELECT md.id, v.code, v.name
FROM public.master_definitions md
JOIN (
    VALUES 
    ('10080001', '工程总承包'),
    ('10080002', '设计施工总承包'),
    ('10080003', '施工总承包'),
    ('10080004', '固定单价'),
    ('10080005', '联营体'),
    ('10080006', 'BT'),
    ('10080007', '单项费用包干'),
    ('10080008', 'BOT'),
    ('10080009', 'PPP')
) AS v(code, name)
ON true
WHERE md.code = 'CONTRACT_CODE'
ON CONFLICT (definition_id, code) DO NOTHING;

-- ==========================================
-- 工程类型 PROJECT_TYPE
-- ==========================================

INSERT INTO public.master_definitions (name, code)
VALUES ('工程类型', 'PROJECT_TYPE')
ON CONFLICT (code) DO NOTHING;

INSERT INTO public.master_data (definition_id, code, name)
SELECT md.id, v.code, v.name
FROM public.master_definitions md
JOIN (
    VALUES 
    ('10110001', '铁路工程'),
    ('10110002', '公路工程'),
    ('10110003', '市政工程'),
    ('10110004', '房建工程'),
    ('10110005', '城市轨道交通工程'),
    ('10110006', '水利水电工程'),
    ('10110007', '其他工程')
) AS v(code, name)
ON true
WHERE md.code = 'PROJECT_TYPE'
ON CONFLICT (definition_id, code) DO NOTHING;


-- ==========================================
-- 工程子类型 PROJECT_SUB_TYPE
-- ==========================================

INSERT INTO public.master_definitions (name, code)
VALUES ('工程子类型', 'PROJECT_SUB_TYPE')
ON CONFLICT (code) DO NOTHING;

INSERT INTO public.master_data (definition_id, code, name)
SELECT md.id, v.code, v.name
FROM public.master_definitions md
JOIN (
    VALUES 
    ('20550001', '高铁'),
    ('20550002', '客专'),
    ('20550003', '一般铁路'),
    ('20550004', '高速公路'),
    ('20550005', '一般公路'),
    ('20550006', '轻轨'),
    ('20550007', '地铁'),
    ('20550008', '高层房建'),
    ('20550009', '一般房建')
) AS v(code, name)
ON true
WHERE md.code = 'PROJECT_SUB_TYPE'
ON CONFLICT (definition_id, code) DO NOTHING;


-- ==========================================
-- 工程性质 ENGINEERING_NATURE
-- ==========================================

INSERT INTO public.master_definitions (name, code)
VALUES ('工程性质', 'ENGINEERING_NATURE')
ON CONFLICT (code) DO NOTHING;

INSERT INTO public.master_data (definition_id, code, name)
SELECT md.id, v.code, v.name
FROM public.master_definitions md
JOIN (
    VALUES 
    ('10120001', '公司自管工程'),
    ('10120002', '代局指工程'),
    ('10120003', '子公司自管'),
    ('10120004', '授权管理工程')
) AS v(code, name)
ON true
WHERE md.code = 'ENGINEERING_NATURE'
ON CONFLICT (definition_id, code) DO NOTHING;

-- ==========================================
-- 合同主体 USE_QUALIFICATION
-- ==========================================

INSERT INTO public.master_definitions (name, code)
VALUES ('合同主体', 'USE_QUALIFICATION')
ON CONFLICT (code) DO NOTHING;

INSERT INTO public.master_data (definition_id, code, name)
SELECT md.id, v.code, v.name
FROM public.master_definitions md
JOIN (
    VALUES 
    ('10130001', '股份公司'),
    ('10130002', '集团公司'),
    ('10130003', '子公司'),
    ('10130004', '联合体')
) AS v(code, name)
ON true
WHERE md.code = 'USE_QUALIFICATION'
ON CONFLICT (definition_id, code) DO NOTHING;



-- ==========================================
-- 风险等级 PROJECT_RISK_LEVEL
-- ==========================================

INSERT INTO public.master_definitions (name, code)
VALUES ('风险等级', 'PROJECT_RISK_LEVEL')
ON CONFLICT (code) DO NOTHING;

INSERT INTO public.master_data (definition_id, code, name)
SELECT md.id, v.code, v.name
FROM public.master_definitions md
JOIN (
    VALUES 
    ('20140001', '重大风险项目'),
    ('20140002', '较大风险项目'),
    ('20140003', '一般风险项目'),
    ('20140004', '低风险项目')
) AS v(code, name)
ON true
WHERE md.code = 'PROJECT_RISK_LEVEL'
ON CONFLICT (definition_id, code) DO NOTHING;


-- ==========================================
-- 项目子状态  PROJECT_SUB_STATUS
-- ==========================================

INSERT INTO public.master_definitions (name, code)
VALUES ('项目子状态', 'PROJECT_SUB_STATUS')
ON CONFLICT (code) DO NOTHING;

INSERT INTO public.master_data (definition_id, code, name)
SELECT md.id, v.code, v.name
FROM public.master_definitions md
JOIN (
    VALUES 
    ('20160001', '未开工'),
    ('20160002', '正常在建'),
    ('20160003', '冬休'),
    ('20160004', '停工'),
    ('20160005', '已完工未竣工'),
    ('20160006', '已竣工未交付'),
    ('20160007', '未竣工已交付'),
    ('20160008', '已竣工已交付')
) AS v(code, name)
ON true
WHERE md.code = 'PROJECT_SUB_STATUS'
ON CONFLICT (definition_id, code) DO NOTHING;

-- ==========================================
-- 项目管控级别  PROJECT_CONTROL_LEVEL
-- ==========================================

INSERT INTO public.master_definitions (name, code)
VALUES ('项目管控级别', 'PROJECT_CONTROL_LEVEL')
ON CONFLICT (code) DO NOTHING;

INSERT INTO public.master_data (definition_id, code, name)
SELECT md.id, v.code, v.name
FROM public.master_definitions md
JOIN (
    VALUES 
    ('20130001', '一级管控级别'),
    ('20130002', '二级管控级别'),
    ('20130003', '三级管控级别'),
    ('20130004', '无')
) AS v(code, name)
ON true
WHERE md.code = 'PROJECT_CONTROL_LEVEL'
ON CONFLICT (definition_id, code) DO NOTHING;


-- ==========================================
-- 项目关注类别  PROJECT_ATTENTION_LEVEL
-- ==========================================

INSERT INTO public.master_definitions (name, code)
VALUES ('项目关注等级', 'PROJECT_ATTENTION_LEVEL')
ON CONFLICT (code) DO NOTHING;

INSERT INTO public.master_data (definition_id, code, name)
SELECT md.id, v.code, v.name
FROM public.master_definitions md
JOIN (
    VALUES 
    ('20560001', '重点项目'),
    ('20560002', '关注项目'),
    ('20560003', '一般项目')
) AS v(code, name)
ON true
WHERE md.code = 'PROJECT_ATTENTION_LEVEL'
ON CONFLICT (definition_id, code) DO NOTHING;

-- ==========================================
-- 项目关注类型  PROJECT_ATTENTION_TYPE
-- ==========================================

INSERT INTO public.master_definitions (name, code)
VALUES ('项目关注类型', 'PROJECT_ATTENTION_TYPE')
ON CONFLICT (code) DO NOTHING;

INSERT INTO public.master_data (definition_id, code, name)
SELECT md.id, v.code, v.name
FROM public.master_definitions md
JOIN (
    VALUES 
    ('20570001', '安全类型'),
    ('20570002', '工期类型'),
    ('20570003', '质量类型'),
    ('20570004', '技术类型'),
    ('20570005', '文明施工'),
    ('20570006', '维稳')
) AS v(code, name)
ON true
WHERE md.code = 'PROJECT_ATTENTION_TYPE'
ON CONFLICT (definition_id, code) DO NOTHING;




insert into proj.geo_rock_classes (
  code,
  name,
  sort_order
)
values
  ('I',     '一类围岩', 1),
  ('II',    '二类围岩', 2),
  ('III',   '三类围岩', 3),
  ('IV',    '四类围岩', 4),
  ('V',     '五类围岩', 5),
  ('VI',    '六类围岩', 6)
on conflict (code) do update
set
  name = excluded.name,
  remark = excluded.remark,
  sort_order = excluded.sort_order,
  updated_at = now();



INSERT INTO proj.geo_classes (
    id,
    parent_id, 
    code,
    name,
    layer,
    remark, 
    sort_order
) VALUES 
    (1,null, null, '岩石', 1, '岩石', 1),
    (2, null, null,'土', 1, '土', 2);

INSERT INTO proj.geo_classes (
    id,    
    parent_id, 
    code,
    name,
    layer,
    remark
) VALUES 
 (3, 1, null, '岩浆岩/火成岩', 2, null),
 (4, 2, null, '碎石土', 2, null),
 (5, 1, null, '沉积岩/水成岩', 2, null),
 (21, 1, null, '变质岩', 2, null),
 (24, 2, null, '黏性土', 2, null),
 (30, 2, null, '砂土', 2, null),
 (31, 2, null, '粉质土', 2, null),
 (32, 2, null, '淤泥性土', 2, null),
 (33, 2, null, '特殊土', 2, null),
 (91, 2, null, '软土', 2, null),
 (93, 2, null, '块状强风化粉砂岩', 2, null),
 (94, 1, null, '风化岩', 2, null),
 (151, 1, null, '普通地层', 2, null),
 (153, 1, null, '短链', 2, null),
 (158, 1, null, '软岩', 2, null),
 (159, 1, null, '上软下硬', 2, null),
 (160, 1, null, '硬岩', 2, null),
 (162, 1, null, '可溶岩', 2, null),
 (163, 1, null, '强/弱透水层分界面', 2, null),
 (164, 1, null, '灰岩、白云岩', 2, null),
 (165, 1, null, '白云岩、砂屑白云岩', 2, null),
 (166, 1, null, '灰岩、灰岩夹页岩', 2, null),
 (177, 2, null, '粉细砂④1、中粗砂④2', 2, null),
 (178, 2, null, '粉细砂④1', 2, null),
 (179, 2, null, '粉细砂④1、粉质黏土④4', 2, null),
 (180, 2, null, '粉细砂④1、粉质黏土⑤1、粉土⑤2', 2, null),
 (196, 1, null, '砂砾岩、粗砂岩', 2, null),
 (199, 1, null, '糜棱岩/碎裂岩', 2, null),
 (201, 1, null, '破碎带', 2, null),
 (215, 1, null, '变粒岩', 2, null),
 (223, 1, null, '断层角砾、糜棱岩、碎块岩', 2, null),
 (243, 1, null, '混合岩', 2, null),
 (274, 1, null, '中等风化砂岩、微风化砂岩、块状强风化砂岩、土状强风化砂岩、全风化砂岩、黏性土', 2, null),
 (277, 1, null, '变粒岩、云母石英片岩，弱风化为主', 2, null),
 (278, 1, null, '碎屑岩、碎裂岩、糜棱岩及断层泥等物质组成,软岩~极软岩', 2, null),
 (296, 2, null, '混合地层', 2, null);



INSERT INTO proj.geo_classes (
    id,
    parent_id, 
    code,
    name,
    layer,
    remark
) VALUES 
 (6, 3, null, '花岗岩', 3, null),
 (8, 3, null, '正长岩', 3, null),
 (9, 3, null, '闪长岩', 3, null),
 (10, 4, null, '漂石', 3, null),
 (22, 21, null, '片麻岩', 3, null),
 (23, 21, null, '片岩', 3, null),
 (25, 24, null, '粉质黏土', 3, null),
 (26, 21, null, '角闪岩', 3, null),
 (28, 5, null, '石灰岩', 3, null),
 (29, 5, null, '砂岩', 3, null),
 (34, 3, null, '辉岩', 3, null),
 (35, 3, null, '玢岩', 3, null),
 (36, 3, null, '流纹岩', 3, null),
 (37, 3, null, '玄武岩', 3, null),
 (38, 3, null, '安山岩', 3, null),
 (39, 5, null, '石英岩', 3, null),
 (40, 5, null, '砾岩', 3, null),
 (41, 5, null, '泥岩', 3, null),
 (42, 5, null, '页岩', 3, null),
 (43, 5, null, '白云岩', 3, null),
 (44, 21, null, '千枚岩', 3, null),
 (45, 21, null, '板岩', 3, null),
 (46, 21, null, '大理岩', 3, null),
 (47, 21, null, '石英岩', 3, null),
 (48, 4, null, '块石', 3, null),
 (49, 4, null, '卵石', 3, null),
 (50, 4, null, '碎石', 3, null),
 (51, 4, null, '圆砾', 3, null),
 (52, 4, null, '角砾', 3, null),
 (53, 30, null, '砾砂', 3, null),
 (54, 30, null, '粗砂', 3, null),
 (56, 30, null, '中砂', 3, null),
 (57, 30, null, '细砂', 3, null),
 (58, 30, null, '粉砂', 3, null),
 (59, 31, null, '粉土', 3, null),
 (60, 31, null, '黏质粉土', 3, null),
 (61, 31, null, '砂质粉土', 3, null),
 (62, 24, null, '黏土', 3, null),
 (63, 32, null, '淤泥质土', 3, null),
 (64, 32, null, '淤泥', 3, null),
 (65, 32, null, '流泥', 3, null),
 (66, 32, null, '浮泥', 3, null),
 (67, 33, null, '湿陷性土', 3, null),
 (68, 33, null, '红黏土', 3, null),
 (69, 33, null, '冻土', 3, null),
 (70, 33, null, '膨胀土', 3, null),
 (71, 33, null, '盐渍土', 3, null),
 (72, 33, null, '混合土', 3, null),
 (73, 33, null, '填土', 3, null),
 (74, 33, null, '污染土', 3, null),
 (75, 5, null, '角砾岩', 3, null),
 (76, 5, null, '凝灰岩', 3, null),
 (77, 5, null, '凝灰质砂岩', 3, null),
 (90, 5, null, '灰岩', 3, null),
 (95, 94, null, '微风化灰岩', 3, null),
 (96, 94, null, '中风化灰岩', 3, null),
 (97, 94, null, '中风化粉砂岩', 3, null),
 (99, 91, null, '土状强风化粉砂岩', 3, null),
 (100, 94, null, '块状强风化粉砂岩', 3, null),
 (101, 94, null, '强风化粉砂岩', 3, null),
 (102, 94, null, '微风化岩', 3, null),
 (103, 94, null, '微风化花岗岩', 3, null),
 (104, 94, null, '中等风化岩', 3, null),
 (105, 94, null, '土状强风化岩', 3, null),
 (106, 91, null, '全风化岩', 3, null),
 (107, 94, null, '块状强风化花岗岩', 3, null),
 (108, 94, null, '中风化花岗岩', 3, null),
 (109, 94, null, '中风化石英砂岩', 3, null),
 (110, 94, null, '强风化断裂破碎带', 3, null),
 (111, 94, null, '微风化石英砂岩', 3, null),
 (112, 94, null, '微风化石英岩', 3, null),
 (113, 94, null, '强风化石英岩', 3, null),
 (114, 94, null, '千枚岩', 3, null),
 (115, 94, null, '中风化石英岩', 3, null),
 (116, 94, null, '弱风化板岩夹砂岩', 3, null),
 (117, 94, null, '弱风化板岩', 3, null),
 (118, 94, null, '弱风化板岩', 3, null),
 (119, 94, null, '弱风化花岗闪长岩', 3, null),
 (120, 94, null, '弱风化二长花岗岩', 3, null),
 (121, 94, null, '微风化玄武岩', 3, null),
 (122, 94, null, '强风化泥质粉砂岩地层', 3, null),
 (123, 94, null, '微风化安山岩', 3, null),
 (124, 94, null, '中风化岩层', 3, null),
 (125, 94, null, '微风化岩层', 3, null),
 (126, 33, null, '回填土', 3, null),
 (127, 33, null, '富水砂层', 3, null),
 (128, 94, null, '微风化地层', 3, null),
 (129, 94, null, '中等风化玄武岩', 3, null),
 (130, 94, null, '中等风化安山岩', 3, null),
 (131, 94, null, '中等风化泥质粉砂岩', 3, null),
 (132, 94, null, '微风化粉砂岩', 3, null),
 (133, 94, null, '微风化炭质粉 砂岩', 3, null),
 (134, 94, null, '中 等风化碎裂岩', 3, null),
 (135, 94, null, '中等风化石粉砂岩', 3, null),
 (136, 94, null, '强风化碎裂岩', 3, null),
 (137, 94, null, '复合地层(灰岩段）', 3, null),
 (138, 94, null, '块状强风化石英砂岩', 3, null),
 (139, 24, null, '砂质粘性土', 3, null),
 (140, 94, null, '土状强风化混合花岗岩', 3, null),
 (141, 94, null, '土状强风化花岗岩', 3, null),
 (142, 24, null, '砾质粘性土', 3, null),
 (143, 94, null, '中风化碎裂岩', 3, null),
 (144, 94, null, '微风化混合花岗岩', 3, null),
 (145, 94, null, '中等风化混合花岗岩', 3, null),
 (146, 24, null, '黏性土', 3, null),
 (147, 94, null, '全风化石英砂岩', 3, null),
 (148, 94, null, '块状强风化石英砂岩', 3, null),
 (149, 33, null, '素填土', 3, null),
 (150, 94, null, '中微风化灰岩', 3, null),
 (152, 94, null, '土状强风化粉砂岩', 3, null),
 (154, 94, null, '中等风化灰岩', 3, null),
 (155, 94, null, '强风化泥岩夹砂岩', 3, null),
 (156, 94, null, '弱风化泥岩夹砂岩', 3, null),
 (157, 91, null, '弱风化泥岩夹砂岩', 3, null),
 (167, 94, null, '黑云二长花岗片麻岩', 3, null),
 (168, 94, null, '片麻岩', 3, null),
 (169, 94, null, '花岗片麻岩', 3, null),
 (170, 94, null, '片麻岩、角闪岩', 3, null),
 (171, 94, null, '砂质页岩、页岩', 3, null),
 (172, 94, null, '土状强风化砂岩', 3, null),
 (173, 94, null, '块状强风化砂岩', 3, null),
 (174, 94, null, '全断面硬岩', 3, null),
 (175, 94, null, '块状强风化砂岩、中风化砂岩', 3, null),
 (176, 94, null, '土状强风化碎裂岩', 3, null),
 (181, 24, null, '粉质黏土、泥质细砂', 3, null),
 (182, 30, null, '泥质细砂', 3, null),
 (190, 94, null, '斑状花岗岩', 3, null),
 (191, 94, null, '微风化斑状花岗岩、花岗岩片麻岩', 3, null),
 (193, 94, null, '弱风化花岗岩', 3, null),
 (194, 94, null, '强风化花岗岩', 3, null),
 (195, 94, null, '全风化花岗岩', 3, null),
 (220, 21, null, '变质泥质粉砂岩', 3, null),
 (221, 215, null, '变粒岩，南华纪侵入岩', 3, null),
 (222, 94, null, '弱风化混合花岗岩、强风化砂岩', 3, null),
 (224, 94, null, '弱风化层变粒岩、弱风化层浅粒岩', 3, null),
 (227, 94, null, '风化混合岩', 3, null),
 (228, 94, null, '全风化变质砂岩', 3, null),
 (229, 94, null, '全风化砂砾岩', 3, null),
 (230, 94, null, '全风化砂岩', 3, null),
 (231, 24, null, '粉质黏土、淤泥质砂', 3, null),
 (232, 24, null, '粉质黏土、淤泥质砂、淤泥质黏土', 3, null),
 (233, 24, null, '粉质黏土、淤泥质黏土', 3, null),
 (234, 32, null, '淤质粘土', 3, null),
 (235, 91, null, '全风化变质砂岩', 3, null),
 (236, 94, null, '上全中强下弱风化灰岩', 3, null),
 (237, 94, null, '上全下强风化变质砂岩', 3, null),
 (238, 94, null, '强风化变质砂岩', 3, null),
 (240, 94, null, '上强变质砂岩下溶洞', 3, null),
 (241, 94, null, '上强下弱风化变质砂岩', 3, null),
 (242, 94, null, '弱风化变质砂岩', 3, null),
 (244, 94, null, '上强下弱风化灰岩', 3, null),
 (245, 94, null, '强风化灰岩', 3, null),
 (246, 94, null, '上全中强下弱风化灰岩', 3, null),
 (247, 94, null, '弱风化灰岩', 3, null),
 (248, 94, null, '上全下强风化灰岩', 3, null),
 (249, 94, null, '上混合岩下全风化灰岩', 3, null),
 (250, 94, null, '弱风化砂岩', 3, null),
 (251, 94, null, '上弱风化灰岩下溶洞', 3, null),
 (253, 21, null, '变质细砂岩、变粒岩', 3, null),
 (255, 94, null, '变质砂岩、微片岩', 3, null),
 (256, 21, null, '变质砂岩', 3, null),
 (257, 94, null, '强风化安山岩', 3, null),
 (262, 94, null, '弱风化泥质砂岩', 3, null),
 (263, 94, null, '强风化泥质砂岩', 3, null),
 (265, 91, null, '全风化泥质砂岩', 3, null),
 (266, 91, null, '强风化泥质砂岩', 3, null),
 (268, 24, null, '黄土状粉质黏土', 3, null),
 (269, 31, null, '黄土状粉土', 3, null),
 (270, 30, null, '粉细砂层', 3, null),
 (271, 94, null, '中风化砂岩', 3, null),
 (272, 94, null, '全风化砂岩、微风化砂岩、微风化粗粒花岗岩', 3, null),
 (273, 94, null, '微风化粗粒花岗岩、中等风化粗粒花岗岩、中风化砂岩、微风化砂岩', 3, null),
 (275, 94, null, '微风化粗粒花岗岩', 3, null),
 (276, 215, null, '变粒岩', 3, null),
 (279, 94, null, '强风化砂砾岩', 3, null),
 (280, 94, null, '强风化粉砂岩', 3, null),
 (281, 94, null, '弱风化钙质砂岩', 3, null),
 (282, 94, null, '泥质砂岩', 3, null),
 (283, 94, null, '弱风化粉砂岩', 3, null),
 (284, 94, null, '花岗岩、斜长片麻岩、闪长玢岩', 3, null),
 (285, 94, null, '闪长岩、角闪岩', 3, null),
 (292, 21, null, '变粒岩', 3, null),
 (294, 94, null, '中风化中粒花岗岩', 3, null),
 (295, 94, null, '微风化中粒花岗岩', 3, null),
 (297, 296, null, '素填土、淤泥质黏性土、全风化、块状、土状强风化砂岩', 3, null),
 (298, 296, null, '土状、块状强风化砂岩、中微风化砂岩', 3, null),
 (299, 296, null, '素填土、黏性土、全风化砂岩', 3, null),
 (300, 91, null, '全风化粗粒花岗岩', 3, null),
 (301, 91, null, '强偏中风化粉砂质泥岩', 3, null),
 (302, 94, null, '中等风化粉砂质泥岩', 3, null),
 (303, 94, null, '微风化石英质砂岩', 3, null),
 (304, 94, null, '微风化岩屑砂岩', 3, null),
 (305, 94, null, '中等风化岩屑砂岩', 3, null),
 (306, 94, null, '微风化粉砂质泥岩', 3, null),
 (307, 91, null, '全风化中粒花岗岩', 3, null),
 (308, 91, null, '土状强风化中粒花岗岩', 3, null),
 (309, 91, null, '全风化砂岩', 3, null),
 (310, 91, null, '粉质黏土、粉细砂', 3, null),
 (311, 91, null, '粉质黏土、粉细砂、中粗砂', 3, null),
 (312, 91, null, '中粗砂、粉质黏土', 3, null),
 (313, 91, null, '强风化砂岩', 3, null),
 (314, 94, null, '中等风化砂岩', 3, null),
 (315, 94, null, '微风化砂岩', 3, null),
 (316, 91, null, '全风化混合花岗岩', 3, null),
 (317, 91, null, '土状强风化混合花岗岩', 3, null),
 (318, 94, null, '中风化混合花岗岩', 3, null),
 (319, 94, null, '微风化混合花岗岩', 3, null),
 (320, 94, null, '中风化砂岩、微风化砂岩', 3, null),
 (321, 91, null, '土状强风化砂岩', 3, null),
 (322, 91, null, '黏性土、全风化/土状强风化粗粒花岗岩', 3, null),
 (323, 94, null, '土状、块状粗粒花岗岩', 3, null),
 (324, 94, null, '块状、微风化粗粒花岗岩', 3, null),
 (325, 94, null, '土状粗粒花岗岩', 3, null),
 (326, 91, null, '全风化、土状强风化粗粒花岗', 3, null),
 (327, 91, null, '土状强风化粗粒花岗', 3, null),
 (328, 94, null, '中、微风化花岗岩', 3, null),
 (329, 94, null, '全风化、土状强风化混合花岗岩', 3, null),
 (330, 94, null, '中等风化、微风化混合花岗岩', 3, null),
 (331, 94, null, '中等风化、土状强风化混合花岗岩', 3, null),
 (332, 296, null, '砾质粘性土、全风化粗粒花岗岩、土状强风化粗粒花岗岩', 3, null),
 (333, 296, null, '全风化粗粒花岗岩、土状强风化粗粒花岗岩、中等风化粗粒花岗岩', 3, null),
 (334, 296, null, '砾质粘性土、全风化粗粒花岗岩', 3, null),
 (335, 296, null, '全风化粗粒花岗岩、强风化粗粒花岗岩', 3, null),
 (336, 296, null, '中风化粗粒花岗岩、微风化粗粒花岗岩', 3, null),
 (337, 296, null, '全风化砂岩、强风化砂岩', 3, null),
 (338, 296, null, '中风化砂岩、微风化砂岩', 3, null),
 (339, 94, null, '中风化中粒花岗岩', 3, null),
 (340, 94, null, '微风化中粒花岗岩', 3, null),
 (342, 91, null, '中等中粒风化花岗岩', 3, null),
 (343, 91, null, '微风化花岗岩', 3, null),
 (344, 94, null, '强风化中砾花岗岩（块状）', 3, null),
 (346, 94, null, '强偏中等风化粉砂质泥岩', 3, null),
 (347, 94, null, '中等风化粉砂质泥岩', 3, null),
 (348, 91, null, '块状强风化混合花岗岩', 3, null),
 (349, 296, null, '淤泥质黏性土、黏性土、粉细砂', 3, null),
 (350, 296, null, '黏性土、全风化砂岩', 3, null),
 (351, 296, null, '黏性土、全风化砂岩、土状强风化砂岩、块状强风化砂岩', 3, null),
 (352, 296, null, '黏性土、全风化砂岩、土状强风化砂岩', 3, null),
 (353, 296, null, '土状强风化砂岩、块状强风化砂岩', 3, null),
 (354, 296, null, '全风化砂岩、土状、块状强风化砂岩', 3, null),
 (355, 296, null, '土状、块状强风化砂岩、中风化砂岩', 3, null),
 (356, 296, null, '土状、块状强风化砂岩', 3, null),
 (357, 296, null, '全风化砂岩、土状强风化砂岩', 3, null),
 (358, 296, null, '块状强风化砂岩、中风化砂岩、微风化砂岩', 3, null),
 (359, 296, null, '全风化砂岩、土状强风化砂岩', 3, null),
 (360, 296, null, '土状强风化砂岩、中风化砂岩', 3, null),
 (361, 296, null, '土状、块状强风化碎裂岩', 3, null),
 (362, 296, null, '土状强风化碎裂岩、块状强风化砂岩', 3, null),
 (363, 296, null, '块状强风化碎裂岩、中风化碎裂岩、微风化碎裂岩', 3, null),
 (364, 94, null, '中、微风化花岗岩', 3, null),
 (365, 91, null, '中风化粗粒花岗岩', 3, null),
 (366, 296, null, '土状粗粒花岗岩、块状粗粒花岗岩、中风化粗粒花岗岩', 3, null),
 (367, 296, null, '块状粗粒花岗岩、中风化粗粒花岗岩、微风化粗粒花岗岩', 3, null),
 (368, 30, null, '中粗砂', 3, null),
 (369, 91, null, '块状强风化中砾花岗岩', 3, null),
 (370, 94, null, '中等中粒风化花岗岩', 3, null),
 (371, 94, null, '中等风化粗粒花岗岩', 3, null),
 (372, 296, null, '中粗砂、粘性土、砾质粘性土、全风化粗粒花岗岩', 3, null),
 (373, 91, null, '全风化中粒花岗岩、强风化块状花岗岩', 3, null),
 (374, 91, null, '全风化中粒花岗岩、砾质粘性土、强风化块状花岗岩', 3, null),
 (375, 159, null, '全风化中粒花岗岩、强风化块状花岗岩、微风化中粒花岗岩、中风化孤石', 3, null),
 (376, 159, null, '强风化块状花岗岩、中风化中粒花岗岩、微风化中粒花岗岩', 3, null),
 (377, 159, null, '强风化块状花岗岩、中风化中粒花岗岩、微风化中粒花岗岩', 3, null),
 (378, 159, null, '强风化块状花岗岩、中风化中粒花岗岩、微风化中粒花岗岩', 3, null),
 (379, 159, null, '全风化中粒花岗岩、强风化块状花岗岩、中风化中粒花岗岩、微风化中粒花岗岩', 3, null),
 (380, 160, null, '微风化中粒花岗岩', 3, null),
 (381, 160, null, '中风化中粒花岗岩、微风化中粒花岗岩', 3, null);








