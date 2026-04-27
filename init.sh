#!/bin/bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$PROJECT_DIR/.env"
EXAMPLE_FILE="$PROJECT_DIR/.env.example"

cd "$PROJECT_DIR"

echo "[1/4] 检查配置文件"
if [ ! -f "$ENV_FILE" ]; then
  if [ -f "$EXAMPLE_FILE" ]; then
    cp "$EXAMPLE_FILE" "$ENV_FILE"
    echo "已生成 .env"
  else
    cat > "$ENV_FILE" <<'ENV'
APP_ENV=dev
PROJECT_ROOT=
BACKEND_HOST=0.0.0.0
BACKEND_PORT=27713
BACKEND_PROXY_HOST=127.0.0.1
FRONTEND_HOST=0.0.0.0
FRONTEND_PORT=5173
BACKEND_LOG=
FRONTEND_LOG=
PYTHON_BIN=
UVICORN_BIN=
NPM_BIN=npm
DORIS_HOST=10.26.20.3
DORIS_PORT=19030
DORIS_USER=root
DORIS_PASSWORD=
DORIS_DATABASE=bank_cdp
DB_WARMUP_ON_START=false
TELEMETRY_ENABLED=true
BEHAVIOR_SCAN_DAYS=120
RETAIL_LINEAGE_DB=retail_lineage
OPENMETADATA_BASE_URL=http://10.26.20.3:8585/api
OPENMETADATA_JWT_TOKEN=
OPENMETADATA_TABLE_FQN_PREFIX=
ENV
    echo "已生成 .env"
  fi
fi

set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

PYTHON_BIN="${PYTHON_BIN:-python3}"
NPM_BIN="${NPM_BIN:-npm}"

if [ ! -d "$PROJECT_DIR/.venv" ]; then
  echo "[2/4] 创建 Python 虚拟环境"
  "$PYTHON_BIN" -m venv "$PROJECT_DIR/.venv"
fi

if [ -x "$PROJECT_DIR/.venv/bin/pip" ]; then
  echo "[3/4] 安装后端依赖"
  "$PROJECT_DIR/.venv/bin/pip" install -r "$PROJECT_DIR/requirements.txt"
fi

echo "[4/4] 安装前端依赖"
cd "$PROJECT_DIR/frontend"
if [ -f package-lock.json ]; then
  "$NPM_BIN" install
else
  "$NPM_BIN" install
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "提示：如需 cairo，可执行 brew install cairo"
fi

echo "初始化完成"
