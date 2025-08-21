# OpenList tvOS Framework

🚀 **OpenList tvOS Framework** 是一個基於 [OpenList](https://github.com/OpenListTeam/OpenList) 項目的 tvOS 原生框架，為 Apple TV 提供完整的文件服務器功能。

## ✨ 特性

- 🎯 **原生 tvOS 支持** - 專為 Apple TV 平台優化
- 📱 **真設備 + 模擬器** - 支持 tvOS 真實設備和模擬器
- 🔧 **完全自動化** - 一鍵構建和配置
- 🏗️ **XCFramework** - 現代化的框架分發格式
- 🔄 **持續更新** - 跟進 OpenList 最新版本

## 🎯 項目背景

本項目將原 alist-ios 專案完全遷移到 **OpenList v4**，使用真正的 OpenList 源碼構建 tvOS 框架，而非依賴已被出售的 alist 項目。

### 核心改進

- ✅ **後端完全遷移** - 從 `github.com/alist-org/alist/v3` 遷移到 `github.com/OpenListTeam/OpenList/v4`
- ✅ **前端完全遷移** - 從 `alist-web` 遷移到 `OpenList-Frontend`
- ✅ **tvOS 原生支持** - 使用修改版 gomobile 支持 tvOS 平台
- ✅ **兼容性修復** - 解決 gopsutil 等依賴庫的 tvOS 兼容性問題
- ✅ **自動化構建** - 提供完整的自動化構建腳本

## 🚀 快速開始

### 系統要求

- macOS (必需)
- Xcode 14.0+
- Go 1.21+

### 一鍵構建

```bash
# 克隆項目
git clone <repository-url>
cd alist-ios-tvos-shallow-framework

# 構建 tvOS 框架
./build_openlist_tvos.sh
```

## 📋 構建腳本說明

### `build_openlist_tvos.sh` - 完整構建腳本

適用於首次配置或重新配置環境，包含：

- ✅ 環境依賴檢查
- ✅ 安裝支持 tvOS 的 gomobile (protonjohn 版本)
- ✅ 自動配置 OpenList v4 依賴
- ✅ 修復 gopsutil tvOS 兼容性
- ✅ 構建 tvOS 淺層框架
- ✅ 生成詳細構建報告
- ✅ 自動化測試和驗證

## 🔧 技術架構

### 核心組件

- **OpenList v4** - 主要的文件服務器核心
- **protonjohn/gomobile** - 支持 tvOS 淺層框架的 Go 移動開發工具
- **alistlib** - 封裝的 tvOS 原生接口層

### 框架結構

```
Alistlib.xcframework/
├── Info.plist                           # 框架元數據
├── tvos-arm64/                          # tvOS 設備版本
│   └── Alistlib.framework/
│       ├── Alistlib                     # 二進制文件
│       ├── Headers/                     # 頭文件
│       │   ├── Alistlib.h
│       │   ├── Alistlib.objc.h
│       │   └── ref.h
│       └── Modules/                     # 模塊映射
└── tvos-arm64_x86_64-simulator/         # tvOS 模擬器版本
    └── Alistlib.framework/
        └── ...
```

## 🎯 Xcode 集成

### 1. 添加框架

將 `Alistlib.xcframework` 拖入你的 Xcode 項目，並在：
**General** → **Frameworks, Libraries, and Embedded Content** 中添加

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

### 常見問題

1. **"no Go package in github.com/protonjohn/gomobile/bind"**
   ```bash
   go install github.com/protonjohn/gomobile/cmd/gomobile@latest
   gomobile init
   ```

2. **"unsupported platform: appletvos"**
   ```bash
   # 確保使用 protonjohn 版本
   go install github.com/protonjohn/gomobile/cmd/gomobile@latest
   which gomobile  # 應該指向 Go bin 目錄
   ```

3. **gopsutil 相關錯誤**
   ```bash
   # 檢查 build tag 修復是否應用
   cat gopsutil/host/host_darwin_cgo.go | head -5
   cat gopsutil/cpu/cpu_darwin_nocgo.go | head -5
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
./build_openlist_tvos.sh
```

### 備份和恢復

```bash
# 查看備份（腳本自動創建）
ls go.mod.backup

# 手動恢復
mv go.mod.backup go.mod
```

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
- [protonjohn/gomobile](https://github.com/protonjohn/gomobile)
- [tvOS 開發文檔](https://developer.apple.com/tvos/)
- [BUILD_GUIDE.md](./BUILD_GUIDE.md) - 詳細構建指南

---

**由 OpenList tvOS Framework 項目維護** 🚀