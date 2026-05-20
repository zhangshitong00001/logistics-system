
-- =============================================
-- 跨境物流业务系统 - 种子数据（真实场景模拟）
-- =============================================

-- 设置默认 deleted=0（后续所有记录默认未删除）
SET session_replication_role = 'origin';

-- 1. 角色数据
INSERT INTO sys_role (id, role_name, role_code, description, status) VALUES
(1, '超级管理员', 'super_admin', '系统最高权限', 1),
(2, '运营主管', 'ops_manager', '业务运营管理', 1),
(3, '仓库管理员', 'warehouse_keeper', '仓储分拣操作', 1),
(4, '运输调度员', 'transport_dispatcher', '运输任务调度', 1),
(5, '报关专员', 'customs_officer', '报关清关处理', 1),
(6, '财务人员', 'finance_staff', '对账结算支付', 1)
ON CONFLICT (id) DO NOTHING;

-- 2. 用户数据
INSERT INTO sys_user (id, username, password_hash, real_name, phone, role_id, status) VALUES
(1, 'zhang', '$2b$12$2BAJEOa0pHMO6beqN8LOD.QP6ZLn6Kkzm6sN/2ZQuEr5FC61y8ecK', '张主管', '13800138001', 2, 1),
(2, 'admin', '$2b$12$2BAJEOa0pHMO6beqN8LOD.QP6ZLn6Kkzm6sN/2ZQuEr5FC61y8ecK', '系统管理员', '13800138000', 1, 1),
(3, 'wang', '$2b$12$2BAJEOa0pHMO6beqN8LOD.QP6ZLn6Kkzm6sN/2ZQuEr5FC61y8ecK', '王仓库', '13800138002', 3, 1),
(4, 'li', '$2b$12$2BAJEOa0pHMO6beqN8LOD.QP6ZLn6Kkzm6sN/2ZQuEr5FC61y8ecK', '李调度', '13800138003', 4, 1),
(5, 'chen', '$2b$12$2BAJEOa0pHMO6beqN8LOD.QP6ZLn6Kkzm6sN/2ZQuEr5FC61y8ecK', '陈报关', '13800138004', 5, 1),
(6, 'zhao', '$2b$12$2BAJEOa0pHMO6beqN8LOD.QP6ZLn6Kkzm6sN/2ZQuEr5FC61y8ecK', '赵会计', '13800138005', 6, 1)
ON CONFLICT (id) DO NOTHING;

-- All users have password: admin123

-- 3. 收件点数据（哈萨克斯坦境内）
INSERT INTO pickup_point (id, point_code, point_name, address, region, contact_person, contact_phone, coverage_status, status) VALUES
(1, 'ALM-001', '阿拉木图中心站', 'Almaty, Abay Ave 156', '阿拉木图州', 'Azamat K.', '+7-727-123-4567', 1, 1),
(2, 'AST-001', '阿斯塔纳北站', 'Astana, Qabanbay Batyr 45', '阿斯塔纳市', 'Serik M.', '+7-717-234-5678', 1, 1),
(3, 'KAR-001', '卡拉干达南站', 'Karaganda, Bukhar-Zhyrau 78', '卡拉干达州', 'Dmitry P.', '+7-721-345-6789', 1, 1),
(4, 'SHY-001', '奇姆肯特东站', 'Shymkent, Tauke Khan 234', '突厥斯坦州', 'Bakhyt S.', '+7-725-456-7890', 1, 1),
(5, 'AKT-001', '阿克托别西站', 'Aktobe, Abulkhair Khan 89', '阿克托别州', 'Nurlan K.', '+7-713-567-8901', 0, 1),
(6, 'TAR-001', '塔拉兹中心站', 'Taraz, Tole Bi 167', '江布尔州', 'Zhanat A.', '+7-726-678-9012', 1, 1),
(7, 'KOK-001', '科克舍套站', 'Kokshetau, Abay 56', '阿克莫拉州', 'Alexey V.', '+7-716-789-0123', 0, 1),
(8, 'PAV-001', '巴甫洛达尔站', 'Pavlodar, Krylov 34', '巴甫洛达尔州', 'Vladimir S.', '+7-718-890-1234', 1, 1)
ON CONFLICT (id) DO NOTHING;

