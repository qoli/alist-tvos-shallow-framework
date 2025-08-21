# OpenList tvOS 構建說明

## 概述

這個項目提供了自動化構建 OpenList tvOS 框架的完整解決方案，支持在全新 macOS 環境中一鍵構建。

## 前置條件

- **macOS**: macOS 10.15+ (推薦 macOS 12+)
- **Xcode**: 已安裝 Xcode 命令行工具或完整 Xcode
- **Go**: Go 1.22+ (腳本會自動檢查)

## 構建腳本

### 1. 完整環境設置與構建 `setup_and_build_tvos.sh`

**適用於**: 全新環境、首次構建、環境重置

```bash
# 一鍵完整構建
./setup_and_build_tvos.sh
```

**功能**:
- ✅ 檢查 Go 環境和版本
- ✅ 設置 Go 環境變量 (GOBIN, PATH)
- ✅ 添加必要的 `golang.org/x/mobile` 依賴
- ✅ 安裝 `protonjohn/gomobile` (支持 tvOS)
- ✅ 驗證 gopsutil 構建標籤
- ✅ 構建 tvOS 框架
- ✅ 驗證構建結果

### 2. 快速構建 `build_tvos_quick.sh`

**適用於**: 已設置環境的日常構建

```bash
# 快速構建
./build_tvos_quick.sh

# 帶前端更新的構建
./build_tvos_quick.sh --update-web
```

**功能**:
- 🚀 快速環境檢查
- 🧹 清理舊框架
- 🔨 構建 tvOS 框架
- 📊 顯示構建結果

## 構建輸出

成功構建後會生成 `Alistlib.xcframework`，包含：

```
Alistlib.xcframework/
├── Info.plist
├── tvos-arm64/                    # tvOS 真機 (ARM64)
│   └── Alistlib.framework/
│       ├── Alistlib               # 二進制文件
│       ├── Headers/               # 頭文件
│       ├── Info.plist
│       └── Modules/
└── tvos-arm64_x86_64-simulator/   # tvOS 模擬器 (ARM64 + x86_64)
    └── Alistlib.framework/
        ├── Alistlib
        ├── Headers/
        ├── Info.plist
        └── Modules/
```

## 技術規格

- **架構**: tvOS 淺層框架結構 (Shallow Bundle)
- **目標平台**: `appletvos`, `appletvsimulator`
- **工具鏈**: `protonjohn/gomobile` (支持 tvOS)
- **Go 模組**: `golang.org/x/mobile@v0.0.0-20241213221354-a87c1cf6cf46`
- **Bundle ID**: `com.openlist.tvos`

## 故障排除

### 1. "gomobile 不支持 tvOS"

```bash
# 重新運行完整設置
./setup_and_build_tvos.sh
```

### 2. "golang.org/x/mobile/bind 找不到"

這通常表示缺少 `golang.org/x/mobile` 依賴：

```bash
# 手動添加依賴
go get golang.org/x/mobile@v0.0.0-20241213221354-a87c1cf6cf46

# 或重新運行完整設置
./setup_and_build_tvos.sh
```

### 3. "函數重複聲明" 錯誤

這表示 gopsutil 構建標籤有問題，腳本會自動檢查並提示修復。

### 4. Go 版本過低

```bash
# 檢查 Go 版本
go version

# 需要 Go 1.22+，請從官網下載更新
# https://golang.org/dl/
```

## 使用框架

將生成的 `Alistlib.xcframework` 拖入你的 Xcode tvOS 項目中：

1. 在 Xcode 中打開你的 tvOS 項目
2. 將 `Alistlib.xcframework` 拖到項目導航器中
3. 在 "Embed & Sign" 中添加框架
4. 在代碼中導入: `import Alistlib`

## 開發貢獻

如果需要修改構建配置：

- 主構建腳本: `setup_and_build_tvos.sh`
- 快速構建: `build_tvos_quick.sh`
- Go 模組: `go.mod`
- gopsutil 配置: `gopsutil/` 目錄

## 版本信息

- **腳本版本**: 1.0
- **創建日期**: 2025-08-21
- **支持的 OpenList 版本**: v4.x
- **測試環境**: macOS 14.x, Go 1.24.2, Xcode 26.0