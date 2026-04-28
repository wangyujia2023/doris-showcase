#!/bin/bash
set -euo pipefail
# shellcheck source=common.sh
source "$(cd "$(dirname "$0")" && pwd)/common.sh"

cd "$PROJECT_DIR"

echo "== Doris Showcase deploy =="
ensure_env
load_env
ensure_dirs
need_cmd "$PYTHON_BIN" "Python 3"
need_cmd "$NPM_BIN" "Node.js/npm"
need_cmd lsof "lsof"
need_cmd curl "curl"

cat <<INFO
Project: $PROJECT_DIR
Backend port: $BACKEND_PORT
Frontend port: $FRONTEND_PORT
Main DB: $DORIS_DATABASE
Lineage DB: $LINEAGE_DATABASE
Upload dir: $UPLOAD_DIR
Log dir: $LOG_DIR
INFO

if [ -d "$PROJECT_DIR/.venv" ] && [ -x "$PROJECT_DIR/.venv/bin/python" ]; then
  if ! "$PROJECT_DIR/.venv/bin/python" -c "import sys; print(sys.executable)" >/dev/null 2>&1; then
    echo "Invalid .venv detected, rebuilding"
    rm -rf "$PROJECT_DIR/.venv"
  fi
fi
if [ ! -d "$PROJECT_DIR/.venv" ]; then
  "$PYTHON_BIN" -m venv "$PROJECT_DIR/.venv"
fi
"$PROJECT_DIR/.venv/bin/pip" install -r "$PROJECT_DIR/requirements.txt"

cd "$PROJECT_DIR/frontend"
"$NPM_BIN" install
"$NPM_BIN" run build
cd "$PROJECT_DIR"

if [ "$INIT_DATABASE_ON_DEPLOY" = "true" ]; then
  bash "$PROJECT_DIR/scripts/init_database.sh" all
else
  echo "Skip database initialization. Run: sh init_database.sh all"
fi

bash "$PROJECT_DIR/scripts/start.sh"
