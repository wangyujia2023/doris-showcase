# Bank Demo Delivery Deployment Manual

This document is intended for handing the project over to another team for independent deployment. Sensitive values are represented as placeholders.

## 1. Delivery Package

| Type | File/Directory | Description |
| --- | --- | --- |
| Backend | `backend/` | FastAPI service |
| Frontend | `frontend/` | Vue 3 + Vite frontend |
| One-click script | `deploy.sh` | Install dependencies, build frontend, start backend and frontend |
| Config template | `.env.example` | Environment variable template |
| SQL delivery directory | `sql/by_database/` | Database-oriented schema and mock SQL files |
| Main DB schema | `sql/by_database/bank_cdp_schema.sql` | Schema for `bank_cdp` |
| Main DB data | `sql/by_database/bank_cdp_mock.sql` | Mock data for `bank_cdp` |
| Lineage schema | `sql/by_database/retail_lineage_schema.sql` | Schema for `retail_lineage` |
| Lineage data | `sql/by_database/retail_lineage_mock.sql` | Mock data and ETL examples for `retail_lineage` |
| Regulatory DB | `sql/by_database/regdb_schema.sql` / `regdb_mock.sql` | Schema and placeholder mock for `regdb` |
| Metro DB | `sql/by_database/bjmetro_schema.sql` / `bjmetro_mock.sql` | Schema and placeholder mock for `bjmetro` |

## 2. Requirements

| Component | Recommended Version | Description |
| --- | --- | --- |
| Linux | CentOS / Ubuntu | Server OS |
| Git | 2.x+ | Clone and update source code |
| Python | 3.10+, recommended 3.12 | Backend runtime |
| Node.js | 18+ | Frontend build and preview |
| npm | 9+ | Frontend package manager |
| Apache Doris | 4.0+ | Database |
| OpenMetadata | Optional | Lineage visualization and sync |

Check commands:

```bash
git --version
python3 --version
node -v
npm -v
mysql --version
```

## 3. Clone Repository

Public repository:

```bash
git clone https://github.com/wangyujia2023/bank-demo.git
cd bank-demo
```

For a private repository, use a GitHub token:

```bash
git clone https://<github_user>:<github_token>@github.com/wangyujia2023/bank-demo.git
cd bank-demo
```

## 4. Configure `.env`

