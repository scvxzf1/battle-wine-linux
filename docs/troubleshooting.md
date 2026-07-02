# Troubleshooting

Start with the environment model in [wine-environment.md](wine-environment.md)
when you need to compare another machine with the known working baseline.

## Battle.net Installer Does Not Start

Check:

```bash
./tools/collect-env-report.sh
```

Then verify:

- `BNET_PROTON` points to an executable `proton`.
- `BNET_COMPAT_DATA_PATH` is writable.
- `Battle.net-Setup.exe` exists at `BNET_INSTALLER_PATH`.

## Battle.net Is Installed But Not Found

Set the exact path:

```bash
BNET_EXE_PATH="/path/to/proton-battlenet/pfx/drive_c/Program Files (x86)/Battle.net/Battle.net.exe"
```

## Wrong GPU Is Used

Run interactively and choose the GPU, or set:

```bash
GPU_SELECT_DEFAULT="exact GPU name from vulkaninfo"
```

## Login Or Region Problems

If your network requires a proxy, source a local proxy env file before launch.
Do not commit proxy credentials.

```bash
source ./my-proxy.env
./scripts/run-battlenet-ge.sh
```
