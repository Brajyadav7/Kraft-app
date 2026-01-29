# Women Safety App 💚

A comprehensive Flutter application designed to empower women with safety tools, real-time assistance, and emotional support.

## 🎯 Features

### Core Safety Features
- 🚨 **Emergency Alerts** - Quick SOS activation
- 📍 **Location Tracking** - Real-time location sharing
- 👥 **Trusted Contacts** - Quick access to emergency contacts
- 🛑 **Fake Call** - Generate fake incoming calls for distraction
- 🤝 **Check-in System** - Safety check-ins with contacts
- 🏘️ **Trusted Zones** - Define safe areas
- 📊 **Incident Tracking** - Log and track safety incidents

### AI Safety Assistant ✨ NEW
- 💚 **Emotional Support** - Compassionate AI responses
- 🤖 **Smart Advice** - AI-powered safety guidance
- 📍 **Area Safety Checking** - Real-time area analysis via Google Places
- 💬 **Chat History** - Maintain conversation context
- 🆘 **Emergency Procedures** - Step-by-step guidance
- 🌙 **24/7 Support** - Available anytime

## 🚀 Quick Start

### Prerequisites
- Flutter 3.10.7+
- Dart 3.10.7+
- Ollama (for AI features)
- Google API Key (optional, for area safety)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd women_safety_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup Ollama (for AI)**
   - Download from [ollama.ai](https://ollama.ai)
   - Install and run Ollama
   - Pull a model: `ollama pull mistral`
   - Start Ollama: `ollama serve`

4. **Run the app**
   ```bash
   flutter run
   ```

5. **In app, connect to AI**
   - Go to "AI Safety Assistant"
   - Enter: `http://localhost:11434`
   - Click "Connect to AI"

## 📖 Documentation

### For Users
- **[AI Setup Guide](AI_SETUP_GUIDE.md)** - Complete setup instructions
- **[Quick Reference](AI_QUICK_REFERENCE.md)** - Examples and quick tips

### For Developers
- **[Technical Documentation](AI_TECHNICAL_DOCS.md)** - Architecture and APIs
- **[Implementation Summary](IMPLEMENTATION_SUMMARY.md)** - What was added

## 🧠 AI Safety Assistant

### Features
1. **Emotional Support**
   - Validates your concerns
   - Provides reassurance
   - Builds confidence
   - Empowering guidance

2. **Area Safety Analysis**
   - Checks nearby locations
   - Calculates safety score (0-100)
   - Finds emergency services
   - Provides recommendations

3. **Smart Responses**
   - Understands context
   - Maintains chat history
   - Personalized advice
   - 24/7 availability

### Example Conversations

**User**: "I'm scared to travel alone at night"

**AI Response**:
```
I understand why you feel that way, and your concerns are completely valid. 
Many women experience similar worries. Here's how to build confidence and 
stay safe:

1. Plan your route - know landmarks and checkpoints
2. Tell someone - share your location with a trusted friend
3. Stay visible - use well-lit streets and populated areas
4. Trust instincts - if something feels wrong, it probably is
5. Keep connected - have charged phone and emergency numbers ready

You are capable and strong. With these precautions, you can navigate 
safely and build confidence over time. You're not alone in this.
```

## 🗺️ Architecture

```
┌─────────────────────────────────────────┐
│     Women Safety App (Flutter)          │
├─────────────────────────────────────────┤
│                                         │
│  ┌──────────────┐   ┌───────────────┐ │
│  │  AI Safety   │   │   Emergency   │ │
│  │  Assistant   │   │   Features    │ │
│  └──────────────┘   └───────────────┘ │
│         │                  │           │
│  ┌──────▼──────┐   ┌───────▼────────┐ │
│  │ Ollama API  │   │ Google Places  │ │
│  │ (Local AI)  │   │ (Area Safety)  │ │
│  └─────────────┘   └────────────────┘ │
│                                         │
└─────────────────────────────────────────┘
```

## 🔒 Privacy & Security

- ✅ **Local AI Processing** - All data processed locally via Ollama
- ✅ **No Cloud Storage** - Chat history saved only on device
- ✅ **Location Privacy** - Location only sent when you request area check
- ✅ **No User Tracking** - No accounts, no tracking, no surveillance
- ✅ **Optional Google API** - Area safety is optional
- ✅ **Transparent** - Open source, auditable code

## 📁 Project Structure

```
women_safety_app/
├── lib/
│   ├── screens/
│   │   ├── ai_safety_assistant_screen.dart
│   │   └── ... (other screens)
│   ├── services/
│   │   ├── ai_safety_assistant_service.dart
│   │   ├── google_places_safety_service.dart
│   │   └── ... (other services)
│   └── main.dart
├── docs/
│   ├── AI_SETUP_GUIDE.md
│   ├── AI_TECHNICAL_DOCS.md
│   ├── AI_QUICK_REFERENCE.md
│   └── IMPLEMENTATION_SUMMARY.md
├── pubspec.yaml
└── README.md
```

## 🛠️ Technologies Used

- **Flutter** - UI Framework
- **Dart** - Programming Language
- **Ollama** - Local AI Models
- **Google Places API** - Area Safety Analysis
- **Geolocator** - Location Services
- **HTTP** - API Communication

## 📦 Dependencies

```yaml
# Core Flutter
flutter:
  sdk: flutter
cupertino_icons: ^1.0.5

# Safety Features
permission_handler: ^12.0.1
geolocator: ^10.1.0
shake: ^2.2.0
flutter_background_service: ^5.0.0
flutter_local_notifications: ^17.0.0

# Communication
http: ^1.1.0
url_launcher: ^6.1.10

# Data Storage
shared_preferences: ^2.1.1

# AI & Maps
google_maps_flutter: ^2.5.0
google_places_flutter: ^2.0.8
uuid: ^4.0.0

# Sensors
sensors_plus: ^6.1.0
```

## 🤝 Contributing

Contributions are welcome! Please ensure:
1. Code follows existing patterns
2. New features include emotional support consideration
3. Documentation is updated
4. Tests are included for critical features

## ⚠️ Important Notice

**This app provides support and guidance but is NOT a replacement for emergency services.**

In case of immediate danger:
- **Call Emergency**: 911 (US) or your country's emergency number
- **Tell Someone**: Contact trusted friend/family
- **Go to Safe Place**: Police station, hospital, or public place
- **Use Emergency Contacts**: Built into the app

## 📞 Support

- **Setup Issues**: See [AI_SETUP_GUIDE.md](AI_SETUP_GUIDE.md)
- **Technical Questions**: See [AI_TECHNICAL_DOCS.md](AI_TECHNICAL_DOCS.md)
- **Usage Tips**: See [AI_QUICK_REFERENCE.md](AI_QUICK_REFERENCE.md)
- **Bug Reports**: Create an issue on GitHub

## 📄 License

This project is open source and available under the MIT License.

## 🙏 Acknowledgments

- Designed with women's safety and empowerment in mind
- Built with Flutter for cross-platform accessibility
- Powered by Ollama for privacy-first AI
- Enhanced by Google Places for real-world data

---

## 🎯 Our Mission

**Empower women with the tools, knowledge, and support they need to stay safe and confident.**

Stay safe. Stay strong. You've got this. 💚

---

**Last Updated**: January 2026
**Version**: 1.0
**Status**: Production Ready ✅
