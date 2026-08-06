

INSERT INTO tbm.tbm_runtime_parameters (code,name,subsystem_id,data_type,unit,digits,is_alarm,sort_order)
SELECT v.code,v.name,ss.id,v.data_type,v.unit,v.digits,v.is_alarm,v.sort_order 
FROM tbm.tbm_subsystems ss
CROSS JOIN (
  VALUES 
('s010101010','刀盘刹车压力1','double','bar',2,false,200010),
('s010102004','刀盘扭矩','double','kN·m',2,false,201004),
('s010103006','刀盘功率','double','kW',2,false,202006),
('s010109001','刀盘转速','double','rpm',2,false,203001),
('s010111001','刀盘角度','double','°',2,false,204001),
('s010114003','刀盘转速设定','double','rpm',2,false,205003),
('s011306002','超挖刀传感器伸出量','double','°',2,false,206002),
('s011311001','超挖刀角度','double','°',2,false,207001)
) AS v(code,name,data_type,unit,digits,is_alarm,sort_order)
WHERE ss.code = 's01'
ON CONFLICT (code) DO NOTHING;


INSERT INTO tbm.tbm_runtime_parameters (code,name,subsystem_id,data_type,unit,digits,is_alarm,sort_order)
SELECT v.code,v.name,ss.id,v.data_type,v.unit,v.digits,v.is_alarm,v.sort_order 
FROM tbm.tbm_subsystems ss
CROSS JOIN (
  VALUES 
('s020901000','土仓土压组','double','bar',2,false,208000),
('s020901001','左中土仓压力','double','bar',2,false,208001),
('s020901002','左上土仓压力','double','bar',2,false,208002),
('s020901003','左下土仓压力','double','bar',2,false,208003),
('s020901004','右下土仓压力','double','bar',2,false,208004),
('s020901005','右中土仓压力','double','bar',2,false,208005),
('s020901006','右上土仓压力','double','bar',2,false,208006),
('s020901007','右上铰接伸出压力','double','bar',2,false,208007),
('s020901008','右上铰接回收压力','double','bar',2,false,208008),
('s020901009','右下铰接伸出压力','double','bar',2,false,208009),
('s020901010','右下铰接回收压力','double','bar',2,false,208010),
('s020901011','左上铰接伸出压力','double','bar',2,false,208011),
('s020901012','左上铰接回收压力','double','bar',2,false,208012),
('s020901013','左下铰接伸出压力','double','bar',2,false,208013),
('s020901014','左下铰接回收压力','double','bar',2,false,208014),
('s020901015','正上土仓压力','double','bar',2,false,208015),
('s020906001','右上铰接位移','double','mm',2,false,209001),
('s020906002','右下铰接位移','double','mm',2,false,209002),
('s020906003','左下铰接位移','double','mm',2,false,209003),
('s020906004','左上铰接位移','double','mm',2,false,209004),
('s021711001','滚动角','double','°',2,false,210001),
('s021711002','俯仰角','double','°',2,false,210002)
) AS v(code,name,data_type,unit,digits,is_alarm,sort_order)
WHERE ss.code = 's02'
ON CONFLICT (code) DO NOTHING;



