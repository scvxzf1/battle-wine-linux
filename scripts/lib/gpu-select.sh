#!/usr/bin/env bash

gpu_select_collect_vulkan_gpus() {
  if ! command -v vulkaninfo >/dev/null 2>&1; then
    return 0
  fi

  vulkaninfo --summary 2>/dev/null \
    | awk -F '= ' '
      BEGIN { IGNORECASE = 1 }
      /deviceType[[:space:]]*=/ { type = $2 }
      /deviceName[[:space:]]*=/ {
        name = $2
        if (type != "PHYSICAL_DEVICE_TYPE_CPU" && name !~ /llvmpipe|lavapipe|SwiftShader/) {
          print name
        }
      }
    ' \
    | awk '!seen[$0]++'
}

gpu_select_collect_lspci_gpus() {
  if ! command -v lspci >/dev/null 2>&1; then
    return 0
  fi

  lspci \
    | awk 'BEGIN { IGNORECASE = 1 } /VGA compatible controller|3D controller|Display controller/ { sub(/^.*: /, ""); print }' \
    | awk '!seen[$0]++'
}

gpu_select_manual_input() {
  local title="$1"
  local value=""

  if [ -t 0 ] && [ -t 1 ] && command -v whiptail >/dev/null 2>&1; then
    if ! value="$(whiptail --title "$title" --inputbox "Enter the GPU name as seen by DXVK:" 10 80 "" 3>&1 1>&2 2>&3)"; then
      return 130
    fi
  else
    read -r -p "Enter the GPU name as seen by DXVK: " value
  fi

  if [ -z "$value" ]; then
    echo "error: GPU name cannot be empty." >&2
    return 1
  fi

  SELECTED_GPU="$value"
}

gpu_select_default_gpu_name() {
  local -a gpus=()
  local gpu

  while IFS= read -r gpu; do
    [ -n "$gpu" ] && gpus+=("$gpu")
  done < <(gpu_select_collect_vulkan_gpus)

  if [ "${#gpus[@]}" -eq 0 ]; then
    while IFS= read -r gpu; do
      [ -n "$gpu" ] && gpus+=("$gpu")
    done < <(gpu_select_collect_lspci_gpus)
  fi

  for gpu in "${gpus[@]}"; do
    if [[ "$gpu" =~ NVIDIA|nvidia|GeForce|RTX|GTX ]]; then
      echo "$gpu"
      return 0
    fi
  done

  if [ "${#gpus[@]}" -gt 0 ]; then
    echo "${gpus[0]}"
  fi
}

gpu_select_choose() {
  local title="${1:-Battle.net launcher}"
  local gpu
  local choice
  local default_gpu="${GPU_SELECT_DEFAULT:-${DXVK_FILTER_DEVICE_NAME:-}}"
  local default_index=1
  local -a gpus=()

  while IFS= read -r gpu; do
    [ -n "$gpu" ] && gpus+=("$gpu")
  done < <(gpu_select_collect_vulkan_gpus)

  if [ "${#gpus[@]}" -eq 0 ]; then
    while IFS= read -r gpu; do
      [ -n "$gpu" ] && gpus+=("$gpu")
    done < <(gpu_select_collect_lspci_gpus)
  fi

  if [ "${#gpus[@]}" -eq 0 ]; then
    if ! [ -t 0 ] || ! [ -t 1 ]; then
      if [ -n "$default_gpu" ]; then
        SELECTED_GPU="$default_gpu"
        echo "No interactive terminal; using GPU: $SELECTED_GPU"
        return 0
      fi

      echo "error: no GPU detected and no interactive terminal is available." >&2
      return 1
    fi

    gpu_select_manual_input "$title"
    return $?
  fi

  local i
  for i in "${!gpus[@]}"; do
    if [ -n "$default_gpu" ] && [ "${gpus[$i]}" = "$default_gpu" ]; then
      default_index="$((i + 1))"
      break
    fi
  done

  if [ -t 0 ] && [ -t 1 ] && command -v whiptail >/dev/null 2>&1; then
    local -a menu_items=()
    for i in "${!gpus[@]}"; do
      menu_items+=("$((i + 1))" "${gpus[$i]}")
    done
    menu_items+=("m" "Manual GPU name")

    if ! choice="$(
      whiptail \
        --title "$title" \
        --default-item "$default_index" \
        --menu "Choose the GPU for this launch:" 18 86 8 \
        "${menu_items[@]}" \
        3>&1 1>&2 2>&3
    )"; then
      return 130
    fi

    if [ "$choice" = "m" ]; then
      gpu_select_manual_input "$title"
      return $?
    fi

    SELECTED_GPU="${gpus[$((choice - 1))]}"
    return 0
  fi

  if ! [ -t 0 ] || ! [ -t 1 ]; then
    SELECTED_GPU="${gpus[$((default_index - 1))]}"
    echo "No interactive terminal; auto-selected GPU: $SELECTED_GPU"
    return 0
  fi

  echo "=========================================="
  echo "  $title"
  echo "  Choose the GPU for this launch:"
  echo "=========================================="

  for i in "${!gpus[@]}"; do
    printf '  %d) %s\n' "$((i + 1))" "${gpus[$i]}"
  done
  echo "  m) Manual GPU name"
  echo ""

  while true; do
    read -r -p "Select a number or m [default ${default_index}]: " choice
    choice="${choice:-${default_index}}"

    if [[ "$choice" =~ ^[mM]$ ]]; then
      gpu_select_manual_input "$title"
      return $?
    fi

    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#gpus[@]}" ]; then
      SELECTED_GPU="${gpus[$((choice - 1))]}"
      return 0
    fi

    echo "Invalid input."
  done
}

