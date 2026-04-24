# 快速启动指南

## 首次部署（从零开始）

### 步骤 1：克隆项目
```bash
git clone <repository-url> bank-demo
cd bank-demo
```

### 步骤 2：初始化环境
```bash
./init.sh
```

这个脚本会：
- ✓ 创建 Python 虚拟环境
- ✓ 安装后端依赖 (requirements.txt)
- ✓ 安装前端依赖 (npm install)
- ✓ 检查配置文件

### 步骤 3：配置数据库
编辑 `.env` 文件，配置 Doris 数据库连接：

```bash
nano .env
```

关键配置项：
```ini
# Doris 数据库
DORIS_HOST=your-host
DORIS_PORT=19030
DORIS_USER=root
DORIS_PASSWORD=your-password
DORIS_DATABASE=bank_cdp

# 服务端口
BACKEND_PORT=27713
FRONTEND_PORT=5173
```

### 步骤 4：启动服务
```bash
./start_all.sh
```

输出示例：
```
===============================================
启动 Bank-CDP 全栈服务
===============================================
【检查依赖】
✓ 依赖检查通过

【启动服务】
后端已启动 ✓ (PID: 1234)
  访问地址: http://0.0.0.0:27713/docs
  
前端已启动 ✓ (PID: 5678)
  访问地址: http://0.0.0.0:5173

===============================================
✅ 启动完成
===============================================
```

## 访问应用

- **前端**: http://localhost:5173
- **后端 API 文档**: http://localhost:27713/docs
- **Swagger UI**: http://localhost:27713/swagger

## 查看日志

```bash
# 后端日志（实时）
tail -f backend.log

# 前端日志（实时）
tail -f frontend.log
```

## 停止服务

```bash
# 查看运行的进程
lsof -i :27713    # 后端
lsof -i :5173     # 前端

# 杀掉进程
kill -9 <PID>
```

## 常见问题

### Q1: uvicorn: command not found
**原因**: 虚拟环境未激活或依赖未安装

**解决**:
```bash
./init.sh
```

### Q2: vite: command not found
**原因**: Node 依赖未安装

**解决**:
```bash
cd frontend
npm install
cd ..
./start_all.sh
```

### Q3: 数据库连接失败
**原因**: .env 配置错误

**解决**:
1. 检查 Doris 服务是否运行
2. 修改 .env 中的 DORIS_HOST/DORIS_PORT
3. 重新启动: `./start_all.sh`

### Q4: 端口被占用
**示例错误**: Address already in use

**解决**:
```bash
# 查找占用的进程
lsof -i :27713

# 杀掉进程
kill -9 <PID>

# 重新启动
./start_all.sh
```

## 开发模式

### 后端开发
```bash
source .venv/bin/activate
cd backend
uvicorn app:app --reload --port 27713
```

### 前端开发
```bash
cd frontend
npm run dev -- --port 5173
```

## 生产部署

建议使用进程管理工具（PM2、Supervisor 等）：

```bash
# 使用 PM2
npm install -g pm2

# 创建 ecosystem.config.js（可选）
# 或直接启动
pm2 start "bash start_all.sh"
pm2 save
pm2 startup
```

## 更多信息

- README.md - 项目说明
- CLAUDE.md - 开发规范
- 后端源码: backend/
- 前端源码: frontend/src/
