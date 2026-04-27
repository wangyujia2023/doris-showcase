#!/bin/bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$PROJECT_DIR/.env"

if [ -f "$ENV_FILE" ]; then
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
fi

BACKEND_HOST="${BACKEND_HOST:-0.0.0.0}"
BACKEND_PORT="${BACKEND_PORT:-27713}"
FRONTEND_HOST="${FRONTEND_HOST:-0.0.0.0}"
FRONTEND_PORT="${FRONTEND_PORT:-5173}"
BACKEND_LOG="${BACKEND_LOG:-$PROJECT_DIR/backend.log}"
FRONTEND_LOG="${FRONTEND_LOG:-$PROJECT_DIR/frontend.log}"
PYTHON_BIN="${PYTHON_BIN:-$PROJECT_DIR/.venv/bin/python}"
UVICORN_BIN="${UVICORN_BIN:-$PROJECT_DIR/.venv/bin/uvicorn}"
NPM_BIN="${NPM_BIN:-npm}"

cd "$PROJECT_DIR"

if [ ! -x "$UVICORN_BIN" ] || [ ! -d "$PROJECT_DIR/.venv" ]; then
  echo "请先执行 ./init.sh"
  exit 1
fi

cd "$PROJECT_DIR/frontend"
if [ ! -d node_modules ]; then
  "$NPM_BIN" install
fi
cd "$PROJECT_DIR"

PID_BACKEND=$(lsof -t -i:"$BACKEND_PORT" 2>/dev/null || true)
[ -n "$PID_BACKEND" ] && kill -9 $PID_BACKEND 2>/dev/null || true
PID_FRONTEND=$(lsof -t -i:"$FRONTEND_PORT" 2>/dev/null || true)
[ -n "$PID_FRONTEND" ] && kill -9 $PID_FRONTEND 2>/dev/null || true

source "$PROJECT_DIR/.venv/bin/activate"
nohup "$UVICORN_BIN" backend.app:app --host "$BACKEND_HOST" --port "$BACKEND_PORT" --reload > "$BACKEND_LOG" 2>&1 &
cd "$PROJECT_DIR/frontend"
nohup "$NPM_BIN" run dev -- --host "$FRONTEND_HOST" --port "$FRONTEND_PORT" > "$FRONTEND_LOG" 2>&1 &

echo "backend: http://$BACKEND_HOST:$BACKEND_PORT"
echo "frontend: http://$FRONTEND_HOST:$FRONTEND_PORT"
