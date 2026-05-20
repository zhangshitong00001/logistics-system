# 跨境物流业务系统部署指南

## 环境要求
- **OS:** Ubuntu 22.04+
- **Python:** 3.12+
- **Node.js:** 22+
- **PostgreSQL:** 16+
- **Redis:** 7+
- **Nginx:** 1.24+

## 第一步：数据库

```bash
# 创建数据库
sudo -u postgres psql -c "CREATE USER zhangshitong WITH PASSWORD 'your_password';"
sudo -u postgres psql -c "CREATE DATABASE logistics_db OWNER zhangshitong;"
sudo -u postgres psql -c "ALTER USER zhangshitong WITH PASSWORD 'your_password';"

# 导入 schema
PGPASSWORD='your_password' psql -h 127.0.0.1 -U zhangshitong -d logistics_db -f database/schema.sql
```

> 也可以让 FastAPI 自动建表：启动后端即可。

## 第二步：后端

```bash
cd /root/LogisticsSystem/backend

# 安装依赖
pip install -r requirements.txt

# 配置环境变量
cp .env.example .env
# 编辑 .env 填入数据库和 Redis 密码

# 启动开发服务器
python run.py
# → http://127.0.0.1:8001

# 或者 systemd 服务
sudo cp /tmp/logistics.service /etc/systemd/system/
sudo systemctl enable --now logistics
```

### 后端环境变量 (.env)
```ini
DB_HOST=127.0.0.1
DB_PORT=5432
DB_USER=zhangshitong
DB_PASSWORD=your_password
DB_NAME=logistics_db

REDIS_HOST=127.0.0.1
REDIS_PORT=6379
REDIS_PASSWORD=your_redis_password
REDIS_DB=2

SECRET_KEY=your-jwt-secret-key
DEBUG=false
```

## 第三步：前端

```bash
cd /root/LogisticsSystem/frontend

# 安装依赖
npm install

# 构建生产版本
npm run build
# → dist/

# 部署到 nginx
sudo mkdir -p /var/www/logistics
sudo cp -r dist/* /var/www/logistics/
sudo chown -R www-data:www-data /var/www/logistics/
```

## 第四步：Nginx

```nginx
server {
    listen 8002;
    server_name _;
    charset utf-8;

    root /var/www/logistics;
    index index.html;

    # SPA 路由
    location / {
        try_files $uri $uri/ /index.html;
    }

    # API 反向代理
    location /api/ {
        proxy_pass http://127.0.0.1:8001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_read_timeout 60s;
    }
}
```

```bash
sudo ln -sf /etc/nginx/sites-available/logistics /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
```

## 第五步：验证

```bash
# 检查前端
curl http://localhost:8002/

# 检查后端健康
curl http://localhost:8002/api/health

# 测试登录
curl -X POST http://localhost:8002/api/v1/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"username":"admin","password":"admin123"}'

# API 文档
open http://localhost:8001/api/docs
```

## 重置管理员密码

```python
from app.core.database import SessionLocal
from app.core.security import get_password_hash
from app.models.sys_user import SysUser

db = SessionLocal()
admin = db.query(SysUser).filter(SysUser.username == 'admin').first()
if admin:
    admin.password_hash = get_password_hash('new_password')
    db.commit()
```

## 备份数据库

```bash
# 每日备份
PGPASSWORD='your_password' pg_dump -h 127.0.0.1 -U zhangshitong -d logistics_db \
  --file=/backup/logistics_$(date +%Y%m%d).sql
```
