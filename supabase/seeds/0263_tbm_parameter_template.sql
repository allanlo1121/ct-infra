
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



INSERT INTO tbm.parameter_template_parameters
 (template_id, parameter_id, sort_order, is_required)
 select t.id, v.parameter_id, v.sort_order, v.is_required
 from tbm.parameter_templates t
 cross join (
    values 
    ( 1, 1, true),
    ( 2, 2, true),
    ( 753, 3, true),
    ( 755, 4, true),
    ( 761, 5, true),
    ( 762, 6, true),
    ( 763, 7, true),
    ( 764, 8, true),
    ( 765, 9, true),
    ( 766, 10, true),
    ( 857, 11, true),
    ( 858, 12, true),
    ( 859, 13, true),
    ( 860, 14, true),
    ( 861, 15, true),
    ( 864, 17, true),
    ( 865, 16, true),
    ( 866, 18, true),
    ( 867, 19, true),
    ( 870, 20, true),
    ( 871, 21, true),
    ( 874, 22, true),
    ( 875, 23, true),
    ( 880, 26, true),
    ( 882, 24, true),
    ( 883, 25, true),
    ( 887, 27, true),
    ( 890, 28, true),
    ( 891, 29, true),
    ( 892, 30, true),
    ( 896, 31, true),
    ( 897, 32, true),
    ( 898, 33, true),
    ( 899, 34, true)
 ) as v(parameter_id, sort_order, is_required)
 where t.code = 'base'
on conflict (template_id, parameter_id) do nothing;


INSERT INTO tbm.parameter_threshold_templates 
(
    parameter_id,
    threshold_type,
    severity,
    reference_value,
    threshold_value
)
VALUES
(896, 'deviation',  'warning', 0, 50),
(896, 'deviation', 'critical', 0, 80),

(897, 'deviation',  'warning', 0, 50),
(897, 'deviation', 'critical', 0, 80),

(898, 'deviation',  'warning', 0, 50),
(898, 'deviation', 'critical', 0, 80),

(899, 'deviation',  'warning', 0, 50),
(899, 'deviation', 'critical', 0, 80),

(900, 'deviation',  'warning', 0, 50),
(900, 'deviation', 'critical', 0, 80),

(901, 'deviation',  'warning', 0, 50),
(901, 'deviation', 'critical', 0, 80);



