FROM python:3.11-slim

WORKDIR /app

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

# 暴露端口
EXPOSE 8000

# 设置环境变量
ENV PYTHONUNBUFFERED=1
ENV DEBUG_MODE=false

# 使用启动脚本
CMD ["/app/start.sh"]