# GitHub Actions CI/CD 使用指南

本指南介绍如何使用优化后的GitHub Actions工作流进行自动化构建和部署。

## 📋 概览

优化后的GitHub Actions工作流具有以下特性：

- ✅ 使用 `${GITHUB_REPOSITORY@L}` 自动转换仓库名为小写
- ✅ 从 `version.txt` 文件读取版本号
- ✅ 支持多平台Docker镜像构建 (linux/amd64, linux/arm64)
- ✅ 自动推送到GitHub Container Registry (ghcr.io)
- ✅ 版本化镜像标签管理
- ✅ 支持手动触发和环境变量注入
- ✅ Kubernetes自动部署配置

## 🚀 快速开始

### 1. 版本管理

项目使用 `version.txt` 文件管理版本：

```bash
# 查看当前版本
cat version.txt

# 手动升级版本（推荐使用脚本）
./scripts/bump-version.sh patch   # 1.0.0 -> 1.0.1
./scripts/bump-version.sh minor   # 1.0.1 -> 1.1.0
./scripts/bump-version.sh major   # 1.1.0 -> 2.0.0
```

### 2. 触发构建

#### 自动触发
推送到 `main` 或 `master` 分支时自动触发：

```bash
git add .
git commit -m "功能更新"
git push origin main
```

#### 手动触发
在GitHub Actions界面手动触发，支持设置JWT令牌：

1. 访问 GitHub仓库 > Actions > Build and Deploy Docker Image
2. 点击 "Run workflow"
3. 可选择填入JWT令牌值
4. 点击 "Run workflow" 开始构建

### 3. 环境变量配置

工作流支持以下环境变量：

```yaml
inputs:
  jwt_token_1: 'JWT Token 1'
  jwt_token_2: 'JWT Token 2'
  jwt_token_3: 'JWT Token 3'
  jwt_token_4: 'JWT Token 4'
  jwt_token_5: 'JWT Token 5'
```

## 🏗️ 工作流程详解

### 构建阶段 (build-and-push)

1. **代码检出**: 获取最新代码
2. **仓库名处理**: 自动转换为小写格式
3. **版本读取**: 从 `version.txt` 读取当前版本
4. **Docker登录**: 登录到GitHub Container Registry
5. **元数据提取**: 生成Docker镜像标签和标签
6. **多平台构建**: 构建 AMD64 和 ARM64 架构镜像
7. **推送镜像**: 推送到 `ghcr.io`

### 部署阶段 (deploy-to-kubernetes)

仅在推送到 `main` 分支时执行：

1. **更新Kubernetes配置**: 使用最新版本更新deployment.yaml
2. **上传清单文件**: 生成带版本号的Kubernetes部署文件

## 🐳 Docker镜像标签策略

工作流会生成以下标签：

- `latest` - 最新的main分支构建
- `v1.0.0` - 带v前缀的版本标签
- `1.0.0` - 纯版本号标签
- `main-abc1234` - 分支名-提交哈希
- `pr-123` - PR构建标签

## 🔧 本地开发

### 本地构建测试

```bash
# 构建Docker镜像
docker build -t jetbrainsai2api:local \
  --build-arg VERSION=1.0.0-dev \
  --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
  --build-arg VCS_REF=$(git rev-parse HEAD) \
  .

# 运行容器
docker run -d \
  --name jetbrainsai2api-test \
  -p 8000:8000 \
  -e JWT_TOKEN_1="your-jwt-token" \
  jetbrainsai2api:local
```

### 本地版本升级

```bash
# 给脚本执行权限（首次使用）
chmod +x scripts/bump-version.sh

# 升级版本
./scripts/bump-version.sh patch

# 提交更改
git add .
git commit -m "Bump version to $(grep version= version.txt | cut -d= -f2)"
git push origin main
```

## 📦 部署到Kubernetes

### 使用构建产物部署

1. 下载构建产物中的 `k8s-manifests-X.X.X`
2. 解压并应用到集群：

```bash
# 创建命名空间（如果不存在）
kubectl create namespace jetbrainsai2api

# 应用Kubernetes配置
kubectl apply -f k8s/ -n jetbrainsai2api

# 检查部署状态
kubectl get pods -n jetbrainsai2api
```

### Claw Cloud专用部署

参考 [`CLAW_CLOUD_DEPLOYMENT.md`](./CLAW_CLOUD_DEPLOYMENT.md) 获取详细的Claw Cloud部署指南。

## 🔍 故障排除

### 构建失败

1. **权限问题**: 确保仓库启用了Actions和Package权限
2. **Docker构建失败**: 检查Dockerfile语法和依赖
3. **推送失败**: 确保GITHUB_TOKEN有packages:write权限

### 部署问题

1. **镜像拉取失败**: 确保镜像已成功推送到ghcr.io
2. **Kubernetes调度失败**: 检查资源约束和节点污点配置
3. **环境变量未生效**: 确保Secret正确配置

### 版本管理问题

```bash
# 检查version.txt格式
cat version.txt
# 应该输出: version=1.0.0

# 手动修复version.txt
echo "version=1.0.0" > version.txt
```

## 📚 最佳实践

1. **版本命名**: 遵循语义化版本规范 (SemVer)
2. **提交信息**: 使用清晰的提交信息便于追踪
3. **安全性**: 敏感信息通过Secrets管理，不要硬编码
4. **监控**: 定期检查Actions运行状态和资源使用情况
5. **测试**: 在推送前进行本地测试

## 🔗 相关文档

- [Docker部署指南](./DEPLOYMENT.md)
- [Claw Cloud部署指南](./CLAW_CLOUD_DEPLOYMENT.md)
- [快速开始指南](./QUICK_START.md)
- [GitHub Actions文档](https://docs.github.com/en/actions)
- [GitHub Container Registry文档](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)