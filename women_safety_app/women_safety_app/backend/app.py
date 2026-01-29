from flask import Flask, request, jsonify
from flask_cors import CORS
import logging
import datetime
import random

import os
import google.generativeai as genai

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# --- CONFIGURATION ---
# TODO: Replace with your actual Gemini API Key from Google AI Studio
# Get one here: https://aistudio.google.com/app/apikey
GEMINI_API_KEY = "AIzaSyBs1jbm0hxUyYzg1_uAyERuXAU3AN7RQ4A"

if GEMINI_API_KEY == "AIzaSyBs1jbm0hxUyYzg1_uAyERuXAU3AN7RQ4A":
    logger.warning("⚠️ GEMINI_API_KEY is not set. AI features will not work until you set it.")
else:
    genai.configure(api_key=GEMINI_API_KEY)

# In-memory chat history
chat_history = []

@app.route('/api/health', methods=['GET'])
def health_check():
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.datetime.now().isoformat(),
        'service': 'Women Safety App AI Backend (Gemini Powered)'
    })

@app.route('/api/ai/chat', methods=['POST'])
def chat():
    data = request.json
    message = data.get('message', '')
    
    logger.info(f"Received chat message: {message}")
    
    # Gemini API Logic - Direct HTTP to avoid library issues
    try:
        if GEMINI_API_KEY == "YOUR_API_KEY_HERE":
            response_text = "⚠️ Please configure your Gemini API Key in backend/app.py to receive AI responses."
        else:
            # List of models to try (using correct model names)
            models_to_try = [
                'gemini-2.0-flash',  # Most stable and available
                'gemini-2.0-flash-exp',
                'gemini-2.0-flash-001',
                'gemini-2.5-flash',  # Latest version
                'gemini-2.0-flash-lite',
            ]
            
            response_text = None
            last_error = "Unknown Error"
            success = False
            
            import requests
            
            # Enhanced system prompt for emotional support
            system_prompt = """You are a compassionate and empowering AI Safety Assistant for women's safety.

Your role is to provide:
1. Emotional Support - Validate feelings, acknowledge concerns
2. Practical Safety Advice - Clear, actionable steps
3. Empowerment - Build confidence and capability
4. Reassurance - Supportive and caring language

When responding:
- Start with empathy and validation
- Acknowledge the user's concerns as legitimate
- Provide practical, step-by-step guidance
- End with reassurance and empowerment
- Use warm, non-judgmental language
- Be concise but comprehensive (max 250 words)

Remember: Your goal is both safety AND emotional wellbeing.
Always validate feelings while providing practical solutions."""
            
            headers = {'Content-Type': 'application/json'}
            
            # Build prompt with system context
            full_prompt = f"{system_prompt}\n\nUser: {message}\n\nAssistant:"
            
            payload = {
                "contents": [{
                    "parts": [{"text": full_prompt}]
                }]
            }
            
            for model_name in models_to_try:
                try:
                    url = f"https://generativelanguage.googleapis.com/v1beta/models/{model_name}:generateContent?key={GEMINI_API_KEY}"
                    
                    logger.info(f"Trying AI model: {model_name}...")
                    api_response = requests.post(url, headers=headers, json=payload, timeout=15)
                    
                    if api_response.status_code == 200:
                        response_json = api_response.json()
                        if 'candidates' in response_json and response_json['candidates']:
                            candidate = response_json['candidates'][0]
                            if 'content' in candidate and 'parts' in candidate['content']:
                                response_text = candidate['content']['parts'][0]['text']
                                success = True
                                logger.info(f"✅ Success with {model_name}")
                                break  # Exit loop on success
                    else:
                        error_msg = f"{api_response.status_code} - {api_response.text[:200]}"
                        logger.warning(f"❌ Failed {model_name}: {error_msg}")
                        last_error = error_msg
                        
                        # If 429 (Rate Limit/Quota), try next model immediately
                        if api_response.status_code == 429:
                            error_json = api_response.json()
                            if 'error' in error_json and 'details' in error_json['error']:
                                for detail in error_json['error']['details']:
                                    if 'RetryInfo' in detail.get('@type', ''):
                                        retry_delay = detail.get('retryDelay', '0s')
                                        logger.warning(f"Rate limit hit, retry after {retry_delay}, trying next model...")
                            continue
                            
                except requests.exceptions.Timeout:
                    logger.warning(f"Timeout trying {model_name}")
                    last_error = f"Timeout connecting to {model_name}"
                    continue
                except Exception as model_err:
                    logger.error(f"Error trying {model_name}: {model_err}")
                    last_error = str(model_err)
                    continue
            
            # If we didn't get a successful response
            if not success or response_text is None:
                logger.error(f"All models failed. Last error: {last_error}")
                response_text = f"""I'm having trouble connecting to my AI service right now, but I'm here for you. 

Your safety is important. Here's what you can do:
1. Trust your instincts - if something feels wrong, it probably is
2. Get to a safe place - go to a populated, well-lit area
3. Contact someone - reach out to a trusted friend or family member
4. Call emergency services if needed - 911 or your local emergency number

I apologize for the technical difficulty. Please try again in a moment, or use the emergency features in the app if you need immediate help."""
            
    except Exception as e:
        logger.error(f"Gemini API Exception: {e}")
        response_text = f"""I encountered a technical issue, but I want to make sure you're safe.

If you're in immediate danger, please:
- Call emergency services (911 or your local number)
- Go to a safe, public place
- Contact someone you trust

For general safety concerns, please try asking again in a moment."""

    chat_history.append({'role': 'user', 'content': message})
    chat_history.append({'role': 'assistant', 'content': response_text})
    
    return jsonify({
        'response': response_text,
        'timestamp': datetime.datetime.now().isoformat()
    })

