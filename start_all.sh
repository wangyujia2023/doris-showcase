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
BACKEND_PORT="${BACKEND_PORT:-27713}"
FRONTEND_HOST="${FRONTEND_HOST:-0.0.0.0}"
FRONTEND_PORT="${FRONTEND_PORT:-5173}"
BACKEND_LOG="${BACKEND_LOG:-$PROJECT_DIR/backend.log}"
FRONTEND_LOG="${FRONTEND_LOG:-$PROJECT_DIR/frontend.log}"
PYTHON_BIN="${PYTHON_BIN:-$PROJECT_DIR/.venv/bin/python}"
UVICORN_BIN="${UVICORN_BIN:-$PROJECT_DIR/.venv/bin/uvicorn}"
NPM_BIN="${NPM_BIN:-npm}"

echo "==============================================="
echo "启动 Bank-CDP 全栈服务"
echo "==============================================="
echo "PROJECT_DIR=$PROJECT_DIR"
echo "BACKEND=http://${BACKEND_HOST}:${BACKEND_PORT}"
echo "FRONTEND=http://${FRONTEND_HOST}:${FRONTEND_PORT}"

cd "$PROJECT_DIR"

# 检查虚拟环境和依赖
echo ""
echo "【检查依赖】"
if [ ! -d ".venv" ]; then
  echo "❌ 虚拟环境不存在！"
  echo ""
  echo "请先运行初始化: ./init.sh"
  exit 1
fi

if [ ! -x "$UVICORN_BIN" ]; then
  echo "❌ uvicorn 未找到: $UVICORN_BIN"
  echo ""
  echo "请先运行初始化: ./init.sh"
  exit 1
fi

# 激活虚拟环境
source "$PROJECT_DIR/.venv/bin/activate"

# 检查前端依赖
if [ -d "frontend/node_modules" ]; then
  echo "✓ 依赖检查通过"
else
  echo "⚠️  前端依赖未安装，正在安装..."
  cd "$PROJECT_DIR/frontend"
  npm install
  cd "$PROJECT_DIR"
fi

echo ""
echo "【清理旧进程】"
PID_BACKEND=$(lsof -t -i:"$BACKEND_PORT" 2>/dev/null || true)
if [ -n "$PID_BACKEND" ]; then
  kill -9 $PID_BACKEND 2>/dev/null || true
  echo "已清理旧后端进程: $BACKEND_PORT"
fi

PID_FRONTEND=$(lsof -t -i:"$FRONTEND_PORT" 2>/dev/null || true)
if [ -n "$PID_FRONTEND" ]; then
  kill -9 $PID_FRONTEND 2>/dev/null || true
  echo "已清理旧前端进程: $FRONTEND_PORT"
fi

echo ""
echo "【启动服务】"
nohup "$UVICORN_BIN" backend.app:app --host "$BACKEND_HOST" --port "$BACKEND_PORT" --reload > "$BACKEND_LOG" 2>&1 &
BACKEND_PID=$!
echo "后端已启动 ✓ (PID: $BACKEND_PID)"
echo "  访问地址: http://${BACKEND_HOST}:${BACKEND_PORT}/docs"
echo "  日志查看: tail -f $BACKEND_LOG"

cd "$PROJECT_DIR/frontend"
nohup npx vite --host "$FRONTEND_HOST" --port "$FRONTEND_PORT" > "$FRONTEND_LOG" 2>&1 &
FRONTEND_PID=$!
echo "前端已启动 ✓ (PID: $FRONTEND_PID)"
echo "  访问地址: http://${FRONTEND_HOST}:${FRONTEND_PORT}"
echo "  日志查看: tail -f $FRONTEND_LOG"

sleep 2
echo ""
echo "==============================================="
echo "✅ 启动完成"
echo "==============================================="
