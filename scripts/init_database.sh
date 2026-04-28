#!/bin/bash
set -euo pipefail
# shellcheck source=common.sh
source "$(cd "$(dirname "$0")" && pwd)/common.sh"

MODE="${1:-all}"
load_env
ensure_dirs
need_cmd mysql "Doris MySQL client"

main_db="$DORIS_DATABASE"
lineage_db="$LINEAGE_DATABASE"

drop_db_if_requested() {
  local db="$1"
  if [ "$DROP_DATABASES" = "true" ]; then
    echo "DROP_DATABASES=true, dropping database: $db"
    mysql_query "DROP DATABASE IF EXISTS \`$db\`;"
  fi
}

run_pair() {
  local db="$1"
  local schema="$2"
  local mock="$3"
  drop_db_if_requested "$db"
  run_sql_file "$schema"
  run_sql_file "$mock"
  validate_db "$db"
}

validate_count() {
  local db="$1"
  local table="$2"
  local min_count="${3:-1}"
  local cnt
  cnt=$(mysql_query "SELECT COUNT(1) FROM \`$db\`.\`$table\`;" 2>/tmp/doris_showcase_validate.err || true)
  cnt="${cnt:-0}"
  if [ "$cnt" -ge "$min_count" ] 2>/dev/null; then
    echo "PASS $db.$table rows=$cnt"
  else
    echo "FAIL $db.$table rows=$cnt expected>=$min_count"
    cat /tmp/doris_showcase_validate.err 2>/dev/null || true
    exit 1
  fi
}

validate_db() {
  local db="$1"
  case "$db" in
    "$main_db")
      validate_count "$db" user_wide 1
      validate_count "$db" user_behavior 1
      validate_count "$db" sys_logs 1
      validate_count "$db" news_article 1
      validate_count "$db" t_customer_tags 1
      ;;
    "$lineage_db")
      validate_count "$db" lineage_asset 1
      validate_count "$db" lineage_edge 1
      ;;
    regdb)
      validate_count "$db" reg_master 1
      ;;
    bjmetro)
      validate_count "$db" bj_metro_lines 1
      ;;
  esac
}

init_main() {
  run_pair "$main_db" "sql/by_database/doris_showcase_schema.sql" "sql/by_database/doris_showcase_mock.sql"
}

init_lineage() {
  run_pair "$lineage_db" "sql/by_database/lineage_showcase_schema.sql" "sql/by_database/lineage_showcase_mock.sql"
}

init_regdb() {
  run_pair regdb "sql/by_database/regdb_schema.sql" "sql/by_database/regdb_mock.sql"
}

init_bjmetro() {
  run_pair bjmetro "sql/by_database/bjmetro_schema.sql" "sql/by_database/bjmetro_mock.sql"
}

init_wide() {
  echo "Running wide-table schema and mock data for $main_db"
  mysql_query "CREATE DATABASE IF NOT EXISTS \`$main_db\`;"
  sed -n '/^-- Table: user_wide$/,$p' "$PROJECT_DIR/sql/by_database/doris_showcase_schema.sql" | mysql_cli "$main_db"
  sed -n '/^-- Table: user_wide$/,$p' "$PROJECT_DIR/sql/by_database/doris_showcase_mock.sql" | mysql_cli "$main_db"
  validate_count "$main_db" user_wide 1
}

cat <<INFO
== Doris Showcase database initialization ==
Doris: $DORIS_USER@$DORIS_HOST:$DORIS_PORT
Main database: $main_db
Lineage database: $lineage_db
Upload dir: $UPLOAD_DIR
Drop databases: $DROP_DATABASES
INFO

case "$MODE" in
  all)
    init_main
    init_lineage
    init_regdb
    init_bjmetro
    ;;
  core|main|doris_showcase)
    init_main
    ;;
  lineage|lineage_showcase)
    init_lineage
    ;;
  regdb)
    init_regdb
    ;;
  bjmetro)
    init_bjmetro
    ;;
  wide)
    init_wide
    ;;
  validate)
    validate_db "$main_db"
    validate_db "$lineage_db"
    validate_db regdb
    validate_db bjmetro
    ;;
  *)
    echo "Usage: sh init_database.sh [all|core|lineage|regdb|bjmetro|wide|validate]"
    exit 1
    ;;
esac

echo "Database initialization finished."
