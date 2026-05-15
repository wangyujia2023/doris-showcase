# Doris 4.0 Showcase 演示平台

[English](README.md) | 中文

基于 Apache Doris 4.0 的全栈演示平台，覆盖用户画像与 CDP 客群分析、指标体系、向量图片检索、监管报送、基金研究、证券实时数仓、制造业与轨道交通等多行业场景。

## 技术栈

- 后端：FastAPI + Python 3
- 前端：Vue 3 + Vite + Element Plus + ECharts
- 数据库：Apache Doris（兼容 MySQL 协议）

## 目录结构

```text
backend/                  FastAPI 后端服务与路由
frontend/                 Vue 前端应用
scripts/                  共用 Shell 脚本
sql/by_database/          建表 Schema 与模拟数据
deploy.sh                 一键安装依赖、构建并启动
scripts/init_database.sh  数据库建表与数据初始化
.env.example              环境变量配置模板
requirements.txt          Python 依赖
```

## 快速开始

```bash
git clone https://github.com/YOUR_ORG/doris-showcase.git
cd doris-showcase
sh deploy.sh
# 打开 http://服务器IP:5173 → 系统配置 → 初始化向导
```

`deploy.sh` 完成后，在浏览器打开前端，按 **初始化向导** 三步完成配置：

1. **基础配置** — 上传/日志目录，以及可选的 LLM 提供商（Gemini、OpenAI、Qwen、DeepSeek 或自定义端点 + API Key）。
2. **连接配置** — Doris 主机、端口、用户名、密码、数据库名，可用内置测试按钮验证后保存。
3. **数据导入** — 一键导入全部演示数据。

向导保存的配置写入根目录 `.env`，重启后自动读取，永久生效。

## 手动配置

无界面或 CI/CD 场景，直接编辑 `.env`：

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
```

说明：

- `BACKEND_PROXY_HOST`：前端 Vite 代理目标，填 `127.0.0.1`，不要填 `0.0.0.0`。
- `UPLOAD_DIR`：向量图片上传目录，脚本自动创建。

## 数据库初始化

推荐使用浏览器初始化向导第三步完成导入，也可直接运行脚本：

```bash
sh scripts/init_database.sh          # 初始化全部演示表
sh scripts/init_database.sh validate # 仅校验，不导入
DROP_DATABASES=true sh scripts/init_database.sh all  # 删除并重建
```

## 部署

```bash
sh deploy.sh   # 安装依赖、构建前端、启动服务
```

启动后默认访问地址：

```text
前端：    http://服务器IP:5173
后端文档：http://服务器IP:27713/docs
健康检查：http://127.0.0.1:5173/api/system/health
```

## 本地开发

```bash
# 后端
. .venv/bin/activate
uvicorn backend.app:app --host 0.0.0.0 --port 27713 --reload

# 前端
cd frontend
npm run dev -- --host 0.0.0.0 --port 5173
```

## 更新生产环境

```bash
git pull
sh deploy.sh
```

若 Schema 或模拟数据有变更：

```bash
sh scripts/init_database.sh
sh deploy.sh
```

## 向量图片检索

向量检索使用 Doris 向量函数，依赖演示表 `user_avatar`、`avatar_label`、`user_avatar_photo`。后端首次请求时自动建表，点击页面初始化按钮加载默认演示数据，也可上传自定义图片。

## 常见问题排查

```bash
lsof -i:27713                                  # 检查端口
curl http://127.0.0.1:27713/api/system/health  # 后端健康检查
curl http://127.0.0.1:5173/api/system/health   # 通过前端代理检查
```

前端空白或一直加载：

1. 查看 `backend.log` 中的 API 异常。
2. 查看 `frontend.log` 中的 Vite 构建或运行错误。
3. 确认 `.env` 中的端口与实际运行服务一致。
4. 确认 Doris 可用配置的 Host 和端口可达。

## 运维命令速查

```bash
sh deploy.sh                              # 安装依赖、构建、启动
sh start.sh                               # 启动（不重新构建）
sh scripts/stop.sh                        # 停止服务
sh scripts/restart.sh                     # 重启服务
sh scripts/logs.sh backend                # 查看后端日志
sh scripts/logs.sh frontend               # 查看前端日志
sh scripts/healthcheck.sh                 # 验证健康状态
FULL_SMOKE=true sh scripts/healthcheck.sh # 全量 API 冒烟测试
```
