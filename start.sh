#!/bin/bash
set -e

echo "🚀 启动 JetBrains AI API 服务器..."

# 运行配置管理器来更新配置文件
echo "📝 更新配置文件..."
python config_manager.py

# 检查配置文件是否存在，如果不存在则创建默认配置
if [ ! -f "jetbrainsai.json" ]; then
    echo "创建默认 jetbrainsai.json..."
    echo '[{"jwt": "your-jwt-here"}]' > jetbrainsai.json
fi

if [ ! -f "client_api_keys.json" ]; then
    echo "创建默认 client_api_keys.json..."
    echo '["sk-your-custom-key-here"]' > client_api_keys.json
fi

if [ ! -f "models.json" ]; then
    echo "创建默认 models.json..."
    cat > models.json << 'MODELS_EOF'
{
    "models": ["anthropic-claude-3.5-sonnet"],
    "anthropic_model_mappings": {
        "claude-3.5-sonnet": "anthropic-claude-3.5-sonnet",
        "sonnet": "anthropic-claude-3.5-sonnet"
    }
}
MODELS_EOF
fi

echo "✅ 配置文件就绪"
echo "🌐 启动API服务器..."

# 启动应用
exec uvicorn main:app --host 0.0.0.0 --port 8000