-- 4. 仓库库存
INSERT INTO warehouse_inventory (id, sku_code, product_name, category, weight_kg, total_qty, available_qty, locked_qty, location, owner, alert_low_qty, alert_high_qty, status) VALUES
(1, 'ELE-FAN-001', '手持风扇 USB充电', '电子产品', 0.65, 5000, 4200, 800, 'A区-01-01', '深圳华强电子', 500, 8000, 1),
(2, 'ELE-PB-002', '20000mAh 移动电源', '电子产品', 0.85, 3500, 2800, 700, 'A区-01-02', '深圳华强电子', 300, 5000, 1),
(3, 'ELE-WB-003', '智能手表 S3', '电子产品', 0.35, 2000, 1500, 500, 'A区-02-01', '广州数码科技', 200, 3000, 1),
(4, 'ELE-BT-004', '蓝牙耳机 Pro', '电子产品', 0.25, 8000, 7200, 800, 'A区-02-02', '深圳声学科技', 500, 10000, 1),
(5, 'CLO-TSH-001', '纯棉T恤 男款L', '服装鞋帽', 0.40, 12000, 10500, 1500, 'B区-01-01', '义乌服装贸易', 1000, 20000, 1),
(6, 'CLO-JKT-002', '轻薄羽绒服 女款M', '服装鞋帽', 0.80, 6000, 4800, 1200, 'B区-01-02', '杭州四季青', 500, 10000, 1),
(7, 'CLO-SNK-003', '运动跑鞋 42码', '服装鞋帽', 1.20, 4000, 3200, 800, 'B区-02-01', '晋江鞋业', 300, 6000, 1),
(8, 'HOM-KT-001', '多功能厨房刀具套装', '家居用品', 2.50, 1500, 1200, 300, 'C区-01-01', '阳江五金制品', 100, 3000, 1),
(9, 'HOM-VC-002', '手持吸尘器 V8', '家居用品', 3.20, 800, 600, 200, 'C区-01-02', '苏州家电制造', 80, 1500, 1),
(10, 'HOM-LG-003', 'LED台灯 护眼款', '家居用品', 0.90, 3000, 2600, 400, 'C区-02-01', '中山照明科技', 300, 5000, 1),
(11, 'TCH-PH-001', '智能手机 A200', '电子产品', 0.50, 2500, 1800, 700, 'A区-03-01', '深圳天机电子', 200, 4000, 1),
(12, 'TCH-ES-002', '真无线耳机 T2', '电子产品', 0.18, 10000, 8500, 1500, 'A区-03-02', '深圳声学科技', 800, 15000, 1),
(13, 'CLO-SCA-001', '羊绒围巾 多色', '服装鞋帽', 0.30, 8000, 6800, 1200, 'B区-03-01', '桐乡羊绒制品', 600, 10000, 1),
(14, 'HOM-BG-001', '真空保温杯 500ml', '家居用品', 0.45, 6000, 5500, 500, 'C区-03-01', '永康杯业', 500, 8000, 1),
(15, 'TOY-DR-001', '遥控无人机 4K', '玩具', 1.80, 1200, 900, 300, 'D区-01-01', '汕头澄海玩具', 100, 2000, 1)
ON CONFLICT (id) DO NOTHING;

-- 5. 入库收货记录
INSERT INTO warehouse_receipt (id, receipt_no, batch_no, sku_code, product_name, qty, weight_kg, owner, location, operator, receipt_date) VALUES
(1, 'RC-250520-001', 'BATCH-20260501', 'ELE-FAN-001', '手持风扇 USB充电', 2000, 1300, '深圳华强电子', 'A区-01-01', '王仓库', '2026-05-20 09:15:00'),
(2, 'RC-250520-002', 'BATCH-20260501', 'ELE-PB-002', '20000mAh 移动电源', 1500, 1275, '深圳华强电子', 'A区-01-02', '王仓库', '2026-05-20 09:30:00'),
(3, 'RC-250520-003', 'BATCH-20260501', 'CLO-JKT-002', '轻薄羽绒服 女款M', 2000, 1600, '杭州四季青', 'B区-01-02', '王仓库', '2026-05-20 10:00:00'),
(4, 'RC-250519-001', 'BATCH-20260428', 'CLO-TSH-001', '纯棉T恤 男款L', 5000, 2000, '义乌服装贸易', 'B区-01-01', '王仓库', '2026-05-19 14:20:00'),
(5, 'RC-250519-002', 'BATCH-20260428', 'HOM-KT-001', '多功能厨房刀具套装', 800, 2000, '阳江五金制品', 'C区-01-01', '王仓库', '2026-05-19 15:00:00'),
(6, 'RC-250518-001', 'BATCH-20260425', 'TCH-PH-001', '智能手机 A200', 1000, 500, '深圳天机电子', 'A区-03-01', '王仓库', '2026-05-18 11:00:00'),
(7, 'RC-250518-002', 'BATCH-20260425', 'ELE-BT-004', '蓝牙耳机 Pro', 3000, 750, '深圳声学科技', 'A区-02-02', '王仓库', '2026-05-18 11:30:00'),
(8, 'RC-250517-001', 'BATCH-20260422', 'TOY-DR-001', '遥控无人机 4K', 600, 1080, '汕头澄海玩具', 'D区-01-01', '王仓库', '2026-05-17 09:00:00');

