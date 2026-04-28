#!/bin/bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$PROJECT_DIR/.env"

cd "$PROJECT_DIR"

echo "== Doris Showcase start =="

if [ ! -f "$ENV_FILE" ]; then
  echo "Missing .env. Run: sh deploy.sh"
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

BACKEND_HOST="${BACKEND_HOST:-0.0.0.0}"
BACKEND_PORT="${BACKEND_PORT:-27713}"
FRONTEND_HOST="${FRONTEND_HOST:-0.0.0.0}"
FRONTEND_PORT="${FRONTEND_PORT:-5173}"
BACKEND_LOG="${BACKEND_LOG:-$PROJECT_DIR/backend.log}"
FRONTEND_LOG="${FRONTEND_LOG:-$PROJECT_DIR/frontend.log}"
NPM_BIN="${NPM_BIN:-npm}"

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

echo "[1/3] Stop old processes"
BACKEND_PID=$(lsof -t -i:"$BACKEND_PORT" 2>/dev/null || true)
if [ -n "$BACKEND_PID" ]; then
  kill -9 $BACKEND_PID 2>/dev/null || true
fi

FRONTEND_PID=$(lsof -t -i:"$FRONTEND_PORT" 2>/dev/null || true)
if [ -n "$FRONTEND_PID" ]; then
  kill -9 $FRONTEND_PID 2>/dev/null || true
fi

echo "[2/3] Start backend: $BACKEND_PORT"
nohup "$PROJECT_DIR/.venv/bin/uvicorn" backend.app:app \
  --host "$BACKEND_HOST" \
  --port "$BACKEND_PORT" \
  > "$BACKEND_LOG" 2>&1 &

echo "[3/3] Start frontend: $FRONTEND_PORT"
cd "$PROJECT_DIR/frontend"
nohup "$NPM_BIN" run preview -- --host "$FRONTEND_HOST" --port "$FRONTEND_PORT" \
  > "$FRONTEND_LOG" 2>&1 &
cd "$PROJECT_DIR"

sleep 2

echo "Started"
echo "Frontend: http://SERVER_IP:$FRONTEND_PORT"
echo "Backend:  http://SERVER_IP:$BACKEND_PORT/docs"
echo "Health:   curl http://127.0.0.1:$FRONTEND_PORT/api/system/health"
echo "Backend log:  tail -f $BACKEND_LOG"
echo "Frontend log: tail -f $FRONTEND_LOG"
