#!/bin/bash
set -euo pipefail
# shellcheck source=common.sh
source "$(cd "$(dirname "$0")" && pwd)/common.sh"
load_env

echo "== Doris Showcase stop =="
stop_port "$BACKEND_PORT"
stop_port "$FRONTEND_PORT"
