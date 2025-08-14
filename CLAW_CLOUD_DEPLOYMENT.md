# 🚀 Claw Cloud 部署指南

## 部署流程概述

1. **GitHub Actions 构建镜像** → 推送到 GitHub Container Registry
2. **Claw Cloud 拉取镜像** → 从 ghcr.io 部署到 Kubernetes

## 📋 前置准备

### 1. 配置 GitHub Repository

```bash
# 1. Fork 或 Clone 项目
git clone https://github.com/YOUR_USERNAME/jetbrainsai2api.git
cd jetbrainsai2api

# 2. 推送代码触发 GitHub Actions
git add .
git commit -m "Initial setup for Claw Cloud deployment"
git push origin main
```

### 2. 设置 GitHub Container Registry 权限

1. 进入 GitHub 项目 Settings → Actions → General
2. 确保 "Read and write permissions" 已启用
3. GitHub Actions 将自动推送镜像到 `ghcr.io/YOUR_USERNAME/jetbrainsai2api:latest`

## 🐳 镜像构建和推送

GitHub Actions 会自动执行以下步骤：

```yaml
# .github/workflows/build-and-deploy.yml 会自动：
1. 构建多平台镜像 (linux/amd64, linux/arm64)
2. 推送到 ghcr.io/YOUR_USERNAME/jetbrainsai2api:latest
3. 创建 Release 并上传部署脚本
```

## ☸️ Claw Cloud 部署步骤

### 步骤 1: 准备配置文件

修改 `k8s/deployment.yaml` 中的镜像地址：

```yaml
# 将 GITHUB_USERNAME 替换为你的实际用户名
image: ghcr.io/YOUR_ACTUAL_USERNAME/jetbrainsai2api:latest
```

### 步骤 2: 创建 Secret

```bash
# 在 Claw Cloud 控制台或通过 kubectl 创建
kubectl create secret generic jetbrainsai-secrets \
  --from-literal=jwt-token-1="your-jwt-token-1" \
  --from-literal=jwt-token-2="your-jwt-token-2" \
  --from-literal=jwt-token-3="your-jwt-token-3"
```

### 步骤 3: 部署应用

```bash
# 应用所有配置
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/deployment.yaml  
kubectl apply -f k8s/service.yaml

# 检查部署状态
kubectl get pods -l app=jetbrainsai2api
kubectl describe pod -l app=jetbrainsai2api
```

## 🔧 解决调度问题的关键配置

### 污点容忍配置
```yaml
tolerations:
- key: "database.run.claw.cloud/node"
  operator: "Exists"
  effect: "NoSchedule"
- key: "monitor.run.claw.cloud/node"
  operator: "Exists"
  effect: "NoSchedule"
- key: "devbox.sealos.io/node"
  operator: "Exists"
  effect: "NoSchedule"
```

### 资源优化配置
```yaml
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

## 🚀 一键部署脚本

创建 `deploy-claw-cloud.sh`:

```bash
#!/bin/bash
set -e

echo "🚀 部署 JetBrains AI API 到 Claw Cloud"

# 检查环境变量
if [ -z "$GITHUB_USERNAME" ]; then
    echo "❌ 请设置 GITHUB_USERNAME 环境变量"
    echo "export GITHUB_USERNAME=your-github-username"
    exit 1
fi

# 更新镜像地址
sed -i "s/GITHUB_USERNAME/$GITHUB_USERNAME/g" k8s/deployment.yaml

# 部署应用
echo "📦 创建 Secret..."
kubectl apply -f k8s/secret.yaml

echo "🚀 部署应用..."
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

echo "✅ 部署完成！"
echo "检查状态："
echo "kubectl get pods -l app=jetbrainsai2api"
echo "kubectl logs -f deployment/jetbrainsai2api"
```

## 📊 验证部署

```bash
# 1. 检查 Pod 状态
kubectl get pods -l app=jetbrainsai2api

# 2. 查看日志
kubectl logs -f deployment/jetbrainsai2api

# 3. 测试API
kubectl port-forward service/jetbrainsai2api-service 8000:8000
curl http://localhost:8000/v1/models
```

## 🔍 故障排除

### 常见问题

1. **镜像拉取失败**
   ```bash
   # 检查镜像是否存在
   docker pull ghcr.io/YOUR_USERNAME/jetbrainsai2api:latest
   
   # 确保GitHub Container Registry权限正确
   ```

2. **Pod 调度失败**
   ```bash
   # 查看详细错误信息
   kubectl describe pod -l app=jetbrainsai2api
   
   # 检查节点状态
   kubectl get nodes -o wide
   ```

3. **环境变量未生效**
   ```bash
   # 检查 Secret 是否创建
   kubectl get secrets jetbrainsai-secrets
   
   # 查看 Secret 内容
   kubectl describe secret jetbrainsai-secrets
   ```

## 🔄 更新部署

```bash
# 1. 推送新代码触发 GitHub Actions
git push origin main

# 2. 等待镜像构建完成后重启部署
kubectl rollout restart deployment/jetbrainsai2api

# 3. 检查更新状态
kubectl rollout status deployment/jetbrainsai2api
```

## 💡 最佳实践

1. **使用特定版本标签**而不是 `latest`
2. **设置资源限制**避免影响其他应用
3. **配置健康检查**确保服务稳定运行
4. **监控日志**及时发现问题

## 🎯 完整部署流程

```bash
# 1. 设置环境变量
export GITHUB_USERNAME=your-github-username

# 2. 克隆并推送代码
git clone https://github.com/$GITHUB_USERNAME/jetbrainsai2api.git
cd jetbrainsai2api
git push origin main  # 触发镜像构建

# 3. 等待镜像构建完成，然后部署
./deploy-claw-cloud.sh

# 4. 验证部署
kubectl get pods -l app=jetbrainsai2api
```

现在您可以成功地将GitHub Actions构建的镜像部署到Claw Cloud了！