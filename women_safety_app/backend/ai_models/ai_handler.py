"""
AI Model Handler for Women Safety App
Handles various AI models and response generation
"""

import logging
import json
from typing import Dict, List, Optional
from datetime import datetime

logger = logging.getLogger(__name__)

class AIModelHandler:
    """Main AI model handler"""
    
    def __init__(self, model_type: str = 'custom'):
        """
        Initialize AI model handler
        
        Args:
            model_type: Type of model ('custom', 'transformers', 'api')
        """
        self.model_type = model_type
        self.chat_history = []
        self.system_prompt = self._get_system_prompt()
        
        logger.info(f"Initializing AI Model Handler - Type: {model_type}")
    
    def _get_system_prompt(self) -> str:
        """Get the system prompt for emotional support"""
        return """You are a compassionate and empowering AI Safety Assistant for women's safety.

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
Always validate feelings while providing practical solutions.
"""
    
    def generate_response(self, user_message: str, context: Optional[Dict] = None) -> Dict:
        """
        Generate AI response with emotional support
        
        Args:
            user_message: User's input message
            context: Optional context data (location, time, etc.)
        
        Returns:
            Dictionary with AI response and metadata
        """
        try:
            logger.info(f"Processing message: {user_message[:50]}...")
            
            # Add to chat history
            self.chat_history.append({
                'role': 'user',
                'content': user_message,
                'timestamp': datetime.now().isoformat()
            })
            
            # Generate response based on model type
            if self.model_type == 'transformers':
                response = self._generate_with_transformers(user_message, context)
            elif self.model_type == 'custom':
                response = self._generate_with_custom_model(user_message, context)
            elif self.model_type == 'api':
                response = self._generate_with_api(user_message, context)
            else:
                response = self._generate_fallback_response(user_message)
            
            # Add to chat history
            self.chat_history.append({
                'role': 'assistant',
                'content': response,
                'timestamp': datetime.now().isoformat()
            })
            
            # Keep chat history limited
            if len(self.chat_history) > 20:
                self.chat_history = self.chat_history[-20:]
            
            return {
                'success': True,
                'response': response,
                'timestamp': datetime.now().isoformat(),
                'model_type': self.model_type
            }
        
        except Exception as e:
            logger.error(f"Error generating response: {str(e)}")
            return {
                'success': False,
                'error': str(e),
                'response': self._generate_fallback_response(user_message),
                'timestamp': datetime.now().isoformat()
            }
    
    def _generate_with_transformers(self, user_message: str, context: Optional[Dict] = None) -> str:
        """Generate response using transformers library (Hugging Face models)"""
        try:
            from transformers import pipeline
            
            # Use text generation pipeline
            generator = pipeline('text-generation', model='gpt2')
            
            # Create prompt with emotional support context
            prompt = f"{self.system_prompt}\n\nUser: {user_message}\n\nAssistant:"
            
            # Generate response
            result = generator(prompt, max_length=300, num_return_sequences=1)
            response = result[0]['generated_text'].split("Assistant:")[-1].strip()
            
            return response
        
        except ImportError:
            logger.warning("Transformers library not installed, using fallback")
            return self._generate_fallback_response(user_message)
        except Exception as e:
            logger.error(f"Error in transformers generation: {str(e)}")
            return self._generate_fallback_response(user_message)
    
    def _generate_with_custom_model(self, user_message: str, context: Optional[Dict] = None) -> str:
        """Generate response using custom rule-based model"""
        
        # Emotional support keywords and responses
        emotional_keywords = {
            'scared': self._respond_to_fear,
            'anxious': self._respond_to_anxiety,
            'afraid': self._respond_to_fear,
            'uncomfortable': self._respond_to_discomfort,
            'help': self._respond_to_help,
            'emergency': self._respond_to_emergency,
            'followed': self._respond_to_threat,
            'alone': self._respond_to_isolation,
            'safe': self._respond_to_safety_check,
            'area': self._respond_to_area_check,
        }
        
        # Check for keywords in message
        message_lower = user_message.lower()
        for keyword, handler in emotional_keywords.items():
            if keyword in message_lower:
                return handler(user_message)
        
        # Default response
        return self._generate_general_response(user_message)
    
    def _generate_with_api(self, user_message: str, context: Optional[Dict] = None) -> str:
        """Generate response using external API (for future integration)"""
        # Can be integrated with OpenAI, Anthropic, etc. in future
        logger.info("API-based generation - using fallback for now")
        return self._generate_fallback_response(user_message)
    
    # Response handlers for custom model
    def _respond_to_fear(self, message: str) -> str:
        return """I understand why you feel scared, and your concerns are completely valid. Fear is a 
natural response to uncertain or potentially unsafe situations.

Here's what you can do:
1. **Acknowledge your fear** - It's your instinct protecting you
2. **Trust your gut** - If something feels wrong, it probably is
3. **Tell someone** - Share your location and plans with a trusted person
4. **Stay visible** - Stay in populated, well-lit areas
5. **Keep connected** - Ensure your phone is charged
6. **Have a plan** - Know safe places and emergency contacts

Remember: You are capable and strong. Fear doesn't mean you're weak - it means you're aware. 
With these precautions, you can navigate confidently. You're not alone in this. 💚"""
    
    def _respond_to_anxiety(self, message: str) -> str:
        return """I completely understand your anxiety, and it's valid. Many women experience anxiety 
about their safety, especially when traveling or in unfamiliar situations.

Here's how to manage anxiety while staying safe:
1. **Prepare** - Plan your route beforehand
2. **Breathe** - Deep breathing calms your nervous system
3. **Connect** - Text friends about your whereabouts
4. **Focus** - Keep your mind engaged (music, podcasts)
5. **Celebrate** - Acknowledge your courage
6. **Practice** - Start small and build confidence gradually

Your anxiety is not weakness - it's awareness. With each safe journey, your confidence will grow.
You have the strength to do this. Take it one step at a time. 💚"""
    
    def _respond_to_discomfort(self, message: str) -> str:
        return """Your discomfort is telling you something important. Trust that feeling.

When you feel uncomfortable:
1. **Acknowledge it** - Don't ignore your instincts
2. **Remove yourself** - Leave the situation if possible
3. **Go to safety** - Find a public, populated place
4. **Tell someone** - Contact a trusted friend or family
5. **Don't apologize** - Your safety comes first
6. **Debrief** - Talk about it to process the experience

Remember: You have every right to feel safe and comfortable. Your instincts are protecting you. 
Listen to them. You deserve to be in environments where you feel good. 💚"""
    
    def _respond_to_help(self, message: str) -> str:
        return """I'm here to help you. Your safety and well-being are important.

Here's what you can do:
1. **Describe the situation** - Tell me specifically what concerns you
2. **Share context** - Time, location, and people involved matter
3. **Ask directly** - What specific help do you need?
4. **Trust resources** - Emergency contacts and services are available
5. **Reach out** - Don't isolate yourself in difficult situations

Whatever you're facing, remember: You are not alone. Help is available. Emergency services 
are just a call away. I'm here to support you with guidance and encouragement. 💚"""
    
    def _respond_to_emergency(self, message: str) -> str:
        return """🚨 EMERGENCY RESPONSE 🚨

If you are in immediate danger:
1. **CALL EMERGENCY IMMEDIATELY** - Dial 911 (or your country's emergency number)
2. **Go to safety** - Leave the situation if possible
3. **Tell someone** - Inform a trusted person of your location
4. **Stay on the line** - Keep communication with emergency services
5. **Provide details** - Location, description of threat, number of people

This AI is support and guidance, NOT emergency response.
For immediate danger, always call emergency services first.

Your safety is the priority. Get help NOW. 💚"""
    
    def _respond_to_threat(self, message: str) -> str:
        return """This is serious, and I'm taking your safety very seriously.

If you're being followed:
1. **Trust your instincts** - If you feel threatened, you probably are
2. **Go to safety** - Head to a police station, hospital, or public place
3. **Be visible** - Stay in well-lit, populated areas
4. **Don't go home** - Don't lead them to your residence
5. **Call for help** - Contact police or emergency services
6. **Tell someone** - Inform a trusted person immediately

If in immediate danger, CALL 911 NOW.

Your safety is paramount. Don't hesitate to reach out for help. 💚"""
    
    def _respond_to_isolation(self, message: str) -> str:
        return """I hear you. Feeling alone can make safety concerns feel bigger and scarier.

You're not truly alone:
1. **Connect with people** - Reach out to friends, family, or support groups
2. **Build your network** - Find trusted people in your life
3. **Join communities** - Safety groups, hobby groups, or online communities
4. **Professional support** - Counselors and therapists are available
5. **This app** - I'm here 24/7 for support and guidance
6. **Emergency services** - Always available when you need them

Remember: Isolation amplifies fear. Connection builds confidence. You deserve community 
and support. Reach out. You don't have to do this alone. 💚"""
    
    def _respond_to_safety_check(self, message: str) -> str:
        return """Great question - assessing safety is smart thinking.

To evaluate if an area is safe:
1. **Time of day** - Daytime = more people = safer
2. **Visibility** - Well-lit streets with clear sightlines
3. **Foot traffic** - More people = more witnesses and help
4. **Nearby services** - Police, hospitals, businesses
5. **Your instinct** - How do you FEEL about the area?
6. **Get updates** - Check recent incident reports if available

Safe areas typically have:
- Good lighting
- Active businesses and people
- Emergency services nearby
- Community presence
- Low reported incidents

Trust your gut feeling about places. If it doesn't feel right, avoid it. 💚"""
    
    def _respond_to_area_check(self, message: str) -> str:
        return """I can help you assess an area's safety.

To give you accurate guidance, I need to know:
1. **Which area?** - Specific location or neighborhood
2. **What time?** - Day, evening, night?
3. **Your activity** - What will you be doing?
4. **Travel method** - Walking, driving, transit?
5. **With who** - Alone, with friends?

Once I understand your situation, I can provide:
- Safety assessment
- Practical precautions
- Alternative options
- Emergency resources

Tell me more about your plan, and I'll help you prepare safely. 💚"""
    
    def _generate_general_response(self, message: str) -> str:
        """Generate a general helpful response"""
        return f"""I appreciate your question about safety. 

Based on what you've shared: "{message[:80]}"

Here's my perspective:

1. **Your Concern Matters** - Whatever you're thinking about, your safety is important
2. **Think Proactively** - Planning ahead shows wisdom and self-care
3. **Trust Your Instincts** - Your gut feeling is valuable information
4. **Stay Connected** - Let people know your plans and whereabouts
5. **Know Your Resources** - Emergency services and support are available
6. **Be Empowered** - You have the capability to protect yourself

Is there a specific safety concern I can help you with? The more details you share, 
the better guidance I can provide. I'm here to support you with both practical advice 
and emotional reassurance. 💚"""
    
    def _generate_fallback_response(self, message: str) -> str:
        """Fallback response when AI generation fails"""
        return f"""I appreciate your trust in reaching out. While I'm processing your request, 
here's some general guidance:

You've asked about: "{message[:50]}..."

Key safety principles:
• Trust your instincts - they're often right
• Stay visible and connected
• Have a plan and share it with someone you trust
• Know where emergency services are located
• Remember - you have the strength and capability to protect yourself

For specific advice on your situation, please share more details, and I'll provide 
tailored guidance. Your safety and well-being matter. 💚"""
    
    def clear_history(self):
        """Clear chat history"""
        self.chat_history = []
        logger.info("Chat history cleared")
    
    def get_history(self) -> List[Dict]:
        """Get chat history"""
        return self.chat_history
    
    def process_area_safety(self, latitude: float, longitude: float, 
                          radius: int = 500) -> Dict:
        """
        Process area safety analysis
        Can be integrated with maps data in future
        """
        return {
            'location': {
                'latitude': latitude,
                'longitude': longitude,
                'radius': radius
            },
            'analysis': f"Area analysis for location ({latitude}, {longitude})",
            'timestamp': datetime.now().isoformat()
        }
