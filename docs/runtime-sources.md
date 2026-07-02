# Runtime Sources

[English](runtime-sources.md) | [简体中文](runtime-sources.zh-CN.md)

This repository intentionally does not bundle Microsoft runtime DLLs, Microsoft
font files, Battle.net installers, GE-Proton packages, Wine prefixes, or any
generated compat data. Those files are downloaded or created locally by the
user.

The reproducible part is the source list and the command baseline below.

## Source List

| Component | How to obtain it | Stored in this repo |
| --- | --- | --- |
| Steam | Install from the official Steam download page or your distribution package manager. | No |
| GE-Proton | Install from GE-Proton releases, usually through ProtonUp-Qt or Steam compatibility tools. | No |
| Battle.net installer | Download from Blizzard's official Battle.net download page and place it at `installers/Battle.net-Setup.exe`. | No |
| Wine prefix / Proton compat data | Generated locally by Wine or Proton under `$BNET_COMPAT_DATA_PATH/pfx`. | No |
| Microsoft Visual C++ runtime DLLs | Install through `winetricks vcrun2022` for plain Wine prefixes. Use Microsoft's Visual C++ Redistributable page only as an upstream reference. | No |
| Microsoft core fonts | Install through `winetricks corefonts` for plain Wine prefixes. | No |
| Wine Mono / Gecko | Prefer the copies bundled in GE-Proton. For plain Wine, let Wine install them when prompted or use distribution packages. | No |
| DXVK / vkd3d-proton / dxvk-nvapi | Prefer the copies bundled in GE-Proton. Upstream projects are useful for diagnostics, not required for this launcher. | No |
| Host extraction tools | Install `winetricks`, `cabextract`, and a `7z` / `p7zip` provider through your distribution package manager when preparing plain Wine prefixes. | No |

The same compact list is stored in:

```text
examples/runtime-sources.txt
```

## Official And Upstream Links

- Steam: https://store.steampowered.com/about/
- GE-Proton releases: https://github.com/GloriousEggroll/proton-ge-custom/releases
- ProtonUp-Qt: https://github.com/DavidoTek/ProtonUp-Qt
- Battle.net installer: https://download.battle.net/
- Winetricks: https://github.com/Winetricks/winetricks
- Microsoft Visual C++ Redistributable reference: https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist
- DXVK: https://github.com/doitsujin/dxvk
- vkd3d-proton: https://github.com/HansKristian-Work/vkd3d-proton
- dxvk-nvapi: https://github.com/jp7677/dxvk-nvapi

## Runtime Baseline

For plain Wine prefixes, the observed Battle.net baseline is:

```bash
WINEPREFIX=/path/to/wine-battlenet winetricks -q win10 corefonts vcrun2022
```

The tracked verb list is:

```text
examples/winetricks-runtime.txt
```

Meaning:

- `win10`: sets the Wine Windows version to Windows 10.
- `corefonts`: installs Microsoft core fonts through winetricks. Do not copy
  generated font files into this repository.
- `vcrun2022`: installs the Visual C++ 2015-2022 runtime through winetricks. Do
  not copy generated Microsoft DLLs into this repository.

## GE-Proton Runtime

The recommended path is GE-Proton. On the maintainer baseline,
`GE-Proton10-34` contains these runtime layers locally:

```text
files/lib/wine/dxvk
files/lib/wine/vkd3d-proton
files/lib/wine/nvapi
files/share/wine/mono
files/share/wine/gecko
files/share/wine/fonts
```

They are part of the user's local GE-Proton installation and are not vendored in
this repository.

## Prefix And Installer Policy

`installers/Battle.net-Setup.exe`, `proton-battlenet/`, `wine-*`, `pfx/`, logs,
registry dumps, crash dumps, screenshots, and generated DLL/font files are
ignored by git. Keep them local.

If a Battle.net update breaks the client, rebuild locally from the documented
sources instead of committing binaries:

```bash
./scripts/run-battlenet-ge.sh
```

If the configured prefix has no Battle.net client yet, the launcher starts the
local installer from `BNET_INSTALLER_PATH`.
