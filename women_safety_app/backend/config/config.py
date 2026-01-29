"""
Configuration settings for Women Safety App Backend
"""

import os
from datetime import timedelta

class Config:
    """Base configuration"""
    
    # Server settings
    HOST = os.getenv('FLASK_HOST', '0.0.0.0')
    PORT = int(os.getenv('FLASK_PORT', 5000))
    DEBUG = os.getenv('FLASK_DEBUG', False)
    
    # AI Model settings
    MODEL_TYPE = os.getenv('AI_MODEL_TYPE', 'transformers')  # 'transformers', 'custom', 'api'
    MODEL_NAME = os.getenv('AI_MODEL_NAME', 'gpt2')  # Model to use
    MAX_INPUT_LENGTH = 512
    MAX_OUTPUT_LENGTH = 250
    
    # Chat settings
    CHAT_HISTORY_LIMIT = 20  # Keep last 20 messages
    SESSION_TIMEOUT = timedelta(hours=24)
    
    # API settings
    TIMEOUT = 30  # Request timeout in seconds
    RATE_LIMIT = '100/hour'  # Rate limiting
    
    # Emotional Support settings
    ENABLE_EMOTIONAL_SUPPORT = True
    EMPATHY_MODE = True
    
    # Database settings (if needed)
    DATABASE_URL = os.getenv('DATABASE_URL', 'sqlite:///chat_history.db')
    
    # Logging
    LOG_LEVEL = os.getenv('LOG_LEVEL', 'INFO')
    LOG_FILE = 'logs/backend.log'
    
    # CORS settings
    CORS_ORIGINS = ['*']
    
    # Security
    SECRET_KEY = os.getenv('SECRET_KEY', 'dev-secret-key-change-in-production')
    JSON_SORT_KEYS = False

class DevelopmentConfig(Config):
    """Development configuration"""
    DEBUG = True
    LOG_LEVEL = 'DEBUG'

class ProductionConfig(Config):
    """Production configuration"""
    DEBUG = False
    LOG_LEVEL = 'WARNING'
    CORS_ORIGINS = [
        'http://localhost:8080',
        'https://yourdomain.com'
    ]

class TestingConfig(Config):
    """Testing configuration"""
    TESTING = True
    DEBUG = True
    DATABASE_URL = 'sqlite:///:memory:'
    LOG_LEVEL = 'DEBUG'

# Load appropriate config
config_name = os.getenv('FLASK_ENV', 'development')
if config_name == 'production':
    app_config = ProductionConfig
elif config_name == 'testing':
    app_config = TestingConfig
else:
    app_config = DevelopmentConfig
