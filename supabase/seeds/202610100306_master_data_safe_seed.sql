

-- ==========================================
-- 安全风险类型 SAFE  Type
-- ==========================================

--RISK CATEGORY
INSERT INTO master_data.dictionary_types (code,name)
VALUES ('5001', '风险类别')
ON CONFLICT (code) DO NOTHING;

INSERT INTO master_data.dictionary_items (dictionary_type_code, code, name)
VALUES 
    ('5001', '50010001', '常规风险'),
    ('5001', '50010002', '周边环境风险'),
    ('5001', '50010003', '工程自身风险'),
    ('5001', '50010004', '施工作业特色风险')
ON CONFLICT (code) DO NOTHING;

-- ==========================================
-- 风险隐患等级 RISK LEVEL
-- ==========================================

INSERT INTO master_data.dictionary_types (code,name)
VALUES ('5002', '风险隐患等级')
ON CONFLICT (code) DO NOTHING;

INSERT INTO master_data.dictionary_items (dictionary_type_code, code, name)
VALUES 
    ('5002', '50020001', 'I'),
    ('5002', '50020002', 'II'),
    ('5002', '50020003', 'III'),
    ('5002', '50020004', 'IV')
ON CONFLICT (code) DO NOTHING;


-- ==========================================
-- 警告级别 ALERT_SEVERITY
-- ==========================================

INSERT INTO master_data.dictionary_types (code,name)
VALUES ('5201', '警告级别')
ON CONFLICT (code) DO NOTHING;

INSERT INTO master_data.dictionary_items (dictionary_type_code, code, name)
VALUES 
    ('5201', '52010001', '一般告警'),
    ('5201', '52010002', '严重告警'),
    ('5201', '52010003', '紧急告警')
ON CONFLICT (code) DO NOTHING;

-- -- ==========================================
-- -- TBM运行状态 TBM PHASE
-- -- ==========================================
-- INSERT INTO master_data.dictionary_types (code,name)
-- VALUES ('4530', 'TBM运行状态')
-- ON CONFLICT (code) DO NOTHING;

-- INSERT INTO master_data.dictionary_items (dictionary_type_code, code, name)
-- VALUES 
--     ('4530', '45300001', '掘进'),
--     ('4530', '45300002', '拼装'),
--     ('4530', '45300003', '等待'),
--     ('4530', '45300004', '停机'),
--     ('4530', '45300005', '故障'),
--     ('4530', '45300006', '换刀'),
--     ('4530', '45300007', '维修'),
--     ('4530', '45300008', '其他')
-- ON CONFLICT (code) DO NOTHING;

-- -- ==========================================
-- -- TBM参数阈值类型 THRESHOLD TYPE
-- -- ==========================================
-- INSERT INTO master_data.dictionary_types (code,name)
-- VALUES ('4540', 'TBM参数阈值类型')
-- ON CONFLICT (code) DO NOTHING;

-- INSERT INTO master_data.dictionary_items (dictionary_type_code, code, name)
-- VALUES 
--     ('4540', '45400001', '上限'),
--     ('4540', '45400002', '下限'),
--     ('4540', '45400003', '偏差'),
--     ('4540', '45400004', '区间'),
--     ('4540', '45400005', '变化量')
-- ON CONFLICT (code) DO NOTHING;



