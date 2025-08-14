FROM python:3.11-slim

# 构建时参数
ARG VERSION=unknown
ARG BUILD_DATE=unknown
ARG VCS_REF=unknown

# 添加标签
LABEL org.opencontainers.image.title="JetBrains AI API"
LABEL org.opencontainers.image.description="JetBrains AI API服务"
LABEL org.opencontainers.image.version="${VERSION}"
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.revision="${VCS_REF}"
LABEL org.opencontainers.image.source="https://github.com/${GITHUB_REPOSITORY}"

WORKDIR /app

# 安装系统依赖（包含curl用于健康检查）
RUN apt-get update && apt-get install -y \
    gcc \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 安装依赖
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 复制应用文件
COPY main.py .
COPY config_manager.py .
COPY start.sh .

# 设置启动脚本权限
RUN chmod +x /app/start.sh

# 复制配置文件（如果存在）
COPY jetbrainsai.json* ./
COPY client_api_keys.json* ./
COPY models.json* ./

# 创建版本信息文件
RUN echo "VERSION=${VERSION}" > /app/version.info && \
    echo "BUILD_DATE=${BUILD_DATE}" >> /app/version.info && \
    echo "VCS_REF=${VCS_REF}" >> /app/version.info

# 暴露端口
EXPOSE 8000

# 设置环境变量
ENV PYTHONUNBUFFERED=1
ENV DEBUG_MODE=false

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# 使用启动脚本
CMD ["/app/start.sh"]