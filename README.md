# AndroidTun / KernelSU / APatch

本项目是一个 Magisk / KernelSU / APatch 模块，用于在 Android 设备上部署多种代理核心，包括 **mihomo**、**sing-box**。

支持的透明代理模式：
- **TUN**：TCP + UDP（由核心提供，仅 sing-box、mihomo 支持）

## 免责声明

本项目不对设备变砖、数据损坏或其他硬件/软件问题负责。

**重要警告**：请确保您的配置文件不会导致流量回环，否则可能引起设备无限重启！

如果您不熟悉代理配置，建议先使用用户友好的应用（如 ClashForAndroid、sing-box for Android、v2rayNG、SagerNet 等）学习基本概念。

## 安装

1. 从 [Releases](https://github.com/yagh779/AndroidTun/releases) 下载最新模块 ZIP 包。
2. 在 Magisk Manager、KernelSU Manager 或 APatch Manager 中安装。
3. 支持在线更新（更新后重启即可生效）。

配置项请参照 [box4magisk](https://github.com/CHIZI-0618/box4magisk)
  
## 使用方法

### 常规使用（推荐）

- 服务默认开机自启。
- 通过 Magisk / KernelSU / APatch Manager **启用/禁用模块** 即可实时启停服务（无需重启设备）。

#### 仅使用核心原生 TUN

## 卸载

- 从 Magisk Manager，KernelSU Manager 或 APatch 应用卸载本模块，会删除 `/data/adb/service.d/atun_service.sh` 文件，保留 atun 数据目录 `/data/adb/atun`
- 可使用命令清除 Box 数据：`rm -rf /data/adb/atun`

## 更新日志

[CHANGELOG](changelog.md)
