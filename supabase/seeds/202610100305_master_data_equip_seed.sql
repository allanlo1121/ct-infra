

-- ==========================================
-- 盾构机类型 TBM Type
-- ==========================================

INSERT INTO master_data.dictionary_types (code,name)
VALUES ('4500', '盾构机类型')
ON CONFLICT (code) DO NOTHING;

INSERT INTO master_data.dictionary_items (dictionary_type_code, code, name)
VALUES 
    ('4500', '45000001', '敞开式TBM'),
    ('4500', '45000002', '双护盾TBM'),
    ('4500', '45000003', '土压平衡盾构'),
    ('4500', '45000004', '泥水盾构'),
    ('4500', '45000005', '顶管机'),
    ('4500', '45000006', '矿用TBM'),
    ('4500', '45000007', '土压泥水双模'),
    ('4500', '45000008', '土压敞开双模'),
    ('4500', '45000009', '单护盾TBM'),
    ('4500', '45000010', '抽水蓄能TBM')
ON CONFLICT (code) DO NOTHING;

-- ==========================================
-- 盾构机作业模式 TBM Operation Mode
-- ==========================================

INSERT INTO master_data.dictionary_types (code,name)
VALUES ('4510', '盾构机作业模式')
ON CONFLICT (code) DO NOTHING;

INSERT INTO master_data.dictionary_items (dictionary_type_code, code, name)
VALUES 
    ('4510', '45100001', '土压平衡'),
    ('4510', '45100002', '敞开式'),
    ('4510', '45100003', '泥水平衡'),
    ('4510', '45100004', '混合模式')
ON CONFLICT (code) DO NOTHING;


-- ==========================================
-- 设备警告级别 TBM ALARM LEVEL
-- ==========================================

INSERT INTO master_data.dictionary_types (code,name)
VALUES ('4520', '设备告警级别')
ON CONFLICT (code) DO NOTHING;

INSERT INTO master_data.dictionary_items (dictionary_type_code, code, name)
VALUES 
    ('4520', '45200001', '一般告警'),
    ('4520', '45200002', '严重告警'),
    ('4520', '45200003', '紧急告警')
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



