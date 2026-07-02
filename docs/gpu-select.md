# GPU Selection

`scripts/lib/gpu-select.sh` detects GPUs through:

1. `vulkaninfo --summary`
2. `lspci`
3. Manual input

When an NVIDIA GPU is selected, the launcher exports:

```bash
__NV_PRIME_RENDER_OFFLOAD=1
__GLX_VENDOR_LIBRARY_NAME=nvidia
__VK_LAYER_NV_optimus=NVIDIA_only
DXVK_ENABLE_NVAPI=1
DXVK_FILTER_DEVICE_NAME="selected GPU"
```

For non-interactive launches, set:

```bash
GPU_SELECT_DEFAULT="exact GPU name"
```

Disable the picker:

```bash
BNET_ENABLE_GPU_SELECT=0
```

