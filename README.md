# OpenList tvOS Framework

🚀 **OpenList tvOS Framework** 是一個基於 [OpenList v4](https://github.com/OpenListTeam/OpenList) 項目的 tvOS 原生框架，為 Apple TV 提供完整的文件服務器功能。

## ✨ 特性

- 🎯 **原生 tvOS 支持** - 專為 Apple TV 平台優化
- 📱 **真設備 + 模擬器** - 支持 tvOS 真實設備和模擬器
- 🔧 **完全自動化** - 一鍵構建和配置
- 🏗️ **XCFramework** - 現代化的框架分發格式
- 🔄 **持續更新** - 包含最新 OpenList-Frontend

## 🎯 項目背景

本項目將原 alist-ios 專案完全遷移到 **OpenList v4**，使用真正的 OpenList 源碼構建 tvOS 框架。

### 核心改進

- ✅ **後端完全遷移** - 從 `alist/v3` 遷移到 `OpenList/v4`
- ✅ **前端完全遷移** - 從 `alist-web` 遷移到 `OpenList-Frontend`
- ✅ **tvOS 原生支持** - 使用 protonjohn/gomobile 支持 tvOS 平台
- ✅ **兼容性修復** - 解決 gopsutil 等依賴庫的 tvOS 兼容性問題
- ✅ **自動化構建** - 提供完整的自動化構建腳本

## 🚀 快速開始

### 系統要求

- macOS (必需)
- Xcode 14.0+
- Go 1.22+

### 一鍵構建

```bash
# 克隆項目
git clone <repository-url>
cd alist-ios-tvos-shallow-framework

# 首次構建或環境重置
./setup_and_build_tvos.sh

# 日常構建
./build_tvos_quick.sh

# 包含前端更新的構建
./build_tvos_quick.sh --update-web
```

## 📋 構建腳本說明

### 🔧 主要腳本

#### `setup_and_build_tvos.sh` - 完整環境設置
**適用於**: 首次構建、全新環境、環境重置

功能包括:
- ✅ 檢查 Go 環境和版本 (需要 Go 1.22+)
- ✅ 設置 Go 環境變量 (GOBIN, PATH)
- ✅ 添加必要的 `golang.org/x/mobile` 依賴
- ✅ 安裝 `protonjohn/gomobile` (支持 tvOS)
- ✅ 更新前端資源 (OpenList-Frontend)
- ✅ 驗證 gopsutil tvOS 支持
- ✅ 構建 tvOS 框架
- ✅ 驗證構建結果

#### `build_tvos_quick.sh` - 日常快速構建
**適用於**: 已配置環境的日常構建

功能包括:
- 🚀 快速環境檢查
- 🔧 自動修復缺失的依賴
- 🧹 清理舊框架
- 🔨 構建 tvOS 框架
- 📊 顯示構建結果

### 🛠️ 輔助腳本

- `fetch-web.sh` - 更新 OpenList-Frontend 前端資源
- `cleanup.sh` - 清理項目中不必要的文件

## 🔧 技術架構

### 核心組件

- **OpenList v4** - 主要的文件服務器核心
- **protonjohn/gomobile** - 支持 tvOS 的 Go 移動開發工具
- **alistlib** - 封裝的 tvOS 原生接口層
- **gendago/gopsutil** - 官方 tvOS 支持版本

### 框架結構

```
Alistlib.xcframework/
├── Info.plist                           # 框架元數據
├── tvos-arm64/                          # tvOS 設備版本 (ARM64)
│   └── Alistlib.framework/
│       ├── Alistlib                     # 二進制文件
│       ├── Headers/                     # 頭文件
│       │   ├── Alistlib.h
│       │   ├── Alistlib.objc.h
│       │   └── ref.h
│       └── Modules/                     # 模塊映射
└── tvos-arm64_x86_64-simulator/         # tvOS 模擬器版本 (ARM64 + x86_64)
    └── Alistlib.framework/
        └── ...
```

### 技術規格

- **架構**: tvOS 淺層框架結構 (Shallow Bundle)
- **目標平台**: `appletvos`, `appletvsimulator`  
- **工具鏈**: `protonjohn/gomobile` (支持 tvOS)
- **Go 模組**: `golang.org/x/mobile@v0.0.0-20241213221354-a87c1cf6cf46`
- **Bundle ID**: `com.openlist.tvos`
- **框架大小**: ~408MB

## 🎯 Xcode 集成

### 1. 添加框架

將 `Alistlib.xcframework` 拖入你的 Xcode 項目，並在：
**General** → **Frameworks, Libraries, and Embedded Content** 中選擇 **Embed & Sign**

### 2. 導入頭文件

```objc
#import <Alistlib/Alistlib.h>
```

### 3. 基本使用

```objc
// 初始化
NSError *error;
BOOL success = AlistlibInit(eventHandler, logCallback, &error);
if (!success) {
    NSLog(@"初始化失败: %@", error.localizedDescription);
    return;
}

// 配置服務器
AlistlibSetConfigData(@"/path/to/data");
AlistlibSetConfigDebug(YES);
AlistlibSetAdminPassword(@"your_password");

// 啟動服務器
AlistlibStart();

// 檢查運行狀態
BOOL isRunning = AlistlibIsRunning(@"http");
NSLog(@"服務器運行狀態: %@", isRunning ? @"運行中" : @"已停止");

// 關閉服務器
AlistlibShutdown(5000, &error); // 5秒超時
```

### 4. 事件處理

```objc
// 實現事件回調
@interface AppEventHandler : NSObject <AlistlibEvent>
@end

@implementation AppEventHandler
- (void)onProcessExit:(long)code {
    NSLog(@"進程退出，代碼: %ld", code);
}

- (void)onShutdown:(NSString *)type {
    NSLog(@"服務器關閉: %@", type);
}

- (void)onStartError:(NSString *)type err:(NSString *)error {
    NSLog(@"啟動錯誤 [%@]: %@", type, error);
}
@end

// 實現日誌回調
@interface AppLogCallback : NSObject <AlistlibLogCallback>
@end

@implementation AppLogCallback
- (void)onLog:(int16_t)level time:(int64_t)time message:(NSString *)message {
    NSLog(@"[Level:%d] %@", level, message);
}
@end
```

## 🔧 故障排除

### 解決的關鍵問題

#### 1. `golang.org/x/mobile/bind` 錯誤
- **問題**: `no Go package in golang.org/x/mobile/bind`
- **根本原因**: OpenList v4 項目缺少 `golang.org/x/mobile` 依賴
- **解決方案**: 腳本自動添加正確版本依賴

#### 2. gopsutil 函數重複聲明
- **問題**: `VirtualMemory redeclared` 等 CGO/非CGO 函數衝突
- **根本原因**: 構建標籤邏輯錯誤導致衝突
- **解決方案**: 使用 gendago/gopsutil 官方 tvOS 支持版本

#### 3. tvOS 平台支持
- **工具**: protonjohn/gomobile fork 提供 tvOS 支援
- **目標**: 正確的 `appletvos`, `appletvsimulator` 目標

### 常見問題

1. **"gomobile 不支持 tvOS"**
   ```bash
   # 重新運行完整設置
   ./setup_and_build_tvos.sh
   ```

2. **"golang.org/x/mobile/bind 找不到"**
   ```bash
   # 腳本會自動修復，或手動添加
   go get golang.org/x/mobile@v0.0.0-20241213221354-a87c1cf6cf46
   ```

3. **Go 版本過低**
   ```bash
   # 檢查版本 (需要 Go 1.22+)
   go version
   # 請從 https://golang.org/dl/ 更新
   ```

### 調試技巧

```bash
# 詳細構建日誌
gomobile bind -v -target appletvos,appletvsimulator ...

# 檢查模塊狀態
go mod graph | grep OpenList
go list -m all | grep OpenList

# 驗證框架
lipo -info Alistlib.xcframework/tvos-arm64/Alistlib.framework/Alistlib

# 檢查淺層結構
ls -la Alistlib.xcframework/tvos-arm64/Alistlib.framework/
```

## 📚 API 文檔

### 核心函數

| 函數 | 說明 |
|------|------|
| `AlistlibInit()` | 初始化框架 |
| `AlistlibStart()` | 啟動服務器 |
| `AlistlibShutdown()` | 關閉服務器 |
| `AlistlibIsRunning()` | 檢查運行狀態 |
| `AlistlibGetAdminToken()` | 獲取管理員令牌 |
| `AlistlibSetConfigData()` | 設置數據目錄 |

### 配置函數

| 函數 | 說明 |
|------|------|
| `AlistlibSetAdminPassword()` | 設置管理員密碼 |
| `AlistlibSetConfigDebug()` | 設置調試模式 |
| `AlistlibSetConfigLogStd()` | 設置標準日誌輸出 |
| `AlistlibSetConfigNoPrefix()` | 設置無前綴模式 |

## 🔄 版本管理

### 更新到新版本

```bash
# 更新 OpenList 依賴
go get github.com/OpenListTeam/OpenList/v4@latest
go mod tidy

# 重新構建
./build_tvos_quick.sh
```

### 更新前端資源

```bash
# 單獨更新前端
./fetch-web.sh

# 構建時自動更新前端
./build_tvos_quick.sh --update-web
```

## 🏆 成功案例

✅ **測試環境**: macOS 14.x, Go 1.24.2, Xcode 26.0  
✅ **構建時間**: 約 10-15 分鐘 (首次), 約 2-3 分鐘 (日常)  
✅ **框架大小**: ~408MB  
✅ **支援架構**: ARM64 (真機 + 模擬器)  
✅ **自動化程度**: 100% 全自動構建

## 🤝 貢獻

歡迎提交 Issue 和 Pull Request！

### 開發環境設置

1. Fork 本項目
2. 創建功能分支
3. 進行修改
4. 測試構建
5. 提交 PR

## 📄 許可證

本項目遵循 OpenList 項目的許可證。

## 🔗 相關鏈接

- [OpenList 官方倉庫](https://github.com/OpenListTeam/OpenList)
- [OpenList-Frontend](https://github.com/OpenListTeam/OpenList-Frontend)
- [protonjohn/gomobile](https://github.com/protonjohn/gomobile)
- [gendago/gopsutil tvOS 分支](https://github.com/gendago/gopsutil/tree/tvos)
- [tvOS 開發文檔](https://developer.apple.com/tvos/)

---

## 📝 更新歷史

### v1.0 (2025-08-21)
- ✅ 解決 golang.org/x/mobile/bind 錯誤
- ✅ 修復 gopsutil 構建標籤衝突  
- ✅ 整合 protonjohn/gomobile tvOS 支援
- ✅ 提供完整的環境設置自動化
- ✅ 升級到 gendago/gopsutil 官方 tvOS 支持
- ✅ 添加前端資源自動更新

**由 OpenList tvOS Framework 項目維護** 🚀