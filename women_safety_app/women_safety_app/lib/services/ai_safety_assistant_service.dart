import 'package:flutter/foundation.dart';
import 'custom_ai_service.dart';

/// Backwards-compatible facade that exposes the same API as the
/// original service but delegates to the
/// new `CustomAISafetyService` backend.
class AISafetyAssistantService {
  static final AISafetyAssistantService _instance =
      AISafetyAssistantService._internal();

  factory AISafetyAssistantService() => _instance;

  AISafetyAssistantService._internal();

  final CustomAISafetyService _backend = CustomAISafetyService();

  /// Initialize the custom backend. `model` parameter kept for compatibility.
  Future<void> initialize(String backendUrl, {String? model}) async {
    try {
      await _backend.initialize(backendUrl);
      debugPrint('✅ AISafetyAssistantService initialized with $backendUrl');
    } catch (e) {
      debugPrint('❌ AISafetyAssistantService initialization failed: $e');
      rethrow;
    }
  }

  Future<String> askSafetyQuestion(String question) async {
    return await _backend.askSafetyQuestion(question);
  }

  Future<String> assessThreatLevel({
    required double latitude,
    required double longitude,
    required String timeOfDay,
    required int recentIncidentsCount,
    String? locationName,
  }) async {
    final prompt =
        '''Based on the following information, assess the current threat level (Low/Medium/High) and provide safety recommendations:\n- Location: Latitude $latitude, Longitude $longitude ${locationName != null ? '($locationName)' : ''}\n- Time: $timeOfDay\n- Recent incidents in area: $recentIncidentsCount\n\nProvide a brief threat assessment and one actionable safety tip.''';
    return await askSafetyQuestion(prompt);
  }

  Future<String> checkRouteSafety({
    required String startLocation,
    required String endLocation,
    required String timeOfDay,
  }) async {
    final prompt =
        '''Is it safe to travel from $startLocation to $endLocation at $timeOfDay? Provide specific safety concerns and recommendations.''';
    return await askSafetyQuestion(prompt);
  }

  Future<String> getSafetyTips(String situation) async {
    final prompt =
        '''Provide 3 practical safety tips for: $situation\nFormat as a numbered list.''';
    return await askSafetyQuestion(prompt);
  }

  Future<String> suggestSafeNearbyPlaces({
    required String currentLocation,
    required String placeType,
  }) async {
    final prompt =
        '''I'm at $currentLocation and need to find nearby $placeType. What are the safest types of places to go? Provide recommendations.''';
    return await askSafetyQuestion(prompt);
  }

  List<Map<String, String>> getChatHistory() => _backend.getChatHistory();

  void clearChatHistory() => _backend.clearChatHistory();

  Future<String> checkAreaSafetyWithSupport({
    required String areaName,
    required String timeOfDay,
    required String context,
  }) async {
    final prompt =
        '''I'm concerned about the safety of an area. Can you help me assess it?\n\nArea: $areaName\nTime: $timeOfDay\nContext: $context\n\nPlease provide:\n1. Honest safety assessment\n2. Practical safety recommendations\n3. Reassurance and supportive guidance\n4. What to do if I feel unsafe\n\nRemember to be empathetic and supportive while being truthful about risks.''';
    return await askSafetyQuestion(prompt);
  }

  Future<String> getEmotionalSupport(String concern) async {
    return await _backend.getEmotionalSupport(concern);
  }

  Future<String> getHolisticSafetyAdvice(String situation) async {
    final prompt =
        '''I need safety advice and emotional support for this situation:\n\n$situation\n\nPlease provide a comprehensive response that includes:\n1. Understanding: Show you understand their situation and validate their concerns\n2. Practical steps: Clear, actionable safety measures\n3. Emotional support: Build confidence and reassurance\n4. Resources: Suggest emergency contacts or support services if relevant\n5. Empowerment: Remind them of their strength and capability\n\nBe warm, compassionate, and practical in your response.''';
    return await askSafetyQuestion(prompt);
  }

  Future<String> askWithEmotion(String question) async =>
      await askSafetyQuestion(question);

  bool get isInitialized => _backend.isInitialized;
}
