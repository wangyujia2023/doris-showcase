#!/bin/sh
set -eu
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
exec bash "$SCRIPT_DIR/scripts/stop.sh" "$@"
