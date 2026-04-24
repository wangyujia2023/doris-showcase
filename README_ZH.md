# Bank-CDP 部署指南

## 一句话启动

```bash
cd /path/to/bank-demo && ./init.sh && ./start_all.sh
```

---

## 完整步骤

### 第1步：初始化环境（仅需一次）

```bash
./init.sh
```

这会自动：
- ✓ 创建 Python 虚拟环境
- ✓ 安装所有后端依赖
- ✓ 安装所有前端依赖
- ✓ 验证关键工具（uvicorn, vite 等）

**输出示例**：
```
===============================================
Bank-CDP 初始化脚本 v2.0
===============================================

【步骤1】检查 Python 环境...
  Python 版本: 3.9.0
✓ Python 版本检查通过

【步骤2】管理虚拟环境...
  创建虚拟环境...
✓ 虚拟环境创建完成

...

✅ 初始化完成！
```

### 第2步：配置数据库

编辑 `.env` 文件：

```bash
nano .env
```

修改以下内容（重要）：

```ini
DORIS_HOST=your-doris-host      # 改为实际主机名或 IP
DORIS_PORT=19030                # Doris 端口
DORIS_USER=root                 # 用户名
DORIS_PASSWORD=your-password    # 密码
DORIS_DATABASE=bank_cdp         # 数据库名
```

### 第3步：启动服务

```bash
./start_all.sh
```

**输出示例**：
```
===============================================
启动 Bank-CDP 全栈服务
===============================================

【检查依赖】
✓ 依赖检查通过

【启动服务】
后端已启动 ✓ (PID: 12345)
  访问地址: http://0.0.0.0:27713/docs

前端已启动 ✓ (PID: 12346)
  访问地址: http://0.0.0.0:5173

✅ 启动完成
```

---

## 访问应用

| 组件 | 地址 | 说明 |
|------|------|------|
| 前端 | http://localhost:5173 | 主应用 |
| 后端 API 文档 | http://localhost:27713/docs | Swagger UI |
| 后端 ReDoc | http://localhost:27713/redoc | 另一种文档格式 |

---

## 日志查看

```bash
# 实时查看后端日志
tail -f backend.log

# 实时查看前端日志
tail -f frontend.log

# 搜索错误
grep ERROR backend.log
grep error frontend.log
```

---

## 遇到问题？

### 方案 1：诊断（推荐）

```bash
# 运行诊断工具
./diagnose.sh
```

### 方案 2：查看故障排查文档

```bash
cat TROUBLESHOOTING.md
```

### 常见错误快速解决

| 错误 | 解决方案 |
|------|---------|
| `uvicorn: command not found` | `rm -rf .venv && ./init.sh` |
| `vite: command not found` | `cd frontend && npm install && cd ..` |
| `Address already in use` | `lsof -i :27713` 然后 `kill -9 <PID>` |
| 数据库连接失败 | 编辑 `.env` 修改 DORIS_* 配置 |

---

## 停止服务

```bash
# 查看运行的进程
lsof -i :27713    # 后端
lsof -i :5173     # 前端

# 杀掉进程
kill -9 <PID>

# 或者快速杀掉所有相关进程
pkill -f uvicorn
pkill -f vite
```

---

## 开发和调试

### 后端开发

```bash
# 激活虚拟环境
source .venv/bin/activate

# 启动后端（开发模式，带自动重载）
uvicorn backend.app:app --reload --port 27713
```

### 前端开发

```bash
cd frontend
npm run dev -- --port 5173
```

---

## 关键文件说明

| 文件 | 用途 |
|------|------|
| `init.sh` | 首次初始化（创建虚拟环境、安装依赖） |
| `start_all.sh` | 启动服务（前后端） |
| `diagnose.sh` | 环境诊断工具 |
| `.env` | 配置文件（数据库、端口等） |
| `.env.example` | 配置模板 |
| `requirements.txt` | Python 依赖 |
| `frontend/package.json` | Node 依赖 |
| `QUICKSTART.md` | 快速启动指南 |
| `TROUBLESHOOTING.md` | 故障排查指南 |

---

## 环境要求

- Python 3.8+
- Node.js 14+
- Doris 数据库（已部署）
- 网络连接（下载依赖）

---

## 默认配置

```ini
# 后端
BACKEND_HOST=0.0.0.0
BACKEND_PORT=27713

# 前端
FRONTEND_HOST=0.0.0.0
FRONTEND_PORT=5173

# 日志
BACKEND_LOG=./backend.log
FRONTEND_LOG=./frontend.log
```

---

## 更多帮助

- **快速启动**: QUICKSTART.md
- **故障排查**: TROUBLESHOOTING.md
- **项目说明**: README.md
- **开发规范**: CLAUDE.md

---

## 快速命令参考

```bash
# 初始化（首次）
./init.sh

# 启动服务
./start_all.sh

# 诊断环境
./diagnose.sh

# 查看日志
tail -f backend.log
tail -f frontend.log

# 查看配置
cat .env

# 杀掉进程
pkill -f uvicorn
pkill -f vite
```

---

**成功标志**：浏览器能访问 http://localhost:5173，后端 API 文档可访问
