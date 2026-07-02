#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"

export WINEPREFIX="${BNET_WINEPREFIX:-$REPO_DIR/wine-battlenet}"
export LANG="${LANG:-C.UTF-8}"

CLIENT="${BNET_WINE_EXE_PATH:-$WINEPREFIX/drive_c/Program Files (x86)/Battle.net/Battle.net Launcher.exe}"
INSTALLER="${BNET_INSTALLER_PATH:-$REPO_DIR/installers/Battle.net-Setup.exe}"

if ! command -v wine >/dev/null 2>&1; then
  echo "error: wine command not found." >&2
  exit 1
fi

if [ -f "$CLIENT" ]; then
  exec wine "$CLIENT" "$@"
fi

if [ -f "$INSTALLER" ]; then
  echo "Battle.net client not found; starting installer."
  exec wine "$INSTALLER" "$@"
fi

echo "Battle.net client not found:"
echo "  $CLIENT"
echo "Place Battle.net-Setup.exe at:"
echo "  $INSTALLER"
exit 1

