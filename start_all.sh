#!/bin/bash

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="${PROJECT_DIR}/.env"

if [ -f "$ENV_FILE" ]; then
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
fi

BACKEND_HOST="${BACKEND_HOST:-0.0.0.0}"
BACKEND_PORT="${BACKEND_PORT:-8000}"
FRONTEND_HOST="${FRONTEND_HOST:-0.0.0.0}"
FRONTEND_PORT="${FRONTEND_PORT:-5173}"
BACKEND_LOG="${BACKEND_LOG:-$PROJECT_DIR/backend.log}"
FRONTEND_LOG="${FRONTEND_LOG:-$PROJECT_DIR/frontend.log}"
PYTHON_BIN="${PYTHON_BIN:-$PROJECT_DIR/.venv/bin/python}"
UVICORN_BIN="${UVICORN_BIN:-$PROJECT_DIR/.venv/bin/uvicorn}"
NPM_BIN="${NPM_BIN:-npm}"

echo "启动 Bank-CDP 全栈服务"
echo "PROJECT_DIR=$PROJECT_DIR"
echo "BACKEND=http://${BACKEND_HOST}:${BACKEND_PORT}"
echo "FRONTEND=http://${FRONTEND_HOST}:${FRONTEND_PORT}"

cd "$PROJECT_DIR"

PID_BACKEND=$(lsof -t -i:"$BACKEND_PORT" || true)
[ -n "$PID_BACKEND" ] && kill -9 $PID_BACKEND && echo "已清理旧后端进程:$BACKEND_PORT"

PID_FRONTEND=$(lsof -t -i:"$FRONTEND_PORT" || true)
[ -n "$PID_FRONTEND" ] && kill -9 $PID_FRONTEND && echo "已清理旧前端进程:$FRONTEND_PORT"

if [ ! -x "$UVICORN_BIN" ]; then
  echo "未找到 uvicorn: $UVICORN_BIN"
  exit 1
fi

nohup "$UVICORN_BIN" backend.app:app --host "$BACKEND_HOST" --port "$BACKEND_PORT" --reload > "$BACKEND_LOG" 2>&1 &
echo "后端已启动，日志: $BACKEND_LOG"

cd "$PROJECT_DIR/frontend"
nohup "$NPM_BIN" run dev -- --host "$FRONTEND_HOST" --port "$FRONTEND_PORT" > "$FRONTEND_LOG" 2>&1 &
echo "前端已启动，日志: $FRONTEND_LOG"

sleep 2
echo "完成"
