"""
Women Safety App - Custom AI Backend Server
A Flask-based REST API for AI-powered safety guidance with emotional support
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import logging
import os
from datetime import datetime
from routes.ai_routes import ai_bp
from routes.health_routes import health_bp
from routes.chat_routes import chat_bp
from config.config import Config
from utils.logger import setup_logger

# Initialize Flask app
app = Flask(__name__)

# Load configuration
app.config.from_object(Config)

# Enable CORS for Flutter app
CORS(app, resources={
    r"/api/*": {
        "origins": ["*"],
        "methods": ["GET", "POST", "OPTIONS"],
        "allow_headers": ["Content-Type", "Authorization"]
    }
})

# Setup logging
logger = setup_logger(__name__)

# Register blueprints (modular routes)
app.register_blueprint(health_bp)
app.register_blueprint(ai_bp)
app.register_blueprint(chat_bp)

# Error handlers
@app.errorhandler(400)
def bad_request(error):
    """Handle bad request errors"""
    return jsonify({
        'success': False,
        'error': 'Bad request',
        'message': str(error),
        'timestamp': datetime.now().isoformat()
    }), 400

@app.errorhandler(404)
def not_found(error):
    """Handle not found errors"""
    return jsonify({
        'success': False,
        'error': 'Not found',
        'message': 'Endpoint does not exist',
        'timestamp': datetime.now().isoformat()
    }), 404

@app.errorhandler(500)
def internal_error(error):
    """Handle internal server errors"""
    logger.error(f"Internal server error: {str(error)}")
    return jsonify({
        'success': False,
        'error': 'Internal server error',
        'message': str(error),
        'timestamp': datetime.now().isoformat()
    }), 500

@app.before_request
def log_request():
    """Log incoming requests"""
    logger.info(f"{request.method} {request.path} - {request.remote_addr}")

@app.after_request
def log_response(response):
    """Log outgoing responses"""
    logger.info(f"Response: {response.status_code}")
    return response

@app.route('/')
def home():
    """Home endpoint - provides API information"""
    return jsonify({
        'name': 'Women Safety App - AI Backend',
        'version': '1.0.0',
        'status': 'running',
        'timestamp': datetime.now().isoformat(),
        'endpoints': {
            'health': '/api/health',
            'ai_chat': '/api/ai/chat',
            'ai_support': '/api/ai/support',
            'ai_area_safety': '/api/ai/area-safety',
            'chat_history': '/api/chat/history',
            'chat_clear': '/api/chat/clear'
        }
    })

if __name__ == '__main__':
    logger.info("Starting Women Safety App - AI Backend Server")
    logger.info(f"Debug mode: {app.debug}")
    logger.info(f"Port: {app.config['PORT']}")
    
    # Run Flask development server
    app.run(
        host=app.config['HOST'],
        port=app.config['PORT'],
        debug=app.config['DEBUG'],
        threaded=True,
        use_reloader=False
    )
