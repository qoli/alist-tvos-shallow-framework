#!/bin/bash

# OpenList tvOS 清理无用文件脚本
# 清理 tvOS 框架构建不需要的文件

echo "🧹 开始清理 OpenList tvOS 无用文件..."

# 1. 删除 Docker 相关文件
echo "📦 清理 Docker 相关文件..."
rm -f docker-compose.yml Dockerfile Dockerfile.ci Dockerfile.ffmpeg entrypoint.sh

# 2. 删除旧的构建脚本
echo "🔧 清理旧的构建脚本..."
rm -f build.sh alist-gomobile.sh

# 3. 删除开发工具配置
echo "⚙️ 清理开发工具配置..."
rm -f .air.toml

# 4. 删除不必要的文档
echo "📄 清理不必要的文档..."
rm -f CODE_OF_CONDUCT.md CONTRIBUTING.md

# 5. 删除 wrapper 目录
echo "📁 清理 wrapper 目录..."
rm -rf wrapper/

# 6. 删除系统文件
echo "🍎 清理系统文件..."
rm -f .DS_Store

# 7. 清理临时文件
echo "🗑️ 清理临时文件..."
rm -rf tmp/
rm -f *.log

# 8. 可选：清理不必要的服务器模块（询问用户）
echo ""
read -p "是否删除 FTP/S3/WebDAV 服务器模块？这些在 tvOS 框架中不需要 (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🌐 清理服务器模块..."
    rm -f server/ftp.go server/s3.go server/webdav.go
fi

# 9. 显示清理结果
echo ""
echo "✅ 清理完成！"
echo ""
echo "📊 目录大小对比："
echo "清理前目录内容："
du -sh . 2>/dev/null

echo ""
echo "💡 提示："
echo "  - 保留了所有核心构建文件"
echo "  - 保留了 OpenList tvOS 专用脚本"
echo "  - 如需恢复文件，可从 git 历史中恢复"