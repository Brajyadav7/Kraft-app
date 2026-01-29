# Custom AI Safety Backend

A Flask-based REST API backend for the Women Safety App's custom AI assistant. This backend provides emotional support, area safety analysis, and threat assessment powered by a custom AI model.

## 📋 Features

- **Emotional Support AI**: Specialized responses for fear, anxiety, help requests, emergencies, threats, isolation
- **Area Safety Analysis**: Location-based safety assessment using coordinates
- **Threat Assessment**: Immediate response guidance for dangerous situations
- **Chat History Management**: Persistent conversation tracking
- **Health Monitoring**: Service status and health check endpoints
- **CORS Enabled**: Seamless communication with Flutter app
- **Modular Architecture**: Organized routes and configuration

## 🚀 Quick Start

### Prerequisites

- Python 3.8 or higher
- pip (Python package manager)
- Virtual environment (recommended)

### Installation

1. **Create and activate virtual environment**:
   ```bash
   # Windows
   python -m venv venv
   venv\Scripts\activate
   
   # macOS/Linux
   python3 -m venv venv
   source venv/bin/activate
   ```

2. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

3. **Run the backend**:
   ```bash
   python app.py
   ```

   You should see:
   ```
   * Running on http://127.0.0.1:5000
   * Debug mode: on
   ```

### Configuration

The backend uses environment-based configuration in `config/config.py`:

- **Development**: `FLASK_ENV=development` (default)
- **Production**: `FLASK_ENV=production`
- **Testing**: `FLASK_ENV=testing`

Create a `.env` file in the backend directory for custom configuration:

```env
FLASK_ENV=development
FLASK_DEBUG=True
BACKEND_HOST=127.0.0.1
BACKEND_PORT=5000
MAX_TOKENS_INPUT=512
MAX_TOKENS_OUTPUT=250
CHAT_HISTORY_LIMIT=20
LOG_LEVEL=INFO
```

## 📡 API Endpoints

### Health & Status

#### GET `/api/health`
Quick health check endpoint.

