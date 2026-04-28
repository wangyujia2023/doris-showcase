# Bank Demo 交付部署手册

本文档用于把项目交给其他人独立部署。所有敏感信息均使用占位符，请部署人按实际环境填写。

## 1. 交付清单

| 类型 | 文件/目录 | 说明 |
| --- | --- | --- |
| 后端 | `backend/` | FastAPI 服务 |
| 前端 | `frontend/` | Vue 3 + Vite 前端 |
| 一键脚本 | `deploy.sh` | 初始化依赖、构建前端、启动前后端 |
| 数据脚本 | `init_database.sh` | 一键执行 Doris 建表和 mock 数据导入 |
| 配置模板 | `.env.example` | 环境变量模板 |
| SQL 交付目录 | `sql/by_database/` | 按数据库整理后的建表和 mock 数据 |
| 主库建表 | `sql/by_database/bank_cdp_schema.sql` | `bank_cdp` 建表 |
| 主库数据 | `sql/by_database/bank_cdp_mock.sql` | `bank_cdp` mock 数据 |
| 血缘建表 | `sql/by_database/retail_lineage_schema.sql` | `retail_lineage` 建表 |
| 血缘数据 | `sql/by_database/retail_lineage_mock.sql` | `retail_lineage` mock 数据和 ETL 示例 |
| 监管库 | `sql/by_database/regdb_schema.sql` / `regdb_mock.sql` | `regdb` 建表和占位 mock |
| 地铁库 | `sql/by_database/bjmetro_schema.sql` / `bjmetro_mock.sql` | `bjmetro` 建表和占位 mock |

## 2. 环境要求

| 组件 | 建议版本 | 说明 |
| --- | --- | --- |
| Linux | CentOS / Ubuntu | 服务器环境 |
| Git | 2.x+ | 拉取代码 |
| Python | 3.10+，推荐 3.12 | 后端运行 |
| Node.js | 18+ | 前端构建和 preview |
| npm | 9+ | 前端依赖安装 |
| Apache Doris | 4.0+ | 数据库 |
| OpenMetadata | 可选 | 血缘展示与同步 |

检查命令：

```bash
git --version
python3 --version
node -v
npm -v
mysql --version
```

## 3. 下载代码

公开仓库：

```bash
git clone https://github.com/wangyujia2023/bank-demo.git
cd bank-demo
```

私有仓库请使用 GitHub Token：

```bash
git clone https://<github_user>:<github_token>@github.com/wangyujia2023/bank-demo.git
cd bank-demo
```

## 4. 配置 `.env`

首次执行 `deploy.sh` 会自动从 `.env.example` 生成 `.env`。也可以手动创建：

```bash
cat > .env <<'EOF'
APP_ENV=dev

BACKEND_HOST=0.0.0.0
BACKEND_PORT=27713
BACKEND_PROXY_HOST=127.0.0.1
FRONTEND_HOST=0.0.0.0
FRONTEND_PORT=5173

DORIS_HOST=<DORIS_FE_HOST>
DORIS_PORT=19030
DORIS_USER=root
DORIS_PASSWORD=
DORIS_DATABASE=bank_cdp

DB_WARMUP_ON_START=false
TELEMETRY_ENABLED=true
BEHAVIOR_SCAN_DAYS=120
RETAIL_LINEAGE_DB=retail_lineage

OPENMETADATA_BASE_URL=http://<OPENMETADATA_HOST>:8585/api
OPENMETADATA_JWT_TOKEN=<OPENMETADATA_BOT_TOKEN>
EOF
```

最小必填项：

```env
DORIS_HOST=<DORIS_FE_HOST>
DORIS_PORT=19030
DORIS_USER=root
DORIS_PASSWORD=
DORIS_DATABASE=bank_cdp
RETAIL_LINEAGE_DB=retail_lineage
```

## 5. Doris 初始化

登录 Doris：

```bash
mysql -h <DORIS_FE_HOST> -P19030 -uroot -p
```

如果无密码：

```bash
mysql -h <DORIS_FE_HOST> -P19030 -uroot
```

### 5.1 推荐：一键建库并导入 mock 数据

```bash
chmod +x init_database.sh
sh init_database.sh
```

可按库单独执行：

```bash
sh init_database.sh core
sh init_database.sh lineage
sh init_database.sh regdb
sh init_database.sh bjmetro
```

脚本会读取 `.env` 中的 `DORIS_HOST`、`DORIS_PORT`、`DORIS_USER`、`DORIS_PASSWORD`，并按顺序执行 `sql/by_database/` 下的 schema 和 mock SQL。mock 数据均使用英文内容，方便多语言环境复用。

### 5.2 手动初始化主业务库 `bank_cdp`

```bash
mysql -h <DORIS_FE_HOST> -P19030 -uroot -p < sql/by_database/bank_cdp_schema.sql
mysql -h <DORIS_FE_HOST> -P19030 -uroot -p < sql/by_database/bank_cdp_mock.sql
```

说明：

