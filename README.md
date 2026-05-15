# Doris 4.0 Showcase Platform

English | [中文](README_CN.md)

A full-stack Doris 4.0 demo platform covering customer data profiling, CDP segmentation, metrics analysis, vector image search, regulatory reporting, fund research, securities realtime warehouse, manufacturing, and metro operation scenarios.

## Tech Stack

- Backend: FastAPI + Python 3
- Frontend: Vue 3 + Vite + Element Plus + ECharts
- Database: Apache Doris (MySQL-protocol compatible)

## Repository Layout

```text
backend/                  FastAPI backend services and routes
frontend/                 Vue frontend application
scripts/                  Shared shell scripts
sql/by_database/          Schema and mock data
deploy.sh                 One-click install, build, and start
scripts/init_database.sh  Schema and demo data initialization
.env.example              Environment variable template
requirements.txt          Python dependencies
```

## Quick Start

```bash
git clone https://github.com/YOUR_ORG/doris-showcase.git
cd doris-showcase
sh deploy.sh
# open http://SERVER_IP:5173 → System Config → Init Wizard
```

After `deploy.sh` completes, open the browser and follow the **Init Wizard** (three steps):

1. **Basic** — upload/log directories and optional LLM provider (Gemini, OpenAI, Qwen, DeepSeek, or custom endpoint + API key).
2. **Connection** — Doris host, port, user, password, database. Use the built-in test button before saving.
3. **Import** — one-click demo data import.

The wizard saves all settings to the root `.env` file and they persist across restarts.

## Manual Configuration

For headless or CI deployments, edit `.env` directly:

```bash
cp .env.example .env
```

Key settings:

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

Notes:

- `BACKEND_PROXY_HOST` is the Vite proxy target. Use `127.0.0.1`, not `0.0.0.0`.
- `UPLOAD_DIR` stores uploaded vector-search images. Created automatically.

## Database Initialization

Use the Init Wizard's third step in the browser, or run scripts directly:

```bash
sh scripts/init_database.sh          # initialize all demo tables
sh scripts/init_database.sh validate # validate without importing
DROP_DATABASES=true sh scripts/init_database.sh all  # drop and recreate
```

## Deployment

```bash
sh deploy.sh   # install dependencies, build frontend, start services
```

Default URLs after startup:

```text
Frontend:     http://SERVER_IP:5173
Backend docs: http://SERVER_IP:27713/docs
Health check: http://127.0.0.1:5173/api/system/health
```

## Local Development

```bash
# backend
. .venv/bin/activate
uvicorn backend.app:app --host 0.0.0.0 --port 27713 --reload

# frontend
cd frontend
npm run dev -- --host 0.0.0.0 --port 5173
```

## Production Update

```bash
git pull
sh deploy.sh
```

If schema or mock data changed:

```bash
sh scripts/init_database.sh
sh deploy.sh
```

## Vector Image Search

The vector search module uses Doris vector functions and demo tables (`user_avatar`, `avatar_label`, `user_avatar_photo`). Missing tables are created on demand. Use the page init button to load default demo data, or upload your own images.

## Troubleshooting

```bash
lsof -i:27713                            # check ports
curl http://127.0.0.1:27713/api/system/health  # backend health
curl http://127.0.0.1:5173/api/system/health   # via frontend proxy
```

If the frontend is blank:

1. Check `backend.log` for API exceptions.
2. Check `frontend.log` for Vite build/runtime errors.
3. Confirm `.env` ports match the running services.
4. Confirm Doris is reachable at the configured host and port.

## Operations

```bash
sh deploy.sh                              # install, build, start
sh start.sh                               # start without rebuilding
sh scripts/stop.sh                        # stop services
sh scripts/restart.sh                     # restart services
sh scripts/logs.sh backend                # backend logs
sh scripts/logs.sh frontend               # frontend logs
sh scripts/healthcheck.sh                 # verify health
FULL_SMOKE=true sh scripts/healthcheck.sh # smoke test all APIs
```
