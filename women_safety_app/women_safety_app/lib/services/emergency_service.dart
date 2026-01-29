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
import 'dart:convert';
import 'notification_handler.dart';

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

      List<String> contacts = await ContactService.loadNonEmptyContacts();
      if (contacts.isEmpty) contacts = _defaultContacts;

      onStatusChange('Sending alerts to ${contacts.length} contacts...');

      // Send SMS with location to all contacts
      for (String number in contacts) {
        try {
          await sendSmsWithLocation(number);
          await Future.delayed(const Duration(seconds: 1));
        } catch (e) {
          debugPrint("Could not send SMS to $number: $e");
        }
      }

      onStatusChange('Calling emergency services...');
      try {
        await callEmergency();
      } catch (e) {
        debugPrint("Could not call emergency number: $e");
      }

      // Start Video Recording
      onStatusChange('Starting Safety Video Recording...');
      try {
        await RecordingService.startRecording();
      } catch (e) {
        debugPrint("Could not start recording: $e");
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
        onStatusChange?.call('Err: File not found.');
        return null;
      }
      
      final fileSize = await file.length();
      onStatusChange?.call('Checking Internet...');

      // 1. REAL Internet Check (HTTP GET)
      try {
        final check = await http.get(Uri.parse('https://www.google.com')).timeout(const Duration(seconds: 5));
        if (check.statusCode != 200) throw Exception('Status ${check.statusCode}');
      } catch (e) {
        debugPrint("Internet Check Failed: $e");
        onStatusChange?.call('No Internet Access (Google Failed)');
        return null;
      }

      onStatusChange?.call('Uploading (${(fileSize / 1024 / 1024).toStringAsFixed(1)}MB)...');
      await Future.delayed(const Duration(seconds: 1));

      // 2. Try File.io (Standard Multipart) - Proven Method
      try {
        debugPrint("Trying File.io...");
        var request = http.MultipartRequest('POST', Uri.parse('https://file.io'));
        request.files.add(await http.MultipartFile.fromPath('file', filePath));
        
        var response = await request.send().timeout(const Duration(minutes: 5));
        var responseBody = await response.stream.bytesToString(); // usage of http.Response.fromStream can cause issues sometimes

        if (response.statusCode == 200) {
          var data = jsonDecode(responseBody);
          if (data['success'] == true) return data['link'];
        }
        debugPrint("File.io Status: ${response.statusCode}");
      } catch (e) {
        debugPrint("File.io Error: $e");
      }

      // 3. Fallback: BashUpload (Simple PUT)
      try {
        onStatusChange?.call('Server 2 (BashUpload)...');
        final response = await http.put(
          Uri.parse('https://bashupload.com/${file.path.split('/').last}'),
          body: await file.readAsBytes(),
        ).timeout(const Duration(minutes: 5));
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          final link = response.body.trim();
          if (link.contains('http')) return link;
        }
      } catch (e) {
         debugPrint("BashUpload Error: $e");
      }

      onStatusChange?.call('Upload Failed. Check Data.');
    } catch (e) {
      onStatusChange?.call('Err: ${e.toString().split(' ').take(3).join(' ')}');
    }
    return null;
  }
}