-- 6. 分装任务
INSERT INTO sorting_task (id, task_no, batch_no, sku_code, product_name, total_qty, completed_qty, target_point_id, priority, assignee, status) VALUES
(1, 'ST-B4F3A2C1', 'BATCH-20260501', 'ELE-FAN-001', '手持风扇 USB充电', 800, 800, 1, 1, '王分装', 2),
(2, 'ST-C5D6E7F8', 'BATCH-20260501', 'ELE-PB-002', '20000mAh 移动电源', 600, 600, 1, 1, '王分装', 2),
(3, 'ST-A1B2C3D4', 'BATCH-20260501', 'CLO-JKT-002', '轻薄羽绒服 女款M', 800, 800, 2, 2, '李分装', 2),
(4, 'ST-E9F0G1H2', 'BATCH-20260428', 'CLO-TSH-001', '纯棉T恤 男款L', 2000, 2000, 1, 1, '王分装', 2),
(5, 'ST-I3J4K5L6', 'BATCH-20260428', 'HOM-KT-001', '多功能厨房刀具套装', 300, 300, 3, 3, '张分装', 2),
(6, 'ST-M7N8O9P0', 'BATCH-20260425', 'TCH-PH-001', '智能手机 A200', 400, 400, 2, 1, '李分装', 2),
(7, 'ST-Q1R2S3T4', 'BATCH-20260425', 'ELE-BT-004', '蓝牙耳机 Pro', 1200, 1200, 4, 2, '张分装', 2),
(8, 'ST-U5V6W7X8', 'BATCH-20260422', 'TOY-DR-001', '遥控无人机 4K', 200, 150, 6, 1, '王分装', 1),
(9, 'ST-Y9Z0A1B2', 'BATCH-20260501', 'ELE-FAN-001', '手持风扇 USB充电', 600, 0, 6, 2, '', 0),
(10, 'ST-C3D4E5F6', 'BATCH-20260501', 'ELE-BT-004', '蓝牙耳机 Pro', 1500, 0, 8, 1, '', 0);

-- 7. 文件记录
INSERT INTO file_record (id, file_no, file_name, file_type, version, batch_no, file_size, status, creator) VALUES
(1, 'FL-A1B2C3D4E5', '装车清单_BATCH-20260501', 'loading_list', 'v1.0', 'BATCH-20260501', 245760, 1, '张主管'),
(2, 'CD-F6G7H8I9J0', '商业发票_BATCH-20260501', 'invoice', 'v1.0', 'BATCH-20260501', 184320, 1, '陈报关'),
(3, 'CD-K1L2M3N4O5', '装箱单_BATCH-20260501', 'packing_list', 'v1.0', 'BATCH-20260501', 102400, 1, '陈报关'),
(4, 'CD-P6Q7R8S9T0', '报关单_BATCH-20260501', 'declaration', 'v1.0', 'BATCH-20260501', 153600, 1, '陈报关'),
(5, 'CD-U1V2W3X4Y5', '原产地证明_BATCH-20260501', 'certificate', 'v1.0', 'BATCH-20260501', 81920, 1, '陈报关'),
(6, 'FL-Z6A7B8C9D0', '装车清单_BATCH-20260428', 'loading_list', 'v1.0', 'BATCH-20260428', 315392, 1, '张主管'),
(7, 'CD-E1F2G3H4I5', '商业发票_BATCH-20260428', 'invoice', 'v1.0', 'BATCH-20260428', 204800, 1, '陈报关');

-- 8. 文件模板
INSERT INTO file_template (id, template_name, template_type, description) VALUES
(1, '装车清单模板_v3', 'loading_list', '标准跨境运输装车清单模板'),
(2, '商业发票模板_中俄双语', 'invoice', '中俄双语商业发票，含HS编码'),
(3, '装箱单模板_标准', 'packing_list', '标准出口装箱单'),
(4, '报关单模板_出口', 'declaration', '中国海关出口报关单模板'),
(5, '原产地证明模板_中哈', 'certificate', '中国-哈萨克斯坦原产地证明'),
(6, '海关查验单模板', 'inspection', '海关查验结果记录单');

-- 9. 运输车辆
INSERT INTO transport_vehicle (id, plate_no, vehicle_type, driver_name, driver_phone, max_weight, max_volume, longitude, latitude, speed, status) VALUES
(1, '新A·88888', '重型厢式货车', '马师傅', '13888888001', 32000, 90, 80.2520, 44.2920, 75, 2),
(2, '新B·66666', '重型厢式货车', '刘师傅', '13888888002', 32000, 90, 80.2980, 44.2850, 68, 2),
(3, '新C·55555', '中型厢式货车', '赵师傅', '13888888003', 18000, 55, 76.9450, 43.2670, 82, 2),
(4, '新D·44444', '重型冷藏车', '孙师傅', '13888888004', 28000, 75, null, null, 0, 0),
(5, '新E·33333', '中型厢式货车', '周师傅', '13888888005', 18000, 55, 71.4580, 51.1810, 60, 2),
(6, '新F·22222', '重型厢式货车', '吴师傅', '13888888006', 32000, 90, 76.9280, 43.2550, 0, 1)
ON CONFLICT (id) DO NOTHING;

