# AI Safety Assistant with Emotional Support - Setup Guide

## 🎯 Overview

Your Women Safety App now includes an advanced **AI Safety Assistant** with:

- ✅ **Emotional Support** - Compassionate responses validating concerns
- ✅ **Area Safety Checking** - Google Places API integration
- ✅ **Practical Advice** - Actionable safety recommendations
- ✅ **Privacy First** - Optional local or hosted backend

---

## 🚀 Quick Setup (3 Steps)

### Step 1: Start the Custom AI Backend (Python Flask)

1. The project includes a lightweight Python Flask backend under the `backend/` folder.
2. Create a virtual environment and install dependencies:
   ```bash
   cd backend
   python -m venv venv
   # Windows
   venv\Scripts\activate
   # macOS / Linux
   source venv/bin/activate
   pip install -r requirements.txt
   ```
3. Start the backend server:
   ```bash
   # Windows
   python app.py
   # or use the helper
   start_backend.bat

   # macOS / Linux
   python app.py
   # or
   ./start_backend.sh
   ```
4. The backend listens on `http://127.0.0.1:5000` by default. On Android emulator use `http://10.0.2.2:5000`.

### Step 2: Connect in App

1. Open the Women Safety App
2. Go to **AI Safety Assistant** screen
3. Enter backend URL: `http://127.0.0.1:5000` (or `http://10.0.2.2:5000` for Android emulator)
4. Tap **"Connect to AI"**

### Step 3 (Optional): Enable Area Safety Checking

1. Get a Google API Key:
   - Go to [Google Cloud Console](https://console.cloud.google.com)
   - Create a project and enable **Places API**
   - Create an **API Key** (restrict to Places API)
2. In the app, when prompted, paste your Google API Key
3. Area safety checks will use the Places API and device location

---

## 🧠 AI Features Explained

### Emotional Support System

The assistant:
- **Validates** feelings
- **Acknowledges** safety fears
- **Empowers** with practical steps
- **Reassures** and offers resources

### Area Safety Checking

When you tap the location icon the app:
- Collects nearby places via Google Places
- Scores place types and ratings
- Computes a safety score (0-100)
- Sends the analysis to the backend AI for interpretation

Safety Score Interpretation:
- **80-100**: Very Safe
- **60-79**: Moderately Safe
- **40-59**: Mixed Safety
- **0-39**: Poor Safety

---

## 📝 Example Conversations

### Emotional Support

**You:** "I'm feeling really anxious about traveling alone"

**AI Response:**
```
I completely understand why you might feel anxious. Here are some practical
steps you can take to feel safer and build confidence:

1. Plan your route and share it with a friend
2. Keep your phone charged and share location
3. Use well-lit, populated routes
4. Trust your instincts and leave if uncomfortable

You are not alone — small steps can increase your sense of safety.
```

### Area Safety Check

**You:** "Is downtown safe at 8 PM?"

**AI Response:**
```
Area Safety Analysis:
Safety Score: 72/100 — Moderately safe. Stay in busy streets, avoid isolated
parks after dark, and keep short routes where emergency services are nearby.
```

---

## 🔧 Configuration Files

### Updated Files

1. **lib/services/ai_safety_assistant_service.dart** — Facade for AI backend
2. **lib/services/custom_ai_service.dart** — HTTP client for the Flask backend
3. **lib/services/google_places_safety_service.dart** — Google Places integration
4. **lib/screens/ai_safety_assistant_screen.dart** — UI and connection flow

---

## 🔒 Privacy & Security

- Backend can run locally (your machine) or on a hosted server
- Google API: only location data is sent to Google (optional)
- Chat history is stored locally on device unless configured otherwise

---

## 🐛 Troubleshooting

### "Connection failed to AI backend"
- Ensure the backend is running (`python app.py` in `backend/`)
- Check URL: `http://127.0.0.1:5000` (use `http://10.0.2.2:5000` for Android emulator)
- Ensure no firewall is blocking port 5000

### "Location permission denied"
- Enable location in device settings and retry

### "Google API not initialized"
- Optional feature: enable Places API and paste API key when prompted

### "Slow responses"
- First requests may take a few seconds while the backend initializes
- Check backend logs in `backend/logs/` for errors

---

## 📱 Using the Features

- Chat naturally — the AI provides both emotional support and practical tips
- Tap the location icon to run an area safety check (requires location)

---

## 🎯 Next Steps

- Start the backend, connect the app, and run a few test queries
- If you want, I can update other docs to remove remaining Ollama references

- Requires location permission
- Analyzes nearby services and places
- Provides safety score and recommendations

---

## 🎨 Future Enhancements

The architecture supports:
- Multiple AI models
- Custom safety databases
- Real-time incident reporting
- Community safety mapping
- Integration with emergency contacts
- Offline mode with cached data

---

## 📞 Support Resources

If you need help:
1. Check Ollama documentation: https://ollama.ai
2. Google Places API docs: https://developers.google.com/maps/documentation/places
3. Flutter documentation: https://flutter.dev
4. Contact emergency services if in danger (not the AI!)

---

## ✅ Checklist

Before using the AI Assistant:

- [ ] Downloaded and installed Ollama from ollama.ai
- [ ] Run `ollama pull mistral` (or other model)
- [ ] Ollama is running on `http://localhost:11434`
- [ ] Connected to Ollama in app
- [ ] (Optional) Got Google API Key for area safety checking
- [ ] (Optional) Pasted Google API Key in app

---

## 💚 Remember

This AI is here to:
- Support your emotional well-being
- Provide practical safety guidance
- Empower you with knowledge
- Validate your concerns
- Help you stay safe

Your safety and peace of mind matter. Use this tool with confidence!
