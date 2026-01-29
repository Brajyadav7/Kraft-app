import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomAISafetyService {
  static final CustomAISafetyService _instance =
      CustomAISafetyService._internal();

  factory CustomAISafetyService() {
    return _instance;
  }

  CustomAISafetyService._internal();

  String _backendUrl = 'http://127.0.0.1:5000';
  bool _isInitialized = false;
  final List<Map<String, String>> _chatHistory = [];

  /// Initialize connection to custom AI backend
  Future<void> initialize(String backendUrl) async {
    try {
      _backendUrl = backendUrl;

      // Test connection with health check
      final response = await http
          .get(Uri.parse('$_backendUrl/api/health'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        _isInitialized = true;
        debugPrint('✅ Connected to Custom AI Backend at $_backendUrl');
      } else {
        throw Exception('Failed to connect to Custom AI Backend');
      }
    } catch (e) {
      debugPrint('❌ Failed to initialize Custom AI Backend: $e');
      throw Exception(
        'Make sure the Custom AI Backend is running on $_backendUrl\nError: $e',
      );
    }
  }

  /// Send a message to the custom AI backend
  Future<String> askSafetyQuestion(String question) async {
    if (!_isInitialized) {
      throw Exception(
        'Custom AI Backend not initialized. Call initialize() with backend URL first.',
      );
    }

    try {
      debugPrint('🤖 User: $question');

      // Add to chat history
      _chatHistory.add({'role': 'user', 'content': question});

      // Send to custom backend
      final response = await http
          .post(
            Uri.parse('$_backendUrl/api/ai/chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'message': question,
              'context': {
                'type': 'chat',
                'timestamp': DateTime.now().toIso8601String(),
              },
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['response'] ?? 'No response';

        // Add to chat history
        _chatHistory.add({'role': 'assistant', 'content': aiResponse});

        debugPrint('🤖 AI: $aiResponse');
        return aiResponse;
      } else {
        throw Exception('Backend error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error getting AI response: $e');
      return 'Error: Unable to process your request. Make sure the Custom AI Backend is running on $_backendUrl';
    }
  }

  /// Get emotional support response
  Future<String> getEmotionalSupport(String concern) async {
    if (!_isInitialized) {
      throw Exception('Custom AI Backend not initialized');
    }

    try {
      final response = await http
          .post(
            Uri.parse('$_backendUrl/api/ai/support'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'concern': concern,
              'context': {
                'type': 'emotional_support',
                'timestamp': DateTime.now().toIso8601String(),
              },
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['response'] ?? 'No response';
        _chatHistory.add({'role': 'assistant', 'content': aiResponse});
        return aiResponse;
      } else {
        throw Exception('Backend error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error getting emotional support: $e');
      return 'Error: Unable to process your request.';
    }
  }

  /// Check area safety
  Future<String> checkAreaSafetyWithSupport({
    required String areaName,
    required String timeOfDay,
    required double latitude,
    required double longitude,
  }) async {
    if (!_isInitialized) {
      throw Exception('Custom AI Backend not initialized');
    }

    try {
      final response = await http
          .post(
            Uri.parse('$_backendUrl/api/ai/area-safety'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'latitude': latitude,
              'longitude': longitude,
              'area_name': areaName,
              'time_of_day': timeOfDay,
              'radius': 500,
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiAnalysis = data['ai_analysis'] ?? 'No analysis available';
        _chatHistory.add({'role': 'assistant', 'content': aiAnalysis});
        return aiAnalysis;
      } else {
        throw Exception('Backend error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error checking area safety: $e');
      return 'Error: Unable to analyze area safety.';
    }
  }

  /// Get threat assessment
  Future<String> getThreatAssessment(String threat) async {
    if (!_isInitialized) {
      throw Exception('Custom AI Backend not initialized');
    }

    try {
      final response = await http
          .post(
            Uri.parse('$_backendUrl/api/ai/threat-assessment'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'threat': threat}),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['response'] ?? 'No response';
        _chatHistory.add({'role': 'assistant', 'content': aiResponse});
        return aiResponse;
      } else {
        throw Exception('Backend error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error getting threat assessment: $e');
      return 'Error: Unable to process threat assessment.';
    }
  }

  /// Get chat history
  List<Map<String, String>> getChatHistory() {
    return List.from(_chatHistory);
  }

  /// Clear chat history
  Future<void> clearChatHistory() async {
    if (!_isInitialized) {
      return;
    }

    try {
      await http
          .post(
            Uri.parse('$_backendUrl/api/chat/clear'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 15));

      _chatHistory.clear();
      debugPrint('🗑️ Chat history cleared');
    } catch (e) {
      debugPrint('Warning: Could not clear backend history: $e');
      _chatHistory.clear();
    }
  }

  /// Get backend status
  Future<bool> checkBackendStatus() async {
    try {
      final response = await http
          .get(Uri.parse('$_backendUrl/api/health'))
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  bool get isInitialized => _isInitialized;
  String get backendUrl => _backendUrl;
}
