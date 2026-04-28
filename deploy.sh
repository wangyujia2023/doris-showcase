#!/bin/bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$PROJECT_DIR/.env"
EXAMPLE_FILE="$PROJECT_DIR/.env.example"

cd "$PROJECT_DIR"

echo "== Doris Showcase 一键初始化并启动 =="

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "缺少命令: $1"
    echo "请先安装 $2 后重新执行: sh deploy.sh"
    exit 1
  fi
}

need_cmd python3 "Python 3"
need_cmd npm "Node.js/npm"

echo "[1/6] 准备 .env"
if [ ! -f "$ENV_FILE" ]; then
  if [ -f "$EXAMPLE_FILE" ]; then
    cp "$EXAMPLE_FILE" "$ENV_FILE"
  else
    cat > "$ENV_FILE" <<'ENV'
BACKEND_HOST=0.0.0.0
BACKEND_PORT=27713
BACKEND_PROXY_HOST=127.0.0.1
FRONTEND_HOST=0.0.0.0
FRONTEND_PORT=5173
DORIS_HOST=10.26.20.3
DORIS_PORT=19030
DORIS_USER=root
DORIS_PASSWORD=
DORIS_DATABASE=doris_showcase
UPLOAD_DIR=./uploads
DB_WARMUP_ON_START=false
TELEMETRY_ENABLED=true
BEHAVIOR_SCAN_DAYS=120
LINEAGE_DATABASE=lineage_showcase
OPENMETADATA_BASE_URL=http://10.26.20.3:8585/api
OPENMETADATA_JWT_TOKEN=
ENV
  fi
  echo "已生成 .env，请按需修改 Doris/OpenMetadata 配置"
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
PYTHON_BIN="${PYTHON_BIN:-python3}"
NPM_BIN="${NPM_BIN:-npm}"
UPLOAD_DIR="${UPLOAD_DIR:-./uploads}"
mkdir -p "$UPLOAD_DIR"
echo "上传目录: $UPLOAD_DIR"

echo "[2/6] 准备 Python 虚拟环境"
if [ -d "$PROJECT_DIR/.venv" ] && [ -x "$PROJECT_DIR/.venv/bin/python" ]; then
  if ! "$PROJECT_DIR/.venv/bin/python" -c "import sys; print(sys.executable)" >/dev/null 2>&1; then
    echo "检测到不可用的旧 .venv，自动重建"
    rm -rf "$PROJECT_DIR/.venv"
  fi
fi
if [ -d "$PROJECT_DIR/.venv" ] && [ -x "$PROJECT_DIR/.venv/bin/pip" ]; then
  if ! "$PROJECT_DIR/.venv/bin/pip" --version >/dev/null 2>&1; then
    echo "检测到不可用的旧 pip，自动重建 .venv"
    rm -rf "$PROJECT_DIR/.venv"
  fi
fi
if [ ! -d "$PROJECT_DIR/.venv" ]; then
  "$PYTHON_BIN" -m venv "$PROJECT_DIR/.venv"
fi
"$PROJECT_DIR/.venv/bin/pip" install -r "$PROJECT_DIR/requirements.txt"

echo "[3/6] 安装前端依赖并构建"
cd "$PROJECT_DIR/frontend"
"$NPM_BIN" install
"$NPM_BIN" run build
cd "$PROJECT_DIR"

echo "[4/6] 清理旧进程"
BACKEND_PID=$(lsof -t -i:"$BACKEND_PORT" 2>/dev/null || true)
if [ -n "$BACKEND_PID" ]; then
  kill -9 $BACKEND_PID 2>/dev/null || true
fi
FRONTEND_PID=$(lsof -t -i:"$FRONTEND_PORT" 2>/dev/null || true)
if [ -n "$FRONTEND_PID" ]; then
  kill -9 $FRONTEND_PID 2>/dev/null || true
fi

echo "[5/6] 启动后端 $BACKEND_PORT"
nohup "$PROJECT_DIR/.venv/bin/uvicorn" backend.app:app \
  --host "$BACKEND_HOST" \
  --port "$BACKEND_PORT" \
  > "$BACKEND_LOG" 2>&1 &

echo "[6/6] 启动前端 $FRONTEND_PORT"
cd "$PROJECT_DIR/frontend"
nohup "$NPM_BIN" run preview -- --host "$FRONTEND_HOST" --port "$FRONTEND_PORT" \
  > "$FRONTEND_LOG" 2>&1 &
cd "$PROJECT_DIR"

sleep 2

echo "启动完成"
echo "前端: http://服务器IP:$FRONTEND_PORT"
echo "后端: http://服务器IP:$BACKEND_PORT/docs"
echo "健康检查: curl http://127.0.0.1:$FRONTEND_PORT/api/system/health"
echo "后端日志: tail -f $BACKEND_LOG"
echo "前端日志: tail -f $FRONTEND_LOG"
