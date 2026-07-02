# Installation

## Requirements

- Linux desktop environment.
- Steam installed.
- GE-Proton installed under Steam compatibility tools.
- `curl`, `unzip`, and basic shell tools.
- `vulkaninfo` and `lspci` are recommended for GPU detection.
- `whiptail` is optional for a nicer terminal menu.
- `winetricks`, `cabextract`, and `7z` / `p7zip` are optional when preparing
  plain Wine prefixes.

For a detailed description of the Wine / Proton stack, see
[wine-environment.md](wine-environment.md). For the source list of installers,
runtimes, fonts, and GE-Proton, see [runtime-sources.md](runtime-sources.md).

## Install GE-Proton

Install GE-Proton with your preferred tool, such as ProtonUp-Qt, or place it
under:

```text
~/.steam/debian-installation/compatibilitytools.d/
```

The launcher tries to auto-detect the newest `proton` executable in that
directory. If that fails, set `BNET_PROTON` in `battlenet.env`.

GE-Proton itself is not bundled. Download sources are recorded in
[runtime-sources.md](runtime-sources.md).

## Configure

Copy the example:

```bash
cp examples/battlenet.env.example battlenet.env
```

Edit `battlenet.env` if needed:

```bash
BNET_PROTON="$HOME/.steam/debian-installation/compatibilitytools.d/GE-Proton10-34/proton"
BNET_COMPAT_DATA_PATH="$PWD/proton-battlenet"
```

## Install Battle.net

Download the official Battle.net installer from Blizzard and place it at:

```text
installers/Battle.net-Setup.exe
```

The installer is intentionally ignored by git. Keep it local.

Then run:

```bash
./scripts/run-battlenet-ge.sh
```

If Battle.net is not installed in the configured prefix, the script starts the
installer. After installation, run the script again to start the client.

## Optional Plain Wine Runtime Baseline

For non-Proton Wine prefixes, the observed baseline is:

```bash
WINEPREFIX=/path/to/wine-battlenet winetricks -q win10 corefonts vcrun2022
```

The same verb list is stored in `examples/winetricks-runtime.txt`.
Download/source notes for the generated Microsoft DLLs and fonts are stored in
`docs/runtime-sources.md` and `examples/runtime-sources.txt`.
