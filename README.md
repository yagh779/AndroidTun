# AndroidTun Magisk / KernelSU / APatch

![GitHub downloads](https://img.shields.io/github/downloads/yagh779/AndroidTun/total?logo=github&logoColor=white&color=ffd166)
[![Join Telegram Channel](https://img.shields.io/badge/Telegram-Join%20Channel-06d6a0?logo=telegram&logoColor=white)](https://t.me/AndroidTunChat)
[![Join Telegram Group](https://img.shields.io/badge/Telegram-Join%20Group-118ab2?logo=telegram&logoColor=white)](https://t.me/AndroidTun)

关注我们的频道获取最新消息，或加入我们的群组进行讨论！ 

## 简介

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

**注意**：

- 模块默认提供的 `mihomo` 核心：[mihomo](https://github.com/MetaCubeX/mihomo)
- 模块默认提供的 `sing-box` 核心：[sing-box-reF1nd](https://github.com/reF1nd/sing-box)

核心位置位于 `/data/adb/atun/bin/` ，或者也可手动下载对应设备架构的核心可执行文件，放置到 `/data/adb/atun/bin/` 目录下。

## 配置

### 选择代理核心

#### 核心目录
核心工作目录：`/data/adb/atun/<核心名字>`  
核心由 `/data/adb/atun/scripts/config.sh` 中的 `bin_name` 决定，可选值：

- `sing-box`
- `mihomo`（默认）

**提示**：`mihomo` 和 `sing-box` 自带默认配置文件，已预设好与透明代理配合（您也可以在 [exampleConfig](https://github.com/yagh779/exampleConfig) 获取单独的预设配置文件）。建议直接编辑 `proxy-providers` 或 `outbounds` 部分添加您的节点。  
进阶配置请参考官方文档：

- [mihomo](https://wiki.metacubex.one)
- [sing-box-reF1nd](https://sing-boxr.dustinwin.cc.cd)

模块会自动检查配置文件合法性，结果保存在 `/data/adb/atun/run/check.log`。

#### 配置文件

核心配置文件：`/data/adb/atun/scripts/config.sh`   
核心热点转发由 `/data/adb/atun/scripts/config.sh` 中的 `tun_device` 决定，请确保该值与你的配置一致，否则无法正确代理热点。

## 使用方法

### 常规使用（推荐）

- 服务默认开机自启。
- 通过 Magisk / KernelSU / APatch Manager **启用/禁用模块** 即可实时启停服务（无需重启设备）。

### 手动模式

手动命令：
  - 服务：`/data/adb/atun/scripts/service.sh start|stop|restart|status`

## 其他说明

- 日志位于 `/data/adb/atun/run/` 目录。
- 对应核心目录下有 `status.sh` 可直接运行查看模块运行状态。

## 卸载

- 从 Magisk Manager，KernelSU Manager 或 APatch 应用卸载本模块，会删除 `/data/adb/service.d/atun_service.sh` 文件，保留 atun 数据目录 `/data/adb/atun`
- 可使用命令清除 Box 数据：`rm -rf /data/adb/atun`

## 更新日志

[CHANGELOG](changelog.md)

## 致谢

- 模块完全基于 [box4magisk](https://github.com/CHIZI-0618/box4magisk) 来的
- 代码贡献度 [e5](https://github.com/CHIZI-0618) 占比 ___100%___
- 感谢伟大的 [box4magisk](https://github.com/CHIZI-0618/box4magisk)
