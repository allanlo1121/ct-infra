
INSERT INTO tbm.parameter_templates
 (code, name, tbm_type_id, diameter, is_default, sort_order, is_disabled, remark) 
 select v.code, v.name, mt.id, v.diameter, v.is_default, v.sort_order, v.is_disabled, v.remark
 from public.master_data mt
    cross join (
        values 
        ('base', '基础模板', 6000, true, 0, true, null)
    ) as v(code, name, diameter, is_default, sort_order, is_disabled, remark)
    where mt.code = '45000003'
on conflict (code) do nothing;



insert into
  tbm.parameter_template_items (template_id, parameter_code, sort_order)
select
  t.id,
  v.parameter_code,
  v.sort_order
from
  tbm.parameter_templates t
  cross join (
    values
      ('b000000001', 1),
      ('b000000002', 2),
      ('s010102004', 3),
      ('s010109001', 4),
      ('s020901001', 5),
      ('s020901002', 6),
      ('s020901003', 7),
      ('s020901004', 8),
      ('s020901005', 9),
      ('s020901006', 10),
      ('s050001001', 11),
      ('s050001019', 12),
      ('s050001020', 13),
      ('s050001021', 14),
      ('s050001022', 15),
      ('s050006005', 17),
      ('s050006006', 16),
      ('s050006007', 18),
      ('s050006008', 19),
      ('s050009003', 20),
      ('s050109001', 21),
      ('s070102001', 22),
      ('s070109001', 23),
      ('s070301001', 26),
      ('s070606001', 24),
      ('s070606002', 25),
      ('s100100005', 27),
      ('s100100008', 28),
      ('s100111009', 29),
      ('s100111010', 30),
      ('s100206003', 31),
      ('s100206004', 32),
      ('s100206006', 33),
      ('s100206007', 34)
  ) as v (parameter_code, sort_order)
where
  t.code = 'base'
on conflict (template_id, parameter_code) do nothing;


INSERT INTO tbm.parameter_threshold_rules
(
    parameter_code,
    threshold_type,
    severity,
    reference_value,
    threshold_value
)
VALUES
('s100206003', 'deviation', 'warning', 0, 50),
('s100206003', 'deviation', 'critical', 0, 80),

('s100206004', 'deviation', 'warning', 0, 50),
('s100206004', 'deviation', 'critical', 0, 80),

('s100206006', 'deviation', 'warning', 0, 50),
('s100206006', 'deviation', 'critical', 0, 80),

('s100206007', 'deviation', 'warning', 0, 50),
('s100206007', 'deviation', 'critical', 0, 80),

('s100206009', 'deviation', 'warning', 0, 50),
('s100206009', 'deviation', 'critical', 0, 80),

('s100206010', 'deviation', 'warning', 0, 50),
('s100206010', 'deviation', 'critical', 0, 80);




