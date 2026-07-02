# Battle.net Wine Launcher

[English](README.md) | [简体中文](README.zh-CN.md)

这是一个面向 Linux 的 Battle.net 启动脚手架，用于通过 Wine 或 GE-Proton 启动 Battle.net。

仓库只包含脚本、示例配置和文档。它不会附带 Battle.net、本地游戏文件、Wine prefix、登录状态、代理配置或任何游戏插件逻辑。

## 这个仓库是什么

- 基于 GE-Proton 的 Battle.net 启动器。
- 面向 DXVK / NVIDIA PRIME 多显卡环境的 GPU 选择工具。
- 一个纯 Wine 启动示例。
- 一个用于排障的安全环境报告工具。

## 这个仓库不是什么

- 不是 Battle.net 镜像。
- 不是游戏安装包合集。
- 不包含任何 Blizzard 二进制文件。
- 不包含 Wine / Proton prefix。
- 不包含 Hearthstone 或 HsMod 插件逻辑。

## 已测试硬件

这套启动环境已经在 NVIDIA GTX 960、GTX 1070、RTX 2060、RTX 3080 上测试过。当前维护机器使用的 NVIDIA 驱动版本是 `580.159.03`。

## Wine / Proton 环境

主路径使用 GE-Proton，并使用独立的 compat data 目录。真正的 Wine prefix 位于：

```text
$BNET_COMPAT_DATA_PATH/pfx
```

当前维护环境基线是 Ubuntu 24.04.4 LTS、Wayland / GNOME、Wine `9.0`、GE-Proton `GE-Proton10-34`、NVIDIA 驱动 `580.159.03`。

详细运行模型、prefix 结构、环境变量、GPU 图形栈和开源安全边界见：

[docs/wine-environment.zh-CN.md](docs/wine-environment.zh-CN.md)

安装器、运行库、字体和 GE-Proton 的官方/上游来源清单见：

[docs/runtime-sources.zh-CN.md](docs/runtime-sources.zh-CN.md)

已验证的可选 winetricks 运行库基线是：

```text
win10
corefonts
vcrun2022
```

## 目录结构

```text
scripts/
  run-battlenet-ge.sh              GE-Proton 主启动脚本
  run-battlenet-ge-select-gpu.sh   强制打开 GPU 选择器的兼容入口
  lib/gpu-select.sh                GPU 检测与 DXVK 环境变量辅助脚本

examples/
  battlenet.env.example            本地配置模板
  proxy.env.example                可选代理环境变量模板
  winetricks-runtime.txt           可选 Wine 运行库基线
  runtime-sources.txt              上游获取来源文本清单
  run-battlenet-wine.sh            纯 Wine 启动示例

tools/
  collect-env-report.sh            安全环境报告工具

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

## 快速开始

1. 安装 Steam 和 GE-Proton。来源链接记录在 [docs/runtime-sources.zh-CN.md](docs/runtime-sources.zh-CN.md)。
2. 复制配置模板：

```bash
cp examples/battlenet.env.example battlenet.env
```

3. 如果自动检测不到 Proton 路径，编辑 `battlenet.env`。
4. 从 Blizzard 官方下载 Battle.net 安装器，并放到：

```text
installers/Battle.net-Setup.exe
```

5. 启动：

```bash
./scripts/run-battlenet-ge.sh
```

如果配置的 Proton compat data 目录中还没有 Battle.net，首次运行会启动安装器。安装完成后，再运行同一个脚本即可启动 Battle.net 客户端。

## 环境报告

排障时运行：

```bash
./tools/collect-env-report.sh
```

这个报告会避免输出注册表 dump、cookies、token、Battle.net 账号信息和完整 prefix 文件列表。

## 安全边界

不要提交 `battlenet.env`、Wine prefix、安装器、截图、日志、代理配置或崩溃 dump。仓库里的 `.gitignore` 会尽量保守地拦住这些文件。

## 许可证

MIT。详见 [LICENSE](LICENSE)。
