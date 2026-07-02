#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
CONFIG_FILE="${BNET_LAUNCHER_CONFIG:-$REPO_DIR/battlenet.env}"

if [ -f "$CONFIG_FILE" ]; then
  set -a
  # shellcheck source=/dev/null
  . "$CONFIG_FILE"
  set +a
fi

# shellcheck source=scripts/lib/gpu-select.sh
. "$SCRIPT_DIR/lib/gpu-select.sh"

display_path() {
  local path="$1"
  printf '%s\n' "${path/#$HOME/\~}"
}

discover_steam_root() {
  if [ -d "$HOME/.steam/debian-installation" ]; then
    printf '%s\n' "$HOME/.steam/debian-installation"
  elif [ -d "$HOME/.steam/steam" ]; then
    printf '%s\n' "$HOME/.steam/steam"
  else
    printf '%s\n' "$HOME/.steam/debian-installation"
  fi
}

discover_proton() {
  if [ -n "${BNET_PROTON:-}" ]; then
    printf '%s\n' "$BNET_PROTON"
    return 0
  fi

  local steam_root="${BNET_STEAM_ROOT:-$(discover_steam_root)}"
  local proton
  proton="$(
    find "$steam_root/compatibilitytools.d" -maxdepth 2 -type f -name proton 2>/dev/null \
      | sort -V \
      | tail -1
  )"

  if [ -n "$proton" ]; then
    printf '%s\n' "$proton"
    return 0
  fi

  return 1
}

STEAM_ROOT="${BNET_STEAM_ROOT:-$(discover_steam_root)}"
PROTON="$(discover_proton || true)"
COMPAT_DATA_PATH="${BNET_COMPAT_DATA_PATH:-$REPO_DIR/proton-battlenet}"
CLIENT="${BNET_EXE_PATH:-$COMPAT_DATA_PATH/pfx/drive_c/Program Files (x86)/Battle.net/Battle.net.exe}"
INSTALLER="${BNET_INSTALLER_PATH:-$REPO_DIR/installers/Battle.net-Setup.exe}"

if [ -z "$PROTON" ] || [ ! -x "$PROTON" ]; then
  echo "error: Proton executable not found."
  echo "Set BNET_PROTON in battlenet.env, for example:"
  echo "  BNET_PROTON=\"\$HOME/.steam/debian-installation/compatibilitytools.d/GE-Proton10-34/proton\""
  exit 1
fi

export STEAM_COMPAT_CLIENT_INSTALL_PATH="$STEAM_ROOT"
export STEAM_COMPAT_DATA_PATH="$COMPAT_DATA_PATH"
export PROTON_USE_XALIA="${PROTON_USE_XALIA:-0}"

SELECTED_GPU="${GPU_SELECT_DEFAULT:-${DXVK_FILTER_DEVICE_NAME:-}}"
if [ "${BNET_ENABLE_GPU_SELECT:-1}" != "0" ]; then
  launch_tui_choose "Battle.net GE-Proton launcher"
fi
gpu_select_apply_env "${SELECTED_GPU:-}"
gpu_select_apply_performance_env

echo "=========================================="
echo "Battle.net GE-Proton launcher"
echo "Proton:      $(display_path "$PROTON")"
echo "Steam root:  $(display_path "$STEAM_ROOT")"
echo "Compat data: $(display_path "$COMPAT_DATA_PATH")"
echo "GPU:         ${DXVK_FILTER_DEVICE_NAME:-default}"
echo "Xalia:       ${PROTON_USE_XALIA}"
echo "=========================================="

if [ ! -f "$CLIENT" ]; then
  echo "Battle.net client not found:"
  echo "  $(display_path "$CLIENT")"
  echo ""

  if [ -f "$INSTALLER" ]; then
    echo "Starting local Battle.net installer:"
    echo "  $(display_path "$INSTALLER")"
    exec "$PROTON" run "$INSTALLER" "$@"
  fi

  echo "Download Battle.net installer from Blizzard, place it at:"
  echo "  $(display_path "$INSTALLER")"
  echo "Then re-run this script. The installer is intentionally not tracked by this repo."
  exit 1
fi

echo "Starting Battle.net..."
exec "$PROTON" run "$CLIENT" "$@"