INSERT INTO tbm.tbm_runtime_parameters (code,name,subsystem_id,data_type,unit,digits,is_alarm,sort_order)
SELECT v.code,v.name,ss.id,v.data_type,v.unit,v.digits,v.is_alarm,v.sort_order 
FROM tbm.tbm_subsystems ss
CROSS JOIN (
  VALUES 
('s030007001','主驱动线电压L1/L2','double','v',2,false,211001),
('s030007002','主驱动线电压L1/L3','double','v',2,false,211002),
('s030007003','主驱动线电压L2/L3','double','v',2,false,211003),
('s030007004','主驱动2L1-L2线电压','double','V',2,false,211004),
('s030007005','主驱动2L1-L3线电压','double','V',2,false,211005),
('s030007006','主驱动2L2-L3线电压','double','V',2,false,211006),
('s030007007','主驱动3L1-L2线电压','double','V',2,false,211007),
('s030007008','主驱动3L1-L3线电压','double','V',2,false,211008),
('s030007009','主驱动3L2-L3线电压','double','V',2,false,211009),
('s030102001','1#电机扭矩','double','N.m',2,false,212001),
('s030103001','1#电机功率','double','kW',2,false,213001),
('s030104001','1#电机温度','double','℃',2,false,214001),
('s030104015','1#电机轴承温度','double','℃',2,false,214015),
('s030104016','2#电机轴承温度','double','℃',2,false,214016),
('s030104017','3#电机轴承温度','double','℃',2,false,214017),
('s030104018','4#电机轴承温度','double','℃',2,false,214018),
('s030104019','5#电机轴承温度','double','℃',2,false,214019),
('s030104020','6#电机轴承温度','double','℃',2,false,214020),
('s030104021','7#电机轴承温度','double','℃',2,false,214021),
('s030104022','8#电机轴承温度','double','℃',2,false,214022),
('s030104023','9#电机轴承温度','double','℃',2,false,214023),
('s030104024','10#电机轴承温度','double','℃',2,false,214024),
('s030104025','1#电机轴承温度2','double','℃',2,false,214025),
('s030104026','2#电机轴承温度2','double','℃',2,false,214026),
('s030104027','3#电机轴承温度2','double','℃',2,false,214027),
('s030104028','4#电机轴承温度2','double','℃',2,false,214028),
('s030104029','5#电机轴承温度2','double','℃',2,false,214029),
('s030104030','6#电机轴承温度2','double','℃',2,false,214030),
('s030104031','7#电机轴承温度2','double','℃',2,false,214031),
('s030104032','8#电机轴承温度2','double','℃',2,false,214032),
('s030104033','9#电机轴承温度2','double','℃',2,false,214033),
('s030104034','10#电机轴承温度2','double','℃',2,false,214034),
('s030105001','1#电机频率','double','Hz',2,false,215001),
('s030108001','1#电机电流','double','A',2,false,216001),
('s030202001','2#电机扭矩','double','N.m',2,false,217001),
('s030203001','2#电机功率','double','kW',2,false,218001),
('s030304001','3#电机温度','double','℃',2,false,219001),
('s030305001','3#电机频率','double','Hz',2,false,225001),
('s030308001','3#电机电流','double','A',2,false,226001),
('s030402001','4#电机扭矩','double','N.m',2,false,227001),
('s030403001','4#电机功率','double','kW',2,false,228001),
('s030404001','4#电机温度','double','℃',2,false,229001),
('s030405001','4#电机频率','double','Hz',2,false,230001),
('s030408001','4#电机电流','double','A',2,false,231001),
('s030502001','5#电机扭矩','double','N.m',2,false,232001),
('s030503001','5#电机功率','double','kW',2,false,233001),
('s030504001','5#电机温度','double','℃',2,false,234001),
('s030505001','5#电机频率','double','Hz',2,false,235001),
('s030508001','5#电机电流','double','A',2,false,236001),
('s030602001','6#电机扭矩','double','N.m',2,false,237001),
('s030603001','6#电机功率','double','kW',2,false,238001),
('s030604001','6#电机温度','double','℃',2,false,239001),
('s030605001','6#电机频率','double','Hz',2,false,240001),
('s030608001','6#电机电流','double','A',2,false,241001),
('s030702001','7#电机扭矩','double','N.m',2,false,242001),
('s030703001','7#电机功率','double','kW',2,false,243001),
('s030704001','7#电机温度','double','℃',2,false,244001),
('s030705001','7#电机频率','double','Hz',2,false,245001),
('s030708001','7#电机电流','double','A',2,false,246001),
('s030802001','8#电机扭矩','double','N.m',2,false,247001),
('s030803001','8#电机功率','double','kW',2,false,248001),
('s030804001','8#电机温度','double','℃',2,false,249001),
('s030805001','8#电机频率','double','Hz',2,false,250001),
('s030808001','8#电机电流','double','A',2,false,251001),
('s030902001','9#电机扭矩','double','N.m',2,false,252001),
('s030903001','9#电机功率','double','kW',2,false,253001),
('s030904001','9#电机温度','double','℃',2,false,254001),
('s030905001','9#电机频率','double','Hz',2,false,255001),
('s030908001','9#电机电流','double','A',2,false,256001),
('s031002001','10#电机扭矩','double','N.m',2,false,257001),
('s031003001','10#电机功率','double','kW',2,false,258001),
('s031004001','10#电机温度','double','℃',2,false,259001),
('s031005001','10#电机频率','double','Hz',2,false,260001),
('s031008001','10#电机电流','double','A',2,false,261001)
) AS v(code,name,data_type,unit,digits,is_alarm,sort_order)
WHERE ss.code = 's03'
ON CONFLICT (code) DO NOTHING;

INSERT INTO tbm.tbm_runtime_parameters (code,name,subsystem_id,data_type,unit,digits,is_alarm,sort_order)
SELECT v.code,v.name,ss.id,v.data_type,v.unit,v.digits,v.is_alarm,v.sort_order 
FROM tbm.tbm_subsystems ss
CROSS JOIN (
  VALUES 
('s040211001','抓举头角度','double','°',2,false,262001)
) AS v(code,name,data_type,unit,digits,is_alarm,sort_order)
WHERE ss.code = 's04'
ON CONFLICT (code) DO NOTHING;


