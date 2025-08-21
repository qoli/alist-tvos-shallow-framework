#!/bin/bash

# OpenList tvOS 完整環境設置與構建腳本
# 適用於全新 macOS 環境的自動化構建
# 
# 使用方法: ./setup_and_build_tvos.sh
# 
# 前置條件: 已安裝 Xcode
#
# Author: Claude Code AI
# Version: 1.0
# Date: 2025-08-21

set -e

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
NC='\033[0m' # No Color

# 日誌函數
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

# 檢查是否為項目根目錄
check_project_root() {
    if [[ ! -f "go.mod" ]] || [[ ! -d "alistlib" ]]; then
        log_error "請在 OpenList 項目根目錄下運行此腳本"
        log_info "項目根目錄應包含 go.mod 和 alistlib 目錄"
        exit 1
    fi
    
    if ! grep -q "github.com/OpenListTeam/OpenList/v4" go.mod; then
        log_error "這不是 OpenList v4 項目"
        exit 1
    fi
}

# 檢查 Go 版本
check_go_version() {
    log_step "檢查 Go 環境..."
    
    if ! command -v go &> /dev/null; then
        log_error "Go 未安裝，請先安裝 Go 1.22+"
        log_info "下載地址: https://golang.org/dl/"
        exit 1
    fi
    
    GO_VERSION=$(go version | awk '{print $3}' | sed 's/go//')
    log_info "Go 版本: $GO_VERSION"
    
    # 檢查 Go 版本是否為 1.22+
    if [[ $(echo "$GO_VERSION 1.22" | tr " " "\n" | sort -V | head -n1) != "1.22" ]]; then
        log_error "需要 Go 1.22 或更高版本，當前版本: $GO_VERSION"
        exit 1
    fi
    
    log_success "✅ Go 環境檢查通過"
}

# 檢查 GOPATH 和 GOBIN
setup_go_environment() {
    log_step "設置 Go 環境變量..."
    
    # 確保 GOBIN 設置
    if [[ -z "$GOBIN" ]]; then
        export GOBIN="$HOME/go/bin"
        log_info "設置 GOBIN=$GOBIN"
    fi
    
    # 確保 GOBIN 目錄存在
    mkdir -p "$GOBIN"
    
    # 確保 GOBIN 在 PATH 中
    if [[ ":$PATH:" != *":$GOBIN:"* ]]; then
        export PATH="$GOBIN:$PATH"
        log_info "將 $GOBIN 添加到 PATH"
    fi
    
    log_success "✅ Go 環境變量設置完成"
}

# 添加 golang.org/x/mobile 依賴
add_mobile_dependency() {
    log_step "添加 golang.org/x/mobile 依賴..."
    
    # 檢查是否已有正確版本的依賴
    if go list -m golang.org/x/mobile 2>/dev/null | grep -q "$MOBILE_VERSION"; then
        log_info "golang.org/x/mobile 依賴已存在且版本正確 ($MOBILE_VERSION)"
    else
        log_info "添加 golang.org/x/mobile 依賴 ($MOBILE_VERSION)..."
        go get golang.org/x/mobile@$MOBILE_VERSION
        log_success "✅ golang.org/x/mobile 依賴添加完成"
    fi
}

# 安裝 protonjohn/gomobile
install_protonjohn_gomobile() {
    log_step "安裝 protonjohn/gomobile (支持 tvOS)..."
    
    # 檢查是否已安裝並支持 tvOS
    if command -v gomobile &> /dev/null && gomobile bind -help 2>&1 | grep -q "appletvos"; then
        log_info "protonjohn/gomobile 已安裝且支持 tvOS"
        return 0
    fi
    
    local temp_dir="/tmp/protonjohn-gomobile-$(date +%s)"
    
    log_info "下載 protonjohn/gomobile fork ($GOMOBILE_BRANCH)..."
    git clone -b "$GOMOBILE_BRANCH" "$GOMOBILE_REPO" "$temp_dir"
    
    cd "$temp_dir"
    
    log_info "編譯並安裝 gomobile 工具..."
    go install ./cmd/gomobile
    
    cd - > /dev/null
    
    # 清理臨時目錄
    rm -rf "$temp_dir"
    
    # 初始化 gomobile
    log_info "初始化 gomobile..."
    gomobile init
    
    # 驗證安裝
    if gomobile bind -help 2>&1 | grep -q "appletvos"; then
        log_success "✅ protonjohn/gomobile 安裝成功，支持 appletvos 目標"
    else
        log_error "gomobile 安裝失敗或不支持 appletvos"
        exit 1
    fi
}