-- 10. 运输任务
INSERT INTO transport_task (id, task_no, vehicle_id, route_from, route_to, departure_time, estimated_arrival, actual_arrival, batch_no, driver_name, driver_phone, status) VALUES
(1, 'TT-D4E5F678', 1, '霍尔果斯口岸', '阿拉木图中心站', '2026-05-20 08:00:00', '2026-05-20 14:00:00', null, 'BATCH-20260501', '马师傅', '13888888001', 1),
(2, 'TT-A1B2C345', 2, '霍尔果斯口岸', '阿斯塔纳北站', '2026-05-20 06:30:00', '2026-05-20 18:00:00', '2026-05-20 17:45:00', 'BATCH-20260428', '刘师傅', '13888888002', 2),
(3, 'TT-G7H8I901', 3, '霍尔果斯口岸', '卡拉干达南站', '2026-05-19 22:00:00', '2026-05-20 10:00:00', '2026-05-20 09:30:00', 'BATCH-20260425', '赵师傅', '13888888003', 2),
(4, 'TT-J2K3L456', 5, '霍尔果斯口岸', '奇姆肯特东站', '2026-05-20 10:00:00', '2026-05-20 16:00:00', null, 'BATCH-20260422', '周师傅', '13888888005', 1),
(5, 'TT-M7N8O901', 4, '霍尔果斯口岸', '阿克托别西站', '2026-05-21 06:00:00', '2026-05-22 08:00:00', null, 'BATCH-20260501', '孙师傅', '13888888004', 0),
(6, 'TT-P2Q3R456', 6, '霍尔果斯口岸', '塔拉兹中心站', '2026-05-20 09:00:00', '2026-05-20 15:00:00', '2026-05-20 14:20:00', 'BATCH-20260501', '吴师傅', '13888888006', 2);

-- 11. 报关单
INSERT INTO customs_declaration (id, declaration_no, batch_no, sku_info, total_value, currency, customs_office, declaration_type, status, submitter, create_time) VALUES
(1, 'BG-CUSTOMS-001', 'BATCH-20260501', '[{"sku":"ELE-FAN-001","qty":1400,"value":16800},{"sku":"ELE-PB-002","qty":600,"value":36000}]', 52800, 'USD', '霍尔果斯口岸', 'export', 1, '陈报关', '2026-05-19 10:30:00'),
(2, 'BG-CUSTOMS-002', 'BATCH-20260428', '[{"sku":"CLO-TSH-001","qty":2000,"value":20000},{"sku":"HOM-KT-001","qty":300,"value":15000}]', 35000, 'USD', '霍尔果斯口岸', 'export', 2, '陈报关', '2026-05-18 14:00:00'),
(3, 'BG-CUSTOMS-003', 'BATCH-20260425', '[{"sku":"TCH-PH-001","qty":400,"value":80000},{"sku":"ELE-BT-004","qty":1200,"value":24000}]', 104000, 'USD', '霍尔果斯口岸', 'export', 2, '陈报关', '2026-05-17 11:00:00'),
(4, 'BG-CUSTOMS-004', 'BATCH-20260422', '[{"sku":"TOY-DR-001","qty":200,"value":40000}]', 40000, 'USD', '霍尔果斯口岸', 'export', 3, '陈报关', '2026-05-16 09:00:00'),
(5, 'BG-CUSTOMS-005', 'BATCH-20260501', '[{"sku":"CLO-JKT-002","qty":800,"value":48000}]', 48000, 'USD', '阿拉山口口岸', 'export', 0, '陈报关', '2026-05-20 08:00:00');

-- Update reviewed ones
UPDATE customs_declaration SET review_time = '2026-05-18 16:00:00', review_comment = '单证齐全，审核通过' WHERE id = 2;
UPDATE customs_declaration SET review_time = '2026-05-17 15:00:00', review_comment = '审核通过，准予放行' WHERE id = 3;
UPDATE customs_declaration SET review_time = '2026-05-16 14:00:00', review_comment = '商品归类有误，请重新申报' WHERE id = 4;

-- 12. 仓库分拣任务
INSERT INTO warehouse_sorting_task (id, task_no, batch_no, sku_code, product_name, total_qty, sorted_qty, location, assignee, status) VALUES
(1, 'WS-001', 'BATCH-20260501', 'ELE-FAN-001', '手持风扇 USB充电', 600, 600, 'A区-01-01', '王仓库', 2),
(2, 'WS-002', 'BATCH-20260501', 'ELE-BT-004', '蓝牙耳机 Pro', 1500, 1200, 'A区-02-02', '王仓库', 1),
(3, 'WS-003', 'BATCH-20260501', 'CLO-JKT-002', '轻薄羽绒服 女款M', 500, 500, 'B区-01-02', '李仓库', 2),
(4, 'WS-004', 'BATCH-20260501', 'HOM-LG-003', 'LED台灯 护眼款', 800, 0, 'C区-02-01', '', 0),
(5, 'WS-005', 'BATCH-20260428', 'CLO-TSH-001', '纯棉T恤 男款L', 3000, 3000, 'B区-01-01', '王仓库', 2),
(6, 'WS-006', 'BATCH-20260428', 'HOM-KT-001', '多功能厨房刀具套装', 500, 500, 'C区-01-01', '李仓库', 2),
(7, 'WS-007', 'BATCH-20260425', 'TCH-PH-001', '智能手机 A200', 600, 600, 'A区-03-01', '王仓库', 2);

