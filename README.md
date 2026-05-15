# Doris 4.0 Showcase Platform

English | [中文](README_CN.md)

A full-stack Doris 4.0 demo platform for customer data, metrics analysis, vector image search, data lineage, regulatory reporting, fund research, securities realtime warehouse, manufacturing, and metro operation scenarios.

## Tech Stack

- Backend: FastAPI + Python 3
- Frontend: Vue 3 + Vite + Element Plus + ECharts
- Database: Apache Doris / SelectDB / VeolDB compatible MySQL protocol
- Optional metadata integration: OpenMetadata

## Repository Layout

```text
backend/              FastAPI backend services and routes
frontend/             Vue frontend application
docs/                 Architecture, deployment, and operations documents
scripts/              Script implementations shared by root entry scripts
sql/by_database/      Database schema and mock data, grouped by database
deploy.sh             Root wrapper for one-click dependency install, build, and startup
scripts/init_database.sh  Doris schema/mock initialization and validation
.env.example          Environment configuration template
requirements.txt      Backend Python dependencies
```

## Configuration

### Web Setup Wizard (recommended)

On first launch, open the frontend in your browser and click **System Config → Init Wizard**. The three-step wizard covers:

1. **Basic** — upload/log directories and optional LLM provider (Gemini, OpenAI, Qwen, DeepSeek, or custom endpoint + API key).
2. **Connection** — Doris host, port, user, password, and database. Use the built-in test button to verify before saving.
3. **Import** — one-click demo data import into the configured database.

The wizard writes all settings to the root `.env` file and they persist across restarts.

### Manual configuration

For headless or CI deployments, copy the template and edit directly:

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

OPENMETADATA_BASE_URL=http://YOUR_OPENMETADATA_HOST:8585/api
OPENMETADATA_JWT_TOKEN=
INIT_DATABASE_ON_DEPLOY=false
DROP_DATABASES=false
```

Notes:

- `BACKEND_PROXY_HOST` is the Vite proxy target. Use `127.0.0.1`, not `0.0.0.0`.
- `UPLOAD_DIR` stores uploaded vector-search images. Scripts create this directory automatically.
- `INIT_DATABASE_ON_DEPLOY=true` makes `deploy.sh` run `scripts/init_database.sh all` before startup.
- `DROP_DATABASES=true` makes `scripts/init_database.sh` drop managed demo databases before recreating them.
- OpenMetadata settings are required only for lineage synchronization to OpenMetadata.

## Database Initialization

SQL files are grouped by scenario under `sql/by_database/`, but all demo tables are imported into the single configured `DORIS_DATABASE`.

Default database:

- `doris_showcase`: all business, regulatory, metro, and lineage demo tables

Initialize all demo tables:

```bash
sh scripts/init_database.sh
```

Initialize one scenario into the same database:

```bash
sh scripts/init_database.sh core
sh scripts/init_database.sh regdb
sh scripts/init_database.sh bjmetro
```

The mock data files use English demo data where applicable. Initialization validates key tables after import.

Validate existing databases without importing data:

```bash
sh scripts/init_database.sh validate
```

Drop and recreate the managed demo database:

```bash
DROP_DATABASES=true sh scripts/init_database.sh all
```

## One-Click Deployment

Run from the project root:

```bash
sh deploy.sh
```

The script will:

1. Create `.env` if it does not exist.
2. Create or repair `.venv`.
3. Install backend dependencies.
4. Install frontend dependencies.
5. Build the frontend.
6. Stop old processes on configured ports.
7. Start backend and frontend in the background.

Default URLs:

```text
Frontend: http://SERVER_IP:5173
Backend docs: http://SERVER_IP:27713/docs
Health check: http://127.0.0.1:5173/api/system/health
```

Logs:

```bash
tail -f backend.log
tail -f frontend.log
```

## Local Development

Start backend manually:

```bash
. .venv/bin/activate
uvicorn backend.app:app --host 0.0.0.0 --port 27713 --reload
```

Start frontend manually:

```bash
cd frontend
npm run dev -- --host 0.0.0.0 --port 5173
```

Build frontend:

```bash
cd frontend
npm run build
```

Python syntax check example:

```bash
PYTHONPYCACHEPREFIX=/tmp/doris-showcase-pycache python3 -m py_compile backend/settings.py backend/app.py
```

## Production Update

After pulling the latest code:

```bash
git pull
sh deploy.sh
```

If database schema or mock data changed, run:

```bash
sh scripts/init_database.sh
sh deploy.sh
```

## Data Lineage

Lineage features use two data sources:

- Doris audit SQL parsing for lineage synchronization.
- OpenMetadata API for lineage query and visualization.

Required `.env` settings:

```env
LINEAGE_DATABASE=lineage_showcase
OPENMETADATA_BASE_URL=http://YOUR_OPENMETADATA_HOST:8585/api
OPENMETADATA_JWT_TOKEN=YOUR_OPENMETADATA_BOT_TOKEN
```

If OpenMetadata is not configured, the local lineage pages can still display local/demo data, but OpenMetadata synchronization will not work.

## Vector Image Search

The vector image search module uses Doris vector functions and demo tables:

- `user_avatar`
- `avatar_label`
- `user_avatar_photo`

The backend will create missing vector demo tables on demand. Use the page initialization button to load default demo users, or upload your own user images.

## Internationalization Architecture

Frontend fixed UI text is stored in:

```text
frontend/src/i18n/messages.js
```

Runtime i18n logic is stored in:

```text
frontend/src/i18n/index.js
```

Business dictionaries are served by the backend:

```text
GET /api/meta/dictionaries?locale=zh
GET /api/meta/dictionaries?locale=en
```

Dictionary source:

```text
backend/service/dictionary_service.py
```

This keeps business labels, tags, metric dimensions, and status labels out of large Vue files.

## API Organization

Frontend API calls are split by business module:

```text
frontend/src/api/modules/
```

The compatibility facade remains:

```text
frontend/src/api/index.js
```

Existing pages can continue importing APIs from `@/api`.

## Troubleshooting

Check running ports:

```bash
lsof -i:27713
lsof -i:5173
```

Check backend health directly:

```bash
curl http://127.0.0.1:27713/api/system/health
```

Check through frontend proxy:

```bash
curl http://127.0.0.1:5173/api/system/health
```

If the frontend is blank or keeps loading:

1. Check `frontend.log` for Vite build/runtime errors.
2. Check `backend.log` for API exceptions.
3. Confirm `.env` ports match the running services.
4. Confirm Doris is reachable with the configured host and port.

## Minimal Server Setup Flow

```bash
git clone https://github.com/YOUR_ORG/doris-showcase.git
cd doris-showcase
sh deploy.sh
# open http://SERVER_IP:5173 → System Config → Init Wizard → configure and import
```


## Operations

```bash
sh deploy.sh          # initialize runtime, install dependencies, build frontend, start services
sh start.sh           # start existing runtime
sh scripts/stop.sh            # stop backend and frontend ports
sh scripts/restart.sh         # restart services
sh scripts/logs.sh backend    # backend logs
sh scripts/logs.sh frontend   # frontend logs
sh scripts/healthcheck.sh     # verify backend, frontend proxy and key APIs
FULL_SMOKE=true sh scripts/healthcheck.sh  # verify all main feature APIs return data
```

See also:
- `docs/API.md` for API contract and frontend request rules.
- `docs/OPERATIONS.md` for the delivery operations guide.
