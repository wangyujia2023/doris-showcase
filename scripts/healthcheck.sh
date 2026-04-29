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

echo
echo "== Local filesystem =="
mkdir -p "$UPLOAD_DIR" || fail=1
if touch "$UPLOAD_DIR/.healthcheck" 2>/dev/null; then
  rm -f "$UPLOAD_DIR/.healthcheck"
  echo "PASS upload-dir writable: $UPLOAD_DIR"
else
  echo "FAIL upload-dir not writable: $UPLOAD_DIR"
  fail=1
fi

echo
echo "== Doris databases =="
if mysql_query "SHOW DATABASES LIKE '$DORIS_DATABASE';" | grep -q "$DORIS_DATABASE"; then
  echo "PASS main-db exists: $DORIS_DATABASE"
else
  echo "FAIL main-db missing: $DORIS_DATABASE"
  fail=1
fi
if mysql_query "SHOW DATABASES LIKE '$LINEAGE_DATABASE';" | grep -q "$LINEAGE_DATABASE"; then
  echo "PASS lineage-db exists: $LINEAGE_DATABASE"
else
  echo "FAIL lineage-db missing: $LINEAGE_DATABASE"
  fail=1
fi

if [ -n "${OPENMETADATA_BASE_URL:-}" ]; then
  echo
  echo "== OpenMetadata optional check =="
  if [ -n "${OPENMETADATA_JWT_TOKEN:-}" ]; then
    if curl -fsS --max-time 8 -H "Authorization: Bearer $OPENMETADATA_JWT_TOKEN" "$OPENMETADATA_BASE_URL/v1/system/version" >/dev/null 2>&1; then
      echo "PASS openmetadata"
    else
      echo "WARN openmetadata unreachable or token invalid: $OPENMETADATA_BASE_URL"
    fi
  else
    echo "WARN openmetadata token empty, lineage import to OpenMetadata will be skipped/failed"
  fi
fi

if [ "${FULL_SMOKE:-false}" = "true" ]; then
  echo
  "$PYTHON_BIN" "$PROJECT_DIR/scripts/smoke_api.py" || fail=1
fi

echo
echo "Main DB: $DORIS_DATABASE"
echo "Lineage DB: $LINEAGE_DATABASE"
echo "Upload dir: $UPLOAD_DIR"
echo "Backend log: $BACKEND_LOG"
echo "Frontend log: $FRONTEND_LOG"
exit "$fail"