INSERT INTO tbm.tbm_runtime_parameters (code,name,subsystem_id,data_type,unit,digits,is_alarm,sort_order)
SELECT v.code,v.name,ss.id,v.data_type,v.unit,v.digits,v.is_alarm,v.sort_order 
FROM tbm.tbm_subsystems ss
CROSS JOIN (
  VALUES 
('s050001001','总推进力','double','kN',2,true,260001),
('s050001019','A组压力','double','bar',2,false,260019),
('s050001020','B组压力','double','bar',2,false,260020),
('s050001021','C组压力','double','bar',2,false,260021),
('s050001022','D组压力','double','bar',2,false,260022),
('s050001023','E组压力','double','bar',2,false,260023),
('s050001024','F组压力','double','bar',2,false,260024),
('s050006005','C组推进油缸行程','double','mm',2,false,264005),
('s050006006','A组推进油缸行程','double','mm',2,false,264006),
('s050006007','D组推进油缸行程','double','mm',2,false,264007),
('s050006008','B组推进油缸行程','double','mm',2,false,264008),
('s050006009','E组推进油缸行程','double','mm',2,false,264009),
('s050006010','F组推进油缸行程','double','mm',2,false,264010),
('s050009003','推进速度','double','mm/min',2,true,265003),
('s050109001','贯入度','double','mm/rpm',2,false,266901),
('s051206001','1#拖拉油缸行程','double','cm',2,false,267601),
('s051206002','2#拖拉油缸行程','double','cm',2,false,267602)
) AS v(code,name,data_type,unit,digits,is_alarm,sort_order)
WHERE ss.code = 's05'
ON CONFLICT (code) DO NOTHING;


INSERT INTO tbm.tbm_runtime_parameters (code,name,subsystem_id,data_type,unit,digits,is_alarm,sort_order)
SELECT v.code,v.name,ss.id,v.data_type,v.unit,v.digits,v.is_alarm,v.sort_order 
FROM tbm.tbm_subsystems ss
CROSS JOIN (
  VALUES 
('s070102001','螺机扭矩','double','kN·m',2,false,268001),
('s070109001','螺机转速','double','rpm',2,false,269001),
('s070201001','螺机补油压力','double','bar',2,false,270001),
('s070201002','螺机泵控制油压力','double','bar',2,false,270002),
('s070201003','螺机马达压力','double','bar',2,false,270003),
('s070204001','螺机马达油温','double','℃',2,false,271001),
('s070301001','螺机后部压力','double','bar',2,false,270201),
('s070401002','螺机中部压力','double','bar',2,false,3273002),
('s070606001','螺机后上闸门行程','double','mm',2,false,274001),
('s070606002','螺机后下闸门行程','double','mm',2,false,274002),
('s070710001','螺机O2','double','%vol',2,false,275001)
) AS v(code,name,data_type,unit,digits,is_alarm,sort_order)
WHERE ss.code = 's07'
ON CONFLICT (code) DO NOTHING;

INSERT INTO tbm.tbm_runtime_parameters (code,name,subsystem_id,data_type,unit,digits,is_alarm,sort_order)
SELECT v.code,v.name,ss.id,v.data_type,v.unit,v.digits,v.is_alarm,v.sort_order 
FROM tbm.tbm_subsystems ss
CROSS JOIN (
  VALUES 
('s080201001','后配套拖拉油缸压力','double','bar',2,false,276001)
) AS v(code,name,data_type,unit,digits,is_alarm,sort_order)
WHERE ss.code = 's08'
ON CONFLICT (code) DO NOTHING;

INSERT INTO tbm.tbm_runtime_parameters (code,name,subsystem_id,data_type,unit,digits,is_alarm,sort_order)
SELECT v.code,v.name,ss.id,v.data_type,v.unit,v.digits,v.is_alarm,v.sort_order 
FROM tbm.tbm_subsystems ss
CROSS JOIN (
  VALUES 
('s090109003','皮带机转速（rpm）','double','rpm',2,false,277003)
) AS v(code,name,data_type,unit,digits,is_alarm,sort_order)
WHERE ss.code = 's09'
ON CONFLICT (code) DO NOTHING;

INSERT INTO tbm.tbm_runtime_parameters (code,name,subsystem_id,data_type,unit,digits,is_alarm,sort_order)
SELECT v.code,v.name,ss.id,v.data_type,v.unit,v.digits,v.is_alarm,v.sort_order 
FROM tbm.tbm_subsystems ss
CROSS JOIN (
  VALUES 
('s100100005','导向盾尾里程','double','m',2,false,278005),
('s100100006','水平偏差趋向','double','mm/m',2,false,278006),
('s100100007','垂直偏差趋向','double','mm/m',2,false,278007),
('s100100008','导向环号','integer','环',0,false,278008),
('s100111009','导向滚动角','double','°',2,false,279009),
('s100111010','导向俯仰角','double','°',2,false,279010),
('s100111011','导向滚动角2','double','°',2,false,279011),
('s100111012','导向俯仰角2','double','°',2,false,279012),
('s100206000','导向偏差组','double','mm',2,false,280000),
('s100206003','前点水平偏差','double','mm',2,true,280003),
('s100206004','前点垂直偏差','double','mm',2,true,280004),
('s100206006','后点水平偏差','double','mm',2,true,280006),
('s100206007','后点垂直偏差','double','mm',2,true,280007),
('s100206009','中点水平偏差','double','mm',2,false,280009),
('s100206010','中点垂直偏差','double','mm',2,false,280010),
('s100406005','导向推进油缸A组位移','double','mm',2,false,281005),
('s100406006','导向推进油缸B组位移','double','mm',2,false,281006),
('s100406007','导向推进油缸C组位移','double','mm',2,false,281007),
('s100406008','导向推进油缸D组位移','double','mm',2,false,281008),
('s100406009','导向推进油缸E组位移','double','mm',2,false,281009),
('s100406010','导向推进油缸F组位移','double','mm',2,false,281010)
) AS v(code,name,data_type,unit,digits,is_alarm,sort_order)
WHERE ss.code = 's10'
ON CONFLICT (code) DO NOTHING;

