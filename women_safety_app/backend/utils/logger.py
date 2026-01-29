"""
Logging configuration for Women Safety App Backend
"""

import logging
import os
from datetime import datetime

def setup_logger(name):
    """Setup logger with file and console handlers"""
    
    # Create logs directory if it doesn't exist
    os.makedirs('logs', exist_ok=True)
    
    # Create logger
    logger = logging.getLogger(name)
    logger.setLevel(logging.DEBUG)
    
    # Log file path
    log_file = f"logs/backend_{datetime.now().strftime('%Y%m%d')}.log"
    
    # Create formatters
    detailed_formatter = logging.Formatter(
        '[%(asctime)s] %(levelname)s in %(name)s: %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )
    
    # File handler
    file_handler = logging.FileHandler(log_file)
    file_handler.setLevel(logging.DEBUG)
    file_handler.setFormatter(detailed_formatter)
    
    # Console handler
    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.INFO)
    console_formatter = logging.Formatter(
        '%(levelname)s: %(message)s'
    )
    console_handler.setFormatter(console_formatter)
    
    # Add handlers to logger
    if not logger.handlers:  # Avoid duplicate handlers
        logger.addHandler(file_handler)
        logger.addHandler(console_handler)
    
    return logger
