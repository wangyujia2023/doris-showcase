# Doris 4.0 Showcase 演示平台

[English](README.md) | 中文

基于 Apache Doris 4.0 的全栈演示平台，覆盖用户画像与 CDP、指标分析、向量图片检索、数据血缘、监管报送、基金研究、证券实时数仓、制造业与轨道交通等多行业场景。

## 技术栈

- 后端：FastAPI + Python 3
- 前端：Vue 3 + Vite + Element Plus + ECharts
- 数据库：Apache Doris（兼容 MySQL 协议，SelectDB / VeolDB 同样适用）
- 可选集成：OpenMetadata（数据血缘）

## 目录结构

```text
backend/              FastAPI 后端服务与路由
frontend/             Vue 前端应用
docs/                 架构、部署与运维文档
scripts/              各启动脚本共用的子脚本
sql/by_database/      按数据库分组的 Schema 建表与模拟数据
deploy.sh             一键安装依赖、构建并启动
scripts/init_database.sh  Doris 建库建表与数据初始化
.env.example          环境变量配置模板
requirements.txt      后端 Python 依赖
```

## 环境配置

### 页面向导配置（推荐）

首次启动后，在浏览器打开前端，点击 **系统配置 → 初始化向导**，按三步完成配置：

1. **基础配置** — 上传/日志目录，以及可选的 LLM 提供商（Gemini、OpenAI、Qwen、DeepSeek 或自定义端点 + API Key）。
2. **连接配置** — Doris 的主机、端口、用户名、密码和数据库名，可通过内置测试按钮验证连通性后保存。
3. **数据导入** — 一键导入全部演示数据到已配置的数据库。

向导保存的配置写入根目录 `.env` 文件，重启后自动读取，永久生效。

### 手动配置

无界面或 CI/CD 部署场景，可直接编辑配置文件：

```bash
cp .env.example .env
```

常用配置项：

```env
BACKEND_HOST=0.0.0.0
BACKEND_PORT=27713
BACKEND_PROXY_HOST=127.0.0.1
FRONTEND_HOST=0.0.0.0
FRONTEND_PORT=5173

DORIS_HOST=127.0.0.1
DORIS_PORT=9030
DORIS_USER=root
DORIS_PASSWORD=
DORIS_DATABASE=doris_showcase

UPLOAD_DIR=./uploads
LOG_DIR=./logs

OPENMETADATA_BASE_URL=http://YOUR_OPENMETADATA_HOST:8585/api
OPENMETADATA_JWT_TOKEN=
INIT_DATABASE_ON_DEPLOY=false
DROP_DATABASES=false
```

配置说明：

- `BACKEND_PROXY_HOST`：前端 Vite 代理的目标地址，填 `127.0.0.1`，不要填 `0.0.0.0`。
- `UPLOAD_DIR`：向量图片检索上传目录，脚本会自动创建。
- `INIT_DATABASE_ON_DEPLOY=true`：`deploy.sh` 启动前自动执行数据库初始化。
- `DROP_DATABASES=true`：初始化脚本会先删除再重建受管数据库。
- OpenMetadata 相关配置仅用于血缘同步功能，不配置则本地血缘页面仍可正常显示。

## 数据库初始化

SQL 文件按场景分组存放在 `sql/by_database/`，但所有演示表都会导入同一个 `DORIS_DATABASE`。

默认数据库：

- `doris_showcase`：承载用户画像、CDP、证券、基金、制造、监管、地铁、血缘等全部演示表

初始化全部演示表：

```bash
sh scripts/init_database.sh
```

初始化单个场景到同一个库：

```bash
sh scripts/init_database.sh core      # doris_showcase
sh scripts/init_database.sh regdb     # 监管表
sh scripts/init_database.sh bjmetro   # 地铁表
```

仅校验数据库（不导入数据）：

```bash
sh scripts/init_database.sh validate
```

删除并重建受管演示库：

```bash
DROP_DATABASES=true sh scripts/init_database.sh all
```

## 一键部署

在项目根目录执行：

```bash
sh deploy.sh
```

脚本执行流程：