| 文件 | 内容 |
| --- | --- |
| `sql/by_database/bank_cdp_schema.sql` | `CREATE DATABASE bank_cdp`、核心表、物化视图、首页大盘表 |
| `sql/by_database/bank_cdp_mock.sql` | `user_wide`、`user_tag`、`user_behavior`、日志、标签字典、首页大盘 mock 数据 |

### 5.3 手动初始化血缘库 `retail_lineage`

```bash
mysql -h <DORIS_FE_HOST> -P19030 -uroot -p < sql/by_database/retail_lineage_schema.sql
mysql -h <DORIS_FE_HOST> -P19030 -uroot -p < sql/by_database/retail_lineage_mock.sql
```

说明：

| 文件 | 内容 |
| --- | --- |
| `sql/by_database/retail_lineage_schema.sql` | 血缘基础表、同步日志表、ETL 任务表、服饰零售物理表 |
| `sql/by_database/retail_lineage_mock.sql` | 血缘资产、血缘边、ETL 任务映射、真实风格 insert into select 示例、复杂 ETL 示例 |

### 5.4 可选：初始化监管库 `regdb`

```bash
mysql -h <DORIS_FE_HOST> -P19030 -uroot -p < sql/by_database/regdb_schema.sql
mysql -h <DORIS_FE_HOST> -P19030 -uroot -p < sql/by_database/regdb_mock.sql
```

### 5.5 可选：初始化北京地铁库 `bjmetro`

```bash
mysql -h <DORIS_FE_HOST> -P19030 -uroot -p < sql/by_database/bjmetro_schema.sql
mysql -h <DORIS_FE_HOST> -P19030 -uroot -p < sql/by_database/bjmetro_mock.sql
```

## 6. 一键初始化并启动

```bash
chmod +x deploy.sh
sh deploy.sh
```

脚本会自动执行：

```bash
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
cd frontend && npm install
cd frontend && npm run build
uvicorn backend.app:app --host 0.0.0.0 --port 27713
cd frontend && npm run preview -- --host 0.0.0.0 --port 5173
```

说明：

| 端口 | 服务 |
| --- | --- |
| `27713` | FastAPI 后端 |
| `5173` | Vite preview 前端 |

不使用 nginx 时，前端通过 Vite preview 的 `/api` 代理转发到后端：

```text
浏览器 -> http://服务器IP:5173
前端 /api/* -> http://127.0.0.1:27713/api/*
```

## 7. 验证

```bash
curl http://127.0.0.1:27713/api/system/health
curl http://127.0.0.1:5173/api/system/health
```

浏览器访问：

```text
http://<SERVER_IP>:5173
```

查看端口：

```bash
lsof -nP -iTCP -sTCP:LISTEN
lsof -nP -iTCP:27713 -sTCP:LISTEN
lsof -nP -iTCP:5173 -sTCP:LISTEN
```

查看日志：

```bash
tail -f backend.log
tail -f frontend.log
```

## 8. 更新部署

```bash
cd bank-demo
git pull origin main
sh deploy.sh
```

## 9. 常见问题

### 9.1 `Permission denied (publickey)`

说明服务器没有配置 GitHub SSH Key。改用 HTTPS：

```bash
git clone https://github.com/wangyujia2023/bank-demo.git
```

### 9.2 `.venv/bin/pip: bad interpreter`

说明旧虚拟环境来自其他机器。新版 `deploy.sh` 会自动重建；也可以手动删除：

```bash
rm -rf .venv
sh deploy.sh
```

### 9.3 页面点菜单白屏或转圈

确认不是开发模式启动。应使用：

```bash
npm run build
npm run preview -- --host 0.0.0.0 --port 5173
```

不要在服务器长期使用：

```bash
npm run dev
```

### 9.4 `/api` 请求失败

检查 `.env`：

```env
BACKEND_PORT=27713
FRONTEND_PORT=5173
BACKEND_PROXY_HOST=127.0.0.1
```

检查：

```bash
curl http://127.0.0.1:27713/api/system/health
curl http://127.0.0.1:5173/api/system/health
```

### 9.5 Qwen / AI Function 不工作

Qwen 配置不在前后端项目里，而是在 Doris Resource 里。

检查：

```sql
SHOW RESOURCES;
SHOW RESOURCES WHERE Name = 'qwen_llm';
```

项目中新闻模块默认调用：

```sql
AI_SUMMARIZE('qwen_llm', content)
AI_SENTIMENT('qwen_llm', content)
AI_EXTRACT('qwen_llm', content, ARRAY(...))
```

## 10. 交付验收清单

| 检查项 | 结果 |
| --- | --- |
| `git clone` 成功 |  |
| `.env` 已配置 Doris |  |
| `bank_cdp` 建表完成 |  |
| `bank_cdp` mock 数据导入完成 |  |
| `retail_lineage` 建表完成 |  |
| 血缘 mock/ETL 数据导入完成 |  |
| `sh deploy.sh` 成功 |  |
| `27713` 后端端口监听 |  |
| `5173` 前端端口监听 |  |
| 首页可访问 |  |
| 指标平台可访问 |  |
| 数据血缘可访问 |  |
| 日志无明显报错 |  |
