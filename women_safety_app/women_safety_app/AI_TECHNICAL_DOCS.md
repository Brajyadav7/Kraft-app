# AI Safety Assistant - Technical Documentation

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│         AI Safety Assistant Screen (UI)                 │
└────────────┬────────────────────────────────────────┬───┘
             │                                        │
      ┌──────▼──────────┐              ┌──────────────▼────┐
      │  AI Service     │              │ Google Places     │
      │  (Ollama)       │              │ Safety Service    │
      └──────┬──────────┘              └──────┬───────────┘
             │                                │
      ┌──────▼──────────┐              ┌──────▼───────────┐
      │ Ollama API      │              │ Google Places    │
      │ (localhost)     │              │ API              │
      └─────────────────┘              └──────────────────┘
```

## Core Services

### 1. AISafetyAssistantService

**File**: `lib/services/ai_safety_assistant_service.dart`

**Responsibilities**:
- Initialize and connect to Ollama
- Maintain chat history
- Process safety questions
- Provide emotional support responses

**Key Methods**:

```dart
// Initialize with Ollama URL
Future<void> initialize(String ollamaUrl, {String model = 'mistral'})

// Ask a question (general)
Future<String> askSafetyQuestion(String question)

// Check area safety with emotional support
Future<String> checkAreaSafetyWithSupport({
  required String areaName,
  required String timeOfDay,
  required String context,
})

// Get emotional support for anxiety/fear
Future<String> getEmotionalSupport(String concern)

// Holistic safety advice
Future<String> getHolisticSafetyAdvice(String situation)

// Get chat history
List<Map<String, String>> getChatHistory()

// Clear history
void clearChatHistory()
```

**System Prompt Features**:
- Empathy-first approach
- Validation of concerns
- Practical + emotional balance
- Culturally sensitive responses
- 250-word response limit

---

### 2. GooglePlacesSafetyService

**File**: `lib/services/google_places_safety_service.dart`

**Responsibilities**:
- Analyze area safety using Google Places API
- Calculate safety scores
- Find emergency services
- Provide area recommendations

**Key Methods**:

```dart
// Initialize with Google API Key
void initialize(String googleApiKey)

// Check area safety (500m radius)
Future<Map<String, dynamic>> checkAreaSafety({
  required double latitude,
  required double longitude,
  required String radius,
})

// Get safety rating for location
Future<Map<String, dynamic>> getLocationSafetyRating({
  required double latitude,
  required double longitude,
})

// Find emergency services nearby
Future<List<Map<String, dynamic>>> getNearbyEmergencyServices({
  required double latitude,
  required double longitude,
})
```

**Safety Scoring Algorithm**:

Place Types and Safety Scores:
```
100 - Police station
95  - Hospital, Fire station
80  - Shopping mall
75  - Grocery/Supermarket, Bank, Cafe, Restaurant
70  - Cafe, Restaurant
65  - Gas station, Transit station, Bus/Train station
60  - ATM
50  - Parking lot
40  - Park
35  - Bar
30  - Night club
25  - Liquor store
20  - (Other places)
```

Final Score Calculation:
1. Get all nearby places (within radius)
2. Assign safety score based on place type
3. Adjust by place rating (Google rating)
4. Average all scores
5. Apply safety thresholds

---

## Data Flow

### Chat Flow
```
User Input
    ↓
[Check if Ollama initialized]
    ↓
[Add to chat history]
    ↓
[Send to Ollama API]
    ↓
[Ollama processes with system prompt]
    ↓
[Get response]
    ↓
[Add to chat history]
    ↓
Display to User
```

### Area Safety Check Flow
```
User taps Location button
    ↓
[Get device location via Geolocator]
    ↓
[Call Google Places API nearby search]
    ↓
[Analyze places and safety score]
    ↓
[Send analysis to AI for interpretation]
    ↓
[Combine API data + AI analysis]
    ↓
Display comprehensive report
```

---

## Configuration

### Ollama Setup
```
URL: http://localhost:11434
Model: mistral (default)
Stream: false (single response)
Timeout: 60 seconds
```

### Google Places API
```
Service: Google Places API
Required Scopes: Places API
Rate Limit: Standard quota
Radius: 500m (default for safety check)
Results: Top 10 places analyzed
```

---

## Response Structure

### Chat Response
```dart
{
  "role": "assistant",
  "content": "User-friendly response text"
}
```

### Area Safety Response
```dart
{
  'isSafe': bool,
  'safetyScore': int (0-100),
  'message': String,
  'recommendation': String,
  'details': {
    'totalPlaces': int,
    'safePlaces': int,
    'riskyPlaces': int,
    'neutralPlaces': int,
    'placeTypes': {
      'place_type': count,
      ...
    }
  }
}
```

---

## Error Handling

### Ollama Errors
- Connection timeout → Show setup screen
- Invalid model → Fallback to mistral
- No response → User-friendly error message

### Google Places Errors
- API key invalid → Optional feature
- No location permission → Prompt user
- Network error → Graceful degradation

### Common Issues
```
Error: "Make sure Ollama is running"
Solution: Verify localhost:11434 is accessible

