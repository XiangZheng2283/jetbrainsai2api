#!/bin/bash

# 版本升级脚本
# 用法: ./scripts/bump-version.sh [major|minor|patch]

set -e

# 默认升级类型为patch
VERSION_TYPE=${1:-patch}

# 读取当前版本
CURRENT_VERSION=$(grep "version=" version.txt | cut -d= -f2)

if [ -z "$CURRENT_VERSION" ]; then
    echo "错误: 无法读取当前版本"
    exit 1
fi

echo "当前版本: $CURRENT_VERSION"

# 分解版本号
IFS='.' read -ra VERSION_PARTS <<< "$CURRENT_VERSION"
MAJOR=${VERSION_PARTS}
MINOR=${VERSION_PARTS}[1]
PATCH=${VERSION_PARTS}

# 根据类型升级版本
case $VERSION_TYPE in
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        ;;
    minor)
        MINOR=$((MINOR + 1))
        PATCH=0
        ;;
    patch)
        PATCH=$((PATCH + 1))
        ;;
    *)
        echo "错误: 无效的版本类型。请使用 major, minor, 或 patch"
        exit 1
        ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"
echo "新版本: $NEW_VERSION"

# 更新version.txt文件
echo "version=$NEW_VERSION" > version.txt

# 更新Kubernetes deployment文件中的镜像版本
if [ -f "k8s/deployment.yaml" ]; then
    sed -i "s|ghcr.io/GITHUB_USERNAME/jetbrainsai2api:.*|ghcr.io/GITHUB_USERNAME/jetbrainsai2api:$NEW_VERSION|g" k8s/deployment.yaml
    echo "已更新 k8s/deployment.yaml 中的镜像版本"
fi

# 更新docker-compose.yml中的镜像版本
if [ -f "docker-compose.yml" ]; then
    sed -i "s|ghcr.io/GITHUB_USERNAME/jetbrainsai2api:.*|ghcr.io/GITHUB_USERNAME/jetbrainsai2api:$NEW_VERSION|g" docker-compose.yml
    echo "已更新 docker-compose.yml 中的镜像版本"
fi

echo "版本升级完成: $CURRENT_VERSION -> $NEW_VERSION"
echo ""
echo "接下来的步骤："
echo "1. git add ."
echo "2. git commit -m \"Bump version to $NEW_VERSION\""
echo "3. git tag v$NEW_VERSION"
echo "4. git push origin main --tags"