`deploy.sh` creates `.env` from `.env.example` on first run. You can also create it manually:

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
OPENMETADATA_TABLE_FQN_PREFIX=
EOF
```

Minimum required values:

```env
DORIS_HOST=<DORIS_FE_HOST>
DORIS_PORT=19030
DORIS_USER=root
DORIS_PASSWORD=
DORIS_DATABASE=bank_cdp
RETAIL_LINEAGE_DB=retail_lineage
```

## 5. Initialize Doris

Log in to Doris:

```bash
mysql -h <DORIS_FE_HOST> -P19030 -uroot -p
```

Without password:

```bash
mysql -h <DORIS_FE_HOST> -P19030 -uroot
```

### 5.1 Initialize Main Business Database `bank_cdp`

```bash
mysql -h <DORIS_FE_HOST> -P19030 -uroot -p < sql/by_database/bank_cdp_schema.sql
mysql -h <DORIS_FE_HOST> -P19030 -uroot -p < sql/by_database/bank_cdp_mock.sql
```

Description:

| File | Content |
| --- | --- |
| `sql/by_database/bank_cdp_schema.sql` | `CREATE DATABASE bank_cdp`, core tables, materialized views and dashboard tables |
| `sql/by_database/bank_cdp_mock.sql` | Mock data for `user_wide`, `user_tag`, `user_behavior`, logs, tag dictionary and dashboard |

### 5.2 Initialize Lineage Database `retail_lineage`

```bash
mysql -h <DORIS_FE_HOST> -P19030 -uroot -p < sql/by_database/retail_lineage_schema.sql
mysql -h <DORIS_FE_HOST> -P19030 -uroot -p < sql/by_database/retail_lineage_mock.sql
```

Description:

| File | Content |
| --- | --- |
| `sql/by_database/retail_lineage_schema.sql` | Base lineage tables, sync log table, ETL task tables and retail physical tables |
| `sql/by_database/retail_lineage_mock.sql` | Lineage assets, edges, ETL mappings, realistic insert-select jobs and complex ETL examples |

### 5.3 Optional: Initialize Regulatory Database `regdb`

```bash
mysql -h <DORIS_FE_HOST> -P19030 -uroot -p < sql/by_database/regdb_schema.sql
mysql -h <DORIS_FE_HOST> -P19030 -uroot -p < sql/by_database/regdb_mock.sql
```

### 5.4 Optional: Initialize Beijing Metro Database `bjmetro`

```bash
mysql -h <DORIS_FE_HOST> -P19030 -uroot -p < sql/by_database/bjmetro_schema.sql
mysql -h <DORIS_FE_HOST> -P19030 -uroot -p < sql/by_database/bjmetro_mock.sql
```

## 6. One-click Initialization and Startup

```bash
chmod +x deploy.sh
sh deploy.sh
```

The script performs:

```bash
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
cd frontend && npm install
cd frontend && npm run build
uvicorn backend.app:app --host 0.0.0.0 --port 27713
cd frontend && npm run preview -- --host 0.0.0.0 --port 5173
```

Ports:

| Port | Service |
| --- | --- |
| `27713` | FastAPI backend |
| `5173` | Vite preview frontend |

Without nginx, frontend `/api` requests are proxied by Vite preview:

```text
Browser -> http://SERVER_IP:5173
Frontend /api/* -> http://127.0.0.1:27713/api/*
```

## 7. Verification

```bash
curl http://127.0.0.1:27713/api/system/health
curl http://127.0.0.1:5173/api/system/health
```

Open in browser:

```text
http://<SERVER_IP>:5173
```

Check ports:

```bash
lsof -nP -iTCP -sTCP:LISTEN
lsof -nP -iTCP:27713 -sTCP:LISTEN
lsof -nP -iTCP:5173 -sTCP:LISTEN
```

Check logs:

```bash
tail -f backend.log
tail -f frontend.log
```

## 8. Update Deployment

```bash
cd bank-demo
git pull origin main
sh deploy.sh
```

## 9. Troubleshooting

### 9.1 `Permission denied (publickey)`

The server does not have a GitHub SSH key. Use HTTPS:

```bash
git clone https://github.com/wangyujia2023/bank-demo.git
```

### 9.2 `.venv/bin/pip: bad interpreter`

The virtual environment was copied from another machine. The latest `deploy.sh` rebuilds it automatically. You can also remove it manually:

```bash
rm -rf .venv
sh deploy.sh
```

### 9.3 Blank page or endless loading after menu click

Make sure the frontend is not running in Vite dev mode. Use:

```bash
npm run build
npm run preview -- --host 0.0.0.0 --port 5173
```

Do not use this as the long-running server process:

```bash
npm run dev
```

### 9.4 `/api` Request Failure

Check `.env`:

```env
BACKEND_PORT=27713
FRONTEND_PORT=5173
BACKEND_PROXY_HOST=127.0.0.1
```

Check:

```bash
curl http://127.0.0.1:27713/api/system/health
curl http://127.0.0.1:5173/api/system/health
```

### 9.5 Qwen / AI Function Failure

Qwen configuration is not stored in this frontend/backend project. It is registered as a Doris Resource.

Check:

```sql
SHOW RESOURCES;
SHOW RESOURCES WHERE Name = 'qwen_llm';
```

The news module uses:

```sql
AI_SUMMARIZE('qwen_llm', content)
AI_SENTIMENT('qwen_llm', content)
AI_EXTRACT('qwen_llm', content, ARRAY(...))
```

## 10. Acceptance Checklist

| Item | Result |
| --- | --- |
| `git clone` succeeded |  |
| `.env` configured for Doris |  |
| `bank_cdp` DDL executed |  |
| `bank_cdp` mock data inserted |  |
| `retail_lineage` DDL executed |  |
| Lineage mock/ETL data inserted |  |
| `sh deploy.sh` succeeded |  |
| Backend port `27713` is listening |  |
| Frontend port `5173` is listening |  |
| Dashboard is accessible |  |
| Metrics platform is accessible |  |
| Data lineage page is accessible |  |
| No critical errors in logs |  |
