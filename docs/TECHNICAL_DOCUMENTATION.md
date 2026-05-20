# 技术说明文档

## 1. 数据库设计

### 1.1 表结构总览

| 模块 | 表名 | 说明 |
|------|------|------|
| 权限 | sys_user | 用户表（username, password_hash, real_name, phone, email, role_id, status） |
| 权限 | sys_role | 角色表（role_name, role_code, description, status） |
| 权限 | sys_permission | 权限表（perm_name, perm_code, module, action） |
| 权限 | sys_role_permission | 角色-权限关联（role_id, permission_id） |
| 权限 | sys_operation_log | 操作日志（username, module, action, target, ip_address, duration_ms） |
| 集货 | warehouse_inventory | 库存表（sku_code, product_name, category, total_qty, available_qty, weight_kg, location） |
| 集货 | warehouse_receipt | 收货记录（receipt_no, batch_no, sku_code, qty, weight_kg, owner） |
| 分装 | pickup_point | 收件点（point_code, point_name, address, region, contact, status） |
| 分装 | sorting_task | 分装任务（task_no, batch_no, sku_code, total_qty, target_point_id, priority, status） |
| 文件 | file_record | 文件记录（file_no, file_name, file_type, version, batch_no, file_path, status） |
| 文件 | file_template | 文件模板（template_name, template_type, file_path） |
| 运输 | transport_vehicle | 车辆（plate_no, vehicle_type, driver_name, driver_phone, max_weight, max_volume, longitude, latitude） |
| 运输 | transport_task | 运输任务（task_no, vehicle_id, route_from, route_to, departure_time, estimated_arrival, status） |
| 报关 | customs_declaration | 报关单（declaration_no, batch_no, total_value, currency, customs_office, declaration_type, status） |
| 分拣 | warehouse_sorting_task | 仓库分拣任务（task_no, batch_no, sku_code, total_qty, sorted_qty, assignee, status） |
| 配送 | delivery_task | 配送任务（task_no, pickup_point_id, package_count, batch_no, delivery_person, status） |
| 签收 | sign_receipt | 签收记录（receipt_no, package_no, sign_result, signer, signature_image, inbound_status） |
| 追踪 | tracking_package | 包裹（package_no, order_no, batch_no, product_name, sender, receiver, current_status） |
| 追踪 | tracking_log | 追踪日志（package_no, node_name, node_order, operator, location, status） |
| 财务 | reconciliation | 对账（recon_no, partner, cycle, order_amount, logistics_fee, diff_amount, status） |
| 财务 | settlement | 结算单（settle_no, recon_id, partner, settle_amount, direction, status） |
| 财务 | payment | 支付（payment_no, settle_id, pay_amount, pay_channel, status） |
| 财务 | invoice | 发票（invoice_no, payment_id, invoice_type, amount, buyer_name, buyer_tax_no, status） |
| 预警 | alert_rule | 预警规则（rule_name, alert_type, severity, trigger_condition, threshold_value） |
| 预警 | alert_record | 预警记录（batch_no, alert_type, severity, content, status, handled_by） |
| 计费 | billing_rule | 计费规则（rule_name, fee_type, charge_method, base_rate, rate_unit, tier_config, priority） |

### 1.2 通用字段
所有业务表均包含以下通用字段：
- `id` — 自增主键
- `create_time` — 创建时间
- `update_time` — 更新时间
- `deleted` — 逻辑删除标记（0=未删除, 1=已删除）

### 1.3 金额字段规范
- 金额使用 `decimal(18,2)` 类型
- 币种统一管理（默认 CNY/USD）

## 2. API 接口规范

### 2.1 通用约定
- 基础路径：`/api/v1`
- 认证方式：JWT Bearer Token
- 请求体：JSON
- 分页：`?page=1&size=20`
- 统一响应格式：
```json
{
  "code": 200,
  "message": "success",
  "data": {}
}
```

### 2.2 认证接口
| 方法 | 路径 | 说明 |
|------|------|------|
| POST | /auth/login | 用户登录，返回JWT |
| POST | /auth/logout | 退出登录 |
| GET | /auth/userinfo | 获取当前用户信息 |

### 2.3 核心业务接口
| 方法 | 路径 | 说明 |
|------|------|------|
| GET | /consolidation/dashboard | 集货仪表盘 |
| GET | /consolidation/inventory | 库存明细 |
| POST | /consolidation/receipt | 收货登记 |
| GET | /sorting/dashboard | 分装仪表盘 |
| GET/POST | /sorting/task | 分装任务CRUD |
| GET | /transport/dashboard | 运输仪表盘 |
| GET/POST | /transport/task | 运输任务CRUD |
| GET | /customs/dashboard | 报关仪表盘 |
| GET/POST | /customs/declaration | 报关单CRUD |
| PUT | /customs/declaration/{id}/review | 审核报关 |
| GET | /warehouse/kanban | 分拣看板 |
| POST | /sign | 签收提交 |
| GET | /tracking/query | 物流查询 |
| POST | /reconciliation/task | 创建对账任务 |
| POST | /settlement/order | 生成结算单 |
| PUT | /settlement/order/{id}/audit | 审核结算单 |
| PUT | /alert/record/{id}/handle | 处理预警 |
| POST | /billing/rules | 创建计费规则 |

## 3. 安全设计

- **密码加密**：BCrypt 加盐哈希存储
- **JWT 认证**：24小时过期，含用户ID/角色信息
- **逻辑删除**：所有表使用 `deleted` 字段标记删除
- **参数校验**：FastAPI Pydantic 模型校验
- **CORS**：全放通（生产环境需限制来源）

## 4. 部署说明

### 4.1 生产部署
```bash
# 后端 systemd 服务
[Unit]
Description=Logistics System Backend
After=network.target postgresql.service

[Service]
Type=simple
User=root
WorkingDirectory=/root/LogisticsSystem/backend
ExecStart=/usr/bin/python3 -m uvicorn app.main:app --host 127.0.0.1 --port 8001
Restart=always

[Install]
WantedBy=multi-user.target
```

### 4.2 Nginx 配置
```nginx
server {
    listen 8002;
    root /var/www/logistics;
    index index.html;
    
    location / { try_files $uri $uri/ /index.html; }
    location /api/ { proxy_pass http://127.0.0.1:8001; }
}
```

### 4.3 环境变量
通过 `.env` 文件配置：
- `DB_HOST/PORT/USER/PASSWORD/NAME` — 数据库连接
- `REDIS_HOST/PORT/PASSWORD/DB` — Redis连接
- `SECRET_KEY` — JWT签名密钥
- `DEBUG` — 调试模式开关

## 5. 版本记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0.0 | 2026-05-20 | 初版，18个功能模块，28张表，80+ API |
