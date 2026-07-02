# 运行库来源清单

[English](runtime-sources.md) | [简体中文](runtime-sources.zh-CN.md)

这个仓库刻意不打包微软运行库 DLL、微软字体文件、Battle.net 安装器、GE-Proton 包、Wine prefix 或任何生成出来的 compat data。这些文件应该由用户在本机下载、安装或生成。

仓库负责保留的是可复现的来源清单和命令基线。

## 来源清单

| 组件 | 获取方式 | 是否放入本仓库 |
| --- | --- | --- |
| Steam | 从 Steam 官方下载页或发行版包管理器安装。 | 否 |
| GE-Proton | 从 GE-Proton releases 获取，通常通过 ProtonUp-Qt 安装到 Steam compatibility tools。 | 否 |
| Battle.net 安装器 | 从 Blizzard 官方 Battle.net 下载页获取，并放到 `installers/Battle.net-Setup.exe`。 | 否 |
| Wine prefix / Proton compat data | 由 Wine 或 Proton 在 `$BNET_COMPAT_DATA_PATH/pfx` 本地生成。 | 否 |
| Microsoft Visual C++ 运行库 DLL | 纯 Wine prefix 使用 `winetricks vcrun2022` 安装。Microsoft Visual C++ Redistributable 页面只作为上游参考。 | 否 |
| Microsoft 核心字体 | 纯 Wine prefix 使用 `winetricks corefonts` 安装。 | 否 |
| Wine Mono / Gecko | 优先使用 GE-Proton 自带副本。纯 Wine 场景下，让 Wine 按提示安装，或使用发行版软件包。 | 否 |
| DXVK / vkd3d-proton / dxvk-nvapi | 优先使用 GE-Proton 自带副本。上游项目用于排障参考，不要求本启动器单独下载。 | 否 |
| 宿主机解包工具 | 准备纯 Wine prefix 时，通过发行版包管理器安装 `winetricks`、`cabextract` 和 `7z` / `p7zip` 提供者。 | 否 |

同样的精简文本清单放在：

```text
examples/runtime-sources.txt
```

## 官方与上游链接

- Steam: https://store.steampowered.com/about/
- GE-Proton releases: https://github.com/GloriousEggroll/proton-ge-custom/releases
- ProtonUp-Qt: https://github.com/DavidoTek/ProtonUp-Qt
- Battle.net 安装器: https://download.battle.net/
- Winetricks: https://github.com/Winetricks/winetricks
- Microsoft Visual C++ Redistributable 参考: https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist
- DXVK: https://github.com/doitsujin/dxvk
- vkd3d-proton: https://github.com/HansKristian-Work/vkd3d-proton
- dxvk-nvapi: https://github.com/jp7677/dxvk-nvapi

## 运行库基线

纯 Wine prefix 已验证的 Battle.net 基线是：

```bash
WINEPREFIX=/path/to/wine-battlenet winetricks -q win10 corefonts vcrun2022
```

已跟踪的 winetricks verb 清单是：

```text
examples/winetricks-runtime.txt
```

含义：

- `win10`：把 Wine 的 Windows 版本设为 Windows 10。
- `corefonts`：通过 winetricks 安装 Microsoft 核心字体。不要把生成出来的字体文件复制进仓库。
- `vcrun2022`：通过 winetricks 安装 Visual C++ 2015-2022 运行库。不要把生成出来的 Microsoft DLL 复制进仓库。

## GE-Proton 自带运行层

推荐路径是 GE-Proton。在当前维护基线 `GE-Proton10-34` 中，本机可见这些运行层：

```text
files/lib/wine/dxvk
files/lib/wine/vkd3d-proton
files/lib/wine/nvapi
files/share/wine/mono
files/share/wine/gecko
files/share/wine/fonts
```

它们属于用户本机安装的 GE-Proton，不会 vendoring 到这个仓库里。

## Prefix 与安装器策略

`installers/Battle.net-Setup.exe`、`proton-battlenet/`、`wine-*`、`pfx/`、日志、注册表 dump、崩溃 dump、截图，以及生成出来的 DLL/字体文件都被 git 忽略，只保留在本机。

如果 Battle.net 更新后客户端损坏，按文档来源在本机重建，不提交二进制文件：

```bash
./scripts/run-battlenet-ge.sh
```

如果配置的 prefix 内还没有 Battle.net 客户端，启动器会从 `BNET_INSTALLER_PATH` 指向的本地安装器开始安装。