-- 13. 配送任务
INSERT INTO delivery_task (id, task_no, pickup_point_id, package_count, batch_no, delivery_person, status) VALUES
(1, 'PS-001', 1, 45, 'BATCH-20260501', '配送员别克', 1),
(2, 'PS-002', 2, 38, 'BATCH-20260428', '配送员阿依', 2),
(3, 'PS-003', 3, 28, 'BATCH-20260425', '配送员叶尔兰', 2),
(4, 'PS-004', 6, 22, 'BATCH-20260422', '配送员迪娜', 3),
(5, 'PS-005', 4, 35, 'BATCH-20260501', '配送员萨沙', 0),
(6, 'PS-006', 8, 42, 'BATCH-20260501', '配送员维克多', 1);

-- 14. 签收记录
INSERT INTO sign_receipt (id, receipt_no, package_no, delivery_task_id, pickup_point_id, sign_result, signer, sign_time, inbound_status) VALUES
(1, 'SR-001', 'PKG-20260501-001', 2, 1, 'normal', 'Azamat K.', '2026-05-20 13:00:00', 1),
(2, 'SR-002', 'PKG-20260501-002', 2, 1, 'normal', 'Azamat K.', '2026-05-20 13:05:00', 1),
(3, 'SR-003', 'PKG-20260501-003', 3, 3, 'normal', 'Dmitry P.', '2026-05-20 10:30:00', 1),
(4, 'SR-004', 'PKG-20260501-004', 3, 3, 'damaged', 'Dmitry P.', '2026-05-20 10:35:00', 0),
(5, 'SR-005', 'PKG-20260501-005', 2, 2, 'normal', 'Serik M.', '2026-05-20 14:00:00', 1),
(6, 'SR-006', 'PKG-20260501-006', 2, 2, 'normal', 'Serik M.', '2026-05-20 14:05:00', 1),
(7, 'SR-007', 'PKG-20260501-007', 4, 6, 'lost', 'Zhanat A.', null, 0);

-- 15. 物流追踪 - 包裹
INSERT INTO tracking_package (id, package_no, order_no, batch_no, product_name, sku_code, qty, weight_kg, sender, receiver, receiver_phone, receiver_address, current_node, current_status) VALUES
(1, 'PKG-20260501-001', 'ORD-202605-0001', 'BATCH-20260501', '手持风扇 USB充电', 'ELE-FAN-001', 200, 130, '深圳华强电子', 'Azamat K.', '+7-727-123-4567', 'Almaty, Abay Ave 156', '阿拉木图配送中', 4),
(2, 'PKG-20260501-002', 'ORD-202605-0002', 'BATCH-20260501', '20000mAh 移动电源', 'ELE-PB-002', 100, 85, '深圳华强电子', 'Serik M.', '+7-717-234-5678', 'Astana, Qabanbay Batyr 45', '阿斯塔纳待签收', 4),
(3, 'PKG-20260501-003', 'ORD-202605-0003', 'BATCH-20260428', '纯棉T恤 男款L', 'CLO-TSH-001', 500, 200, '义乌服装贸易', 'Bakhyt S.', '+7-725-456-7890', 'Shymkent, Tauke Khan 234', '已签收', 5),
(4, 'PKG-20260501-004', 'ORD-202605-0004', 'BATCH-20260428', '多功能厨房刀具套装', 'HOM-KT-001', 100, 250, '阳江五金制品', 'Dmitry P.', '+7-721-345-6789', 'Karaganda, Bukhar-Zhyrau 78', '已签收(损坏)', 5),
(5, 'PKG-20260501-005', 'ORD-202605-0005', 'BATCH-20260425', '智能手机 A200', 'TCH-PH-001', 100, 50, '深圳天机电子', 'Azamat K.', '+7-727-123-4567', 'Almaty, Abay Ave 156', '清关中', 3),
(6, 'PKG-20260501-006', 'ORD-202605-0006', 'BATCH-20260425', '蓝牙耳机 Pro', 'ELE-BT-004', 400, 100, '深圳声学科技', 'Nurlan K.', '+7-713-567-8901', 'Aktobe, Abulkhair Khan 89', '已签收', 5),
(7, 'PKG-20260501-007', 'ORD-202605-0007', 'BATCH-20260422', '遥控无人机 4K', 'TOY-DR-001', 50, 90, '汕头澄海玩具', 'Zhanat A.', '+7-726-678-9012', 'Taraz, Tole Bi 167', '待集货', 0),
(8, 'PKG-20260501-008', 'ORD-202605-0008', 'BATCH-20260501', '轻薄羽绒服 女款M', 'CLO-JKT-002', 200, 160, '杭州四季青', 'Vladimir S.', '+7-718-890-1234', 'Pavlodar, Krylov 34', '运输中', 1);

