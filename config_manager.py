#!/usr/bin/env python3
"""
配置管理器 - 从环境变量更新jetbrainsai.json文件
"""
import os
import json
import sys
from typing import List, Dict, Any

def load_existing_config(config_file: str = "jetbrainsai.json") -> List[Dict[str, Any]]:
    """加载现有的配置文件"""
    try:
        with open(config_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
            if isinstance(data, list):
                return data
            else:
                print(f"警告: {config_file} 格式不正确，应为数组格式")
                return []
    except FileNotFoundError:
        print(f"配置文件 {config_file} 不存在，将创建新文件")
        return []
    except json.JSONDecodeError as e:
        print(f"解析 {config_file} 时出错: {e}")
        return []

def update_config_from_env() -> bool:
    """从环境变量更新配置"""
    # 从环境变量获取JWT tokens
    jwt_tokens = []
    
    # 支持多种环境变量格式
    # 方式1: JWT_TOKEN_1, JWT_TOKEN_2, 等
    for i in range(1, 11):  # 支持最多10个JWT token
        token_key = f"JWT_TOKEN_{i}"
        token_value = os.getenv(token_key)
        if token_value and token_value.strip():
            jwt_tokens.append(token_value.strip())
    
    # 方式2: JWT_TOKENS (逗号分隔)
    jwt_tokens_env = os.getenv("JWT_TOKENS")
    if jwt_tokens_env:
        tokens_from_env = [token.strip() for token in jwt_tokens_env.split(",") if token.strip()]
        jwt_tokens.extend(tokens_from_env)
    
    # 方式3: 从现有配置文件获取更多字段
    existing_config = load_existing_config()
    
    # 如果没有从环境变量获取到JWT tokens，但存在现有配置，则保持现有配置
    if not jwt_tokens and existing_config:
        print("未找到环境变量中的JWT tokens，保持现有配置")
        return True
    
    # 如果既没有环境变量也没有现有配置，创建示例配置
    if not jwt_tokens:
        print("未找到JWT tokens，创建示例配置")
        jwt_tokens = ["your-jwt-here-1", "your-jwt-here-2"]
    
    # 构建新的配置
    new_config = []
    
    # 合并现有配置和新的JWT tokens
    for i, jwt_token in enumerate(jwt_tokens):
        # 尝试从现有配置中找到对应的项
        existing_item = None
        if i < len(existing_config):
            existing_item = existing_config[i]
        
        # 构建配置项
        config_item = {
            "jwt": jwt_token
        }
        
        # 如果存在现有配置，保留其他字段
        if existing_item and isinstance(existing_item, dict):
            for key, value in existing_item.items():
                if key not in config_item:  # 不覆盖jwt
                    config_item[key] = value
        
        # 从环境变量获取其他可能的字段
        license_id_key = f"LICENSE_ID_{i+1}"
        authorization_key = f"AUTHORIZATION_{i+1}"
        
        license_id = os.getenv(license_id_key)
        authorization = os.getenv(authorization_key)
        
        if license_id:
            config_item["licenseId"] = license_id
        if authorization:
            config_item["authorization"] = authorization
            
        # 设置默认值
        config_item.setdefault("last_updated", 0)
        config_item.setdefault("has_quota", True)
        config_item.setdefault("last_quota_check", 0)
        
        new_config.append(config_item)
    
    # 写入新配置
    try:
        with open("jetbrainsai.json", 'w', encoding='utf-8') as f:
            json.dump(new_config, f, indent=2, ensure_ascii=False)
        print(f"✅ 成功更新配置文件，包含 {len(new_config)} 个JWT tokens")
        
        # 打印配置摘要（隐藏敏感信息）
        for i, item in enumerate(new_config, 1):
            jwt = item.get("jwt", "")
            jwt_preview = f"{jwt[:8]}...{jwt[-8:]}" if len(jwt) > 16 else "***"
            license_id = item.get("licenseId", "未设置")
            print(f"  Token {i}: {jwt_preview} (License: {license_id})")
        
        return True
    except Exception as e:
        print(f"❌ 写入配置文件时出错: {e}")
        return False

def main():
    """主函数"""
    print("🔧 JetBrains AI 配置管理器")
    print("正在从环境变量更新配置...")
    
    # 显示环境变量信息
    jwt_env_vars = [key for key in os.environ.keys() if key.startswith('JWT_TOKEN_')]
    if jwt_env_vars:
        print(f"发现 {len(jwt_env_vars)} 个JWT环境变量: {', '.join(jwt_env_vars)}")
    
    other_env_vars = [key for key in os.environ.keys() if key.startswith(('LICENSE_ID_', 'AUTHORIZATION_', 'JWT_TOKENS'))]
    if other_env_vars:
        print(f"发现其他相关环境变量: {', '.join(other_env_vars)}")
    
    success = update_config_from_env()
    
    if success:
        print("✅ 配置更新完成")
        sys.exit(0)
    else:
        print("❌ 配置更新失败")
        sys.exit(1)

if __name__ == "__main__":
    main()