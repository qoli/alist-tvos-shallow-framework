# OpenList tvOS 框架構建項目

## 🎯 項目概述

這是一個完整的、自動化的 OpenList tvOS 框架構建解決方案，支援在任何全新 macOS 環境中一鍵構建 tvOS 框架。

## ✅ 成功解決的關鍵問題

### 1. **golang.org/x/mobile/bind 錯誤**
- **問題**: `no Go package in golang.org/x/mobile/bind` 
- **根本原因**: OpenList v4 項目缺少 `golang.org/x/mobile` 依賴
- **解決方案**: 添加正確版本的依賴 `golang.org/x/mobile@v0.0.0-20241213221354-a87c1cf6cf46`

### 2. **gopsutil 函數重複聲明錯誤**
- **問題**: `VirtualMemory redeclared` 等 CGO/非CGO 函數衝突
- **根本原因**: 構建標籤邏輯錯誤 (`|| ios` 條件導致衝突)
- **解決方案**: 恢復簡單構建標籤 `//go:build darwin && !cgo`

### 3. **tvOS 目標支援**
- **工具**: 使用 `protonjohn/gomobile` fork 提供 tvOS 支援
- **目標平台**: `appletvos`, `appletvsimulator`
- **框架結構**: 淺層結構 (Shallow Bundle)

## 🚀 構建腳本

### 主構建腳本 `setup_and_build_tvos.sh`
完整的環境設置與構建腳本，適用於全新環境：

```bash
./setup_and_build_tvos.sh
```

**功能包括**:
- ✅ Go 環境檢查與設置
- ✅ 依賴管理 (golang.org/x/mobile)
- ✅ protonjohn/gomobile 自動安裝
- ✅ gopsutil 構建標籤驗證
- ✅ tvOS 框架構建與驗證

### 快速構建腳本 `build_tvos_quick.sh`
日常使用的快速構建腳本：

```bash
./build_tvos_quick.sh              # 普通構建
./build_tvos_quick.sh --update-web # 包含前端更新
```

## 📦 構建輸出

成功構建生成 `Alistlib.xcframework` (約 408MB)：

```
Alistlib.xcframework/
├── Info.plist
├── tvos-arm64/                    # tvOS 真機
│   └── Alistlib.framework/
└── tvos-arm64_x86_64-simulator/   # tvOS 模擬器
    └── Alistlib.framework/
```

## 🛠️ 技術規格

- **Go 版本**: 1.22+
- **工具鏈**: protonjohn/gomobile 
- **框架類型**: tvOS 淺層框架 (Shallow Bundle)
- **支援平台**: tvOS 真機 + 模擬器
- **Bundle ID**: com.openlist.tvos

## 📚 相關文件

- `BUILD_INSTRUCTIONS.md` - 詳細構建說明
- `setup_and_build_tvos.sh` - 完整環境設置腳本  
- `build_tvos_quick.sh` - 快速構建腳本
- `quick_build.sh` - 舊版快速構建 (已修復)

## 🔧 故障排除

所有常見問題的解決方案都已整合到自動化腳本中：

1. **缺少 gomobile**: 自動安裝 protonjohn/gomobile
2. **依賴錯誤**: 自動添加 golang.org/x/mobile 依賴  
3. **構建標籤衝突**: 自動驗證並提示修復
4. **環境配置**: 自動設置 GOBIN 和 PATH

## 🎉 使用方法

### 首次構建或環境重置
```bash
./setup_and_build_tvos.sh
```

### 日常構建  
```bash
./build_tvos_quick.sh
```

### 在 Xcode 中使用
1. 將生成的 `Alistlib.xcframework` 拖入 tvOS 項目
2. 在 Target 設置中選擇 "Embed & Sign"  
3. 在代碼中 `import Alistlib`

## 🏆 成功案例

✅ **測試環境**: macOS 14.x, Go 1.24.2, Xcode 26.0  
✅ **構建時間**: 約 2-3 分鐘 (首次), 約 1 分鐘 (增量)  
✅ **框架大小**: ~408MB  
✅ **支援架構**: ARM64 (真機 + 模擬器)  

## 📄 版本歷史

- **v1.0** (2025-08-21): 完整自動化構建解決方案
  - 解決 golang.org/x/mobile/bind 錯誤
  - 修復 gopsutil 構建標籤衝突  
  - 整合 protonjohn/gomobile tvOS 支援
  - 提供完整的環境設置自動化

---

**此項目提供了在任何 macOS 環境中可靠構建 OpenList tvOS 框架的完整解決方案。** 🚀