#!/bin/sh
set -eu

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$PROJECT_DIR/.env"
MODE="${1:-all}"

if [ -f "$ENV_FILE" ]; then
  set -a
  # shellcheck disable=SC1090
  . "$ENV_FILE"
  set +a
fi

DORIS_HOST="${DORIS_HOST:-10.26.20.3}"
DORIS_PORT="${DORIS_PORT:-19030}"
DORIS_USER="${DORIS_USER:-root}"
DORIS_PASSWORD="${DORIS_PASSWORD:-}"
UPLOAD_DIR="${UPLOAD_DIR:-/mnt/disk13/wangyujia/data/bank-demo/uploads}"

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing command: $1"
    exit 1
  fi
}

mysql_exec() {
  sql_file="$1"
  full_path="$PROJECT_DIR/$sql_file"

  if [ ! -f "$full_path" ]; then
    echo "SQL file not found: $sql_file"
    exit 1
  fi

  echo "Running $sql_file"
  if [ -n "$DORIS_PASSWORD" ]; then
    MYSQL_PWD="$DORIS_PASSWORD" mysql -h "$DORIS_HOST" -P "$DORIS_PORT" -u "$DORIS_USER" < "$full_path"
  else
    mysql -h "$DORIS_HOST" -P "$DORIS_PORT" -u "$DORIS_USER" < "$full_path"
  fi
}

mysql_exec_wide() {
  echo "Running wide-table schema and mock data"
  if [ -n "$DORIS_PASSWORD" ]; then
    { printf 'CREATE DATABASE IF NOT EXISTS bank_cdp;\nUSE bank_cdp;\n'; sed -n '/^-- Table: user_wide$/,$p' "$PROJECT_DIR/sql/by_database/bank_cdp_schema.sql"; } | MYSQL_PWD="$DORIS_PASSWORD" mysql -h "$DORIS_HOST" -P "$DORIS_PORT" -u "$DORIS_USER"
    { printf 'CREATE DATABASE IF NOT EXISTS bank_cdp;\nUSE bank_cdp;\n'; sed -n '/^-- Table: user_wide$/,$p' "$PROJECT_DIR/sql/by_database/bank_cdp_mock.sql"; } | MYSQL_PWD="$DORIS_PASSWORD" mysql -h "$DORIS_HOST" -P "$DORIS_PORT" -u "$DORIS_USER"
  else
    { printf 'CREATE DATABASE IF NOT EXISTS bank_cdp;\nUSE bank_cdp;\n'; sed -n '/^-- Table: user_wide$/,$p' "$PROJECT_DIR/sql/by_database/bank_cdp_schema.sql"; } | mysql -h "$DORIS_HOST" -P "$DORIS_PORT" -u "$DORIS_USER"
    { printf 'CREATE DATABASE IF NOT EXISTS bank_cdp;\nUSE bank_cdp;\n'; sed -n '/^-- Table: user_wide$/,$p' "$PROJECT_DIR/sql/by_database/bank_cdp_mock.sql"; } | mysql -h "$DORIS_HOST" -P "$DORIS_PORT" -u "$DORIS_USER"
  fi
}

init_db() {
  db_name="$1"
  mysql_exec "sql/by_database/${db_name}_schema.sql"
  mysql_exec "sql/by_database/${db_name}_mock.sql"
}

need_cmd mysql

echo "== Bank Demo Doris database initialization =="
echo "Doris: $DORIS_USER@$DORIS_HOST:$DORIS_PORT"
mkdir -p "$UPLOAD_DIR"
echo "Upload dir: $UPLOAD_DIR"

case "$MODE" in
  all)
    init_db bank_cdp
    init_db retail_lineage
    init_db regdb
    init_db bjmetro
    ;;
  core|bank_cdp)
    init_db bank_cdp
    ;;
  lineage|retail_lineage)
    init_db retail_lineage
    ;;
  regdb)
    init_db regdb
    ;;
  bjmetro)
    init_db bjmetro
    ;;
  wide)
    mysql_exec_wide
    ;;
  *)
    echo "Usage: sh init_database.sh [all|core|lineage|regdb|bjmetro|wide]"
    exit 1
    ;;
esac

echo "Database initialization finished."
