import 'package:camera/camera.dart';

import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';

class RecordingService {
  static CameraController? _controller;
  
  // Use ValueNotifier so UI can listen to state changes
  static final ValueNotifier<bool> isRecordingNotifier = ValueNotifier<bool>(false);

  static bool get isRecording => isRecordingNotifier.value;

  /// Initialize the camera (rear camera by default)
  static Future<void> initialize() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint("No cameras available");
        return;
      }

      // Use the first available camera (usually rear)
      final camera = cameras.first;

      _controller = CameraController(
        camera,
        ResolutionPreset.medium, // Medium quality to save space but keeping it clear
        enableAudio: true,
      );

      await _controller!.initialize();
      debugPrint("Camera initialized");
    } catch (e) {
      debugPrint("Error initializing recording service: $e");
    }
  }

  /// Start recording video
  static Future<void> startRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      await initialize();
    }

    if (_controller == null) {
       debugPrint("Camera controller is null after init attempt");
       return;
    }

    if (isRecording) {
      debugPrint("Already recording");
      return;
    }

    try {
      await _controller!.startVideoRecording();
      isRecordingNotifier.value = true;
      debugPrint("Started Video Recording");
    } catch (e) {
      debugPrint("Error starting video recording: $e");
    }
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
