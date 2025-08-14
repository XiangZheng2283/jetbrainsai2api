# JetBrains AI API 部署指南

## 🚀 快速开始

### 使用 Docker Compose（推荐）

1. **克隆项目**
   ```bash
   git clone <your-repo-url>
   cd jetbrainsai2api
   ```

2. **配置环境变量**
   ```bash
   cp .env.example .env
   # 编辑 .env 文件，填入你的JWT tokens
   ```

3. **启动服务**
   ```bash
   docker-compose up -d
   ```

4. **验证服务**
   ```bash
   curl http://localhost:8000/v1/models
   ```

### 使用 GitHub Actions 一键部署

1. **Fork 此项目到你的 GitHub 账户**

2. **设置 GitHub Secrets（可选）**
   在你的 GitHub 仓库设置中添加以下 Secrets：
   - `JWT_TOKEN_1`: 你的第一个JWT token
   - `JWT_TOKEN_2`: 你的第二个JWT token
   - 等等...

3. **触发构建**
   - 推送代码到 main/master 分支
   - 或者在 Actions 页面手动运行 "Build and Deploy Docker Image" workflow

4. **下载部署脚本**
   - 在 Release 页面下载 `deploy.sh` 脚本
   - 或者在 Actions 运行结果中下载 deployment-script artifact

5. **运行部署脚本**
   ```bash
   # 设置环境变量
   export JWT_TOKEN_1="your-jwt-token-1"
   export JWT_TOKEN_2="your-jwt-token-2"
   
   # 运行部署
   chmod +x deploy.sh
   ./deploy.sh
   ```

## 🔧 环境变量说明

### JWT Tokens
- `JWT_TOKEN_1` - `JWT_TOKEN_5`: 单独设置每个JWT token（推荐）
- `JWT_TOKENS`: 使用逗号分隔的多个tokens（备选方案）

### License 信息（可选）
- `LICENSE_ID_1`, `LICENSE_ID_2`: JetBrains License ID，用于自动刷新JWT
- `AUTHORIZATION_1`, `AUTHORIZATION_2`: Authorization tokens，配合License ID使用

### 其他配置
- `DEBUG_MODE`: 调试模式，默认为 false

## 📦 Docker 镜像

### 手动拉取和运行
```bash
# 拉取最新镜像
docker pull ghcr.io/your-username/jetbrainsai2api:latest

# 运行容器
docker run -d \
  --name jetbrainsai2api \
  -p 8000:8000 \
  --restart unless-stopped \
  -e JWT_TOKEN_1="your-jwt-token-1" \
  -e JWT_TOKEN_2="your-jwt-token-2" \
  ghcr.io/your-username/jetbrainsai2api:latest
```

### 使用自定义配置
```bash
docker run -d \
  --name jetbrainsai2api \
  -p 8000:8000 \
  --restart unless-stopped \
  -e JWT_TOKEN_1="eyJ..." \
  -e JWT_TOKEN_2="eyJ..." \
  -e LICENSE_ID_1="your-license-id" \
  -e AUTHORIZATION_1="your-auth-token" \
  -e DEBUG_MODE="false" \
  ghcr.io/your-username/jetbrainsai2api:latest
```

## 🔍 配置文件管理

本项目支持通过环境变量自动生成和更新配置文件：

### jetbrainsai.json
系统会根据环境变量自动生成或更新此文件：
```json
[
  {
    "jwt": "your-jwt-token-1",
    "licenseId": "your-license-id-1", 
    "authorization": "your-auth-token-1",
    "last_updated": 0,
    "has_quota": true,
    "last_quota_check": 0
  }
]
```

### 优先级
1. 环境变量中的JWT tokens
2. 现有 jetbrainsai.json 文件中的配置
3. 默认示例配置

## 🛠️ 故障排除

### 查看日志
```bash
docker logs -f jetbrainsai2api
```

### 重新构建镜像
```bash
docker-compose build --no-cache
docker-compose up -d
```

### 清理和重启
```bash
docker-compose down
docker-compose up -d
```

### 更新JWT tokens
```bash
# 方式1：修改环境变量后重启
export JWT_TOKEN_1="new-token"
docker-compose restart

# 方式2：直接重新运行容器
docker stop jetbrainsai2api
docker rm jetbrainsai2api
# 然后使用新的环境变量运行
```

## 🔒 安全建议

1. **保护敏感信息**
   - 不要在代码中硬编码JWT tokens
   - 使用环境变量或 Secrets 管理敏感信息

2. **网络安全**
   - 在生产环境中使用反向代理（如Nginx）
   - 配置HTTPS和适当的防火墙规则

3. **访问控制**
   - 定期轮换JWT tokens
   - 监控API使用情况

## 📚 API 端点

服务启动后，可以访问以下端点：

- `GET /v1/models` - 列出可用模型
- `POST /v1/chat/completions` - OpenAI 兼容的聊天完成
- `POST /v1/messages` - Anthropic 兼容的消息接口

详细的API文档请参考项目的README.md文件。