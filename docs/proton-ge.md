# GE-Proton Notes

The main launcher uses Proton outside Steam by setting:

```bash
STEAM_COMPAT_CLIENT_INSTALL_PATH
STEAM_COMPAT_DATA_PATH
```

`STEAM_COMPAT_DATA_PATH` becomes the Proton compat data directory. The actual
Wine prefix lives under:

```text
$STEAM_COMPAT_DATA_PATH/pfx
```

By default, the launcher uses:

```text
./proton-battlenet
```

This directory is ignored by git.

## Xalia

`PROTON_USE_XALIA=0` is the default because Xalia can crash under some
non-Steam desktop launches.

