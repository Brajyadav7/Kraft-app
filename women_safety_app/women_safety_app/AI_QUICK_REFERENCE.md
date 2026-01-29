# AI Safety Assistant - Quick Reference & Examples

## 🎯 Quick Start Commands

### For Windows Users

**Step 1: Install & Run Ollama**
```powershell
# Download from: https://ollama.ai

# Open PowerShell and run:
ollama pull mistral

# Start Ollama service (runs in background)
ollama serve
```

**Step 2: Open Women Safety App**
- Go to AI Safety Assistant
- Enter: `http://localhost:11434`
- Click "Connect to AI"

---

### For Mac Users

```bash
# Install via Homebrew
brew install ollama

# Run Ollama
ollama pull mistral
ollama serve

# In app: http://localhost:11434
```

---

### For Linux Users

```bash
# Download from ollama.ai or:
curl -fsSL https://ollama.ai/install.sh | sh

# Pull model
ollama pull mistral

# Run
ollama serve
```

---

## 💬 Example Prompts for AI Assistant

### 1. Emotional Support (Anxiety)
**You**: "I'm really scared to travel alone at night"

**Expected Response**: Validates fear, provides practical steps, builds confidence

---

### 2. Route Safety
**You**: "Is it safe to walk from Station A to Station B at 9 PM?"

**Expected Response**: Assesses route, identifies risks, suggests alternatives

---

### 3. Threat Assessment
**You**: "A stranger is following me, what should I do?"

**Expected Response**: Clear step-by-step emergency guidance with reassurance

---

### 4. General Safety Tips
**You**: "What are the best practices for traveling alone?"

**Expected Response**: Comprehensive list of practical safety measures

---

### 5. Emotional + Practical
**You**: "I want to go out more but I'm constantly worried about my safety"

**Expected Response**: Validates concerns + builds confidence + practical strategies

---

## 📍 Area Safety Check Examples

### What It Analyzes
```
Location: Your current position (via GPS)
Radius: 500 meters around you
Analysis:
  ✓ Police stations nearby
  ✓ Hospitals nearby
  ✓ Shopping malls (busy, safer)
  ✓ Restaurants/cafes
  ✓ Banks
  ✓ Bars/clubs (riskier at night)
  ✓ Parks (check timing)
  ✓ Gas stations
  ✓ Parking areas
```

### Safety Score Meaning
```
Score: 85/100
Interpretation: VERY SAFE
What It Means:
  - Good infrastructure nearby
  - Emergency services accessible
  - Busy, populated area
  - Multiple safe options available

Recommendation: Good area to be in. Maintain normal precautions.
```

---

## 🔧 Code Examples for Developers

### Using the AI Service

```dart
// Initialize
final aiService = AISafetyAssistantService();
await aiService.initialize('http://localhost:11434');

// Ask a question
final response = await aiService.askSafetyQuestion(
  'Is it safe to travel alone at night?'
);

// Get emotional support
final support = await aiService.getEmotionalSupport(
  'I\'m feeling anxious about leaving home'
);

// Check area safety with support
final areaSafety = await aiService.checkAreaSafetyWithSupport(
  areaName: 'Downtown District',
  timeOfDay: 'Evening',
  context: 'Traveling alone'
);
```

### Using Google Places Service

```dart
// Initialize
final googleService = GooglePlacesSafetyService();
googleService.initialize('YOUR_GOOGLE_API_KEY');

// Check area safety
final safety = await googleService.checkAreaSafety(
  latitude: 40.7128,
  longitude: -74.0060,
  radius: '500'
);

// Get emergency services
final emergency = await googleService.getNearbyEmergencyServices(
  latitude: 40.7128,
  longitude: -74.0060
);
```

---

## 🐛 Common Issues & Solutions

### Issue: "Ollama is thinking..." hangs forever
**Solution**:
```
1. Check Ollama is still running
2. Restart Ollama: powershell/terminal > ollama serve
3. Check internet/network connection
4. Try shorter question for faster response
```

### Issue: "Connection failed" on startup
**Solution**:
```
1. Start Ollama first (ollama serve)
2. Wait 5 seconds for startup
3. Then open app
4. Enter correct URL (http://localhost:11434)
5. Check firewall isn't blocking port 11434
```

### Issue: "Permission denied" for location
**Solution**:
```
Android:
1. Settings > Apps > Women Safety App > Permissions
2. Enable Location
3. Try area check again

iOS:
1. Settings > Privacy > Location Services
2. Find Women Safety App
3. Set to "While Using the App"
```

### Issue: Google API setup takes too long
**Solution**:
```
1. Google API is OPTIONAL
2. Can skip and just use AI
3. Click "Continue without Maps"
4. AI still provides full safety guidance
```

---

## 💡 Tips for Best Results