-- 16. 物流追踪 - 日志
INSERT INTO tracking_log (id, package_no, node_name, node_order, operator, location, description, status, operate_time) VALUES
(1, 'PKG-20260501-001', '深圳集货仓', 1, '王仓库', '深圳', '包裹已入库', 1, '2026-05-18 09:00:00'),
(2, 'PKG-20260501-001', '霍尔果斯口岸', 2, '陈报关', '霍尔果斯', '出口报关通过，放行', 2, '2026-05-19 14:00:00'),
(3, 'PKG-20260501-001', '阿拉木图中心站', 3, '马师傅', '阿拉木图', '运输到达，卸货完成', 3, '2026-05-20 13:00:00'),
(4, 'PKG-20260501-001', '阿拉木图配送中', 4, '配送员别克', '阿拉木图', '配送途中', 4, '2026-05-20 15:00:00'),
(5, 'PKG-20260501-003', '义乌集货仓', 1, '李仓库', '义乌', '包裹已入库', 1, '2026-05-17 10:00:00'),
(6, 'PKG-20260501-003', '霍尔果斯口岸', 2, '陈报关', '霍尔果斯', '出口报关通过', 2, '2026-05-18 10:00:00'),
(7, 'PKG-20260501-003', '奇姆肯特东站', 3, '刘师傅', '奇姆肯特', '运输到达', 3, '2026-05-19 15:00:00'),
(8, 'PKG-20260501-003', '已签收', 4, 'Bakhyt S.', '奇姆肯特', '客户已签收', 5, '2026-05-20 10:00:00'),
(9, 'PKG-20260501-005', '深圳集货仓', 1, '王仓库', '深圳', '包裹已入库', 1, '2026-05-16 09:00:00'),
(10, 'PKG-20260501-005', '霍尔果斯口岸', 2, '陈报关', '霍尔果斯', '出口报关通过', 2, '2026-05-17 11:00:00'),
(11, 'PKG-20260501-005', '清关审核中', 3, '陈报关', '阿拉木图', '进口清关审核中', 3, '2026-05-19 09:30:00'),
(12, 'PKG-20260501-006', '深圳集货仓', 1, '王仓库', '深圳', '包裹已入库', 1, '2026-05-16 10:00:00'),
(13, 'PKG-20260501-006', '霍尔果斯口岸', 2, '陈报关', '霍尔果斯', '出口报关通过', 2, '2026-05-17 14:00:00'),
(14, 'PKG-20260501-006', '阿克托别西站', 3, '赵师傅', '阿克托别', '运输到达', 3, '2026-05-19 11:00:00'),
(15, 'PKG-20260501-006', '已签收', 4, 'Nurlan K.', '阿克托别', '客户已签收', 5, '2026-05-20 12:00:00'),
(16, 'PKG-20260501-008', '深圳集货仓', 1, '王仓库', '深圳', '包裹已入库', 1, '2026-05-19 08:00:00'),
(17, 'PKG-20260501-008', '霍尔果斯口岸', 2, '陈报关', '霍尔果斯', '等待装车', 2, '2026-05-20 07:00:00'),
(18, 'PKG-20260501-008', '运输途中', 3, '吴师傅', '阿拉木图方向', '运输途中', 1, '2026-05-20 10:00:00');

-- 17. 对账任务
INSERT INTO reconciliation (id, recon_no, partner, cycle_start, cycle_end, order_amount, logistics_fee, diff_amount, diff_count, status, operator) VALUES
(1, 'DZ-001', '深圳华强电子', '2026-04-01', '2026-04-30', 528000, 528000, 0, 0, 2, '赵会计'),
(2, 'DZ-002', '杭州四季青', '2026-04-01', '2026-04-30', 384000, 383500, 500, 1, 3, '赵会计'),
(3, 'DZ-003', '义乌服装贸易', '2026-05-01', '2026-05-15', 286000, 286000, 0, 0, 2, '赵会计'),
(4, 'DZ-004', '深圳声学科技', '2026-04-01', '2026-04-30', 672000, 670000, 2000, 2, 3, '赵会计'),
(5, 'DZ-005', '阳江五金制品', '2026-04-01', '2026-04-30', 156000, 156000, 0, 0, 1, '赵会计'),
(6, 'DZ-006', '深圳天机电子', '2026-05-01', '2026-05-15', 420000, 420000, 0, 0, 0, '');

-- 18. 结算单
INSERT INTO settlement (id, settle_no, recon_id, partner, settle_cycle_start, settle_cycle_end, settle_amount, direction, status, submitter) VALUES
(1, 'JS-001', 1, '深圳华强电子', '2026-04-01', '2026-04-30', 528000, 'payable', 2, '赵会计'),
(2, 'JS-002', 3, '义乌服装贸易', '2026-05-01', '2026-05-15', 286000, 'payable', 0, '赵会计'),
(3, 'JS-003', 5, '阳江五金制品', '2026-04-01', '2026-04-30', 156000, 'payable', 1, '赵会计'),
(4, 'JS-004', null, '汕头澄海玩具', '2026-04-01', '2026-04-30', 89000, 'receivable', 2, '赵会计');

-- Update audit info
UPDATE settlement SET auditor = '张主管', audit_time = '2026-05-10 15:00:00', audit_comment = '核对无误，准予结算', status = 2 WHERE id = 1;
UPDATE settlement SET auditor = '张主管', audit_time = '2026-05-15 16:00:00', audit_comment = '同意', status = 2 WHERE id = 4;