INSERT INTO tbm.tbm_runtime_parameters (code,name,subsystem_id,data_type,unit,digits,is_alarm,sort_order)
SELECT v.code,v.name,ss.id,v.data_type,v.unit,v.digits,v.is_alarm,v.sort_order 
FROM tbm.tbm_subsystems ss
CROSS JOIN (
  VALUES 
('s200013001','A液当前环累计量','double','L',2,false,282001),
('s200013002','A液总累计量','double','L',2,false,282002),
('s200101001','左上注浆压力','double','bar',2,false,283001),
('s200113005','1#注浆计数','integer','次',0,false,284005),
('s200113006','2#注浆计数','integer','次',0,false,284006),
('s200113007','3#注浆计数','integer','次',0,false,284007),
('s200113008','4#注浆计数','integer','次',0,false,284008),
('s200113009','5#注浆计数','integer','次',0,false,284009),
('s200113010','6#注浆计数','integer','次',0,false,284010),
('s200201001','右上注浆压力','double','bar',2,false,293001),
('s200301001','左下注浆压力','double','bar',2,false,295001),
('s200313003','注浆A液1#当前环累计量','double','L',2,false,296003),
('s200313004','注浆A液2#当前环累计量','double','L',2,false,296004),
('s200313005','注浆A液3#当前环累计量','double','L',2,false,296005),
('s200313006','注浆A液4#当前环累计量','double','L',2,false,296006),
('s200313007','注浆A液5#当前环累计量','double','L',2,false,296007),
('s200401001','右下注浆压力','double','bar',2,false,297001),
('s200701001','左中注浆压力','double','bar',2,false,289001),
('s200701002','右中注浆压力','double','bar',2,false,289002)
) AS v(code,name,data_type,unit,digits,is_alarm,sort_order)
WHERE ss.code = 's20'
ON CONFLICT (code) DO NOTHING;


INSERT INTO tbm.tbm_runtime_parameters (code,name,subsystem_id,data_type,unit,digits,is_alarm,sort_order)
SELECT v.code,v.name,ss.id,v.data_type,v.unit,v.digits,v.is_alarm,v.sort_order 
FROM tbm.tbm_subsystems ss
CROSS JOIN (
  VALUES 
('s210013001','泡沫系统当前环用水量','double','L',2,false,290001),
('s210013002','泡沫系统总用水量','double','L',2,false,290002),
('s210013003','泡沫原液当前环累计用量','double','L',2,false,290003),
('s210013004','泡沫原液总用量','double','L',2,false,290004),
('s210013005','混合液当前环累计用量','double','L',2,false,290005),
('s210013006','混合液总用量','double','L',2,false,290006),
('s210101002','1路泡沫压力','double','bar',2,false,291002),
('s210113001','1路空气流量','double','L/min',2,false,292001),
('s210113002','1路混合液流量','double','L/min',2,false,292002),
('s210201002','2路泡沫压力','double','bar',2,false,293002),
('s210213001','2路空气流量','double','L/min',2,false,294001),
('s210213002','2路混合液流量','double','L/min',2,false,294002),
('s210301002','3路泡沫压力','double','bar',2,false,295002),
('s210313001','3路空气流量','double','L/min',2,false,296001),
('s210313002','3路混合液流量','double','L/min',2,false,296002),
('s210401002','4路泡沫压力','double','bar',2,false,297002),
('s210413001','4路空气流量','double','L/min',2,false,298001),
('s210413002','4路混合液流量','double','L/min',2,false,298002),
('s210501002','5路泡沫压力','double','bar',2,false,299002),
('s210513001','5路空气流量','double','L/min',2,false,300001),
('s210513002','5路混合液流量','double','L/min',2,false,300002),
('s210601002','6路泡沫压力','double','bar',2,false,3301002),
('s210613001','6路空气流量','double','L/min',2,false,302001),
('s210613002','6路混合液流量','double','L/min',2,false,302002),
('s210701002','7路泡沫压力','double','bar',2,false,303002),
('s210713001','7路空气流量','double','L/min',2,false,304001),
('s210713002','7路混合液流量','double','L/min',2,false,304002),
('s210801002','8路泡沫压力','double','bar',2,false,305002),
('s210813001','8路空气流量','double','L/min',2,false,306001),
('s210813002','8路混合液流量','double','L/min',2,false,306002),
('s210901001','9路泡沫压力','double','bar',2,false,307001),
('s210913001','9路空气流量','double','L/min',2,false,308001),
('s211001002','10路泡沫压力','double','bar',2,false,309002),
('s211013002','10路空气流量','double','L/min',2,false,310002),
('s211206001','泡沫原液罐液位','double','mm',2,false,311001),
('s211306001','泡沫混合液罐液位','double','mm',2,false,312001),
('s212913001','9路混合液流量','double','L/min',2,false,313002),
('s213013001','10路混合液流量','double','L/min',2,false,314002)
) AS v(code,name,data_type,unit,digits,is_alarm,sort_order)
WHERE ss.code = 's21'
ON CONFLICT (code) DO NOTHING;

