"""
Health check routes
"""

from flask import Blueprint, jsonify
import logging
from datetime import datetime

logger = logging.getLogger(__name__)

health_bp = Blueprint('health', __name__, url_prefix='/api')

@health_bp.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'service': 'Women Safety App AI Backend',
        'timestamp': datetime.now().isoformat()
    }), 200

@health_bp.route('/status', methods=['GET'])
def status():
    """Get backend status"""
    return jsonify({
        'status': 'online',
        'service': 'Women Safety App AI Backend',
        'version': '1.0.0',
        'timestamp': datetime.now().isoformat()
    }), 200
