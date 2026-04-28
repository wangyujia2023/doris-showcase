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
DORIS_DATABASE="${DORIS_DATABASE:-doris_showcase}"
LINEAGE_DATABASE="${LINEAGE_DATABASE:-lineage_showcase}"

echo "== Doris Showcase healthcheck =="
fail=0
check_url() {
  name="$1"
  url="$2"
  if curl -fsS --max-time 8 "$url" >/tmp/doris_showcase_health.out 2>/tmp/doris_showcase_health.err; then
    echo "PASS $name $url"
  else
    echo "FAIL $name $url"
    cat /tmp/doris_showcase_health.err 2>/dev/null || true
    fail=1
  fi
}
check_url "backend" "http://127.0.0.1:$BACKEND_PORT/api/system/health"
check_url "frontend-proxy" "http://127.0.0.1:$FRONTEND_PORT/api/system/health"
check_url "dictionary" "http://127.0.0.1:$BACKEND_PORT/api/meta/dictionaries?locale=en"
echo "Database: $DORIS_DATABASE"
echo "Lineage database: $LINEAGE_DATABASE"
exit "$fail"
