#!/bin/bash
set -euo pipefail
# shellcheck source=common.sh
source "$(cd "$(dirname "$0")" && pwd)/common.sh"
load_env
need_cmd curl "curl"

echo "== Doris Showcase healthcheck =="
fail=0
check_url "backend" "http://127.0.0.1:$BACKEND_PORT/api/system/health" || fail=1
check_url "frontend-proxy" "http://127.0.0.1:$FRONTEND_PORT/api/system/health" || fail=1
check_url "dictionary" "http://127.0.0.1:$BACKEND_PORT/api/meta/dictionaries?locale=en" || fail=1
check_url "dashboard" "http://127.0.0.1:$BACKEND_PORT/api/dashboard" || fail=1
check_url "vector-labels" "http://127.0.0.1:$BACKEND_PORT/api/vector/labels" || fail=1
check_url "lineage-assets" "http://127.0.0.1:$BACKEND_PORT/api/lineage/assets?keyword=" || fail=1

echo "Main DB: $DORIS_DATABASE"
echo "Lineage DB: $LINEAGE_DATABASE"
echo "Backend log: $BACKEND_LOG"
echo "Frontend log: $FRONTEND_LOG"
exit "$fail"