### For AI Responses:
1. **Be Specific**: "9 PM in downtown" → Better than "at night"
2. **Context Matters**: Mention if traveling alone/with someone
3. **Be Honest**: Share your actual concerns for better advice
4. **Ask Follow-ups**: Build on previous responses
5. **Use Chat History**: AI remembers conversation context

### For Area Safety:
1. **Check Regularly**: Area safety changes with time of day
2. **Trust the Score**: 80+ is genuinely safer
3. **Use with Location**: Need GPS enabled for accuracy
4. **Combine with AI**: Area score + AI analysis = best insight
5. **Check Emergency Services**: Hospital/Police locations matter

---

## 🚀 Advanced Usage

### Custom Safety Analysis

Request specific analysis:
```
"I'm going to the downtown mall at 8 PM with a friend. 
Is this safe? Please consider:
1. Time of day
2. Presence of security (mall)
3. People around
4. Emergency access
5. My comfort level"
```

### Situation-Based Questions

Ask for specific scenarios:
```
"What if I get separated from my friend in a crowd?
What immediate steps should I take?
How do I stay safe while looking for them?"
```

### Building Confidence

Use AI for empowerment:
```
"I want to go out solo but I'm scared. 
Help me build a realistic safety plan 
and boost my confidence to try."
```

---

## 📊 Safety Score Breakdown

```
Score 90-100: VERY SAFE ✅✅✅
├── What this means:
│   ├── Multiple police/hospital nearby
│   ├── Busy, populated area
│   ├── Good lighting/visibility expected
│   ├── Major businesses/shops present
│   └── Emergency access easy
└── Best for: Solo travel, any time

Score 70-89: MODERATELY SAFE ✅✅
├── What this means:
│   ├── Some safe places nearby
│   ├── Decent foot traffic expected
│   ├── Emergency services accessible
│   ├── Mix of safe/neutral businesses
│   └── Reasonably well-developed area
└── Best for: Daytime, with precautions

Score 50-69: MIXED SAFETY ⚠️
├── What this means:
│   ├── Some safe, some risky areas
│   ├── Variable foot traffic
│   ├── Emergency services not immediate
│   ├── Need to stay alert
│   └── Avoid isolated paths
└── Best for: With companion, daylight hours

Score 0-49: POOR SAFETY ⚠️⚠️
├── What this means:
│   ├── Isolated/dangerous indicators
│   ├── Limited emergency access
│   ├── Few safe places to go
│   ├── High-risk business types
│   └── Minimal visibility/activity
└── Best for: Avoid if possible
```

---

## 🎓 Learning Resources

### Understanding Your Responses

**Empathy Recognition**:
- Look for: "I understand", "Your feelings are valid"
- This shows emotional intelligence

**Practical Advice**:
- Look for: Numbered steps, specific actions
- This is actionable guidance

**Reassurance**:
- Look for: "You're capable", "You can"
- This builds confidence

### Improving Your Questions

Bad: "Is it safe?"
Better: "Is it safe for a 25-year-old woman to walk alone to a restaurant 1km away at 8 PM?"

Bad: "I'm scared"
Better: "I'm scared of being followed. What should I do?"

Bad: "Safety tips"
Better: "I'm traveling alone for the first time. What are the top 5 safety tips?"

---

## 🔐 Privacy Checklist

Your data:
- ☑️ Chat history: Stored ONLY on your device
- ☑️ Location: Only sent when YOU request area check
- ☑️ Ollama: 100% local processing
- ☑️ Google API: Minimal data (only location)
- ☑️ No account required
- ☑️ Can clear everything anytime

---

## 📞 Emergency Resources

**This AI is NOT a replacement for real help!**

If in danger:
1. **Call Emergency**: 911 (US) or your country's emergency number
2. **Tell Someone**: Text/call trusted friend/family
3. **Use Safety Contacts**: Built into app
4. **Go to Police/Hospital**: If threatened or hurt
5. **Text Help Services**: Crisis hotlines support texting

This AI provides support and guidance, not emergency response.

---

## ✅ Setup Verification Checklist

Before considering setup complete:

- [ ] Ollama installed and running
- [ ] Model downloaded (`ollama pull mistral`)
- [ ] App connects to Ollama successfully
- [ ] Can send and receive chat messages
- [ ] Initial greeting displays properly
- [ ] Chat history works (messages appear)
- [ ] Clear history button works
- [ ] Location permissions enabled (optional)
- [ ] Area safety button works (if using Google)
- [ ] Emergency contacts still accessible

---

## 🎉 You're All Set!

Your AI Safety Assistant with emotional support is now:
- ✅ Connected and ready
- ✅ Providing empathetic responses
- ✅ Analyzing area safety
- ✅ Supporting your well-being

**Remember**: Stay safe, trust your instincts, and reach out for real help when needed.

For technical questions, see: `AI_TECHNICAL_DOCS.md`
For setup help, see: `AI_SETUP_GUIDE.md`

---

**Version**: 1.0
**Last Updated**: January 2026
**Status**: Ready to Use 🚀