1. 若 `.env` 不存在则从模板自动创建
2. 创建或修复 Python 虚拟环境 `.venv`
3. 安装后端依赖
4. 安装前端依赖
5. 构建前端静态文件
6. 停止旧进程
7. 后台启动后端和前端

默认访问地址：

```text
前端：    http://服务器IP:5173
后端文档：http://服务器IP:27713/docs
健康检查：http://127.0.0.1:5173/api/system/health
```

查看日志：

```bash
tail -f backend.log
tail -f frontend.log
```

## 本地开发

单独启动后端：

```bash
. .venv/bin/activate
uvicorn backend.app:app --host 0.0.0.0 --port 27713 --reload
```

单独启动前端（热更新）：

```bash
cd frontend
npm run dev -- --host 0.0.0.0 --port 5173
```

构建前端：

```bash
cd frontend
npm run build
```

## 更新生产环境

拉取最新代码后：

```bash
git pull
sh deploy.sh
```

若数据库 Schema 或模拟数据有变更，先执行初始化再重启：

```bash
sh scripts/init_database.sh
sh deploy.sh
```

## 数据血缘

血缘功能依赖两个数据源：

- Doris 审计日志 SQL 解析（本地血缘同步）
- OpenMetadata API（血缘查询与可视化）

所需 `.env` 配置：

```env
LINEAGE_DATABASE=lineage_showcase
OPENMETADATA_BASE_URL=http://YOUR_OPENMETADATA_HOST:8585/api
OPENMETADATA_JWT_TOKEN=YOUR_OPENMETADATA_BOT_TOKEN
```

未配置 OpenMetadata 时，血缘页面仍可展示本地演示数据，但不支持同步到 OpenMetadata。

## 向量图片检索

向量检索功能使用 Doris 向量函数，依赖以下演示表：

- `user_avatar`
- `avatar_label`
- `user_avatar_photo`

后端会在首次请求时自动创建缺失的向量演示表。点击页面初始化按钮可加载默认演示用户，也可上传自定义图片。

## 国际化架构

前端固定 UI 文本存储在：

```text
frontend/src/i18n/messages.js
```

运行时 i18n 逻辑：

```text
frontend/src/i18n/index.js
```

业务字典由后端提供：

```text
GET /api/meta/dictionaries?locale=zh
GET /api/meta/dictionaries?locale=en
```

字典数据源：

```text
backend/service/dictionary_service.py
```

## API 组织结构

前端 API 调用按业务模块拆分：

```text
frontend/src/api/modules/
```

兼容性统一入口保留在：

```text
frontend/src/api/index.js
```

## 常见问题排查

检查端口占用：

```bash
lsof -i:27713
lsof -i:5173
```

直接检查后端健康：

```bash
curl http://127.0.0.1:27713/api/system/health
```

通过前端代理检查：

```bash
curl http://127.0.0.1:5173/api/system/health
```

前端空白或一直加载：

1. 查看 `frontend.log` 中的 Vite 构建或运行错误
2. 查看 `backend.log` 中的 API 异常
3. 确认 `.env` 中的端口与实际运行服务一致
4. 确认 Doris 可用配置的 Host 和端口可达

## 最小化服务器部署流程

```bash
git clone https://github.com/YOUR_ORG/doris-showcase.git
cd doris-showcase
sh deploy.sh
# 打开 http://服务器IP:5173 → 系统配置 → 初始化向导 → 配置连接并导入数据
```

## 运维命令速查

```bash
sh deploy.sh                              # 安装依赖、构建、启动服务
sh start.sh                               # 启动已有运行时（不重新构建）
sh scripts/stop.sh                        # 停止服务
sh scripts/restart.sh                     # 重启服务
sh scripts/logs.sh backend                # 查看后端日志
sh scripts/logs.sh frontend               # 查看前端日志
sh scripts/healthcheck.sh                 # 验证后端、代理和主要 API
FULL_SMOKE=true sh scripts/healthcheck.sh # 验证所有功能 API 是否返回数据
```

更多文档：

- `docs/API.md`：API 接口规范与前端请求规则
- `docs/OPERATIONS.md`：交付运维操作指南
