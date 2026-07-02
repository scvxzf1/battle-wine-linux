# Wine / Proton 环境说明

[English](wine-environment.md) | [简体中文](wine-environment.zh-CN.md)

本文描述这个启动器期望的 Wine / Proton 运行环境。目标是让别人能复现环境，而不是把一份已经登录过的 Wine prefix、Battle.net 状态或游戏文件发布出去。

## 运行模型

推荐路径是 GE-Proton，而不是直接使用系统 Wine：

```text
Linux 桌面环境
  -> Steam compatibility runtime
    -> GE-Proton proton 脚本
      -> Proton compat data 目录
        -> Wine prefix: $STEAM_COMPAT_DATA_PATH/pfx
          -> C:\Program Files (x86)\Battle.net\Battle.net.exe
```

`examples/run-battlenet-wine.sh` 保留为纯 Wine 参考路径，但主入口是：

```bash
./scripts/run-battlenet-ge.sh
```

## 当前维护环境基线

下面是维护机器和已验证环境的基线。它们不是硬性要求，但很适合用于对照排障：

```text
OS: Ubuntu 24.04.4 LTS
Kernel: Linux 6.17.0-35-generic x86_64
Session: Wayland
Desktop: GNOME / Ubuntu session
Wine package: wine-9.0
GE-Proton: GE-Proton10-34
NVIDIA driver: 580.159.03
已测试 GPU: GTX 960, GTX 1070, RTX 2060, RTX 3080
```

## 主机侧依赖

最低要求：

- 可正常图形加速的 Linux 桌面会话。
- 已安装 Steam。
- 已安装 GE-Proton，并放在 Steam compatibility tools 目录下。
- `curl`、`unzip`、`bash`、`find`、`awk`、`sed` 和 coreutils。

推荐安装：

- `vulkaninfo`：用于发现 DXVK 可见的 GPU。
- `lspci`：GPU 检测的备用来源。
- `nvidia-smi`：确认 NVIDIA GPU 和驱动版本。
- `whiptail`：提供更舒服的终端选择菜单。

准备非 Proton 的纯 Wine prefix 时可选：

- `winetricks`
- `cabextract`
- `7z` / `p7zip`

## Proton 路径

启动器主要使用下面几个路径概念：

```bash
BNET_STEAM_ROOT="$HOME/.steam/debian-installation"
BNET_PROTON="$BNET_STEAM_ROOT/compatibilitytools.d/GE-Proton10-34/proton"
BNET_COMPAT_DATA_PATH="$PWD/proton-battlenet"
```

如果没有设置 `BNET_PROTON`，启动器会搜索：

```text
$BNET_STEAM_ROOT/compatibilitytools.d/*/proton
```

并按版本排序选择最新的 `proton` 路径。

## Compat Data 与 Wine Prefix

`BNET_COMPAT_DATA_PATH` 是 Proton compat data 目录。真正的 Wine prefix 会创建在它下面：

```text
$BNET_COMPAT_DATA_PATH/
  pfx/
    drive_c/
    system.reg
    user.reg
    userdef.reg
```

默认仓库路径下就是：

```text
./proton-battlenet/pfx
```

这个目录会被 git 忽略。它可能包含账号状态、注册表、cookies、缓存、安装器、崩溃 dump 和 Blizzard 客户端文件，不应该发布。

## 运行库与 Winetricks 基线

仓库不会打包微软运行库、字体文件或 Wine prefix 内容。这里记录的是已经验证可用的 Battle.net Wine prefix 运行库基线。下载和获取来源集中记录在 [runtime-sources.zh-CN.md](runtime-sources.zh-CN.md)。

已验证的 winetricks 基线是：

```text
win10
corefonts
vcrun2022
```

同样的清单放在：

```text
examples/winetricks-runtime.txt
```

上游/来源清单放在：

```text
examples/runtime-sources.txt
```

含义：

- `win10`：把 Wine 的 Windows 版本设为 Windows 10。
- `corefonts`：安装常见 Microsoft 核心字体。实际 `winetricks.log` 里可能展开成 `andale`、`arial`、`comicsans`、`courier`、`georgia`、`impact`、`times`、`trebuchet`、`verdana`、`webdings`。
- `vcrun2022`：安装 Visual C++ 2015-2022 运行库，很多现代 Windows 程序都会依赖它。

纯 Wine prefix 的等价准备命令：

