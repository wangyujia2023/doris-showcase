#!/bin/bash
set -euo pipefail
# shellcheck source=common.sh
source "$(cd "$(dirname "$0")" && pwd)/common.sh"
load_env
ensure_dirs
case "${1:-all}" in
  backend) touch "$BACKEND_LOG"; tail -f "$BACKEND_LOG" ;;
  frontend) touch "$FRONTEND_LOG"; tail -f "$FRONTEND_LOG" ;;
  all) touch "$BACKEND_LOG" "$FRONTEND_LOG"; tail -f "$BACKEND_LOG" "$FRONTEND_LOG" ;;
  *) echo "Usage: sh logs.sh [all|backend|frontend]"; exit 1 ;;
esac
