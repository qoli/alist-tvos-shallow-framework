#!/bin/bash

# OpenList tvOS 快速構建腳本
# 用於已經配置好環境的日常構建
# 
# 使用方法: ./build_tvos_quick.sh [--update-web]
#
# Author: Claude Code AI
# Version: 1.0
# Date: 2025-08-21

set -e

# 版本配置  
MOBILE_VERSION="v0.0.0-20241213221354-a87c1cf6cf46"

# 顏色定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo "🚀 OpenList tvOS 快速構建"
echo "========================"

# 檢查環境
if ! command -v gomobile &> /dev/null; then
    log_error "gomobile 未安裝，請先運行完整設置腳本: ./setup_and_build_tvos.sh"
    exit 1
fi

# 檢查 tvOS 支持
if ! gomobile bind -help 2>&1 | grep -q "appletvos"; then
    log_error "gomobile 不支持 tvOS，請先運行完整設置腳本: ./setup_and_build_tvos.sh"
    exit 1
fi

# 檢查並自動修復 golang.org/x/mobile 依賴
if ! go list -m golang.org/x/mobile 2>/dev/null | grep -q "$MOBILE_VERSION"; then
    log_info "🔧 自動添加缺失的 golang.org/x/mobile 依賴 ($MOBILE_VERSION)..."
    go get golang.org/x/mobile@$MOBILE_VERSION
    log_success "✅ golang.org/x/mobile 依賴已自動修復"
fi

# 更新前端（可選）
if [[ "$1" == "--update-web" ]]; then
    log_info "📥 更新前端資源..."
    if [[ -f "fetch-web.sh" ]]; then
        ./fetch-web.sh
    fi
fi

# 清理舊框架
log_info "🧹 清理舊框架..."
rm -rf Alistlib.xcframework
gomobile clean

# 構建框架
log_info "🔨 構建 tvOS 框架..."
gomobile bind \
    -target appletvos,appletvsimulator \
    -bundleid com.openlist.tvos \
    -o ./Alistlib.xcframework \
    -ldflags "-s -w" \
    github.com/OpenListTeam/OpenList/v4/alistlib

echo ""
log_success "✅ 構建完成！"
log_info "📁 框架位置: $(pwd)/Alistlib.xcframework"
echo ""

# 顯示框架信息
if [[ -d "Alistlib.xcframework" ]]; then
    log_info "🎯 支持平台:"
    ls -la Alistlib.xcframework/ | grep -E "(tvos|arm64)" | sed 's/^/   /'
    
    # 顯示框架大小
    framework_size=$(du -sh Alistlib.xcframework | awk '{print $1}')
    log_info "📊 框架大小: $framework_size"
fi

echo ""
log_info "💡 提示:"
log_info "   • 首次構建請使用: ./setup_and_build_tvos.sh"
log_info "   • 更新前端資源: ./build_tvos_quick.sh --update-web"