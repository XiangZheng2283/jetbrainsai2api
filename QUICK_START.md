# 🚀 JetBrains AI API 快速部署

## 一键部署方式

### 方式1：GitHub Actions 自动构建

1. **Fork 项目**
   - 点击 Fork 按钮将项目复制到你的 GitHub 账户

2. **触发构建**
   - 推送任何代码到 main 分支，或手动运行 Actions

3. **下载并运行**
   ```bash
   # 从 Release 页面下载 deploy.sh
   wget https://github.com/YOUR_USERNAME/jetbrainsai2api/releases/latest/download/deploy.sh
   
   # 设置你的JWT tokens
   export JWT_TOKEN_1="eyJ0eXAiOiJKV1QiLCJhbGci..."
   export JWT_TOKEN_2="eyJ0eXAiOiJKV1QiLCJhbGci..."
   
   # 一键部署
   chmod +x deploy.sh && ./deploy.sh
   ```

### 方式2：Docker Compose

1. **克隆项目**
   ```bash
   git clone https://github.com/YOUR_USERNAME/jetbrainsai2api.git
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

### 方式3：直接使用Docker

```bash
docker run -d \
  --name jetbrainsai2api \
  -p 8000:8000 \
  --restart unless-stopped \
  -e JWT_TOKEN_1="your-jwt-token-1" \
  -e JWT_TOKEN_2="your-jwt-token-2" \
  ghcr.io/YOUR_USERNAME/jetbrainsai2api:latest
```

## ✅ 验证部署

```bash
# 检查服务状态
curl http://localhost:8000/v1/models

# 测试聊天功能
curl -X POST http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-your-custom-key-here" \
  -d '{
    "model": "anthropic-claude-3.5-sonnet",
    "messages": [{"role": "user", "content": "Hello"}],
    "stream": false
  }'
```

## 🔧 获取JWT Token

1. 登录 JetBrains IDE（如 PyCharm）
2. 打开开发者工具 (F12)
3. 访问 AI 助手功能
4. 在网络请求中找到包含 `grazie-authenticate-jwt` 的请求头
5. 复制JWT token的值

## 📝 环境变量说明

| 变量名 | 说明 | 示例 |
|--------|------|------|
| JWT_TOKEN_1 | 第一个JWT token | eyJ0eXAiOiJKV1QiLCJhbGci... |
| JWT_TOKEN_2 | 第二个JWT token | eyJ0eXAiOiJKV1QiLCJhbGci... |
| DEBUG_MODE | 调试模式 | false |

完整部署指南请查看 [DEPLOYMENT.md](DEPLOYMENT.md)