@app.route('/api/ai/support', methods=['POST'])
def support():
    data = request.json
    concern = data.get('concern', '')
    
    logger.info(f"Received support request: {concern}")
    
    # Use Gemini API for emotional support
    try:
        if GEMINI_API_KEY == "YOUR_API_KEY_HERE":
            response_text = "You are not alone. Your safety and well-being are important. Remember to trust your instincts."
        else:
            import requests
            
            system_prompt = """You are a compassionate AI Safety Assistant providing emotional support. 
The user is sharing a concern or feeling anxious about their safety. 

Respond with:
- Validation of their feelings
- Empathy and understanding
- Practical reassurance
- Empowerment and confidence building
- Supportive, warm language

Keep your response under 200 words and focus on emotional support."""
            
            prompt = f"{system_prompt}\n\nUser's concern: {concern}\n\nAssistant:"
            
            headers = {'Content-Type': 'application/json'}
            payload = {
                "contents": [{
                    "parts": [{"text": prompt}]
                }]
            }
            
            # Try multiple models
            models_to_try = ['gemini-2.0-flash', 'gemini-2.0-flash-lite', 'gemini-2.5-flash']
            response_text = None
            last_status_code = None
            
            for model_name in models_to_try:
                try:
                    url = f"https://generativelanguage.googleapis.com/v1beta/models/{model_name}:generateContent?key={GEMINI_API_KEY}"
                    api_response = requests.post(url, headers=headers, json=payload, timeout=15)
                    last_status_code = api_response.status_code
                    
                    if api_response.status_code == 200:
                        response_json = api_response.json()
                        if 'candidates' in response_json and response_json['candidates']:
                            candidate = response_json['candidates'][0]
                            if 'content' in candidate and 'parts' in candidate['content']:
                                response_text = candidate['content']['parts'][0]['text']
                                logger.info(f"✅ Success with {model_name}")
                                break
                    elif api_response.status_code == 429:
                        # Quota exceeded - try next model
                        logger.warning(f"Quota exceeded for {model_name}, trying next model...")
                        continue
                    else:
                        logger.warning(f"Gemini API error {api_response.status_code} for {model_name}")
                        continue
                except Exception as e:
                    logger.error(f"Error with {model_name}: {e}")
                    continue
            
            if not response_text:
                # Check if it's a quota issue
                if last_status_code == 429:
                    response_text = """I'm currently experiencing high demand, but I'm here for you.

Your safety is important. Here's what you can do right now:
1. Trust your instincts - if something feels wrong, it probably is
2. Get to a safe place - go to a populated, well-lit area
3. Contact someone - reach out to a trusted friend or family member
4. Call emergency services if needed - 911 or your local emergency number

Please try again in a moment, or use the emergency features in the app if you need immediate help."""
                else:
                    response_text = "You are not alone. Your safety and well-being are important. Remember to trust your instincts."
                
    except Exception as e:
        logger.error(f"Error in support endpoint: {e}")
        response_text = "You are not alone. Your safety and well-being are important. Remember to trust your instincts."
    
    return jsonify({
        'response': response_text,
        'timestamp': datetime.datetime.now().isoformat()
    })

