import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'contact_service.dart';
import 'permission_service.dart';
import 'location_service.dart';
import 'incident_history_service.dart';
import 'recording_service.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'notification_handler.dart';
import 'supabase_service.dart';

class EmergencyService {
  static const String emergencyNumber = "112"; // India emergency number
  static const MethodChannel _channel = MethodChannel(
    'com.example.women_safety_app/emergency',
  );

  static const List<String> _defaultContacts = [
    "9368853848",
    "9876543210",
    "9123456780",
  ];

  static bool _isUploading = false;

  static Future<void> triggerSOS(
    Function(String) onStatusChange, {
    bool isBackground = false,
  }) async {
    try {
      await PermissionService.requestAllPermissions();

      // Explicit Check for Permanent Denial (New Device Issue)
      if (await Permission.camera.isPermanentlyDenied || await Permission.microphone.isPermanentlyDenied) {
        onStatusChange('Camera/Mic Permanently Denied. Opening Settings...');
        await Future.delayed(const Duration(seconds: 2));
        await openAppSettings();
        return; // Stop SOS trigger here until fixed
      }

      List<String> contacts = await ContactService.loadNonEmptyContacts();
      if (contacts.isEmpty) contacts = _defaultContacts;

      onStatusChange('Starting Safety Video Recording...');
      // 1. Start Recording FIRST (Best chance to capture evidence before Call/OS kills background)
      try {
        await RecordingService.startRecording();
      } catch (e) {
        debugPrint("Could not start recording: $e");
        onStatusChange('Video Error: ${e.toString().split(':').last.trim()}');
      }

      // 2. Send SMS with location
      onStatusChange('Sending alerts to ${contacts.length} contacts...');
      for (String number in contacts) {
        try {
          await sendSmsWithLocation(number);
          await Future.delayed(const Duration(seconds: 1));
        } catch (e) {
          debugPrint("Could not send SMS to $number: $e");
        }
      }

      // 3. Call Emergency (Likely pushes app to background)
      onStatusChange('Calling emergency services...');
      try {
        await callEmergency();
      } catch (e) {
        debugPrint("Could not call emergency number: $e");
      }

      // Log incident to history
      try {
        String? location;
        try {
          location = await LocationService.getCurrentLocationString();
        } catch (e) {
          debugPrint("Could not get location: $e");
        }

        final incident = IncidentEntry(
          timestamp: DateTime.now(),
          type: 'sos',
          location: location,
          contactsNotified: contacts,
        );
        await IncidentHistoryService.logIncident(incident);
      } catch (e) {
        debugPrint("Could not log incident: $e");
      }
    } catch (e) {
      debugPrint("Error in SOS trigger: $e");
      onStatusChange('Error: $e');
    }
  }

  static Future<bool> callEmergency() async {
    final status = await Permission.phone.request();
    if (status.isGranted) {
      try {
        final bool? result = await _channel.invokeMethod('callNumber', {
          'number': emergencyNumber,
        });
        return result ?? false;
      } catch (e) {
        debugPrint("MethodChannel call failed: $e");
        // Fallback? The user wants "original", original had channel.
        return false;
      }
    }
    return false;
  }

  static Future<bool> sendSmsToContact(String number, String message) async {
    try {
      final bool? result = await _channel.invokeMethod('sendSms', {
        'number': number,
        'message': message,
      });
      return result ?? false;
    } catch (e) {
      debugPrint("MethodChannel SMS failed: $e");
      return false;
    }
  }

  static Future<bool> sendSmsWithLocation(String number) async {
    try {
      String locationString = await LocationService.getCurrentLocationString();
      String message = 'EMERGENCY: I need help!\n\n$locationString';
      return await sendSmsToContact(number, message);
    } catch (e) {
      debugPrint('Error sending SMS with location: $e');
      return false;
    }
  }

  static Future<void> stopSOS({Function(String)? onStatusChange}) async {
    try {
      final String? filePath = await RecordingService.stopRecording();
      debugPrint("SOS and Recording Stopped. File path: $filePath");
      
      if (filePath != null && !_isUploading) {
        _isUploading = true;
        // START FOREGROUND NOTIFICATION TO PREVENT KILL
        await NotificationHandler.showUploadNotification();
        onStatusChange?.call('Uploading video evidence...');
        
        try {
          final String? downloadLink = await _uploadVideo(filePath, onStatusChange: onStatusChange);
          
          if (downloadLink != null) {
            onStatusChange?.call('Video uploaded! Sending link to contacts...');
            
            List<String> contacts = await ContactService.loadNonEmptyContacts();
            if (contacts.isEmpty) contacts = _defaultContacts;

            final String alertMessage = 'Emergency video recorded. Watch here: $downloadLink';
            
            for (String number in contacts) {
              await sendSmsToContact(number, alertMessage);
              await Future.delayed(const Duration(milliseconds: 500));
            }
            onStatusChange?.call('Video link sent to emergency contacts.');
          } else {
            // Error message already handled inside _uploadVideo
          }
        } catch (e) {
          debugPrint("Error during upload/SMS: $e");
          onStatusChange?.call('Error sharing video: ${e.toString().split('\n').first}');
        } finally {
          _isUploading = false;
          // STOP FOREGROUND NOTIFICATION
          await NotificationHandler.cancelUploadNotification();
        }
      } else if (filePath == null) {
        onStatusChange?.call('No recording found to upload.');
      }
    } catch (e) {
      debugPrint("Error stopping SOS: $e");
    }
  }

  static Future<String?> _uploadVideo(String filePath, {Function(String)? onStatusChange}) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        onStatusChange?.call('Err: Video file not found.');
        return null;
      }
      
      final fileSize = await file.length();
      onStatusChange?.call('Checking Internet...');

      // 1. Simple Internet Check
      try {
        final check = await http.get(Uri.parse('https://www.google.com')).timeout(const Duration(seconds: 5));
        if (check.statusCode != 200) throw Exception('Status ${check.statusCode}');
      } catch (e) {
        debugPrint("Internet Check Failed: $e");
        onStatusChange?.call('No Internet Access.');
        return null;
      }

      onStatusChange?.call('Uploading Video (${(fileSize / 1024 / 1024).toStringAsFixed(1)}MB)...');
      await Future.delayed(const Duration(seconds: 1));

      // 2. Upload to Supabase Storage
      try {
        final publicUrl = await SupabaseService.uploadVideo(file);
        
        if (publicUrl != null) {
          debugPrint("✅ Video Uploaded to Supabase: $publicUrl");
          return publicUrl;
        } else {
          onStatusChange?.call('Upload Failed. Retrying...');
        }
      } catch (e) {
        debugPrint("Supabase Upload Error: $e");
        onStatusChange?.call('Upload Error: ${e.toString().split(':').last.trim()}');
      }

      onStatusChange?.call('Video Upload Failed. Saving locally.');
    } catch (e) {
      onStatusChange?.call('Crit Err: ${e.toString().split(' ').take(3).join(' ')}');
    }
    return null;
  }
}