INSERT INTO tbm.tbm_runtime_parameters (code,name,subsystem_id,data_type,unit,digits,is_alarm,sort_order)
SELECT v.code,v.name,ss.id,v.data_type,v.unit,v.digits,v.is_alarm,v.sort_order 
FROM tbm.tbm_subsystems ss
CROSS JOIN (
  VALUES 
('s220810001','螺机CH4','double','%',2,false,315001),
('s220810002','螺机H2S','double','%',2,false,315002)
) AS v(code,name,data_type,unit,digits,is_alarm,sort_order)
WHERE ss.code = 's22'
ON CONFLICT (code) DO NOTHING;


INSERT INTO tbm.tbm_runtime_parameters (code,name,subsystem_id,data_type,unit,digits,is_alarm,sort_order)
SELECT v.code,v.name,ss.id,v.data_type,v.unit,v.digits,v.is_alarm,v.sort_order 
FROM tbm.tbm_subsystems ss
CROSS JOIN (
  VALUES 
('s240101001','膨润土罐压力','double','bar',2,false,316001),
('s240113001','膨润土当前环累计量','double','m3',2,false,317001),
('s240113002','膨润土总累计量','double','m3',2,false,317002),
('s240301001','膨润土1路压力','double','bar',2,false,318001),
('s240301002','膨润土2路压力','double','bar',2,false,318002),
('s240313001','膨润土1路流量','double','L/min',2,false,319001),
('s240313002','膨润土2路流量','double','L/min',2,false,319002)
) AS v(code,name,data_type,unit,digits,is_alarm,sort_order)
WHERE ss.code = 's24'
ON CONFLICT (code) DO NOTHING;


INSERT INTO tbm.tbm_runtime_parameters (code,name,subsystem_id,data_type,unit,digits,is_alarm,sort_order)
SELECT v.code,v.name,ss.id,v.data_type,v.unit,v.digits,v.is_alarm,v.sort_order 
FROM tbm.tbm_subsystems ss
CROSS JOIN (
  VALUES 
('s260001001','盾尾油脂泵压力','double','bar',2,false,320001),
('s260001002','盾尾油脂泵2压力','double','bar',2,false,320002),
('s260001003','盾尾油脂泵3压力','double','bar',2,false,321003),
('s260013001','EP2当前环累计量','double','L',2,false,321001),
('s260013002','EP2总用量','double','L',2,false,321002),
('s260101001','EP2泵出口压力','double','bar',2,false,322001),
('s260200005','外密封后腔计数','integer','次',0,false,323005),
('s260201002','外密封前腔压力','double','bar',2,false,324002),
('s260201004','外密封后腔压力','double','bar',2,false,324004),
('s260201005','外密封2#前腔压力','double','bar',2,false,324005),
('s260201007','外密封中腔压力','double','bar',2,false,324007),
('s260201008','2#外密封中腔压力','double','bar',2,false,324008),
('s260201009','外密封2#后腔压力','double','bar',2,false,324009),
('s260213005','外密封前腔计数','integer','次',0,false,325005),
('s260213007','2#外密封前腔计数','integer','次',0,false,325007),
('s260213008','3#外密封前腔计数','integer','次',0,false,325008),
('s260213009','外密封中腔计数','integer','次',0,false,325009),
('s260300001','内密封后腔计数','integer','次',0,false,326001),
('s260301002','内密封前腔压力','double','bar',2,false,327002),
('s260301004','内密封后腔压力','double','bar',2,false,327004),
('s260301005','内密封中腔压力','double','bar',2,false,327005),
('s260313003','内密封前腔计数','integer','次',0,false,328003),
('s260313004','内密封前腔2#计数','integer','次',0,false,328004),
('s260313005','内密封中腔计数','integer','次',0,false,328005),
('s260412001','EP2主驱动铰接润滑剩余时间','double','s',2,false,329001),
('s260413007','主驱动前部铰接润滑计数','integer','次',0,false,330007),
('s260504001','齿轮油箱温度','double','℃',2,false,331001),
('s260504002','2#齿轮油箱温度','double','℃',2,false,331002),
('s260601001','1#齿轮油泵压力','double','bar',2,false,332001),
('s260601002','2#齿轮油泵压力','double','bar',2,false,332002),
('s260613001','1#齿轮油泵润滑计数','integer','次',0,false,333001),
('s260812001','小轴承润滑剩余时间','double','s',2,false,338001),
('s260813012','小齿轮油强制润滑计数','integer','次',0,false,339012),
('s260813013','小轴承油润滑计数','integer','次',0,false,339013),
('s260913002','螺机润滑计数','integer','次',0,false,341002),
('s261801001','EP2密封回转中心1#压力','double','bar',2,false,337001),
('s261801002','回转中心接头通道1#压力','double','bar',2,false,337002),
('s261801003','回转中心接头通道2#压力','double','bar',2,false,337003),
('s261812001','回转中心计数剩余时间','double','s',2,false,338001),
('s261812002','内密封回转中心计数剩余时间','double','s',2,false,338002),
('s261813001','EP2密封回转中心1#计数','double','bar',2,false,339001),
('s261813002','EP2回转中心接头通道计数','integer','次',0,false,339002),
('s261912001','EP2拼装机轴向移动润滑剩余时间','double','s',2,false,340001),
('s261912002','EP2拼装机支持及啮合剩余时间','double','s',2,false,340002),
('s261913001','EP2拼装机轴向移动润滑计数','integer','次',0,false,341001),
('s261913002','EP2拼装机支持及啮合次数','double','s',2,false,341002),
('s262012001','螺旋机闸门润滑剩余时间','double','s',2,false,342001),
('s262013001','螺旋机闸门润滑计数','double','s',2,false,343001)
) AS v(code,name,data_type,unit,digits,is_alarm,sort_order)
WHERE ss.code = 's26'
ON CONFLICT (code) DO NOTHING;


