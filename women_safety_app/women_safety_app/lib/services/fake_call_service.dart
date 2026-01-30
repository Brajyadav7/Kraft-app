import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/fake_call_screen.dart';

class FakeCallService {
  static const String _prefsKey = 'fake_call_contact_name';
  
  /// Schedule a fake call after a delay
  static Future<void> scheduleFakeCall(BuildContext context, {
    Duration delay = const Duration(seconds: 5),
    String? contactName,
  }) async {
    // If no name provided, fetch from prefs
    contactName ??= await getSavedContactName();

    if (!context.mounted) return;

    // Show a snackbar or some feedback that call is scheduled
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Fake call scheduled in ${delay.inSeconds} seconds..."),
        duration: const Duration(seconds: 2),
      ),
    );

    // Capture the name for the closure
    final String finalName = contactName;

    Timer(delay, () {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => FakeCallScreen(contactName: finalName),
          ),
        );
      }
    });
  }

  /// Save contact name preference
  static Future<void> saveContactName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, name);
  }

  /// Get saved contact name or default
  static Future<String> getSavedContactName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefsKey) ?? 'Mom';
  }

  /// Get a list of fake contact names for testing
  static List<String> getFakeContactNames() {
    return [
      'Mom',
      'Dad',
      'Sister',
      'Brother',
      'Best Friend',
      'Emergency Services',
    ];
  }
}
