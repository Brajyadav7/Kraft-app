# Integration Guide: Flutter App ↔ Custom AI Backend

This guide walks through integrating the Flutter Women Safety App with the custom Python Flask AI backend.

## 🔗 Architecture Overview

```
Flutter App (Port 1)
      ↓ (HTTP REST)
Flask Backend (http://127.0.0.1:5000)
      ↓ (Custom AI Logic)
AI Model (Rule-based Emotional Support)
```

## ✅ Prerequisites

- ✅ Backend created in `/backend` folder
- ✅ Flask server ready to run
- ✅ `custom_ai_service.dart` created in `lib/services/`
- ✅ Flutter project setup

## 🚀 Integration Steps

### Step 1: Start the Backend

**Open terminal in the backend folder:**

```bash
cd backend

# Create virtual environment (first time only)
python -m venv venv

# Activate virtual environment
# Windows:
venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run the server
python app.py
```

**Expected output:**
```
 * Serving Flask app 'app'
 * Debug mode: on
 * Running on http://127.0.0.1:5000
```

**Keep this terminal open!** The backend must be running while you use the Flutter app.

### Step 2: Initialize the AI Service in Flutter

In your Flutter main screen or initialization code:

```dart
import 'package:women_safety_app/services/custom_ai_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize custom AI backend
  try {
    await CustomAISafetyService().initialize('http://127.0.0.1:5000');
    runApp(const MyApp());
  } catch (e) {
    print('Failed to initialize AI: $e');
    // Show error dialog to user
  }
}
```

Or in your AI Safety Assistant Screen:

```dart
@override
void initState() {
  super.initState();
  _initializeAI();
}

Future<void> _initializeAI() async {
  try {
    await CustomAISafetyService().initialize('http://127.0.0.1:5000');
    print('✅ AI Backend Connected');
  } catch (e) {
    print('❌ AI Backend Connection Failed: $e');
    // Show snackbar or dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  }
}
```

### Step 3: Use the AI Service in Screens

**Example: Ask a Safety Question**

```dart
import 'package:women_safety_app/services/custom_ai_service.dart';

class AISafetyAssistantScreen extends StatefulWidget {
  @override
  State<AISafetyAssistantScreen> createState() => _AISafetyAssistantScreenState();
}

class _AISafetyAssistantScreenState extends State<AISafetyAssistantScreen> {
  final _aiService = CustomAISafetyService();
  final _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];

  void _sendMessage() async {
    String userMessage = _messageController.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      _messages.add({
        'role': 'user',
        'content': userMessage,
        'timestamp': DateTime.now(),
      });
    });

    _messageController.clear();

    try {
      // Get AI response
      String aiResponse = await _aiService.askSafetyQuestion(userMessage);
      
      setState(() {
        _messages.add({
          'role': 'assistant',
          'content': aiResponse,
          'timestamp': DateTime.now(),
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Safety Assistant')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.all(8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg['content'],
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask your question...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### Step 4: Emotional Support Feature

```dart
void _requestEmotionalSupport(String concern) async {
  try {
    String response = await _aiService.getEmotionalSupport(concern);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('💚 Support'),
        content: Text(response),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  } catch (e) {
    print('Error: $e');
  }
}
```

### Step 5: Area Safety Check

```dart
void _checkAreaSafety(double lat, double lng) async {
  try {
    String analysis = await _aiService.checkAreaSafetyWithSupport(
      areaName: 'Current Location',
      timeOfDay: 'night',
      latitude: lat,
      longitude: lng,
    );
    
    print('📍 Safety Analysis: $analysis');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Area Safety Report'),
        content: SingleChildScrollView(
          child: Text(analysis),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  } catch (e) {
    print('Error: $e');
  }
}
```

### Step 6: Threat Assessment

```dart
void _handleEmergency(String threat) async {
  try {
    String response = await _aiService.getThreatAssessment(threat);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🚨 Emergency Response'),
        content: Text(response),
        backgroundColor: Colors.red[50],
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Understood'),
          ),
        ],
      ),
    );
  } catch (e) {
    print('Error: $e');
  }
}
```

## 🧪 Testing the Integration

### Test 1: Connection Check

```dart
Future<void> testBackendConnection() async {
  bool isHealthy = await CustomAISafetyService().checkBackendStatus();
  print(isHealthy ? '✅ Backend is online' : '❌ Backend is offline');
}
```

### Test 2: Simple Chat

**Open terminal with backend running, then test with cURL:**

```bash
curl -X POST http://localhost:5000/api/ai/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"I feel scared walking home"}'
```

### Test 3: Full Flutter App

1. Start backend: `python app.py`
2. Run Flutter app: `flutter run`
3. Type in chat field and send message
4. Verify response appears

## 🔍 Debugging

### Backend Won't Connect

**Error**: `Connection refused` or `Failed to connect`

**Solutions**:
```bash
# 1. Verify backend is running
curl http://localhost:5000/api/health

# 2. Check if port 5000 is in use
# Windows:
netstat -ano | findstr :5000

# 3. Change port in config/config.py if needed
BACKEND_PORT=5001

# 4. Update Flutter to use new port
await CustomAISafetyService().initialize('http://127.0.0.1:5001');
```

### No Response from AI

**Check logs**:
```bash
# Terminal where backend is running
# Look for error messages in console

# Or check log file
tail -f logs/backend_*.log
```

**Common issues**:
- Message is empty → Add validation
- Backend crashed → Check error in terminal
- Timeout → Increase request timeout in custom_ai_service.dart

### CORS Issues (if on different machine)

**In `app.py`, update CORS config:**
```python
from flask_cors import CORS

# Allow specific origins
CORS(app, resources={
    r"/api/*": {"origins": ["http://192.168.x.x:port", "http://localhost:5000"]}
})
```

## 📱 Network Configuration

### Local Network (Same Machine)
```dart
await CustomAISafetyService().initialize('http://127.0.0.1:5000');
```

### Local Network (Different Machine)
```dart
// Get backend machine IP (e.g., 192.168.1.100)
await CustomAISafetyService().initialize('http://192.168.1.100:5000');
```

### Android Emulator
```dart
// Use host machine IP, not localhost
await CustomAISafetyService().initialize('http://10.0.2.2:5000');
```

### iOS Simulator
```dart
// Can use localhost
await CustomAISafetyService().initialize('http://127.0.0.1:5000');
```

## 🚀 Next Steps

1. **Enhance AI Model**: Add more response types in `backend/ai_models/ai_handler.py`
2. **Add Database**: Store conversations persistently
3. **Deploy Backend**: Use Gunicorn + Nginx for production
4. **Add Authentication**: Secure API with API keys
5. **Mobile Push Notifications**: Alert user to safety checks

## 📊 API Testing Tools

- **Postman**: https://www.postman.com/
- **Insomnia**: https://insomnia.rest/
- **VS Code REST Client**: Install extension, create `.http` file
- **curl**: Command line (examples above)

## 🆘 Troubleshooting Checklist

- [ ] Backend running on `127.0.0.1:5000`
- [ ] Backend port not blocked by firewall
- [ ] Flutter app has internet permission
- [ ] Custom AI Service initialized in main.dart
- [ ] No typos in backend URL
- [ ] Requirements.txt installed in virtual env
- [ ] Check log files for errors
- [ ] Test with curl first before Flutter

## 📞 Support

For issues:
1. Check backend console for errors
2. Review log files: `backend/logs/`
3. Test with curl commands above
4. Verify Flask is running: `/api/health` endpoint
5. Check Flutter console for exceptions

---

**Integration Complete!** Your Flutter app is now connected to your custom AI backend. 🎉
