# Hugging Face Spaces 部署指南

本指南说明如何将JetBrains AI API项目部署到Hugging Face Spaces。

## 🚀 快速开始

### 1. 准备Hugging Face账户和Token

1. 访问 [Hugging Face](https://huggingface.co/) 并注册账户
2. 前往 Settings → Access Tokens
3. 创建一个新的Write权限token
4. 复制token备用

### 2. 配置GitHub Secrets

在您的GitHub仓库中添加以下secrets：

1. 进入仓库 Settings → Secrets and variables → Actions
2. 添加以下secrets：
   - `HF_TOKEN`: 您的Hugging Face访问token
   - `HF_SPACE_NAME`: 您想要的Space名称（格式：username/space-name）

### 3. 自动部署

推送代码到main分支或手动触发工作流：

```bash
git add .
git commit -m "Deploy to Hugging Face"
git push origin main
```

## 🔧 配置说明

### GitHub Actions工作流特性

- ✅ 自动从`version.txt`读取版本号
- ✅ 创建适合Hugging Face的Docker配置
- ✅ 自动生成README.md文件
- ✅ 支持手动触发并配置JWT tokens
- ✅ 完整的错误处理和状态反馈

### Hugging Face Space配置

工作流会自动创建以下结构：

```
huggingface-space/
├── README.md          # Space描述文件
├── Dockerfile         # 专门为HF优化的Docker配置
├── main.py           # 主应用程序
├── config_manager.py # 配置管理器
├── requirements.txt  # Python依赖
└── *.json           # 配置文件
```

### 环境变量配置

在Hugging Face Space中配置以下secrets：

- `JWT_TOKEN_1` - `JWT_TOKEN_5`: 您的JWT令牌
- `OPENAI_API_KEY`: OpenAI API密钥（可选）
- `ANTHROPIC_API_KEY`: Anthropic API密钥（可选）

## 📝 使用方法

### 手动触发部署

1. 在GitHub仓库中进入Actions页面
2. 选择"Deploy to Hugging Face Spaces"工作流
3. 点击"Run workflow"
4. 可选择填入JWT tokens进行测试
5. 点击"Run workflow"开始部署

### 配置JWT Tokens

部署完成后：

1. 访问您的Hugging Face Space
2. 进入Space的Settings页面
3. 在Variables and secrets中添加您的JWT tokens
4. 重启Space使配置生效

## 🔍 故障排除

### 常见问题

1. **HF_TOKEN未设置**
   ```
   ❌ HF_TOKEN secret not set. Please add your Hugging Face token to repository secrets.
   ```
   解决：在GitHub仓库secrets中添加您的Hugging Face token

2. **HF_SPACE_NAME未设置**
   ```
   ❌ HF_SPACE_NAME secret not set. Please set your desired space name.
   ```
   解决：设置Space名称格式为 `username/space-name`

3. **权限错误**
   - 确保Hugging Face token有Write权限
   - 确保Space名称中的用户名是您的用户名

4. **Space启动失败**
   - 检查Dockerfile语法
   - 确保所有依赖都在requirements.txt中
   - 查看Space的Build logs获取详细错误信息

### 调试方法

1. 查看GitHub Actions构建日志
2. 访问Hugging Face Space的Build logs
3. 检查Space的Runtime logs

## 🌟 优势特点

### 相比传统部署方式的优势

- **免费托管**: Hugging Face Spaces提供免费的Docker托管
- **自动扩展**: 根据使用量自动管理资源
- **简单配置**: 通过Web界面管理环境变量
- **版本管理**: 支持Git版本控制
- **社区友好**: 易于分享和展示

### 技术特点

- **Docker化部署**: 基于Python 3.11-slim镜像
- **健康检查**: 内置容器健康检查
- **环境变量管理**: 自动处理JWT tokens配置
- **自动启动**: 配置自动处理和应用启动

## 📚 相关链接

- [Hugging Face Spaces文档](https://huggingface.co/docs/hub/spaces)
- [Docker Spaces指南](https://huggingface.co/docs/hub/spaces-sdks-docker)
- [GitHub Actions文档](https://docs.github.com/en/actions)

部署完成后，您的API将在 `https://huggingface.co/spaces/YOUR_USERNAME/YOUR_SPACE_NAME` 上运行！