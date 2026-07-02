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

display_path() {
  local path="${1:-}"
  [ -n "$path" ] || return 0
  printf '%s\n' "${path/#$HOME/\~}"
}

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

print_cmd_status() {
  if has_cmd "$1"; then
    printf '  %-14s yes (%s)\n' "$1" "$(command -v "$1")"
  else
    printf '  %-14s no\n' "$1"
  fi
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
  find "$steam_root/compatibilitytools.d" -maxdepth 2 -type f -name proton 2>/dev/null \
    | sort -V \
    | tail -1
}

STEAM_ROOT="${BNET_STEAM_ROOT:-$(discover_steam_root)}"
PROTON="$(discover_proton || true)"
COMPAT_DATA_PATH="${BNET_COMPAT_DATA_PATH:-$REPO_DIR/proton-battlenet}"
CLIENT="${BNET_EXE_PATH:-$COMPAT_DATA_PATH/pfx/drive_c/Program Files (x86)/Battle.net/Battle.net.exe}"

echo "# Battle.net Wine/Proton Environment Report"
echo
echo "Generated: $(date -Is)"
echo

echo "## System"
if [ -r /etc/os-release ]; then
  . /etc/os-release
  echo "OS: ${PRETTY_NAME:-unknown}"
else
  echo "OS: unknown"
fi
echo "Kernel: $(uname -srmo)"
echo "Session: ${XDG_SESSION_TYPE:-unknown}"
echo "Desktop: ${XDG_CURRENT_DESKTOP:-${DESKTOP_SESSION:-unknown}}"
echo "DISPLAY: ${DISPLAY:+set}"
echo "WAYLAND_DISPLAY: ${WAYLAND_DISPLAY:+set}"
echo

echo "## Commands"
for cmd in wine vulkaninfo lspci nvidia-smi whiptail curl unzip; do
  print_cmd_status "$cmd"
done
echo

echo "## Wine / Proton"
if has_cmd wine; then
  echo "Wine: $(wine --version 2>/dev/null || true)"
else
  echo "Wine: not found"
fi
echo "Steam root: $(display_path "$STEAM_ROOT")"
echo "Proton: $(display_path "$PROTON")"
if [ -n "$PROTON" ] && [ -x "$PROTON" ]; then
  echo "Proton executable: yes"
else
  echo "Proton executable: no"
fi
echo

echo "## Prefix"
echo "Compat data: $(display_path "$COMPAT_DATA_PATH")"
if [ -d "$COMPAT_DATA_PATH" ]; then
  echo "Compat data exists: yes"
  du -sh "$COMPAT_DATA_PATH" 2>/dev/null | awk '{ print "Compat data size: " $1 }'
else
  echo "Compat data exists: no"
fi
if [ -f "$CLIENT" ]; then
  echo "Battle.net client: yes"
else
  echo "Battle.net client: no"
fi
echo

echo "## GPUs"
if has_cmd vulkaninfo; then
  vulkaninfo --summary 2>/dev/null \
    | awk -F '= ' '
      BEGIN { IGNORECASE = 1 }
      /deviceType[[:space:]]*=/ { type = $2 }
      /deviceName[[:space:]]*=/ {
        name = $2
        if (type != "PHYSICAL_DEVICE_TYPE_CPU" && name !~ /llvmpipe|lavapipe|SwiftShader/) {
          print "- Vulkan: " name
        }
      }
    ' \
    | awk '!seen[$0]++'
else
  echo "- Vulkan: vulkaninfo not found"
fi

if has_cmd nvidia-smi; then
  nvidia-smi --query-gpu=name,driver_version --format=csv,noheader 2>/dev/null \
    | sed 's/^/- NVIDIA: /' || true
fi

if has_cmd lspci; then
  lspci \
    | awk 'BEGIN { IGNORECASE = 1 } /VGA compatible controller|3D controller|Display controller/ { sub(/^.*: /, ""); print "- PCI: " $0 }'
fi

