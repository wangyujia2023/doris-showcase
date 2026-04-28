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
BACKEND_LOG="${BACKEND_LOG:-$PROJECT_DIR/backend.log}"
FRONTEND_LOG="${FRONTEND_LOG:-$PROJECT_DIR/frontend.log}"
case "${1:-all}" in
  backend) tail -f "$BACKEND_LOG" ;;
  frontend) tail -f "$FRONTEND_LOG" ;;
  all) tail -f "$BACKEND_LOG" "$FRONTEND_LOG" ;;
  *) echo "Usage: sh logs.sh [all|backend|frontend]"; exit 1 ;;
esac
