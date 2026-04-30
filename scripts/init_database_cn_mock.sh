#!/bin/sh
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
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

init_db_cn_mock() {
  db_name="$1"
  mysql_exec "sql/by_database/${db_name}_schema.sql"
  mysql_exec "sql/by_database/${db_name}_mock_cn.sql"
}

need_cmd mysql

echo "== Bank Demo Doris Chinese mock initialization =="
echo "Doris: $DORIS_USER@$DORIS_HOST:$DORIS_PORT"

case "$MODE" in
  all)
    init_db_cn_mock bank_cdp
    init_db_cn_mock retail_lineage
    init_db_cn_mock regdb
    init_db_cn_mock bjmetro
    ;;
  core|bank_cdp)
    init_db_cn_mock bank_cdp
    ;;
  lineage|retail_lineage)
    init_db_cn_mock retail_lineage
    ;;
  regdb)
    init_db_cn_mock regdb
    ;;
  bjmetro)
    init_db_cn_mock bjmetro
    ;;
  *)
    echo "Usage: sh scripts/init_database_cn_mock.sh [all|core|lineage|regdb|bjmetro]"
    exit 1
    ;;
esac

echo "Chinese mock initialization finished."