**Response** (200 OK):
```json
{
  "status": "healthy",
  "service": "Women Safety AI Backend",
  "version": "1.0.0",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

#### GET `/api/status`
Detailed status information.

**Response** (200 OK):
```json
{
  "status": "healthy",
  "service": "Women Safety AI Backend",
  "version": "1.0.0",
  "timestamp": "2024-01-15T10:30:00Z",
  "uptime_seconds": 3600,
  "total_requests": 150
}
```

### Chat & Conversation

#### POST `/api/ai/chat`
Send a message to the AI assistant.

**Request**:
```json
{
  "message": "I feel scared walking home alone",
  "context": {
    "type": "chat",
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

**Response** (200 OK):
```json
{
  "response": "I understand why you feel scared...",
  "type": "emotional_support",
  "timestamp": "2024-01-15T10:30:05Z"
}
```

**cURL Example**:
```bash
curl -X POST http://localhost:5000/api/ai/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"I feel unsafe","context":{"type":"chat"}}'
```

#### POST `/api/ai/support`
Request emotional support for specific concerns.

**Request**:
```json
{
  "concern": "I am experiencing anxiety",
  "context": {
    "type": "emotional_support"
  }
}
```

**Response** (200 OK):
```json
{
  "response": "Your feelings are valid and understandable...",
  "support_type": "anxiety",
  "resources": ["helpline", "breathing_exercises"],
  "timestamp": "2024-01-15T10:30:05Z"
}
```

**cURL Example**:
```bash
curl -X POST http://localhost:5000/api/ai/support \
  -H "Content-Type: application/json" \
  -d '{"concern":"I feel very anxious"}'
```

#### POST `/api/ai/area-safety`
Analyze safety of a specific area.

**Request**:
```json
{
  "latitude": 40.7128,
  "longitude": -74.0060,
  "area_name": "Central Park South",
  "time_of_day": "night",
  "radius": 500
}
```

**Response** (200 OK):
```json
{
  "area_name": "Central Park South",
  "safety_level": "moderate",
  "ai_analysis": "This area is moderately safe at night...",
  "recommendations": [
    "Stay on well-lit paths",
    "Keep phone charged",
    "Share location with trusted contact"
  ],
  "nearby_resources": {
    "police_stations": 2,
    "hospitals": 1,
    "safe_spaces": 3
  },
  "timestamp": "2024-01-15T10:30:05Z"
}
```

**cURL Example**:
```bash
curl -X POST http://localhost:5000/api/ai/area-safety \
  -H "Content-Type: application/json" \
  -d '{
    "latitude": 40.7128,
    "longitude": -74.0060,
    "area_name": "Central Park South",
    "time_of_day": "night",
    "radius": 500
  }'
```

#### POST `/api/ai/threat-assessment`
Get immediate response for threatening situations.

**Request**:
```json
{
  "threat": "Someone is following me"
}
```

**Response** (200 OK):
```json
{
  "response": "Trust your instincts. Here's what you should do immediately...",
  "threat_level": "high",
  "immediate_actions": [
    "Go to nearest public place",
    "Call 911",
    "Notify trusted contact"
  ],
  "emergency_numbers": {
    "police": "911",
    "safety_hotline": "1-800-656-HOPE"
  },
  "timestamp": "2024-01-15T10:30:05Z"
}
```

**cURL Example**:
```bash
curl -X POST http://localhost:5000/api/ai/threat-assessment \
  -H "Content-Type: application/json" \
  -d '{"threat":"Someone is following me"}'
```

### Chat History

#### GET `/api/chat/history`
Retrieve full chat history.

**Response** (200 OK):
```json
{
  "history": [
    {
      "role": "user",
      "content": "I feel scared",
      "timestamp": "2024-01-15T10:30:00Z"
    },
    {
      "role": "assistant",
      "content": "I understand...",
      "timestamp": "2024-01-15T10:30:05Z"
    }
  ],
  "total_messages": 2
}
```

**cURL Example**:
```bash
curl -X GET http://localhost:5000/api/chat/history
```

#### GET `/api/chat/stats`
Get conversation statistics.

**Response** (200 OK):
```json
{
  "total_messages": 42,
  "user_messages": 20,
  "assistant_messages": 22,
  "conversation_duration_seconds": 1800,
  "most_common_concern": "safety_check"
}
```

**cURL Example**:
```bash
curl -X GET http://localhost:5000/api/chat/stats
```

#### POST `/api/chat/clear`
Clear chat history.

**Response** (200 OK):
```json
{
  "status": "success",
  "message": "Chat history cleared"
}
```

**cURL Example**:
```bash
curl -X POST http://localhost:5000/api/chat/clear
```

## 🤖 AI Model Details

### Rule-Based Emotional Support Model

The backend uses a custom rule-based model that recognizes emotional keywords and provides specialized responses:

**Supported Concerns**:
1. **Fear** - Validates feelings and provides safety strategies
2. **Anxiety** - Offers calming techniques and reassurance
3. **Help Requests** - Connects to resources and support
4. **Emergencies** - Provides immediate action guidance
5. **Threats** - Delivers quick response tactics
6. **Isolation** - Addresses loneliness and provides connection strategies
7. **Safety Checks** - Gathers location and situation details
8. **Area Safety** - Analyzes regional safety factors

### Model Configuration

Located in `ai_models/ai_handler.py`:
- **Token Limits**: 512 input, 250 output
- **Chat History**: Last 20 messages retained
- **Response Routing**: Keyword-based categorization
- **Fallback**: Safe, supportive default response

### Extending the Model

To add new response types:

1. Add keyword detection in `ai_handler.py`:
   ```python
   def generate_response(self, message):
       if self._contains_keywords(message, ['your_keywords']):
           return self._respond_to_new_concern(message)
   ```

2. Implement response handler:
   ```python
   def _respond_to_new_concern(self, message):
       return "Your customized response..."
   ```

3. Test endpoint with cURL

## 📝 Logging

Logs are automatically created in the `logs/` directory:
- **File**: `backend_YYYYMMDD.log`
- **Format**: Timestamp | Level | Module | Message
- **Levels**: DEBUG, INFO, WARNING, ERROR

Access logs:
```bash
tail -f logs/backend_20240115.log
```

## 🔧 Development

### Project Structure

```
backend/
├── app.py                          # Flask application entry point
├── requirements.txt                # Python dependencies
├── config/
│   └── config.py                  # Configuration management
├── ai_models/
│   └── ai_handler.py             # Core AI logic
├── routes/
│   ├── health_routes.py           # Health endpoints
│   ├── ai_routes.py               # AI chat endpoints
│   └── chat_routes.py             # Chat history endpoints
├── utils/
│   └── logger.py                  # Logging setup
└── logs/                          # Daily log files
```

### Adding New Routes

1. Create route file in `routes/`:
   ```python
   # routes/my_routes.py
   from flask import Blueprint, jsonify, request

   my_bp = Blueprint('my_routes', __name__)

   @my_bp.route('/api/my-endpoint', methods=['POST'])
   def my_endpoint():
       return jsonify({'status': 'success'})
   ```

2. Register in `app.py`:
   ```python
   from routes.my_routes import my_bp
   app.register_blueprint(my_bp)
   ```

### Testing Endpoints

Use the provided cURL examples or use tools like:
- **Postman** - GUI REST client
- **curl** - Command line
- **VS Code REST Client** - Extension

## 🚨 Troubleshooting

### Backend Won't Start
```bash
# Check if port 5000 is in use
netstat -ano | findstr :5000

# Kill the process (Windows)
taskkill /PID <PID> /F

# Change port in config/config.py
BACKEND_PORT=5001
```

### Flutter Can't Connect
1. Ensure backend is running on `127.0.0.1:5000`
2. Check firewall settings
3. Verify network connection
4. Look at logs: `tail logs/backend_*.log`

### Dependencies Issues
```bash
# Upgrade pip
pip install --upgrade pip

# Reinstall dependencies
pip install -r requirements.txt --force-reinstall
```

## 🚀 Production Deployment

### Using Gunicorn

```bash
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:5000 app:app
```

### Using Docker

Create `Dockerfile`:
```dockerfile
FROM python:3.10-slim
WORKDIR /backend
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "app:app"]
```

Build and run:
```bash
docker build -t women-safety-backend .
docker run -p 5000:5000 women-safety-backend
```

## 📊 Performance Tips

- **Increase Workers**: Modify `gunicorn -w` parameter for high load
- **Enable Caching**: Implement response caching for common queries
- **Database**: Add persistent storage for production
- **Rate Limiting**: Add Flask-Limiter for DDoS protection

## 🔐 Security

- CORS is enabled for Flutter app only
- Add authentication for production:
  ```python
  from flask_httpauth import HTTPBasicAuth
  auth = HTTPBasicAuth()
  ```
- Store sensitive config in environment variables
- Validate all user inputs

## 📞 Support

For issues or feature requests:
1. Check logs: `logs/backend_*.log`
2. Test endpoints with cURL
3. Verify Flask is running: `http://localhost:5000/api/health`
4. Review error messages in console

## 📄 License

This backend is part of the Women Safety App project.

---

**Last Updated**: January 2024
**Backend Version**: 1.0.0
**Python Required**: 3.8+
