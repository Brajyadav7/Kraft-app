
import 'package:flutter/foundation.dart';
import 'emergency_service.dart';

class VoiceCommandService {
  static final VoiceCommandService _instance = VoiceCommandService._internal();
  factory VoiceCommandService() => _instance;
  VoiceCommandService._internal();

  // Stub for speech to text
  // final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;

  


  bool get isListening => _isListening;

  Future<bool> initialize() async {
    // Stub
    debugPrint('Voice Service: Speech to text disabled');
    return false;
  }

  void startListening({required Function(String text) onResult}) {
    // Stub
    debugPrint('Voice Service: startListening called but disabled');
  }

  void stopListening() {
    // Stub
    _isListening = false;
  }

  // Wrapper to call static EmergencyService
  void triggerSOS() {
    EmergencyService.triggerSOS((status) {
      debugPrint('Voice SOS Status: $status');
    });
  }
}