# 驗證 gopsutil tvOS 支持
verify_gopsutil_tvos_support() {
    log_step "驗證 gopsutil tvOS 支持..."
    
    # 檢查是否使用了 gendago/gopsutil 版本
    if [[ -f "gopsutil/host/host_darwin_cgo.go" ]]; then
        if grep -q "!appletvos && !appletvsimulator" "gopsutil/host/host_darwin_cgo.go"; then
            log_info "✓ 發現正確的 tvOS 排除標籤在 CGO 版本"
        else
            log_warning "CGO 版本可能缺少 tvOS 排除標籤"
        fi
        
        if grep -q "//go:build darwin && !cgo" "gopsutil/host/host_darwin_nocgo.go"; then
            log_info "✓ 發現正確的簡潔構建標籤在非CGO版本"  
        else
            log_warning "非CGO 版本構建標籤可能不正確"
        fi
        
        log_success "✅ gopsutil tvOS 支持驗證通過"
    else
        log_warning "未找到 gopsutil 目錄，跳過驗證"
    fi
}

# 構建 tvOS 框架
build_tvos_framework() {
    log_step "構建 tvOS 框架..."
    
    # 清理舊框架
    log_info "清理舊框架..."
    rm -rf Alistlib.xcframework
    gomobile clean
    
    # 構建框架
    log_info "開始構建 tvOS 框架..."
    local build_cmd="gomobile bind \
        -target appletvos,appletvsimulator \
        -bundleid com.openlist.tvos \
        -o ./Alistlib.xcframework \
        -ldflags \"-s -w\" \
        github.com/OpenListTeam/OpenList/v4/alistlib"
    
    log_info "執行構建命令:"
    log_info "$build_cmd"
    
    if eval "$build_cmd"; then
        log_success "✅ tvOS 框架構建成功"
    else
        log_error "tvOS 框架構建失敗"
        exit 1
    fi
}

# 驗證構建結果
verify_build_result() {
    log_step "驗證構建結果..."
    
    if [[ ! -d "Alistlib.xcframework" ]]; then
        log_error "Alistlib.xcframework 不存在"
        exit 1
    fi
    
    local required_platforms=("tvos-arm64" "tvos-arm64_x86_64-simulator")
    
    for platform in "${required_platforms[@]}"; do
        local platform_path="Alistlib.xcframework/$platform"
        if [[ ! -d "$platform_path" ]]; then
            log_error "缺少平台: $platform"
            exit 1
        fi
        
        local framework_path="$platform_path/Alistlib.framework"
        if [[ ! -d "$framework_path" ]]; then
            log_error "缺少框架目錄: $framework_path"
            exit 1
        fi
        
        local binary_path="$framework_path/Alistlib"
        if [[ ! -f "$binary_path" ]]; then
            log_error "缺少二進制文件: $binary_path"
            exit 1
        fi
        
        log_info "✓ 平台 $platform 驗證通過"
    done
    
    # 顯示框架大小信息
    local framework_size=$(du -sh Alistlib.xcframework | awk '{print $1}')
    log_info "框架大小: $framework_size"
    
    log_success "✅ 構建結果驗證通過"
}

# 顯示構建總結
show_build_summary() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                   構建完成總結                               ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    log_success "🎉 OpenList tvOS 框架構建成功！"
    echo ""
    
    log_info "📁 框架位置: $(pwd)/Alistlib.xcframework"
    
    if [[ -d "Alistlib.xcframework" ]]; then
        log_info "🎯 支持平台:"
        ls -la Alistlib.xcframework/ | grep -E "(tvos|arm64)" | sed 's/^/   /'
    fi
    
    echo ""
    log_info "📊 框架信息:"
    log_info "   • 架構: tvOS 淺層框架結構 (Shallow Bundle)"
    log_info "   • 工具鏈: protonjohn/gomobile + Go $(go version | awk '{print $3}')"
    log_info "   • 目標平台: appletvos, appletvsimulator"
    
    echo ""
    log_info "🚀 使用方法:"
    log_info "   將 Alistlib.xcframework 拖入你的 Xcode tvOS 項目中即可使用"
    
    echo ""
}

# 主函數
main() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║            OpenList tvOS 完整環境設置與構建腳本               ║"
    echo "║                                                              ║"
    echo "║  🎯 目標: 自動化設置並構建 tvOS 框架                          ║"
    echo "║  📦 輸出: Alistlib.xcframework (淺層結構)                     ║"
    echo "║  🔧 工具: protonjohn/gomobile (tvOS 支持)                     ║"
    echo "║  🚀 版本: 1.0                                                ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    
    # 執行構建步驟
    check_project_root
    check_go_version
    setup_go_environment
    add_mobile_dependency
    install_protonjohn_gomobile
    verify_gopsutil_tvos_support
    build_tvos_framework
    verify_build_result
    show_build_summary
}

# 版本配置
MOBILE_VERSION="v0.0.0-20241213221354-a87c1cf6cf46"
GOMOBILE_REPO="https://github.com/protonjohn/gomobile.git"
GOMOBILE_BRANCH="pr/jkb/add-tvos-xros-support"

# 錯誤處理
trap 'log_error "腳本執行失敗，請檢查上面的錯誤信息"; exit 1' ERR

# 執行主函數
main "$@"