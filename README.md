# 跨境物流业务系统

> Cross-Border Logistics Management System  
> 中国-哈萨克斯坦跨境物流全链路数字化平台

---

## 项目概述

覆盖从中国云仓集货 → 运输 → 报关/清关 → 末端配送 → 签收入库的完整跨境物流链路，含对账结算、异常预警、数据分析等配套功能。

**业务范围：** 18 个核心功能域，408 个收件点（哈萨克斯坦），中国霍尔果斯口岸进出。

## 技术栈

| 层 | 技术 | 版本 |
|---|------|------|
| 前端 | Vue 3 + Element Plus + Pinia + Vue Router | Vue 3.4+ |
| 构建 | Vite 8 | - |
| 后端 | FastAPI + SQLAlchemy + Pydantic | Python 3.12 |
| 数据库 | PostgreSQL 16 | 28 张业务表 |
| 缓存 | Redis 7 | 会话/验证码 |
| 认证 | JWT (PyJWT) + BCrypt | 24h 过期 |
| 代理 | Nginx | 前端静态 + API 反向代理 |

## 系统架构

```
用户浏览器
    │
    ▼
Nginx (:8002) ──── 前端静态资源 (/var/www/logistics)
    │
    ▼  /api/*
FastAPI (:8001) ──── PostgreSQL (logistics_db)
                └─── Redis (db 2)
```

## 快速部署

### 环境要求
- Python 3.12+
- Node.js 22+
- PostgreSQL 16+
- Redis 7+

### 后端

```bash
cd backend
pip install -r requirements.txt
# 编辑 .env 配置数据库连接
python run.py
# 服务运行在 http://127.0.0.1:8001
```

### 前端

```bash
cd frontend
npm install
npm run dev        # 开发模式 :5173
npx vite build     # 生产构建 → dist/
```

### 数据库

```bash
# 手动创建数据库
sudo -u postgres psql -c "CREATE DATABASE logistics_db OWNER zhangshitong;"

# 或导入 schema
psql -h 127.0.0.1 -U zhangshitong -d logistics_db -f database/schema.sql
```

> 后端启动时会自动调用 `Base.metadata.create_all()` 建表。

## 功能模块

### 业务流程 (8 模块)
| 模块 | 说明 | API 前缀 |
|------|------|----------|
| 📦 云仓集货管理 | 库存管理、收货登记、缺货/溢货预警 | `/consolidation` |
| 📋 收件点分装管理 | 分装任务分配、进度追踪、收件点维护 | `/sorting` |
| 📄 文件生成管理 | 装车清单/商业发票/装箱单/原产地证明 | `/files` |
| 🚛 装车运输管理 | 车辆管理、运输任务、实时位置 | `/transport` |
| 🏛️ 报关/清关管理 | 出口报关/进口清关、审核流程 | `/customs` |
| 📦 仓库分拣管理 | Kanban看板、分拣任务、入库 | `/warehouse` |
| 🚚 配送管理 | 配送任务、路线优化、状态跟踪 | `/delivery` |
| ✍️ 签收入库管理 | 扫码签收、异常处理、入库确认 | `/sign` |

### 财务管理 (3 模块)
| 模块 | 说明 | API 前缀 |
|------|------|----------|
| 💰 对账管理 | 对账任务、差异处理、自动对账 | `/reconciliation` |
| 💵 资金结算 | 结算单、审核流程、应收/应付 | `/settlement` |
| 📜 支付开票 | 支付记录、发票生成 | `/payment` |

### 核心功能 (5 模块)
| 模块 | 说明 | API 前缀 |
|------|------|----------|
| 🔍 物流状态追踪 | 多维度查询、7步进度、时间线 | `/tracking` |
| 🔐 权限管理 | 角色RBAC、用户管理、操作日志 | `/permission` |
| 📈 统计分析 | KPI指标、趋势分析、预置报表 | `/analytics` |
| ⚠️ 异常预警中心 | 预警规则、预警记录、处理 | `/alert` |
| ⚙️ 计费规则配置 | 运输费/仓储费/包装费/附加费 | `/billing` |

## API 概览

总计 **80+ RESTful API 端点**，基础路径 `/api/v1`。

认证方式：JWT Bearer Token（`Authorization: Bearer <token>`）

通用响应格式：
```json
{
  "code": 200,
  "message": "success",
  "data": {}
}
```

完整 API 文档：启动后端后访问 `/api/docs`（Swagger UI）

## 数据库

28 张业务表，关系概要：

```
用户 ↔ 角色 ↔ 权限（多对多）
集货单 → 批次 → SKU（一对多）
分装任务 ↔ 收件点（多对一）
运输任务 → 车辆（多对一）
报关单 → 批次（多对一）
配送任务 → 收件点（多对一）
签收单 → 包裹（一对一）
对账 ↔ 结算 ↔ 支付（一对一）
物流追踪 → 包裹（多对一）
```

详细建表 SQL 见 `database/schema.sql`

## 访问

- **前端：** http://120.77.10.212:8002/
- **API 文档：** http://120.77.10.212:8001/api/docs
- **管理员：** admin / admin123

## 开发说明

### 分支策略
- `main` — 稳定版本

### 提交规范
```bash
git commit -m "feat: 添加XX功能"
git commit -m "fix: 修复XX问题"
git commit -m "docs: 更新文档"
```
