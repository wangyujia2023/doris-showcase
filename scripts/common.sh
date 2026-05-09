#!/bin/bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$PROJECT_DIR/.env"
EXAMPLE_FILE="$PROJECT_DIR/.env.example"

project_path() {
  case "$1" in
    /*) printf "%s" "$1" ;;
    *) printf "%s/%s" "$PROJECT_DIR" "$1" ;;
  esac
}

load_env() {
  if [ -f "$ENV_FILE" ]; then
    set -a
    # shellcheck disable=SC1090
    source "$ENV_FILE"
    set +a
  fi

  BACKEND_HOST="${BACKEND_HOST:-0.0.0.0}"
  BACKEND_PORT="${BACKEND_PORT:-27713}"
  BACKEND_PROXY_HOST="${BACKEND_PROXY_HOST:-127.0.0.1}"
  FRONTEND_HOST="${FRONTEND_HOST:-0.0.0.0}"
  FRONTEND_PORT="${FRONTEND_PORT:-5173}"
  DORIS_HOST="${DORIS_HOST:-10.26.20.3}"
  DORIS_PORT="${DORIS_PORT:-19030}"
  DORIS_USER="${DORIS_USER:-root}"
  DORIS_PASSWORD="${DORIS_PASSWORD:-}"
  DORIS_DATABASE="${DORIS_DATABASE:-doris_showcase}"
  LINEAGE_DATABASE="${LINEAGE_DATABASE:-lineage_showcase}"
  PYTHON_BIN="${PYTHON_BIN:-python3}"
  NPM_BIN="${NPM_BIN:-npm}"
  LOG_DIR="$(project_path "${LOG_DIR:-logs}")"
  BACKEND_LOG="$(project_path "${BACKEND_LOG:-$LOG_DIR/backend.log}")"
  FRONTEND_LOG="$(project_path "${FRONTEND_LOG:-$LOG_DIR/frontend.log}")"
  UPLOAD_DIR="$(project_path "${UPLOAD_DIR:-uploads}")"
  INIT_DATABASE_ON_DEPLOY="${INIT_DATABASE_ON_DEPLOY:-false}"
  DROP_DATABASES="${DROP_DATABASES:-false}"
}

ensure_env() {
  if [ ! -f "$ENV_FILE" ]; then
    if [ -f "$EXAMPLE_FILE" ]; then
      cp "$EXAMPLE_FILE" "$ENV_FILE"
    else
      echo "Missing .env.example"
      exit 1
    fi
    echo "Created .env from .env.example. Please review Doris/OpenMetadata settings if needed."
  fi
}

ensure_dirs() {
  mkdir -p "$LOG_DIR" "$UPLOAD_DIR"
}

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing command: $1"
    [ "${2:-}" != "" ] && echo "Install: $2"
    exit 1
  fi
}

mysql_cli() {
  if [ -n "$DORIS_PASSWORD" ]; then
    MYSQL_PWD="$DORIS_PASSWORD" mysql -h "$DORIS_HOST" -P "$DORIS_PORT" -u "$DORIS_USER" "$@"
  else
    mysql -h "$DORIS_HOST" -P "$DORIS_PORT" -u "$DORIS_USER" "$@"
  fi
}

mysql_query() {
  mysql_cli -N -B -e "$1"
}

run_sql_file() {
  local sql_file="$1"
  local full_path="$PROJECT_DIR/$sql_file"
  if [ ! -f "$full_path" ]; then
    echo "FAIL SQL file not found: $sql_file"
    exit 1
  fi
  echo "Running $sql_file"
  mysql_cli < "$full_path"
}

stop_port() {
  local port="$1"
  local pid
  pid=$(lsof -t -i:"$port" 2>/dev/null || true)
  if [ -n "$pid" ]; then
    echo "Stop port $port: $pid"
    kill -9 $pid 2>/dev/null || true
  else
    echo "Port $port: no process"
  fi
}

check_url() {
  local name="$1"
  local url="$2"
  local timeout="${3:-8}"
  if curl -fsS --max-time "$timeout" "$url" >/tmp/doris_showcase_health.out 2>/tmp/doris_showcase_health.err; then
    echo "PASS $name"
    return 0
  fi
  echo "FAIL $name -> $url"
  cat /tmp/doris_showcase_health.err 2>/dev/null || true
  return 1
}

wait_url() {
  local name="$1"
  local url="$2"
  local max_wait="${3:-30}"
  local elapsed=0
  while [ "$elapsed" -lt "$max_wait" ]; do
    if curl -fsS --max-time 2 "$url" >/dev/null 2>&1; then
      echo "Ready $name"
      return 0
    fi
    sleep 1
    elapsed=$((elapsed + 1))
  done
  echo "WARN $name not ready after ${max_wait}s: $url"
  return 1
}
