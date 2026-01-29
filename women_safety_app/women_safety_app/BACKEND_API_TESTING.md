# Backend API Testing Guide

Complete guide for testing all Women Safety App Custom AI Backend endpoints.

## 🚀 Getting Started

### Prerequisites
- Backend running: `python app.py` (from `backend/` directory)
- curl installed (or use Postman/Insomnia)
- Text editor for viewing responses

### Quick Status Check
```bash
curl http://127.0.0.1:5000/api/health
```

Expected response:
```json
{
  "status": "healthy",
  "service": "Women Safety AI Backend",
  "version": "1.0.0",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

---

## 🧪 Complete Test Suite

### 1. HEALTH CHECK ENDPOINTS

#### Test 1.1: Basic Health Check
```bash
curl -X GET http://127.0.0.1:5000/api/health
```

**Expected**: Status 200
```json
{
  "status": "healthy",
  "service": "Women Safety AI Backend",
  "version": "1.0.0",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

#### Test 1.2: Detailed Status
```bash
curl -X GET http://127.0.0.1:5000/api/status
```

**Expected**: Status 200 with uptime info
```json
{
  "status": "healthy",
  "service": "Women Safety AI Backend",
  "version": "1.0.0",
  "timestamp": "2024-01-15T10:30:00Z",
  "uptime_seconds": 3600,
  "total_requests": 50
}
```

---

### 2. CHAT ENDPOINTS

#### Test 2.1: Simple Message
```bash
curl -X POST http://127.0.0.1:5000/api/ai/chat \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Hello, how are you?",
    "context": {
      "type": "chat",
      "timestamp": "2024-01-15T10:30:00Z"
    }
  }'
```

**Expected**: Status 200 with AI response
```json
{
  "response": "I'm here to help you stay safe. How can I assist you today?",
  "type": "general",
  "timestamp": "2024-01-15T10:30:05Z"
}
```

#### Test 2.2: Safety Question
```bash
curl -X POST http://127.0.0.1:5000/api/ai/chat \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Is it safe to walk home alone at night?",
    "context": {
      "type": "safety_check"
    }
  }'
```

**Expected**: Status 200 with safety-focused response

#### Test 2.3: Fear Expression
```bash
curl -X POST http://127.0.0.1:5000/api/ai/chat \
  -H "Content-Type: application/json" \
  -d '{
    "message": "I am very scared right now",
    "context": {
      "type": "emotional"
    }
  }'
```

**Expected**: Status 200 with empathetic response validating fears

#### Test 2.4: Empty Message (Error Test)
```bash
curl -X POST http://127.0.0.1:5000/api/ai/chat \
  -H "Content-Type: application/json" \
  -d '{
    "message": "",
    "context": {}
  }'
```

**Expected**: Status 400 with error message
```json
{
  "error": "Message cannot be empty"
}
```

---

### 3. EMOTIONAL SUPPORT ENDPOINTS

#### Test 3.1: Anxiety Support
```bash
curl -X POST http://127.0.0.1:5000/api/ai/support \
  -H "Content-Type: application/json" \
  -d '{
    "concern": "I am experiencing severe anxiety",
    "context": {
      "type": "emotional_support"
    }
  }'
```

**Expected**: Status 200
```json
{
  "response": "Your anxiety is valid and I'm here to support you...",
  "support_type": "anxiety",
  "resources": ["helpline", "breathing_exercises"],
  "timestamp": "2024-01-15T10:30:05Z"
}
```

#### Test 3.2: Isolation Help
```bash
curl -X POST http://127.0.0.1:5000/api/ai/support \
  -H "Content-Type: application/json" \
  -d '{
    "concern": "I feel very alone and isolated",
    "context": {
      "type": "emotional_support"
    }
  }'
```

**Expected**: Status 200 with connection and resource suggestions

#### Test 3.3: Discomfort/Instinct
```bash
curl -X POST http://127.0.0.1:5000/api/ai/support \
  -H "Content-Type: application/json" \
  -d '{
    "concern": "Something feels wrong but I can't explain it",
    "context": {}
  }'
```

**Expected**: Status 200 with affirmation of instincts

---

### 4. AREA SAFETY ENDPOINTS

#### Test 4.1: Urban Area at Night
```bash
curl -X POST http://127.0.0.1:5000/api/ai/area-safety \
  -H "Content-Type: application/json" \
  -d '{
    "latitude": 40.7128,
    "longitude": -74.0060,
    "area_name": "Times Square, New York",
    "time_of_day": "night",
    "radius": 500
  }'
```

**Expected**: Status 200
```json
{
  "area_name": "Times Square, New York",
  "safety_level": "moderate",
  "ai_analysis": "Times Square is generally well-lit and busy even at night...",
  "recommendations": [
    "Stay in crowded areas",
    "Keep phone charged",
    "Avoid side streets after midnight"
  ],
  "nearby_resources": {
    "police_stations": 5,
    "hospitals": 3,
    "safe_spaces": 8
  },
  "timestamp": "2024-01-15T10:30:05Z"
}
```

#### Test 4.2: Residential Area at Day
```bash
curl -X POST http://127.0.0.1:5000/api/ai/area-safety \
  -H "Content-Type: application/json" \
  -d '{
    "latitude": 40.7549,
    "longitude": -73.9840,
    "area_name": "Residential District",
    "time_of_day": "day",
    "radius": 1000
  }'
```

**Expected**: Status 200 with daytime safety assessment

#### Test 4.3: Missing Coordinates (Error Test)
```bash
curl -X POST http://127.0.0.1:5000/api/ai/area-safety \
  -H "Content-Type: application/json" \
  -d '{
    "area_name": "Central Park",
    "time_of_day": "night"
  }'
```

**Expected**: Status 400 with validation error
```json
{
  "error": "latitude and longitude are required"
}
```

---

### 5. THREAT ASSESSMENT ENDPOINTS

#### Test 5.1: Being Followed
```bash
curl -X POST http://127.0.0.1:5000/api/ai/threat-assessment \
  -H "Content-Type: application/json" \
  -d '{
    "threat": "Someone is following me"
  }'
```

**Expected**: Status 200 with immediate action guidance
```json
{
  "response": "Trust your instincts. Here's what to do immediately...",
  "threat_level": "high",
  "immediate_actions": [
    "Go to nearest public place (store, restaurant, police station)",
    "Call 911 if in immediate danger",
    "Tell a trusted person your location",
    "Record the person's appearance if safely possible"
  ],
  "emergency_numbers": {
    "police": "911",
    "support_line": "1-800-656-HOPE"
  },
  "timestamp": "2024-01-15T10:30:05Z"
}
```

#### Test 5.2: Unsafe Situation
```bash
curl -X POST http://127.0.0.1:5000/api/ai/threat-assessment \
  -H "Content-Type: application/json" \
  -d '{
    "threat": "Someone is being aggressive towards me"
  }'
```

**Expected**: Status 200 with priority safety steps

#### Test 5.3: In Danger
```bash
curl -X POST http://127.0.0.1:5000/api/ai/threat-assessment \
  -H "Content-Type: application/json" \
  -d '{
    "threat": "EMERGENCY: I am in immediate danger!"
  }'
```

**Expected**: Status 200 with critical safety response

---

### 6. CHAT HISTORY ENDPOINTS

#### Test 6.1: Send Multiple Messages First
```bash
# Message 1
curl -X POST http://127.0.0.1:5000/api/ai/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"I feel scared","context":{}}'

# Message 2
curl -X POST http://127.0.0.1:5000/api/ai/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"What should I do?","context":{}}'

# Message 3
curl -X POST http://127.0.0.1:5000/api/ai/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"Thank you for helping","context":{}}'
```

#### Test 6.2: Get Chat History
```bash
curl -X GET http://127.0.0.1:5000/api/chat/history
```

**Expected**: Status 200
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
    },
    {
      "role": "user",
      "content": "What should I do?",
      "timestamp": "2024-01-15T10:30:10Z"
    }
  ],
  "total_messages": 6
}
```

#### Test 6.3: Get Chat Statistics
```bash
curl -X GET http://127.0.0.1:5000/api/chat/stats
```

**Expected**: Status 200
```json
{
  "total_messages": 6,
  "user_messages": 3,
  "assistant_messages": 3,
  "conversation_duration_seconds": 300,
  "most_common_concern": "safety"
}
```

#### Test 6.4: Clear Chat History
```bash
curl -X POST http://127.0.0.1:5000/api/chat/clear
```

**Expected**: Status 200
```json
{
  "status": "success",
  "message": "Chat history cleared"
}
```

#### Test 6.5: Verify History is Cleared
```bash
curl -X GET http://127.0.0.1:5000/api/chat/history
```

**Expected**: Status 200 with empty history
```json
{
  "history": [],
  "total_messages": 0
}
```

---

## 📊 Performance Testing

### Load Test with Multiple Requests
```bash
# Send 10 concurrent requests
for i in {1..10}; do
  curl -X POST http://127.0.0.1:5000/api/ai/chat \
    -H "Content-Type: application/json" \
    -d "{\"message\":\"Test message $i\",\"context\":{}}" &