INSERT INTO tbm.tbm_runtime_parameters (code,name,subsystem_id,data_type,unit,digits,is_alarm,sort_order)
SELECT v.code,v.name,ss.id,v.data_type,v.unit,v.digits,v.is_alarm,v.sort_order 
FROM tbm.tbm_subsystems ss
CROSS JOIN (
  VALUES 
('s270001001','进水压力','double','bar',2,false,344001),
('s270001002','工业出水压力','double','bar',2,false,344002),
('s270004001','进水温度','double','℃',2,false,345001),
('s270006001','加水箱液位','double','mm',2,false,346001),
('s270013001','进水流量','double','L/min',2,false,347001),
('s270101001','内循环泵压力','double','bar',2,false,348001),
('s270104002','内循环水出口温度','double','℃',2,false,349002),
('s270104003','内循环水温度','double','℃',2,false,349003),
('s270104005','工业出水温度','double','℃',2,false,349005),
('s270406001','污水箱液位','double','mm',2,false,350001),
('s270500002','刀盘喷水总量','double','L',2,false,352002),
('s270501003','1#刀盘喷水压力','double','bar',2,false,352003),
('s270501004','2#刀盘喷水压力','double','bar',2,false,352004),
('s270501005','3#刀盘喷水压力','double','bar',2,false,352005),
('s270501006','4#刀盘喷水压力','double','bar',2,false,352006),
('s270501007','5#刀盘喷水压力','double','bar',2,false,352007),
('s270513003','刀盘喷水当前环累计量','double','L',2,false,353003)
) AS v(code,name,data_type,unit,digits,is_alarm,sort_order)
WHERE ss.code = 's27'
ON CONFLICT (code) DO NOTHING;