gpu_select_apply_env() {
  local selected_gpu="${1:-}"

  if [ -n "$selected_gpu" ]; then
    export DXVK_FILTER_DEVICE_NAME="$selected_gpu"
  fi

  if [[ "$selected_gpu" =~ NVIDIA|nvidia|GeForce|RTX|GTX ]]; then
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    export DXVK_ENABLE_NVAPI=1
  else
    unset __NV_PRIME_RENDER_OFFLOAD
    unset __GLX_VENDOR_LIBRARY_NAME
    unset __VK_LAYER_NV_optimus
    unset DXVK_ENABLE_NVAPI
  fi
}

gpu_select_apply_performance_env() {
  local mode="${BNET_PERFORMANCE_MODE:-auto}"
  case "$mode" in
    0|off|false|disable|disabled)
      unset DXVK_STATE_CACHE
      unset DXVK_HUD
      unset DXVK_ASYNC
      unset PROTON_NO_ESYNC
      unset PROTON_NO_FSYNC
      return 0
      ;;
  esac

  export DXVK_STATE_CACHE=1
  export DXVK_ASYNC=1
  export PROTON_NO_ESYNC=0
  export PROTON_NO_FSYNC=0
  if [ "${BNET_DXVK_HUD:-0}" = "1" ]; then
    export DXVK_HUD="fps"
  else
    unset DXVK_HUD
  fi
}

launch_tui_choose() {
  local title="${1:-Battle.net launcher}"
  local choice
  local gpu_line

  if [ -z "${SELECTED_GPU:-}" ]; then
    SELECTED_GPU="$(gpu_select_default_gpu_name || true)"
  fi

  if ! [ -t 0 ] || ! [ -t 1 ]; then
    if [ -z "${SELECTED_GPU:-}" ]; then
      SELECTED_GPU="${GPU_SELECT_DEFAULT:-}"
    fi
    if [ -z "$SELECTED_GPU" ]; then
      echo "error: non-interactive launch requires GPU_SELECT_DEFAULT or detectable GPU." >&2
      return 1
    fi
    echo "No interactive terminal; using GPU: $SELECTED_GPU"
    return 0
  fi

  if [ -t 0 ] && [ -t 1 ] && command -v whiptail >/dev/null 2>&1; then
    while true; do
      gpu_line="${SELECTED_GPU:-not selected}"
      choice="$(
        whiptail \
          --title "$title" \
          --menu "Confirm launch options." 18 86 8 \
          "start" "Start Battle.net (GPU: ${gpu_line})" \
          "gpu" "Change GPU..." \
          "cancel" "Cancel" \
          3>&1 1>&2 2>&3
      )" || return 130

      case "$choice" in
        start) return 0 ;;
        gpu) gpu_select_choose "$title" || return $? ;;
        cancel) return 130 ;;
      esac
    done
  fi

  while true; do
    echo "=========================================="
    echo "  $title"
    echo "  GPU: ${SELECTED_GPU:-not selected}"
    echo "  s) Start  g) Change GPU  c) Cancel"
    echo "=========================================="
    read -r -p "Choose [default s]: " choice
    choice="${choice:-s}"
    case "$choice" in
      s|S|start) return 0 ;;
      g|G|gpu) gpu_select_choose "$title" || return $? ;;
      c|C|cancel) return 130 ;;
      *) echo "Invalid input." ;;
    esac
  done
}

