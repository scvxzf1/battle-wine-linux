# Battle.net Wine Launcher

[English](README.md) | [简体中文](README.zh-CN.md)

## Personal Record Notice

Recorded at: `2026-07-03 01:58:35 Asia/Shanghai (UTC+08:00)`.

This repository is a personal record of one working Battle.net Wine / GE-Proton
environment. It is not an out-of-the-box application, a universal installer, or
a compatibility guarantee. Use it as a reference and adapt the paths, runtime
versions, GPU settings, and Wine prefix choices to your own Linux system.

Linux launcher scaffolding for running Battle.net with Wine or GE-Proton.

This repository contains only scripts, examples, and documentation. It does not
ship Battle.net, Blizzard game files, Wine prefixes, login state, proxies, or
game-specific mods.

## What This Is

- A GE-Proton based Battle.net launcher.
- A small GPU picker for DXVK / NVIDIA PRIME systems.
- A pure Wine launcher example.
- A safe environment report tool for troubleshooting.

## What This Is Not

- It is not a Battle.net mirror.
- It is not a game installer bundle.
- It does not include any Blizzard binaries.
- It does not include Wine / Proton prefixes.
- It does not include Hearthstone or HsMod plugin logic.

## Tested Hardware

This setup has been tested on NVIDIA GTX 960, GTX 1070, RTX 2060, and RTX 3080
GPUs. The current maintainer machine is using NVIDIA driver `580.159.03`.

## Wine / Proton Environment

The main path uses GE-Proton with a dedicated compat data directory. The Wine
prefix lives under:

```text
$BNET_COMPAT_DATA_PATH/pfx
```

The maintainer baseline is Ubuntu 24.04.4 LTS, Wayland / GNOME, Wine `9.0`,
GE-Proton `GE-Proton10-34`, and NVIDIA driver `580.159.03`.

See [docs/wine-environment.md](docs/wine-environment.md) for the detailed
runtime model, prefix layout, environment variables, GPU stack, and publishing
safety notes. See [docs/runtime-sources.md](docs/runtime-sources.md) for the
official/upstream source list for installers, runtimes, fonts, and GE-Proton.

The observed optional winetricks baseline for working Wine prefixes is:

```text
win10
corefonts
vcrun2022
```

## Layout

```text
scripts/
  run-battlenet-ge.sh              Main GE-Proton launcher
  run-battlenet-ge-select-gpu.sh   Compatibility wrapper that forces GPU picker
  lib/gpu-select.sh                GPU detection and DXVK env helpers

examples/
  battlenet.env.example            Local configuration template
  proxy.env.example                Optional proxy environment template
  winetricks-runtime.txt           Optional Wine runtime baseline
  runtime-sources.txt              Text list of upstream acquisition sources
  run-battlenet-wine.sh            Pure Wine launcher example

tools/
  collect-env-report.sh            Safe environment report

docs/
  install.md
  configuration.md
  gpu-select.md
  proton-ge.md
  runtime-sources.md
  runtime-sources.zh-CN.md
  wine-environment.md
  wine-environment.zh-CN.md
  troubleshooting.md
  security.md
```

## Quick Start

1. Install Steam and GE-Proton. Source links are tracked in
   [docs/runtime-sources.md](docs/runtime-sources.md).
2. Copy the config template:

```bash
cp examples/battlenet.env.example battlenet.env
```

3. Edit `battlenet.env` for your Proton path if auto-detection is not enough.
4. Download the official Battle.net installer from Blizzard and place it at:

```text
installers/Battle.net-Setup.exe
```

5. Run:

```bash
./scripts/run-battlenet-ge.sh
```

The first run starts the installer if Battle.net is not already present in the
configured Proton compat data path.

## Environment Report

For troubleshooting:

```bash
./tools/collect-env-report.sh
```

The report avoids registry dumps, cookies, tokens, Battle.net account data, and
full prefix file lists.

## Safety

Do not commit `battlenet.env`, Wine prefixes, installers, screenshots, logs,
proxy configs, or crash dumps. The `.gitignore` is intentionally conservative.

## License

MIT. See [LICENSE](LICENSE).