INSERT INTO tbm.tbm_runtime_parameters (code,name,subsystem_id,data_type,unit,digits,is_alarm,sort_order)
SELECT v.code,v.name,ss.id,v.data_type,v.unit,v.digits,v.is_alarm,v.sort_order 
FROM tbm.tbm_subsystems ss
CROSS JOIN (
  VALUES 
('s280013001','盾尾密封当前环累计量','double','L',2,false,354001),
('s280013002','盾尾密封总累计量','double','L',2,false,354002),
('s280101001','盾尾密封前腔1#压力','double','bar',2,false,355001),
('s280101002','盾尾密封前腔2#压力','double','bar',2,false,355002),
('s280101003','盾尾密封前腔3#压力','double','bar',2,false,355003),
('s280101004','盾尾密封前腔4#压力','double','bar',2,false,355004),
('s280101005','盾尾密封前腔5#压力','double','bar',2,false,355005),
('s280101006','盾尾密封前腔6#压力','double','bar',2,false,355006),
('s280101007','盾尾密封前腔7#压力','double','bar',2,false,355007),
('s280101008','盾尾密封前腔8#压力','double','bar',2,false,355008),
('s280101009','盾尾密封前腔9#压力','double','bar',2,false,355009),
('s280101010','盾尾密封前腔10#压力','double','bar',2,false,355010),
('s280101011','盾尾密封前腔11#压力','double','bar',2,false,355011),
('s280113001','盾尾密封前腔1#次数','integer','次',0,false,356001),
('s280113002','盾尾密封前腔2#次数','integer','次',0,false,356002),
('s280113003','盾尾密封前腔3#次数','integer','次',0,false,356003),
('s280113004','盾尾密封前腔4#次数','integer','次',0,false,356004),
('s280113005','盾尾密封前腔5#次数','integer','次',0,false,356005),
('s280113006','盾尾密封前腔6#次数','integer','次',0,false,356006),
('s280113007','盾尾密封前腔7#次数','integer','次',0,false,356007),
('s280113008','盾尾密封前腔8#次数','integer','次',0,false,356008),
('s280113009','盾尾密封前腔9#次数','integer','次',0,false,356009),
('s280113010','盾尾密封前腔10#次数','integer','次',0,false,356010),
('s280113011','盾尾密封前腔11#次数','integer','次',0,false,356011),
('s280301001','盾尾密封中腔1#压力','double','bar',2,false,357001),
('s280301002','盾尾密封中腔2#压力','double','bar',2,false,357002),
('s280301003','盾尾密封中腔3#压力','double','bar',2,false,357003),
('s280301004','盾尾密封中腔4#压力','double','bar',2,false,357004),
('s280301005','盾尾密封中腔5#压力','double','bar',2,false,357005),
('s280301006','盾尾密封中腔6#压力','double','bar',2,false,357006),
('s280301007','盾尾密封中腔7#压力','double','bar',2,false,357007),
('s280301008','盾尾密封中腔8#压力','double','bar',2,false,357008),
('s280301009','盾尾密封中腔9#压力','double','bar',2,false,357009),
('s280301010','盾尾密封中腔10#压力','double','bar',2,false,357010),
('s280301011','盾尾密封中腔11#压力','double','bar',2,false,357011),
('s280313001','盾尾密封中腔1#次数','integer','次',0,false,358001),
('s280313002','盾尾密封中腔2#次数','integer','次',0,false,358002),
('s280313003','盾尾密封中腔3#次数','integer','次',0,false,358003),
('s280313004','盾尾密封中腔4#次数','integer','次',0,false,358004),
('s280313005','盾尾密封中腔5#次数','integer','次',0,false,358005),
('s280313006','盾尾密封中腔6#次数','integer','次',0,false,358006),
('s280313007','盾尾密封中腔7#次数','integer','次',0,false,358007),
('s280313008','盾尾密封中腔8#次数','integer','次',0,false,358008),
('s280313009','盾尾密封中腔9#次数','integer','次',0,false,358009),
('s280313010','盾尾密封中腔10#次数','integer','次',0,false,358010),
('s280313011','盾尾密封中腔11#次数','integer','次',0,false,358011),
('s280501001','盾尾密封后腔1#压力','double','bar',2,false,359001),
('s280501002','盾尾密封后腔2#压力','double','bar',2,false,359002),
('s280501003','盾尾密封后腔3#压力','double','bar',2,false,359003),
('s280501004','盾尾密封后腔4#压力','double','bar',2,false,359004),
('s280501005','盾尾密封后腔5#压力','double','bar',2,false,359005),
('s280501006','盾尾密封后腔6#压力','double','bar',2,false,359006),
('s280501007','盾尾密封后腔7#压力','double','bar',2,false,359007),
('s280501008','盾尾密封后腔8#压力','double','bar',2,false,359008),
('s280501009','盾尾密封后腔9#压力','double','bar',2,false,359009),
('s280501010','盾尾密封后腔10#压力','double','bar',2,false,359010),
('s280501011','盾尾密封后腔11#压力','double','bar',2,false,359011),
('s280513001','盾尾密封后腔1#次数','integer','次',0,false,360001),
('s280513002','盾尾密封后腔2#次数','integer','次',0,false,360002),
('s280513003','盾尾密封后腔3#次数','integer','次',0,false,360003),
('s280513004','盾尾密封后腔4#次数','integer','次',0,false,360004),
('s280513005','盾尾密封后腔5#次数','integer','次',0,false,360005),
('s280513006','盾尾密封后腔6#次数','integer','次',0,false,360006),
('s280513007','盾尾密封后腔7#次数','integer','次',0,false,360007),
('s280513008','盾尾密封后腔8#次数','integer','次',0,false,360008),
('s280513009','盾尾密封后腔9#次数','integer','次',0,false,360009),
('s280513010','盾尾密封后腔10#次数','integer','次',0,false,360010),
('s280513011','盾尾密封后腔11#次数','integer','次',0,false,360011),
('s280613001','盾尾油脂泵1#冲程次数','integer','次',0,false,361001),
('s280613002','盾尾油脂泵2#冲程次数','integer','次',0,false,361002),
('s280613003','盾尾油脂泵3#冲程次数','integer','次',0,false,361003)
) AS v(code,name,data_type,unit,digits,is_alarm,sort_order)
WHERE ss.code = 's28'
ON CONFLICT (code) DO NOTHING;