Error: "Google API not initialized"
Solution: Optional - app works without it

Error: "Location permission denied"
Solution: Enable in device settings
```

---

## Performance Considerations

### Ollama Response Time
- First request: 10-15 seconds (model loading)
- Subsequent requests: 2-5 seconds
- Depends on model size and computer specs

### API Calls
- Nearby places search: ~1 second
- Google API call: ~2 seconds
- Total area check: ~3-5 seconds

### Memory Usage
- Chat history: Stored in RAM (limited)
- Models: Keep first 5-10 messages for context
- UI: ListView with constraint on message width

---

## Testing Recommendations

### Unit Tests
```dart
test('askSafetyQuestion returns response', () async {
  await service.initialize(testUrl);
  final response = await service.askSafetyQuestion('Is area safe?');
  expect(response.isNotEmpty, true);
});

test('Google service calculates safety score', () async {
  service.initialize(apiKey);
  final result = await service.checkAreaSafety(...);
  expect(result['safetyScore'], greaterThanOrEqualTo(0));
});
```

### Integration Tests
- Test Ollama connection
- Test Google Places API
- Test location permissions
- Test end-to-end chat flow

---

## Future Enhancements

### Phase 2
- [ ] Offline mode with cached responses
- [ ] Multiple AI models (Llama2, Neural-chat)
- [ ] Custom safety databases
- [ ] Real-time incident integration

### Phase 3
- [ ] Community safety mapping
- [ ] Saved routes and locations
- [ ] Safety alerts for specific areas
- [ ] Integration with emergency contacts

### Phase 4
- [ ] ML model for threat prediction
- [ ] Voice input/output
- [ ] Multi-language support
- [ ] Advanced analytics

---

## Dependencies Added

```yaml
# For Google Maps and Places integration
google_maps_flutter: ^2.5.0
google_places_flutter: ^2.0.8

# For unique identifiers
uuid: ^4.0.0

# Already present
http: ^1.1.0
geolocator: ^10.1.0
```

---

## File Structure

```
lib/
├── screens/
│   └── ai_safety_assistant_screen.dart (UPDATED)
├── services/
│   ├── ai_safety_assistant_service.dart (UPDATED)
│   └── google_places_safety_service.dart (NEW)
└── main.dart

Documentation/
├── AI_SETUP_GUIDE.md (NEW)
└── AI_TECHNICAL_DOCS.md (this file)
```

---

## Security Considerations

1. **API Keys**
   - Store securely (not in code)
   - Consider environment variables
   - Rotate regularly

2. **Location Data**
   - Only sent when user requests
   - Not stored permanently
   - Requires explicit permission

3. **Chat History**
   - Stored locally only
   - Cleared when user requests
   - Not synced to cloud

4. **Ollama**
   - Localhost only (no external exposure)
   - No API key required
   - All processing local

---

## Deployment Notes

### Android
- Requires `android.permission.ACCESS_FINE_LOCATION`
- Google Play Services for location

### iOS
- Requires `NSLocationWhenInUseUsageDescription`
- Privacy policy must mention location use

### Web
- Limited location support
- Ollama must be CORS-enabled
- Google API key required

---

## Support & Debugging

### Enable Debug Logging
```dart
// Uncomment in services for verbose logging
debugPrint('🤖 User: $question');
debugPrint('🤖 AI: $response');
debugPrint('📍 Safety Score: $score');
```

### Check Ollama Status
```bash
# Terminal/CMD
curl http://localhost:11434/api/tags
# Should return list of available models
```

### Test Google API
```bash
# Test API key validity
curl "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=40.7128,-74.0060&radius=500&key=YOUR_API_KEY"
```

---

## Contributing

When adding new features:
1. Follow existing code patterns
2. Add emotional support context
3. Include error handling
4. Update documentation
5. Test with real data

---

**Last Updated**: January 2026
**Version**: 1.0
**Status**: Production Ready