-- 19. 支付记录
INSERT INTO payment (id, payment_no, settle_id, pay_amount, pay_channel, pay_time, status) VALUES
(1, 'PAY-001', 1, 528000, 'bank', '2026-05-11 10:00:00', 2),
(2, 'PAY-002', 4, 89000, 'alipay', '2026-05-16 14:30:00', 2),
(3, 'PAY-003', 2, 286000, 'bank', '2026-05-20 09:00:00', 1),
(4, 'PAY-004', null, 25000, 'wechat', '2026-05-19 11:30:00', 0);

-- 20. 发票
INSERT INTO invoice (id, invoice_no, payment_id, invoice_type, amount, buyer_name, buyer_tax_no, status) VALUES
(1, 'FP-001', 1, 'special', 528000, '深圳华强电子', '914403001234567890', 1),
(2, 'FP-002', 2, 'normal', 89000, '汕头澄海玩具', '914405001234567890', 1),
(3, 'FP-003', 3, 'special', 286000, '义乌服装贸易', '913307821234567890', 0);

-- 21. 预警规则
INSERT INTO alert_rule (id, rule_name, alert_type, severity, trigger_condition, threshold_value, notify_method, notify_role_id, status) VALUES
(1, '库存低于安全值', 'inventory_low', 'high', 'available_qty <= alert_low_qty', 'alert_low_qty', 'system', 2, 1),
(2, '库存超储告警', 'inventory_high', 'medium', 'available_qty >= alert_high_qty', 'alert_high_qty', 'system', 3, 1),
(3, '运输超时未达', 'transport_delayed', 'high', 'actual_arrival > estimated_arrival + 2h', '2h', 'system', 4, 1),
(4, '报关待审超24h', 'customs_pending', 'medium', 'status=0 and create_time < now-24h', '24h', 'system', 5, 1),
(5, '对账差异超过阈值', 'reconciliation_diff', 'high', 'diff_amount > 10000', '10000', 'system', 6, 1),
(6, '签收异常报告', 'sign_abnormal', 'medium', 'sign_result != normal', '1', 'system', 2, 1);

-- 22. 预警记录
INSERT INTO alert_record (id, batch_no, alert_type, severity, content, status, handle_result) VALUES
(1, 'BATCH-20260501', 'inventory_low', 'high', '手持风扇库存4200件，即将低于安全库存500件，触发时间:2026-05-20', 0, ''),
(2, 'BATCH-20260428', 'inventory_high', 'medium', '纯棉T恤库存10500件，超出高库存阈值10000件，触发时间:2026-05-19', 0, ''),
(3, 'BATCH-20260422', 'transport_delayed', 'high', '运输任务TT-J2K3L456（奇姆肯特方向）已超预计到达时间2小时未到达', 2, '已联系司机确认天气原因延误'),
(4, 'BATCH-20260428', 'customs_pending', 'medium', '报关单BG-CUSTOMS-002已审核24小时未处理，当前状态:审核通过', 2, '已通过'),
(5, 'BATCH-20260425', 'reconciliation_diff', 'high', '深圳声学科技对账差异2000元，需人工介入处理', 2, '已核实为到付运费差异'),
(6, 'BATCH-20260422', 'sign_abnormal', 'medium', '包裹PKG-20260501-004签收结果异常:damaged(损坏)，包裹PKG-20260501-007签收结果异常:lost(丢失)', 1, '已安排理赔流程'),
(7, 'BATCH-20260501', 'inventory_low', 'high', '手持吸尘器库存仅600件，低于安全库存80件阈值', 0, '');

-- 23. 计费规则
INSERT INTO billing_rule (id, rule_name, fee_type, charge_method, base_rate, rate_unit, currency, priority, status) VALUES
(1, '跨境运输-重量计费', 'transport', 'weight', 12.50, '元/kg', 'CNY', 1, 1),
(2, '跨境运输-体积计费', 'transport', 'volume', 3500.00, '元/m³', 'CNY', 2, 1),
(3, '报关服务费', 'customs', 'fixed', 500.00, '元/票', 'CNY', 3, 1),
(4, '仓储费-普通仓', 'warehouse', 'weight', 0.50, '元/kg/天', 'CNY', 4, 1),
(5, '仓储费-冷链仓', 'warehouse', 'weight', 1.20, '元/kg/天', 'CNY', 5, 1),
(6, '分装服务费', 'sorting', 'per_item', 3.00, '元/件', 'CNY', 6, 1),
(7, '派送费-阿拉木图', 'delivery', 'fixed', 800.00, '元/票', 'CNY', 7, 1),
(8, '派送费-阿斯塔纳', 'delivery', 'fixed', 1200.00, '元/票', 'CNY', 8, 1),
(9, '燃油附加费', 'surcharge', 'percent', 8.00, '%', 'CNY', 9, 1),
(10, '旺季附加费', 'surcharge', 'percent', 15.00, '%', 'CNY', 10, 0);