INSERT INTO tbm.tbm_runtime_parameters (code,name,subsystem_id,data_type,unit,digits,is_alarm,sort_order)
SELECT v.code,v.name,ss.id,v.data_type,v.unit,v.digits,v.is_alarm,v.sort_order 
FROM tbm.tbm_subsystems ss
CROSS JOIN (
  VALUES 
('s300101001','推进泵压力','double','bar',2,false,362001),
('s300601001','铰接泵压力','double','bar',2,false,363001),
('s301301001','螺机泵压力','double','bar',2,false,364001),
('s302004001','主油箱油温','double','℃',2,false,365001)
) AS v(code,name,data_type,unit,digits,is_alarm,sort_order)
WHERE ss.code = 's30'
ON CONFLICT (code) DO NOTHING;

INSERT INTO tbm.tbm_runtime_parameters (code,name,subsystem_id,data_type,unit,digits,is_alarm,sort_order)
SELECT v.code,v.name,ss.id,v.data_type,v.unit,v.digits,v.is_alarm,v.sort_order 
FROM tbm.tbm_subsystems ss
CROSS JOIN (
  VALUES 
('s310000001','功率因数','double','cos',2,false,366001),
('s310003000','总功率','double','kW',2,false,367000),
('s310003003','无功功率','double','kVar',2,false,367003),
('s310003010','T2_总功率','double','kW',2,false,367010),
('s310003011','T2_总视在功率','double','kW',2,false,367011),
('s310003012','T2_总无功功率','double','kW',2,false,367012),
('s310003013','T2_总功率因数','double','cos',2,false,367013),
('s310003014','T3_总功率','double','kW',2,false,367014),
('s310003015','T3_总视在功率','double','kW',2,false,367015),
('s310003016','T3_总无功功率','double','kW',2,false,367016),
('s310003017','T3_总功率因素','double','cos',2,false,367017),
('s310005001','配电频率','double','Hz',2,false,36801),
('s310005002','T2_频率','double','Hz',2,false,36802),
('s310005003','T3_频率','double','Hz',2,false,36803),
('s310007001','平均相电压','double','V',2,false,369001),
('s310007002','平均线电压','double','V',2,false,369002),
('s310008001','平均相电流','double','A',2,false,370001),
('s310203001','L1相功率','double','kW',2,false,37101),
('s310203002','L2相功率','double','kW',2,false,37102),
('s310203003','L3相功率','double','kW',2,false,37103),
('s310203004','T2_L1相功率','double','kW',2,false,37104),
('s310203005','T2_L2相功率','double','kW',2,false,37105),
('s310203006','T2_L3相功率','double','kW',2,false,37106),
('s310203007','T3_L1相功率','double','kW',2,false,37107),
('s310203008','T3_L2相功率','double','kW',2,false,37108),
('s310203009','T3_L3相功率','double','kW',2,false,37109),
('s310207001','L1相电压','double','V',2,false,372001),
('s310207002','L2相电压','double','V',2,false,372002),
('s310207003','L3相电压','double','V',2,false,372003),
('s310207004','T2-L1相电压','double','V',2,false,372004),
('s310207005','T2-L2相电压','double','V',2,false,372005),
('s310207006','T2-L3相电压','double','V',2,false,372006),
('s310207007','T3-L1相电压','double','V',2,false,372007),
('s310207008','T3-L2相电压','double','V',2,false,372008),
('s310207009','T3--L3相电压','double','V',2,false,372009),
('s310207010','T2_平均线电压','double','V',2,false,372010),
('s310207011','T2_平均相电压','double','V',2,false,372011),
('s310207012','T2_平均电流','double','A',2,false,372012),
('s310207013','T3_平均线电压','double','V',2,false,372013),
('s310207014','T3_平均相电压','double','V',2,false,372014),
('s310207015','T3_平均电流','double','A',2,false,372015),
('s310208001','L1相电流','double','A',2,false,373001),
('s310208002','L2相电流','double','A',2,false,373002),
('s310208003','L3相电流','double','A',2,false,373003),
('s310208004','T2-L1相电流','double','A',2,false,373004),
('s310208005','T2-L2相电流','double','A',2,false,373005),
('s310208006','T2-L3相电流','double','A',2,false,373006),
('s310208007','T3-L1相电流','double','A',2,false,373007),
('s310208008','T3-L2相电流','double','A',2,false,373008),
('s310208009','T3-L3相电流','double','A',2,false,373009)
) AS v(code,name,data_type,unit,digits,is_alarm,sort_order)
WHERE ss.code = 's31'
ON CONFLICT (code) DO NOTHING;