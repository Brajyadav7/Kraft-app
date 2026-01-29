import 'package:camera/camera.dart';

import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';

class RecordingService {
  static CameraController? _controller;
  
  // Use ValueNotifier so UI can listen to state changes
  static final ValueNotifier<bool> isRecordingNotifier = ValueNotifier<bool>(false);

  static bool get isRecording => isRecordingNotifier.value;

  /// Initialize the camera
  static Future<void> initialize({bool enableAudio = true}) async {
    try {
      // 1. Explicitly check permissions
      var camStatus = await Permission.camera.status;
      if (!camStatus.isGranted) {
        camStatus = await Permission.camera.request();
        if (!camStatus.isGranted) throw Exception("Camera permission denied");
      }

      if (enableAudio) {
        var micStatus = await Permission.microphone.status;
        if (!micStatus.isGranted) {
          micStatus = await Permission.microphone.request();
          if (!micStatus.isGranted) throw Exception("Microphone permission denied");
        }
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) throw Exception("No cameras available");

      final camera = cameras.first;

      _controller = CameraController(
        camera,
        ResolutionPreset.medium, 
        enableAudio: enableAudio,
      );

      await _controller!.initialize();
      debugPrint("Camera initialized (Audio: $enableAudio)");
    } catch (e) {
      debugPrint("Error initializing recording service: $e");
      throw Exception("Init failed: $e");
    }
  }

  /// Start recording video
  static Future<void> startRecording() async {
    isRecordingNotifier.value = false;

    // First attempt: Try with Audio
    try {
      await _startRecordingInternal(enableAudio: true);
    } catch (e) {
      debugPrint("❌ Start with audio failed: $e. Retrying VIDEO ONLY...");
      // Fallback: Try Video Only
      try {
        await _startRecordingInternal(enableAudio: false);
      } catch (e2) {
        debugPrint("❌ Video-only start failed: $e2");
        isRecordingNotifier.value = false;
        throw Exception("Start failed (Audio & Video): $e2");
      }
    }
  }

  static Future<void> _startRecordingInternal({required bool enableAudio}) async {
    // Dispose existing if any
    if (_controller != null) {
      await _controller!.dispose();
    }
    
    await initialize(enableAudio: enableAudio);
    
    if (_controller == null || !_controller!.value.isInitialized) {
       throw Exception("Camera not initialized");
    }

    await _controller!.startVideoRecording();
    isRecordingNotifier.value = true;
    debugPrint("✅ Started Video Recording (Audio: $enableAudio)");
  }

  /// Stop recording and save to Gallery
  static Future<String?> stopRecording() async {
    if (_controller == null || !isRecording) {
      return null;
    }

    try {
      final XFile videoFile = await _controller!.stopVideoRecording();
      isRecordingNotifier.value = false;
      
      final String filePath = videoFile.path;
      debugPrint("Video recorded to temp path: $filePath");
      
      // Save to Gallery using Gal
      try {
        await Gal.putVideo(filePath, album: "SafetyApp_SOS");
        debugPrint("✅ Saved to Gallery via Gal");
      } catch (e) {
        debugPrint("❌ Failed to save to gallery: $e");
      }

      // Dispose controller to free resources
      await _controller!.dispose();
      _controller = null;

      return filePath;
    } catch (e) {
      debugPrint("Error stopping video recording: $e");
      // Even if error, ensure we reset state
      isRecordingNotifier.value = false;
      return null;
    }
  }
}