-- 24. 权限数据
INSERT INTO sys_permission (id, perm_name, perm_code, module, action) VALUES
(1, '系统首页', 'dashboard:view', 'dashboard', 'view'),
(2, '云仓集货查看', 'consolidation:view', 'consolidation', 'view'),
(3, '云仓集货管理', 'consolidation:manage', 'consolidation', 'manage'),
(4, '收件点分装查看', 'sorting:view', 'sorting', 'view'),
(5, '收件点分装管理', 'sorting:manage', 'sorting', 'manage'),
(6, '文件生成查看', 'files:view', 'files', 'view'),
(7, '文件生成管理', 'files:manage', 'files', 'manage'),
(8, '装车运输查看', 'transport:view', 'transport', 'view'),
(9, '装车运输管理', 'transport:manage', 'transport', 'manage'),
(10, '报关清关查看', 'customs:view', 'customs', 'view'),
(11, '报关清关管理', 'customs:manage', 'customs', 'manage'),
(12, '仓库分拣查看', 'warehouse:view', 'warehouse', 'view'),
(13, '仓库分拣管理', 'warehouse:manage', 'warehouse', 'manage'),
(14, '配送管理查看', 'delivery:view', 'delivery', 'view'),
(15, '配送管理操作', 'delivery:manage', 'delivery', 'manage'),
(16, '签收入库查看', 'sign:view', 'sign', 'view'),
(17, '签收入库操作', 'sign:manage', 'sign', 'manage'),
(18, '物流追踪查看', 'tracking:view', 'tracking', 'view'),
(19, '对账管理', 'reconciliation:manage', 'reconciliation', 'manage'),
(20, '资金结算', 'settlement:manage', 'settlement', 'manage'),
(21, '支付开票', 'payment:manage', 'payment', 'manage'),
(22, '预警中心', 'alert:view', 'alert', 'view'),
(23, '统计分析', 'analytics:view', 'analytics', 'view'),
(24, '权限管理', 'permission:manage', 'permission', 'manage'),
(25, '计费规则', 'billing:manage', 'billing', 'manage')
ON CONFLICT (id) DO NOTHING;

-- 25. 角色-权限关联 (super_admin 拥有所有权限)
INSERT INTO sys_role_permission (role_id, permission_id)
SELECT 1, id FROM sys_permission
ON CONFLICT DO NOTHING;

-- ops_manager 权限
INSERT INTO sys_role_permission (role_id, permission_id)
SELECT 2, id FROM sys_permission WHERE perm_code NOT IN ('billing:manage', 'permission:manage')
ON CONFLICT DO NOTHING;

-- 26. 操作日志
INSERT INTO sys_operation_log (id, username, module, action, target, detail, status, create_time) VALUES
(1, 'admin', 'auth', 'login', 'system', '用户登录系统', 1, '2026-05-20 09:15:00'),
(2, 'admin', 'consolidation', 'view', '云仓集货', '查看集货仪表盘', 1, '2026-05-20 09:16:00'),
(3, '张主管', 'transport', 'view', '运输管理', '查看运输仪表盘', 1, '2026-05-20 09:30:00'),
(4, '陈报关', 'customs', 'submit', '报关单BG-CUSTOMS-005', '提交出口报关单', 1, '2026-05-20 08:00:00'),
(5, '王仓库', 'warehouse', 'start', '分拣任务WS-002', '开始仓库分拣', 1, '2026-05-20 09:10:00'),
(26, '赵会计', 'reconciliation', 'view', '对账管理', '查看对账列表', 1, '2026-05-20 10:00:00');

-- 最终清理：确保所有记录的 deleted 字段设置为 0
UPDATE warehouse_inventory SET deleted=0 WHERE deleted IS NULL;
UPDATE warehouse_receipt SET deleted=0 WHERE deleted IS NULL;
UPDATE sorting_task SET deleted=0 WHERE deleted IS NULL;
UPDATE pickup_point SET deleted=0 WHERE deleted IS NULL;
UPDATE file_record SET deleted=0 WHERE deleted IS NULL;
UPDATE file_template SET deleted=0 WHERE deleted IS NULL;
UPDATE transport_vehicle SET deleted=0 WHERE deleted IS NULL;
UPDATE transport_task SET deleted=0 WHERE deleted IS NULL;
UPDATE customs_declaration SET deleted=0 WHERE deleted IS NULL;
UPDATE warehouse_sorting_task SET deleted=0 WHERE deleted IS NULL;
UPDATE delivery_task SET deleted=0 WHERE deleted IS NULL;
UPDATE sign_receipt SET deleted=0 WHERE deleted IS NULL;
UPDATE tracking_package SET deleted=0 WHERE deleted IS NULL;
UPDATE reconciliation SET deleted=0 WHERE deleted IS NULL;
UPDATE settlement SET deleted=0 WHERE deleted IS NULL;
UPDATE payment SET deleted=0 WHERE deleted IS NULL;
UPDATE invoice SET deleted=0 WHERE deleted IS NULL;
UPDATE alert_rule SET deleted=0 WHERE deleted IS NULL;
UPDATE billing_rule SET deleted=0 WHERE deleted IS NULL;
UPDATE sys_permission SET deleted=0 WHERE deleted IS NULL;
UPDATE sys_user SET deleted=0 WHERE deleted IS NULL;
UPDATE sys_role SET deleted=0 WHERE deleted IS NULL;
