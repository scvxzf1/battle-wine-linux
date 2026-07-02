# Battle.net Wine Launcher

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

## Layout

```text
scripts/
  run-battlenet-ge.sh              Main GE-Proton launcher
  run-battlenet-ge-select-gpu.sh   Compatibility wrapper that forces GPU picker
  lib/gpu-select.sh                GPU detection and DXVK env helpers

examples/
  battlenet.env.example            Local configuration template
  proxy.env.example                Optional proxy environment template
  run-battlenet-wine.sh            Pure Wine launcher example

tools/
  collect-env-report.sh            Safe environment report

docs/
  install.md
  configuration.md
  gpu-select.md
  proton-ge.md
  troubleshooting.md
  security.md
```

## Quick Start

1. Install Steam and GE-Proton.
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

