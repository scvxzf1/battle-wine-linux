# Wine / Proton Environment

[English](wine-environment.md) | [简体中文](wine-environment.zh-CN.md)

This document describes the runtime environment expected by this launcher. The
goal is to make the setup reproducible without publishing a live Wine prefix,
Battle.net login state, or Blizzard game files.

## Runtime Model

The recommended path is GE-Proton rather than plain system Wine:

```text
Linux desktop
  -> Steam compatibility runtime
    -> GE-Proton proton script
      -> Proton compat data directory
        -> Wine prefix at $STEAM_COMPAT_DATA_PATH/pfx
          -> C:\Program Files (x86)\Battle.net\Battle.net.exe
```

The pure Wine script in `examples/run-battlenet-wine.sh` is kept as a reference
path, but the main launcher is `scripts/run-battlenet-ge.sh`.

## Maintainer Baseline

This project has been developed and smoke-tested on the following local
baseline. These values are not hard requirements, but they are useful when
comparing reports:

```text
OS: Ubuntu 24.04.4 LTS
Kernel: Linux 6.17.0-35-generic x86_64
Session: Wayland
Desktop: GNOME / Ubuntu session
Wine package: wine-9.0
GE-Proton: GE-Proton10-34
NVIDIA driver: 580.159.03
Tested GPUs: GTX 960, GTX 1070, RTX 2060, RTX 3080
```

## Required Host Components

Minimum:

- A Linux desktop session with working graphics acceleration.
- Steam installed.
- GE-Proton installed under Steam compatibility tools.
- `curl`, `unzip`, `bash`, `find`, `awk`, `sed`, and coreutils.

Recommended:

- `vulkaninfo`, used to discover DXVK-visible GPUs.
- `lspci`, fallback GPU discovery.
- `nvidia-smi`, NVIDIA driver and GPU confirmation.
- `whiptail`, interactive terminal menu.

Optional when preparing non-Proton Wine prefixes:

- `winetricks`
- `cabextract`
- `7z` / `p7zip`

## Proton Paths

The launcher uses these concepts:

```bash
BNET_STEAM_ROOT="$HOME/.steam/debian-installation"
BNET_PROTON="$BNET_STEAM_ROOT/compatibilitytools.d/GE-Proton10-34/proton"
BNET_COMPAT_DATA_PATH="$PWD/proton-battlenet"
```

If `BNET_PROTON` is not set, the launcher searches:

```text
$BNET_STEAM_ROOT/compatibilitytools.d/*/proton
```

and picks the newest path by version sort.

## Compat Data And Wine Prefix

`BNET_COMPAT_DATA_PATH` is the Proton compat data directory. The actual Wine
prefix is created inside it:

```text
$BNET_COMPAT_DATA_PATH/
  pfx/
    drive_c/
    system.reg
    user.reg
    userdef.reg
```

For a default checkout, that means:

```text
./proton-battlenet/pfx
```

This directory is intentionally ignored by git. It may contain account state,
registry data, cookies, caches, installers, crash dumps, and Blizzard client
files.

## Runtime Libraries And Winetricks Baseline

The repository does not bundle Microsoft redistributables, fonts, or Wine prefix
contents. Instead, it documents the runtime baseline observed in the working
Battle.net Wine prefixes. Download and acquisition sources are centralized in
[runtime-sources.md](runtime-sources.md).

The verified winetricks baseline is:

```text
win10
corefonts
vcrun2022
```

The same list is tracked in:

```text
examples/winetricks-runtime.txt
```

The upstream/source list is tracked in:

```text
examples/runtime-sources.txt
```

Meaning:

- `win10`: sets the Wine Windows version to Windows 10.
- `corefonts`: installs common Microsoft core fonts. The resulting
  `winetricks.log` may expand this into `andale`, `arial`, `comicsans`,
  `courier`, `georgia`, `impact`, `times`, `trebuchet`, `verdana`, and
  `webdings`.
- `vcrun2022`: installs the Visual C++ 2015-2022 runtime used by many modern
  Windows applications.

For plain Wine prefixes, the equivalent preparation command is:

```bash
WINEPREFIX=/path/to/wine-battlenet winetricks -q win10 corefonts vcrun2022
```

For Proton prefixes, prefer GE-Proton's bundled runtime first. If you do use
winetricks/protontricks on a Proton prefix, treat it as an advanced operation
and back up the prefix first.

## GE-Proton Bundled Runtime Components

GE-Proton already ships several important runtime layers. On the maintainer
baseline, `GE-Proton10-34` contains:

```text
files/lib/wine/dxvk
files/lib/wine/vkd3d-proton
files/lib/wine/nvapi
files/share/wine/mono
files/share/wine/gecko
files/share/wine/fonts
```

Those are not copied into this repository. They are part of the user's local
GE-Proton installation.

## Battle.net Client Path

The default Battle.net executable path is:

```text
$BNET_COMPAT_DATA_PATH/pfx/drive_c/Program Files (x86)/Battle.net/Battle.net.exe
```

Override it when Battle.net is installed elsewhere:

```bash
BNET_EXE_PATH="/custom/prefix/pfx/drive_c/Program Files (x86)/Battle.net/Battle.net.exe"
```

If the client is missing and `BNET_INSTALLER_PATH` exists, the launcher starts
the installer instead.

## First-Run Lifecycle

1. The launcher resolves config from `battlenet.env`.
2. It discovers or reads the GE-Proton path.
3. It sets Proton compatibility variables:

```bash
STEAM_COMPAT_CLIENT_INSTALL_PATH="$BNET_STEAM_ROOT"
STEAM_COMPAT_DATA_PATH="$BNET_COMPAT_DATA_PATH"
PROTON_USE_XALIA=0
```

4. It applies GPU and DXVK-related environment variables.
5. If Battle.net exists, it starts the client.
6. If Battle.net is missing but the installer exists, it starts the installer.
7. If neither exists, it prints the expected installer location and exits.

## Graphics Stack

The launcher is tuned for DXVK / Vulkan environments. GPU selection does not
bind directly to PCI IDs; it sets DXVK-visible names:

```bash
DXVK_FILTER_DEVICE_NAME="NVIDIA GeForce RTX 3080"
```

For NVIDIA GPUs, it also enables PRIME offload variables:

```bash
__NV_PRIME_RENDER_OFFLOAD=1
__GLX_VENDOR_LIBRARY_NAME=nvidia
__VK_LAYER_NV_optimus=NVIDIA_only
DXVK_ENABLE_NVAPI=1
```

Performance defaults:

```bash
DXVK_STATE_CACHE=1
DXVK_ASYNC=1
PROTON_NO_ESYNC=0
PROTON_NO_FSYNC=0
```

Disable these with:

```bash
BNET_PERFORMANCE_MODE=off
```

## Xalia

The launcher defaults to:

```bash
PROTON_USE_XALIA=0
```

This avoids a class of crashes seen when starting Proton outside the Steam UI on
some Wayland / desktop combinations.

## Network And Proxy

The launcher does not manage proxies directly. If your Battle.net region or
network requires a proxy, export standard proxy variables before launch:

```bash
export http_proxy=http://127.0.0.1:7890
export https_proxy=http://127.0.0.1:7890
export all_proxy=socks5://127.0.0.1:7890
```

Do not commit real proxy credentials.

## Environment Report

Use:

```bash
./tools/collect-env-report.sh
```

The report includes OS, kernel, session type, command availability, Wine /
Proton paths, compat data existence, and GPU summaries. It intentionally avoids
registry dumps, tokens, cookies, Battle.net account state, and full prefix file
lists.

It also reports whether `winetricks` is available, whether a prefix
`winetricks.log` exists, and whether GE-Proton's bundled DXVK / vkd3d-proton /
nvapi / mono / gecko directories are present.

## What Should Never Be Published

Do not publish:

- `proton-battlenet/`
- `wine-*` prefixes
- `pfx/`
- `system.reg`, `user.reg`, `userdef.reg`
- Battle.net installers
- Blizzard game files
- screenshots with account information
- logs or crash dumps
- proxy configs with passwords
- cookies, tokens, or login state
