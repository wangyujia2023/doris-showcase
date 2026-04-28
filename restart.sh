#!/bin/bash
set -euo pipefail
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
sh "$PROJECT_DIR/stop.sh"
sh "$PROJECT_DIR/start.sh"
