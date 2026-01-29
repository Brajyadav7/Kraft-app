"""
AI routes for safety guidance and emotional support
"""

from flask import Blueprint, request, jsonify
import logging
from datetime import datetime
from ai_models.ai_handler import AIModelHandler

logger = logging.getLogger(__name__)

ai_bp = Blueprint('ai', __name__, url_prefix='/api/ai')

# Initialize AI handler
ai_handler = AIModelHandler(model_type='custom')

@ai_bp.route('/chat', methods=['POST'])
def ai_chat():
    """
    Main AI chat endpoint
    Accepts user message and returns AI response with emotional support
    """
    try:
        data = request.get_json()
        
        if not data or 'message' not in data:
            return jsonify({
                'success': False,
                'error': 'Missing message in request'
            }), 400
        
        user_message = data.get('message', '').strip()
        
        if not user_message:
            return jsonify({
                'success': False,
                'error': 'Message cannot be empty'
            }), 400
        
        # Get context if provided
        context = data.get('context', {})
        
        logger.info(f"AI Chat request: {user_message[:100]}")
        
        # Generate response
        response = ai_handler.generate_response(user_message, context)
        
        return jsonify(response), 200
    
    except Exception as e:
        logger.error(f"Error in AI chat: {str(e)}")
        return jsonify({
            'success': False,
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }), 500

@ai_bp.route('/support', methods=['POST'])
def emotional_support():
    """
    Emotional support endpoint
    Specifically for anxiety, fear, and emotional concerns
    """
    try:
        data = request.get_json()
        
        if not data or 'concern' not in data:
            return jsonify({
                'success': False,
                'error': 'Missing concern in request'
            }), 400
        
        concern = data.get('concern', '').strip()
        
        if not concern:
            return jsonify({
                'success': False,
                'error': 'Concern cannot be empty'
            }), 400
        
        logger.info(f"Emotional support request: {concern[:100]}")
        
        # Generate emotional support response
        message_with_context = f"I'm feeling: {concern}"
        response = ai_handler.generate_response(message_with_context, {
            'type': 'emotional_support',
            'timestamp': datetime.now().isoformat()
        })
        
        return jsonify(response), 200
    
    except Exception as e:
        logger.error(f"Error in emotional support: {str(e)}")
        return jsonify({
            'success': False,
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }), 500

@ai_bp.route('/area-safety', methods=['POST'])
def area_safety():
    """
    Area safety analysis endpoint
    Analyzes safety of a given location
    """
    try:
        data = request.get_json()
        
        # Required fields
        latitude = data.get('latitude')
        longitude = data.get('longitude')
        
        if latitude is None or longitude is None:
            return jsonify({
                'success': False,
                'error': 'Missing latitude or longitude'
            }), 400
        
        # Optional fields
        radius = data.get('radius', 500)
        area_name = data.get('area_name', f"Area at ({latitude}, {longitude})")
        time_of_day = data.get('time_of_day', 'unknown')
        
        logger.info(f"Area safety request for {area_name}")
        
        # Process area safety
        area_analysis = ai_handler.process_area_safety(latitude, longitude, radius)
        
        # Get AI analysis
        message = f"Is the {area_name} area safe at {time_of_day}?"
        ai_response = ai_handler.generate_response(message, {
            'type': 'area_analysis',
            'location': {'latitude': latitude, 'longitude': longitude},
            'radius': radius
        })
        
        return jsonify({
            'success': True,
            'area_analysis': area_analysis,
            'ai_analysis': ai_response['response'],
            'timestamp': datetime.now().isoformat()
        }), 200
    
    except Exception as e:
        logger.error(f"Error in area safety: {str(e)}")
        return jsonify({
            'success': False,
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }), 500

@ai_bp.route('/threat-assessment', methods=['POST'])
def threat_assessment():
    """
    Threat assessment endpoint
    For emergency situations and threat evaluation
    """
    try:
        data = request.get_json()
        
        if not data or 'threat' not in data:
            return jsonify({
                'success': False,
                'error': 'Missing threat description'
            }), 400
        
        threat = data.get('threat', '').strip()
        
        if not threat:
            return jsonify({
                'success': False,
                'error': 'Threat description cannot be empty'
            }), 400
        
        logger.info(f"Threat assessment request: {threat[:100]}")
        
        # Generate emergency response
        message = f"Emergency situation: {threat}"
        response = ai_handler.generate_response(message, {
            'type': 'threat_assessment',
            'severity': 'high'
        })
        
        return jsonify({
            'success': True,
            'response': response['response'],
            'emergency': True,
            'timestamp': datetime.now().isoformat()
        }), 200
    
    except Exception as e:
        logger.error(f"Error in threat assessment: {str(e)}")
        return jsonify({
            'success': False,
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }), 500
