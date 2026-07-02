# Installation

## Requirements

- Linux desktop environment.
- Steam installed.
- GE-Proton installed under Steam compatibility tools.
- `curl`, `unzip`, and basic shell tools.
- `vulkaninfo` and `lspci` are recommended for GPU detection.
- `whiptail` is optional for a nicer terminal menu.

## Install GE-Proton

Install GE-Proton with your preferred tool, such as ProtonUp-Qt, or place it
under:

```text
~/.steam/debian-installation/compatibilitytools.d/
```

The launcher tries to auto-detect the newest `proton` executable in that
directory. If that fails, set `BNET_PROTON` in `battlenet.env`.

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

Then run:

```bash
./scripts/run-battlenet-ge.sh
```

If Battle.net is not installed in the configured prefix, the script starts the
installer. After installation, run the script again to start the client.

