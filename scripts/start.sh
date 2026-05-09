#!/bin/bash
set -euo pipefail
# shellcheck source=common.sh
source "$(cd "$(dirname "$0")" && pwd)/common.sh"

ensure_env
load_env
ensure_dirs
need_cmd lsof "lsof"
need_cmd "$NPM_BIN" "Node.js/npm"

cd "$PROJECT_DIR"

if [ ! -x "$PROJECT_DIR/.venv/bin/uvicorn" ]; then
  echo "Missing backend runtime. Run: sh deploy.sh"
  exit 1
fi
if [ ! -d "$PROJECT_DIR/frontend/node_modules" ]; then
  echo "Missing frontend dependencies. Run: sh deploy.sh"
  exit 1
fi
if [ ! -d "$PROJECT_DIR/frontend/dist" ]; then
  echo "Missing frontend build output. Run: sh deploy.sh"
  exit 1
fi

cat <<INFO
== Doris Showcase start ==
Backend: $BACKEND_HOST:$BACKEND_PORT
Frontend: $FRONTEND_HOST:$FRONTEND_PORT
Logs: $LOG_DIR
Uploads: $UPLOAD_DIR
INFO

stop_port "$BACKEND_PORT"
stop_port "$FRONTEND_PORT"

nohup "$PROJECT_DIR/.venv/bin/uvicorn" backend.app:app \
  --host "$BACKEND_HOST" \
  --port "$BACKEND_PORT" \
  > "$BACKEND_LOG" 2>&1 &

cd "$PROJECT_DIR/frontend"
nohup "$NPM_BIN" run preview -- --host "$FRONTEND_HOST" --port "$FRONTEND_PORT" \
  > "$FRONTEND_LOG" 2>&1 &
cd "$PROJECT_DIR"

wait_url "backend" "http://127.0.0.1:$BACKEND_PORT/api/system/health" 45 || true
wait_url "frontend-proxy" "http://127.0.0.1:$FRONTEND_PORT/api/system/health" 45 || true
bash "$PROJECT_DIR/scripts/healthcheck.sh" || true

echo "Frontend: http://SERVER_IP:$FRONTEND_PORT"
echo "Backend docs: http://SERVER_IP:$BACKEND_PORT/docs"
echo "Backend log: sh scripts/logs.sh backend"
echo "Frontend log: sh scripts/logs.sh frontend"
