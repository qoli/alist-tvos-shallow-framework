#!/bin/bash

# OpenList tvOS 快速构建脚本
# 用于已经配置好的项目的日常构建
# 
# 使用方法: ./quick_build.sh

set -e

echo "🚀 OpenList tvOS 快速构建"
echo "========================"

# 检查环境
if ! command -v gomobile &> /dev/null; then
    echo "❌ gomobile 未安装，请先运行完整构建脚本"
    exit 1
fi

# 检查 tvOS 支持
if ! gomobile bind -help 2>&1 | grep -q "appletvos"; then
    echo "❌ gomobile 不支持 tvOS，请先运行完整构建脚本"
    exit 1
fi

# 更新前端（可选）
if [ "$1" = "--update-web" ]; then
    echo "📥 更新前端资源..."
    if [ -f "fetch-web.sh" ]; then
        ./fetch-web.sh
    fi
fi

# 清理旧框架
echo "🧹 清理旧框架..."
rm -rf Alistlib.xcframework
gomobile clean

# 构建框架
echo "🔨 构建 tvOS 框架..."
gomobile bind \
    -target appletvos,appletvsimulator \
    -bundleid com.openlist.tvos \
    -o ./Alistlib.xcframework \
    -ldflags "-s -w" \
    github.com/OpenListTeam/OpenList/v4/alistlib

echo ""
echo "✅ 构建完成！"
echo "📁 框架位置: $(pwd)/Alistlib.xcframework"
echo ""

# 显示框架信息
if [ -d "Alistlib.xcframework" ]; then
    echo "🎯 支持平台:"
    ls -la Alistlib.xcframework/ | grep -E "(tvos|arm64)" | sed 's/^/   /'
fi