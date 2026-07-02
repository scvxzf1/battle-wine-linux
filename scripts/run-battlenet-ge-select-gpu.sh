#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
export BNET_ENABLE_GPU_SELECT=1

exec "$SCRIPT_DIR/run-battlenet-ge.sh" "$@"

