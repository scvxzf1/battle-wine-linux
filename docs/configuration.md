# Configuration

The main script reads `battlenet.env` from the repository root by default.
Override the config path with:

```bash
BNET_LAUNCHER_CONFIG=/path/to/config.env ./scripts/run-battlenet-ge.sh
```

## Common Options

```bash
BNET_PROTON="$HOME/.steam/debian-installation/compatibilitytools.d/GE-Proton10-34/proton"
BNET_STEAM_ROOT="$HOME/.steam/debian-installation"
BNET_COMPAT_DATA_PATH="$PWD/proton-battlenet"
BNET_EXE_PATH="$BNET_COMPAT_DATA_PATH/pfx/drive_c/Program Files (x86)/Battle.net/Battle.net.exe"
BNET_INSTALLER_PATH="$PWD/installers/Battle.net-Setup.exe"
BNET_ENABLE_GPU_SELECT=1
GPU_SELECT_DEFAULT="NVIDIA GeForce RTX 3080"
PROTON_USE_XALIA=0
BNET_PERFORMANCE_MODE=auto
BNET_DXVK_HUD=0
```

The most important path relationship is:

```text
BNET_COMPAT_DATA_PATH
  -> pfx
    -> drive_c
      -> Program Files (x86)
        -> Battle.net
          -> Battle.net.exe
```

See [wine-environment.md](wine-environment.md) for more detail.

## Runtime Baseline

For plain Wine prefixes, the observed winetricks baseline is:

```text
win10
corefonts
vcrun2022
```

This is recorded in `examples/winetricks-runtime.txt`.

## Proxy

Proxy settings are intentionally not stored in the tracked config. Use:

```bash
source examples/proxy.env.example
./scripts/run-battlenet-ge.sh
```

Or create your own untracked local proxy file.