done
wait
```

### Response Time Test
```bash
# Measure response time (Linux/macOS)
curl -w "Response time: %{time_total}s\n" -X POST http://127.0.0.1:5000/api/ai/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"How are you?","context":{}}'

# Windows PowerShell
$start = Get-Date
Invoke-WebRequest -Uri "http://127.0.0.1:5000/api/health"
$end = Get-Date
$time = ($end - $start).TotalSeconds
Write-Host "Response time: ${time}s"
```

---

## 🔧 Using Postman/Insomnia

### Import Collection

Create a new request in Postman:

1. **Chat Test**
   - Method: POST
   - URL: `http://127.0.0.1:5000/api/ai/chat`
   - Body (JSON):
   ```json
   {
     "message": "I feel unsafe",
     "context": {"type": "chat"}
   }
   ```

2. **Area Safety Test**
   - Method: POST
   - URL: `http://127.0.0.1:5000/api/ai/area-safety`
   - Body (JSON):
   ```json
   {
     "latitude": 40.7128,
     "longitude": -74.0060,
     "area_name": "Test Area",
     "time_of_day": "night",
     "radius": 500
   }
   ```

---

## ✅ Test Results Checklist

- [ ] Health check returns 200
- [ ] Chat endpoint accepts messages
- [ ] Emotional support recognizes concerns
- [ ] Area safety analyzes locations
- [ ] Threat assessment handles emergencies
- [ ] Chat history stores messages
- [ ] Clear history works properly
- [ ] Error handling for invalid requests
- [ ] Response times acceptable (<2s)
- [ ] CORS allows Flutter requests

---

## 🚨 Troubleshooting Test Failures

### Backend Not Responding
```bash
# Check if running
curl http://127.0.0.1:5000/api/health

# Check if port is in use
netstat -ano | findstr :5000  # Windows
lsof -i :5000                 # macOS/Linux
```

### Invalid JSON Response
- Ensure `-H "Content-Type: application/json"` is set
- Validate JSON syntax with `jq` or online tools

### Connection Refused
- Verify backend is running: `python app.py`
- Check firewall settings
- Ensure correct port (5000)

### Timeouts
- Backend may be slow
- Check logs: `tail -f logs/backend_*.log`
- Increase timeout in requests

---

## 📝 Logging Test Results

Save test results to file:
```bash
# Run all tests and save output
curl -X GET http://127.0.0.1:5000/api/health > test_results.json
echo "Test run: $(date)" >> test_results.json
```

---

**Happy Testing!** 🎉

If you encounter issues, check `backend/logs/backend_*.log` for detailed error messages.
