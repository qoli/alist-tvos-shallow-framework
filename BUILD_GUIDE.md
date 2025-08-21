# OpenList tvOS 框架构建指南

本指南详细说明如何将 alist-ios 项目迁移到 OpenList 并构建 tvOS 框架。

## 🎯 目标

- 将项目从 `github.com/alist-org/alist/v3` 迁移到 `github.com/OpenListTeam/OpenList/v4`
- 构建支持 tvOS 的 XCFramework
- 保持所有原有功能

## 📋 前置要求

### 系统要求
- macOS (必需，用于 tvOS 开发)
- Xcode 14.0+ 
- Go 1.21+

### 检查命令
```bash
# 检查 Go 版本
go version

# 检查 Xcode
xcodebuild -version
```

## 🚀 快速开始

### 方法一：完整自动化构建（推荐首次使用）

```bash
# 进入 alist-ios 目录
cd /path/to/alist-ios

# 运行完整构建脚本
./build_openlist_tvos.sh
```

### 方法二：快速构建（已配置的项目）

```bash
# 日常构建
./quick_build.sh

# 带前端更新的构建
./quick_build.sh --update-web
```

## 📝 详细步骤说明

### 1. 环境准备

#### 安装支持 tvOS 的 gomobile
```bash
# 官方 gomobile 不支持 tvOS，需要使用 sagernet 修改版
go install github.com/sagernet/gomobile/cmd/gomobile@v0.1.1
go install github.com/sagernet/gomobile/cmd/gobind@v0.1.1

# 添加为模块依赖
go get github.com/sagernet/gomobile@v0.1.1

# 初始化
gomobile init
```

#### 验证 tvOS 支持
```bash
# 应该能看到 tvos 和 tvossimulator
gomobile bind -help | grep tvos
```

### 2. 项目迁移

#### 更新模块路径
```bash
# 修改 go.mod 中的模块名
sed -i '' 's|^module.*|module github.com/OpenListTeam/OpenList/v4|' go.mod
```

#### 批量替换导入路径
```bash
# 替换所有 Go 文件中的导入路径
find . -name "*.go" -exec sed -i '' 's|github.com/alist-org/alist/v3|github.com/OpenListTeam/OpenList/v4|g' {} \;
```

### 3. 修复 tvOS 兼容性

#### gopsutil 库修复
创建 `gopsutil/host/host_darwin_tvos.go`:
```go
//go:build darwin && tvos
// +build darwin,tvos

package host

import (
	"context"
	"github.com/shirou/gopsutil/v3/internal/common"
)

func SensorsTemperaturesWithContext(ctx context.Context) ([]TemperatureStat, error) {
	return []TemperatureStat{}, common.ErrNotImplementedError
}
```

#### 更新构建标签
```bash
# 确保 CGO 版本排除 tvOS
sed -i '' 's|//go:build darwin && cgo.*|//go:build darwin && cgo && !tvos && !tvossimulator|' gopsutil/host/host_darwin_cgo.go
```

### 4. 构建框架

```bash
# 清理旧框架
rm -rf Alistlib.xcframework
gomobile clean

# 构建 tvOS 框架
gomobile bind \
    -target tvos,tvossimulator \
    -bundleid com.openlist.tvos \
    -o ./Alistlib.xcframework \
    -ldflags "-s -w" \
    github.com/OpenListTeam/OpenList/v4/alistlib
```

## 🔧 故障排除

### 常见问题

#### 1. "no Go package in github.com/sagernet/gomobile/bind"
```bash
# 解决方案：重新安装并添加依赖
go get github.com/sagernet/gomobile@v0.1.1
gomobile init
```

#### 2. "unsupported platform: appletvos"
```bash
# 解决方案：确保使用 sagernet 版本
go install github.com/sagernet/gomobile/cmd/gomobile@v0.1.1
which gomobile  # 应该指向 /Users/.../go/bin/gomobile
```

#### 3. "smc_darwin.h file not found"
```bash
# 解决方案：复制头文件
cp ../openList-tvOS/backend/gopsutil/host/smc_darwin.h gopsutil/host/
```

#### 4. 函数重复声明错误
```bash
# 解决方案：检查构建标签
grep -n "//go:build" gopsutil/host/host_*.go
# 确保 tvOS 相关文件有正确的标签
```

### 调试技巧

#### 查看详细构建日志
```bash
gomobile bind -v -target tvos,tvossimulator ... # 添加 -v 参数
```

#### 检查模块状态
```bash
go mod graph | grep OpenList
go list -m all | grep OpenList
```

#### 验证框架
```bash
# 检查框架结构
ls -la Alistlib.xcframework/

# 查看支持的架构
lipo -info Alistlib.xcframework/tvos-arm64/Alistlib.framework/Alistlib
```

## 📁 输出结果

构建成功后，你将得到：

```
Alistlib.xcframework/
├── Info.plist
├── tvos-arm64/                          # tvOS 设备版本
│   └── Alistlib.framework/
│       ├── Alistlib                     # 二进制文件
│       ├── Headers/                     # 头文件
│       │   ├── Alistlib.h
│       │   ├── Alistlib.objc.h
│       │   └── ...
│       └── Modules/                     # 模块映射
└── tvos-arm64_x86_64-simulator/         # tvOS 模拟器版本
    └── Alistlib.framework/
        └── ...
```

## 🔄 版本管理

### 备份和恢复
```bash
# 自动备份（脚本会创建）
ls go.mod.backup

# 手动恢复
mv go.mod.backup go.mod
```

### 更新到新版本
```bash
# 更新 OpenList 依赖
go get github.com/OpenListTeam/OpenList/v4@latest
go mod tidy

# 重新构建
./quick_build.sh
```

## 🎯 集成到 tvOS 项目

### Xcode 集成步骤

1. **添加框架**
   - 将 `Alistlib.xcframework` 拖入 Xcode 项目
   - 在 `General` → `Frameworks, Libraries, and Embedded Content` 中添加

2. **导入头文件**
   ```objc
   #import <Alistlib/Alistlib.h>
   ```

3. **使用示例**
   ```objc
   // 初始化
   NSError *error;
   BOOL success = AlistlibInit(eventHandler, logCallback, &error);
   
   // 启动服务器
   AlistlibStart();
   
   // 检查运行状态
   BOOL isRunning = AlistlibIsRunning(@"http");
   ```

## 📚 相关资源

- [OpenList 官方仓库](https://github.com/OpenListTeam/OpenList)
- [sagernet/gomobile](https://github.com/sagernet/gomobile)
- [tvOS 开发文档](https://developer.apple.com/tvos/)

## 🤝 贡献

如果你发现问题或有改进建议，请：

1. 检查现有的 issue
2. 创建详细的问题报告
3. 提供复现步骤

---

*最后更新: 2025-01-XX*
*构建脚本版本: 1.0*