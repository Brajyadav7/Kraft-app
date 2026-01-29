"""
Chat history routes
"""

from flask import Blueprint, jsonify
import logging
from datetime import datetime
from ai_models.ai_handler import AIModelHandler

logger = logging.getLogger(__name__)

chat_bp = Blueprint('chat', __name__, url_prefix='/api/chat')

# Initialize AI handler
ai_handler = AIModelHandler(model_type='custom')

@chat_bp.route('/history', methods=['GET'])
def get_chat_history():
    """
    Get chat history
    Returns all messages in the current conversation
    """
    try:
        history = ai_handler.get_history()
        
        return jsonify({
            'success': True,
            'messages': history,
            'count': len(history),
            'timestamp': datetime.now().isoformat()
        }), 200
    
    except Exception as e:
        logger.error(f"Error getting chat history: {str(e)}")
        return jsonify({
            'success': False,
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }), 500

@chat_bp.route('/clear', methods=['POST'])
def clear_chat_history():
    """
    Clear chat history
    Resets the conversation
    """
    try:
        ai_handler.clear_history()
        
        logger.info("Chat history cleared")
        
        return jsonify({
            'success': True,
            'message': 'Chat history cleared',
            'timestamp': datetime.now().isoformat()
        }), 200
    
    except Exception as e:
        logger.error(f"Error clearing chat history: {str(e)}")
        return jsonify({
            'success': False,
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }), 500

@chat_bp.route('/stats', methods=['GET'])
def chat_stats():
    """
    Get chat statistics
    """
    try:
        history = ai_handler.get_history()
        
        user_messages = len([m for m in history if m['role'] == 'user'])
        ai_messages = len([m for m in history if m['role'] == 'assistant'])
        
        return jsonify({
            'success': True,
            'stats': {
                'total_messages': len(history),
                'user_messages': user_messages,
                'ai_messages': ai_messages,
                'average_response_length': sum(len(m['content']) for m in history) // max(len(history), 1)
            },
            'timestamp': datetime.now().isoformat()
        }), 200
    
    except Exception as e:
        logger.error(f"Error getting chat stats: {str(e)}")
        return jsonify({
            'success': False,
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }), 500
