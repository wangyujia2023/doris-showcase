# Doris Showcase Operations Guide

## Script Layout

Root scripts are stable user entry points. Implementation lives in `scripts/`.

| Root command | Implementation | Purpose |
| --- | --- | --- |
| `sh deploy.sh` | `scripts/deploy.sh` | Create `.env`, install dependencies, build frontend, optionally initialize DB, start services |
| `sh init_database.sh` | `scripts/init_database.sh` | Initialize Doris databases and validate required mock data |
| `sh start.sh` | `scripts/start.sh` | Start existing backend/frontend runtime |
| `sh stop.sh` | `scripts/stop.sh` | Stop backend/frontend ports |
| `sh restart.sh` | `scripts/restart.sh` | Restart services |
| `sh logs.sh` | `scripts/logs.sh` | Tail backend/frontend logs |
| `sh healthcheck.sh` | `scripts/healthcheck.sh` | Verify backend, frontend proxy and key APIs |

## Environment

All deploy/runtime parameters are in `.env`.

Important variables:

```env
BACKEND_PORT=27713
FRONTEND_PORT=5173
DORIS_DATABASE=doris_showcase
LINEAGE_DATABASE=lineage_showcase
UPLOAD_DIR=./uploads
LOG_DIR=./logs
INIT_DATABASE_ON_DEPLOY=false
DROP_DATABASES=false
```

## Fresh Deployment

```bash
git clone https://github.com/wangyujia2023/doris-showcase.git
cd doris-showcase
cp .env.example .env
# edit .env if Doris/OpenMetadata differs
sh init_database.sh all
sh deploy.sh
sh healthcheck.sh
```

## Reinitialize Databases

Non-destructive initialization:

```bash
sh init_database.sh all
```

Drop and recreate all managed demo databases:

```bash
DROP_DATABASES=true sh init_database.sh all
```

Validate existing data only:

```bash
sh init_database.sh validate
```

## Logs

```bash
sh logs.sh backend
sh logs.sh frontend
sh logs.sh all
```

Default log files:

```text
logs/backend.log
logs/frontend.log
```

## Health Check

```bash
sh healthcheck.sh
```

The script checks:

- Backend `/api/system/health`
- Frontend proxy `/api/system/health`
- Dictionary API
- Dashboard API
- Vector label API
- Lineage asset API
