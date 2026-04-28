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

BACKEND_PORT="${BACKEND_PORT:-27713}"
FRONTEND_PORT="${FRONTEND_PORT:-5173}"

echo "== Doris Showcase stop =="
for port in "$BACKEND_PORT" "$FRONTEND_PORT"; do
  pid=$(lsof -t -i:"$port" 2>/dev/null || true)
  if [ -n "$pid" ]; then
    echo "Stop port $port: $pid"
    kill -9 $pid 2>/dev/null || true
  else
    echo "Port $port: no process"
  fi
done
