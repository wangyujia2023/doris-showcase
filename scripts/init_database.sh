#!/bin/bash
set -euo pipefail
# shellcheck source=common.sh
source "$(cd "$(dirname "$0")" && pwd)/common.sh"

MODE="${1:-all}"
load_env
ensure_dirs
need_cmd mysql "Doris MySQL client"

main_db="$DORIS_DATABASE"

drop_db_if_requested() {
  local db="$1"
  if [ "$DROP_DATABASES" = "true" ]; then
    echo "DROP_DATABASES=true, dropping database: $db"
    mysql_query "DROP DATABASE IF EXISTS \`$db\`;"
  fi
}

run_sql_file_into_db() {
  local db="$1"
  local sql_file="$2"
  local full_path="$PROJECT_DIR/$sql_file"
  local tmp
  if [ ! -f "$full_path" ]; then
    echo "FAIL SQL file not found: $sql_file"
    exit 1
  fi
  tmp="$(mktemp)"
  awk '
    {
      line=toupper($0)
      if (line ~ /^[[:space:]]*CREATE[[:space:]]+DATABASE[[:space:]]+/) next
      if (line ~ /^[[:space:]]*USE[[:space:]]+/) next
      print
    }
  ' "$full_path" > "$tmp"
  echo "Running $sql_file -> $db"
  mysql_cli "$db" < "$tmp"
  rm -f "$tmp"
}

run_pair() {
  local schema="$1"
  local mock="$2"
  mysql_query "CREATE DATABASE IF NOT EXISTS \`$main_db\`;"
  run_sql_file_into_db "$main_db" "$schema"
  run_sql_file_into_db "$main_db" "$mock"
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
      validate_count "$db" news_article 1
      validate_count "$db" t_customer_tags 1
      validate_count "$db" lineage_asset 1
      validate_count "$db" lineage_edge 1
      validate_count "$db" reg_master 1
      validate_count "$db" bj_metro_lines 1
      ;;
  esac
}

init_main() {
  run_pair "sql/by_database/doris_showcase_schema.sql" "sql/by_database/doris_showcase_mock.sql"
}

init_lineage() {
  run_pair "sql/by_database/lineage_showcase_schema.sql" "sql/by_database/lineage_showcase_mock.sql"
}

init_regdb() {
  run_pair "sql/by_database/regdb_schema.sql" "sql/by_database/regdb_mock.sql"
}

init_bjmetro() {
  run_pair "sql/by_database/bjmetro_schema.sql" "sql/by_database/bjmetro_mock.sql"
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
Upload dir: $UPLOAD_DIR
Drop databases: $DROP_DATABASES
INFO

case "$MODE" in
  all)
    drop_db_if_requested "$main_db"
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
    ;;
  *)
    echo "Usage: sh scripts/init_database.sh [all|core|lineage|regdb|bjmetro|wide|validate]"
    exit 1
    ;;
esac

echo "Database initialization finished."
