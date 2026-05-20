# 跨境物流业务系统 实施方案

> **架构：** FastAPI + PostgreSQL + Redis + Vue 3 + Element Plus
> **路由：** Claude Code (DeepSeek代理) 开发
> **部署：** 阿里云 ECS (现有)

---

## 阶段一：项目骨架 + 认证系统

### 1.1 项目基础配置
**文件：**
- `backend/requirements.txt` — FastAPI, SQLAlchemy, psycopg2, redis, pyjwt, passlib, bcrypt
- `backend/app/__init__.py`
- `backend/app/core/config.py` — 数据库/Redis/JWT配置
- `backend/app/core/security.py` — JWT生成验证, 密码哈希
- `backend/app/core/database.py` — SQLAlchemy session + engine
- `backend/app/core/redis_client.py` — Redis连接
- `backend/run.py` — uvicorn启动入口

### 1.2 数据库模型 (30+表)
**文件：** `backend/app/models/`

**用户权限模块：**
- `sys_user.py` — 用户表 (id, username, password_hash, real_name, phone, email, status, role_id)
- `sys_role.py` — 角色表 (id, role_name, role_code, description, status)
- `sys_permission.py` — 权限表 (id, perm_name, perm_code, module, action)
- `sys_role_permission.py` — 角色-权限关联
- `sys_operation_log.py` — 操作日志

**业务核心模块：**
- `warehouse_inventory.py` — 库存表 (sku_code, product_name, total_qty, available_qty, locked_qty, location)
- `warehouse_receipt.py` — 收货记录 (batch_no, sku_code, qty, weight, owner, receipt_date)
- `pickup_point.py` — 收件点 (point_code, point_name, address, region, contact, status)
- `sorting_task.py` — 分装任务 (batch_no, sku_code, total_qty, target_point_id, priority, status)
- `file_record.py` — 文件记录 (file_name, file_type, version, batch_no, file_path, status)
- `file_template.py` — 文件模板
- `transport_vehicle.py` — 车辆 (plate_no, driver_name, driver_phone, vehicle_type, status)
- `transport_task.py` — 运输任务 (task_no, vehicle_id, route_from, route_to, departure_time, estimated_arrival, status)
- `customs_declaration.py` — 报关单 (declaration_no, batch_no, customs_office, total_value, status, review_comment)
- `warehouse_sorting_task.py` — 仓库分拣任务
- `delivery_task.py` — 配送任务
- `sign_receipt.py` — 签收记录
- `tracking_package.py` — 物流包裹
- `tracking_log.py` — 物流追踪日志
- `reconciliation.py` — 对账表
- `settlement.py` — 结算单
- `payment.py` — 支付记录
- `invoice.py` — 发票
- `alert_rule.py` — 预警规则
- `alert_record.py` — 预警记录
- `billing_rule.py` — 计费规则

### 1.3 认证API
**文件：** `backend/app/api/auth.py`
- `POST /api/v1/auth/login` — 登录 (密码+验证码)
- `POST /api/v1/auth/logout` — 退出
- `GET /api/v1/auth/captcha` — 图形验证码
- `POST /api/v1/auth/sms/send` — 短信验证码
- `GET /api/v1/auth/userinfo` — 当前用户信息

## 阶段二：业务核心模块

### 2.1 云仓集货管理
**文件：** `backend/app/api/consolidation.py`
- `GET /dashboard` — 仪表盘
- `GET /inventory` — 库存分页
- `POST /receipt` — 收货登记
- `GET /inventory/export` — 导出Excel

### 2.2 收件点分装管理
**文件：** `backend/app/api/sorting.py`
- `GET /dashboard` — 仪表盘
- `GET /task` — 分装任务列表
- `POST /task` — 创建分装任务
- `PUT /task/{id}/execute` — 执行分装

### 2.3 文件生成管理
**文件：** `backend/app/api/files.py`
- `GET /files` — 文件列表
- `POST /files/loading-list` — 生成装车文件
- `POST /files/customs-docs` — 生成报关文件
- `GET /files/{id}/preview` — 预览
- `GET /files/{id}/download` — 下载

### 2.4 装车运输管理
**文件：** `backend/app/api/transport.py`
- `GET /dashboard` — 运输仪表盘
- `GET /vehicle` — 车辆列表
- `POST /task` — 创建运输任务
- `PUT /task/{id}/status` — 更新状态

### 2.5 报关/清关管理
**文件：** `backend/app/api/customs.py`
- `GET /dashboard` — 报关仪表盘
- `GET /declaration` — 报关单列表
- `POST /declaration` — 提交报关
- `PUT /declaration/{id}/review` — 审核

### 2.6 仓库分拣管理
**文件：** `backend/app/api/warehouse.py`
- `GET /dashboard` — 分拣仪表盘
- `GET /kanban` — 看板数据
- `PUT /sorting-task/{id}/start` — 开始分拣
- `PUT /sorting-task/{id}/complete` — 完成分拣

### 2.7 配送管理
**文件：** `backend/app/api/delivery.py`

### 2.8 签收入库管理
**文件：** `backend/app/api/sign.py`

## 阶段三：财务模块

### 3.1 对账管理
**文件：** `backend/app/api/reconciliation.py`

### 3.2 资金结算管理
**文件：** `backend/app/api/settlement.py`

### 3.3 支付开票
**文件：** `backend/app/api/payment.py`

### 3.4 计费规则配置
**文件：** `backend/app/api/billing.py`

## 阶段四：追踪+预警+统计

### 4.1 物流追踪
**文件：** `backend/app/api/tracking.py`

### 4.2 异常预警
**文件：** `backend/app/api/alert.py`

### 4.3 数据统计
**文件：** `backend/app/api/analytics.py`

### 4.4 权限管理
**文件：** `backend/app/api/permission.py`

## 阶段五：前端开发

### 5.1 项目脚手架
**目录：** `frontend/`
- Vite + Vue 3 + Element Plus + Pinia + Vue Router
- Axios 封装、路由守卫、布局组件

### 5.2 页面开发 (按模块)
- 登录页
- 仪表盘
- 19个业务模块页面（对应原型HTML中所有模块）