@app.route('/api/ai/area-safety', methods=['POST'])
def area_safety():
    data = request.json
    area_name = data.get('area_name', 'Unknown Location')
    time_of_day = data.get('time_of_day', datetime.datetime.now().strftime("%I:%M %p"))
    
    logger.info(f"Analyzing safety for: {area_name} at {time_of_day}")

    # --- 1. TRUSTED ZONE OVERRIDE ---
    if "chandigarh university" in area_name.lower():
        return jsonify({
            'ai_analysis': "This location is a Verified Trusted Zone. Security is active 24/7.",
            'safety_score': 98,
            'timestamp': datetime.datetime.now().isoformat()
        })

    # --- 2. DEFAULT LOGIC (User Requested) ---
    # Default to SAFE
    safety_score = 92
    analysis = "This area is generally considered safe. Maintain normal awareness."

    # Simple Night Check
    is_night = False
    try:
        if "PM" in time_of_day.upper():
            hour = int(time_of_day.split(':')[0])
            if hour == 12: hour = 0
            if hour >= 8 or hour == 0: is_night = True
        elif "AM" in time_of_day.upper():
            hour = int(time_of_day.split(':')[0])
            if hour == 12: hour = 0
            if hour < 6: is_night = True
    except:
        pass

    # Night time penalty
    if is_night:
        safety_score = 85
        analysis = "It is night time. Areas are generally less safe than day. Stay alert."

    return jsonify({
        'ai_analysis': analysis,
        'safety_score': safety_score,
        'timestamp': datetime.datetime.now().isoformat()
    })

@app.route('/api/ai/threat-assessment', methods=['POST'])
def threat_assessment():
    data = request.json
    threat = data.get('threat', '')
    
    logger.info(f"Threat assessment for: {threat}")
    
    # Use Gemini API for threat assessment
    try:
        if GEMINI_API_KEY == "YOUR_API_KEY_HERE":
            response_text = "Please prioritize your physical safety. Move to a populated area immediately if possible. Call emergency services if needed."
        else:
            import requests
            
            system_prompt = """You are an AI Safety Assistant helping assess a potential threat situation.

The user is describing a threat or dangerous situation. Provide:
1. Immediate safety actions (prioritize getting to safety)
2. Assessment of the threat level
3. Specific steps to take
4. When to contact emergency services
5. Reassurance and support

Be direct, practical, and prioritize immediate safety. Keep response under 200 words."""
            
            prompt = f"{system_prompt}\n\nThreat description: {threat}\n\nAssistant:"
            
            headers = {'Content-Type': 'application/json'}
            payload = {
                "contents": [{
                    "parts": [{"text": prompt}]
                }]
            }
            
            # Try multiple models
            models_to_try = ['gemini-2.0-flash', 'gemini-2.0-flash-lite', 'gemini-2.5-flash']
            response_text = None
            
            for model_name in models_to_try:
                try:
                    url = f"https://generativelanguage.googleapis.com/v1beta/models/{model_name}:generateContent?key={GEMINI_API_KEY}"
                    api_response = requests.post(url, headers=headers, json=payload, timeout=15)
                    
                    if api_response.status_code == 200:
                        response_json = api_response.json()
                        if 'candidates' in response_json and response_json['candidates']:
                            candidate = response_json['candidates'][0]
                            if 'content' in candidate and 'parts' in candidate['content']:
                                response_text = candidate['content']['parts'][0]['text']
                                logger.info(f"✅ Success with {model_name}")
                                break
                    elif api_response.status_code == 429:
                        # Quota exceeded - try next model
                        logger.warning(f"Quota exceeded for {model_name}, trying next model...")
                        continue
                    else:
                        logger.warning(f"Gemini API error {api_response.status_code} for {model_name}")
                        continue
                except Exception as e:
                    logger.error(f"Error with {model_name}: {e}")
                    continue
            
            if not response_text:
                # Check if it's a quota issue
                if api_response.status_code == 429:
                    response_text = """I'm currently experiencing high demand, but your safety is my priority.

If you're in immediate danger:
- Call emergency services NOW (911 or your local number)
- Get to a safe, public place immediately
- Contact someone you trust right away

For general safety concerns, please try again in a moment or use the emergency features in the app."""
                else:
                    response_text = "Please prioritize your physical safety. Move to a populated area immediately if possible. Call emergency services if needed."
                
    except Exception as e:
        logger.error(f"Error in threat assessment: {e}")
        response_text = "Please prioritize your physical safety. Move to a populated area immediately if possible. Call emergency services if needed."
    
    return jsonify({
        'response': response_text,
        'timestamp': datetime.datetime.now().isoformat()
    })

@app.route('/api/chat/clear', methods=['POST'])
def clear_history():
    global chat_history
    chat_history = []
    logger.info("Chat history cleared")
    return jsonify({'status': 'success', 'message': 'History cleared'})

if __name__ == '__main__':
    print("🚀 Starting AI Backend on port 5000...")
    app.run(host='0.0.0.0', port=5000, debug=True)
