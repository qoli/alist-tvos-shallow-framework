#!/bin/bash

# 使用 OpenList-Frontend 替代 alist-web
echo "📥 正在获取 OpenList-Frontend 最新版本..."

# 获取最新 release 信息
LATEST_RELEASE=$(curl -s https://api.github.com/repos/OpenListTeam/OpenList-Frontend/releases/latest)
VERSION=$(echo "$LATEST_RELEASE" | grep '"tag_name":' | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/')

echo "📦 找到版本: $VERSION"

# 构建下载URL (优先使用完整版本，如果不存在则使用lite版本)
DIST_URL="https://github.com/OpenListTeam/OpenList-Frontend/releases/download/$VERSION/openlist-frontend-dist-$VERSION.tar.gz"
DIST_LITE_URL="https://github.com/OpenListTeam/OpenList-Frontend/releases/download/$VERSION/openlist-frontend-dist-lite-$VERSION.tar.gz"

echo "🌐 尝试下载完整版前端..."
if curl -L --fail "$DIST_URL" -o openlist-frontend-dist.tar.gz 2>/dev/null; then
    echo "✅ 成功下载完整版前端"
else
    echo "⚠️ 完整版不可用，尝试lite版本..."
    if curl -L --fail "$DIST_LITE_URL" -o openlist-frontend-dist.tar.gz; then
        echo "✅ 成功下载lite版前端"
    else
        echo "❌ 无法下载OpenList前端，退出"
        exit 1
    fi
fi

echo "📂 解压前端文件..."
tar -zxvf openlist-frontend-dist.tar.gz

echo "🔄 更新前端目录..."
rm -rf public/dist
mkdir -p public/dist

# OpenList-Frontend 解压后文件直接在根目录，需要移动到 public/dist
if [ -d "assets" ] && [ -f "index.html" ]; then
    echo "📁 移动前端文件到 public/dist..."
    mv assets static streamer images index.html VERSION public/dist/
    echo "✅ 前端文件移动完成"
else
    echo "❌ 未找到预期的前端文件结构"
    exit 1
fi

echo "🧹 清理临时文件..."
rm -rf openlist-frontend-dist.tar.gz

echo "✅ OpenList-Frontend 更新完成！"