```bash
WINEPREFIX=/path/to/wine-battlenet winetricks -q win10 corefonts vcrun2022
```

Proton prefix 优先使用 GE-Proton 自带运行层。如果你要对 Proton prefix 使用 winetricks/protontricks，把它当作高级操作，先备份 prefix。

## GE-Proton 自带运行层

GE-Proton 本身已经附带了很多关键运行层。在当前维护基线 `GE-Proton10-34` 中可见：

```text
files/lib/wine/dxvk
files/lib/wine/vkd3d-proton
files/lib/wine/nvapi
files/share/wine/mono
files/share/wine/gecko
files/share/wine/fonts
```

这些内容不会复制进本仓库，它们属于用户本机安装的 GE-Proton。

## Battle.net 客户端路径

默认 Battle.net 可执行文件路径是：

```text
$BNET_COMPAT_DATA_PATH/pfx/drive_c/Program Files (x86)/Battle.net/Battle.net.exe
```

如果你的 Battle.net 装在别处，可以覆盖：

```bash
BNET_EXE_PATH="/custom/prefix/pfx/drive_c/Program Files (x86)/Battle.net/Battle.net.exe"
```

如果客户端不存在，但 `BNET_INSTALLER_PATH` 指向的安装器存在，启动器会先运行安装器。

## 首次运行流程

1. 启动器读取 `battlenet.env`。
2. 解析或自动发现 GE-Proton 路径。
3. 设置 Proton compatibility 变量：

```bash
STEAM_COMPAT_CLIENT_INSTALL_PATH="$BNET_STEAM_ROOT"
STEAM_COMPAT_DATA_PATH="$BNET_COMPAT_DATA_PATH"
PROTON_USE_XALIA=0
```

4. 应用 GPU 和 DXVK 相关环境变量。
5. 如果 Battle.net 已存在，直接启动客户端。
6. 如果 Battle.net 不存在但安装器存在，启动安装器。
7. 如果两者都不存在，打印安装器应放置的位置并退出。

## 图形栈与 GPU 选择

启动器主要面向 DXVK / Vulkan 环境。GPU 选择不是绑定 PCI ID，而是设置 DXVK 可见的设备名：

```bash
DXVK_FILTER_DEVICE_NAME="NVIDIA GeForce RTX 3080"
```

选择 NVIDIA GPU 时，还会设置 PRIME offload 相关变量：

```bash
__NV_PRIME_RENDER_OFFLOAD=1
__GLX_VENDOR_LIBRARY_NAME=nvidia
__VK_LAYER_NV_optimus=NVIDIA_only
DXVK_ENABLE_NVAPI=1
```

默认性能变量：

```bash
DXVK_STATE_CACHE=1
DXVK_ASYNC=1
PROTON_NO_ESYNC=0
PROTON_NO_FSYNC=0
```

如果想关闭这些默认优化：

```bash
BNET_PERFORMANCE_MODE=off
```

## Xalia

默认设置：

```bash
PROTON_USE_XALIA=0
```

这是为了规避在某些 Wayland / 桌面环境下，从 Steam UI 之外启动 Proton 时 Xalia 可能导致的崩溃。

## 网络与代理

启动器不会直接管理代理。如果你的 Battle.net 区域或网络环境需要代理，在启动前设置标准代理变量：

```bash
export http_proxy=http://127.0.0.1:7890
export https_proxy=http://127.0.0.1:7890
export all_proxy=socks5://127.0.0.1:7890
```

不要提交真实代理账号或密码。

## 环境报告

排障时运行：

```bash
./tools/collect-env-report.sh
```

报告会包含 OS、内核、桌面会话、关键命令是否存在、Wine / Proton 路径、compat data 是否存在和 GPU 摘要。它会刻意避开注册表 dump、token、cookies、Battle.net 账号状态和完整 prefix 文件列表。

它还会报告 `winetricks` 是否可用、prefix 内是否存在 `winetricks.log`，以及 GE-Proton 自带的 DXVK / vkd3d-proton / nvapi / mono / gecko 目录是否存在。

## 永远不应该发布的内容

不要发布：

- `proton-battlenet/`
- `wine-*` prefix
- `pfx/`
- `system.reg`、`user.reg`、`userdef.reg`
- Battle.net 安装器
- Blizzard 游戏文件
- 带账号信息的截图
- 日志或崩溃 dump
- 带密码的代理配置
- cookies、token 或登录状态
