# Doris 4.0 演示平台

## 一键部署

所有部署参数统一放在项目根目录 `.env`。

第一次部署：

```bash
cp .env.example .env
```

然后只改这一个文件里的参数：

- `BACKEND_HOST` / `BACKEND_PORT`
- `BACKEND_PROXY_HOST`
- `FRONTEND_HOST` / `FRONTEND_PORT`
- `DORIS_HOST` / `DORIS_PORT` / `DORIS_USER` / `DORIS_PASSWORD` / `DORIS_DATABASE`
- `RETAIL_LINEAGE_DB`
- `OPENMETADATA_BASE_URL`
- `OPENMETADATA_JWT_TOKEN`

## 数据库初始化

建表和 mock 数据已经按数据库整理到 `sql/by_database/`，mock 数据使用英文内容。

一键初始化全部数据库：

```bash
sh init_database.sh
```

按库初始化：

```bash
sh init_database.sh core
sh init_database.sh lineage
sh init_database.sh regdb
sh init_database.sh bjmetro
```

包含数据库：

- `bank_cdp`：主业务库
- `retail_lineage`：零售血缘库
- `regdb`：监管演示库
- `bjmetro`：城市数据大盘库

## 统一配置文件

根目录 `.env` 是唯一配置入口。

后端读取：

- `backend/settings.py`

前端读取：

- `frontend/vite.config.js`

启动脚本读取：

- `deploy.sh`
- `init_database.sh`

## 快速启动

### 1. 一键初始化数据库

```bash
sh init_database.sh
```

### 2. 一键安装依赖并启动

```bash
sh deploy.sh
```

默认：

- 后端：`http://127.0.0.1:27713`
- 前端：`http://127.0.0.1:5173`

实际端口以 `.env` 为准。

## 根目录保留文件

- `README.md`：唯一入口说明。
- `deploy.sh`：一键安装依赖、构建前端、启动前后端。
- `init_database.sh`：一键建库和导入 mock 数据。
- `.env.example`：配置模板。
- `requirements.txt`：后端依赖。

## 单独启动

后端：

```bash
. .venv/bin/activate
uvicorn backend.app:app --host 0.0.0.0 --port 27713 --reload
```

前端：

```bash
cd frontend
npm run dev -- --host 0.0.0.0 --port 5173
```

如果你改了端口，请同步改 `.env`，不要再分别改代码。

## 生产更新

从 GitHub 拉代码后，通常只需要：

```bash
git pull
sh deploy.sh
```

如果只更新血缘功能，至少覆盖：

- `backend/service/retail_lineage_service.py`
- `backend/api/lineage_routes.py`
- `frontend/src/views/Lineage.vue`
- `frontend/src/api/index.js`

## 关键说明

### 血缘功能依赖

血缘相关配置必须在 `.env` 中存在：

```env
RETAIL_LINEAGE_DB=retail_lineage
OPENMETADATA_BASE_URL=http://ip:8585/api
OPENMETADATA_JWT_TOKEN=...
```

### 端口统一

不要再分别改：

- `uvicorn --port`
- `vite.config.js`
- 启动脚本里的硬编码端口

现在统一改 `.env`：

```env
BACKEND_PORT=27713
FRONTEND_PORT=5173
BACKEND_PROXY_HOST=127.0.0.1
```

说明：

- `BACKEND_HOST` 是后端监听地址，可用 `0.0.0.0`
- `BACKEND_PROXY_HOST` 是前端 Vite 代理目标，建议固定 `127.0.0.1`
- 不要把代理目标写成 `0.0.0.0`

## 常用命令

前端构建：

```bash
cd frontend && npm run build
```

后端语法检查：

```bash
python3 -m py_compile backend/settings.py backend/app.py backend/api/lineage_routes.py backend/service/retail_lineage_service.py
```
