import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class SafetyCheckInService {
  static const String _lastCheckInKey = 'last_check_in_time';
  static const String _checkInIntervalKey = 'check_in_interval_hours';
  static const String _checkInEnabledKey = 'check_in_enabled';

  /// Enable automatic safety check-ins
  static Future<void> enableCheckIns(int intervalHours) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_checkInEnabledKey, true);
    await prefs.setInt(_checkInIntervalKey, intervalHours);
  }

  /// Disable check-ins
  static Future<void> disableCheckIns() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_checkInEnabledKey, false);
  }

  /// Record a safety check-in
  static Future<void> recordCheckIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastCheckInKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Get the time of last check-in
  static Future<DateTime?> getLastCheckIn() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastCheckInKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Check if a check-in is overdue
  static Future<bool> isCheckInOverdue() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool(_checkInEnabledKey) ?? false;

    if (!isEnabled) return false;

    final lastCheckIn = await getLastCheckIn();
    if (lastCheckIn == null) return true;

    final intervalHours = prefs.getInt(_checkInIntervalKey) ?? 4;
    final now = DateTime.now();
    final difference = now.difference(lastCheckIn).inHours;

    return difference >= intervalHours;
  }

  /// Get check-in status
  static Future<Map<String, dynamic>> getCheckInStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool(_checkInEnabledKey) ?? false;
    final lastCheckIn = await getLastCheckIn();
    final intervalHours = prefs.getInt(_checkInIntervalKey) ?? 4;
    final isOverdue = await isCheckInOverdue();

    return {
      'isEnabled': isEnabled,
      'lastCheckIn': lastCheckIn,
      'intervalHours': intervalHours,
      'isOverdue': isOverdue,
      'nextCheckInDue': lastCheckIn?.add(Duration(hours: intervalHours)),
    };
  }
}
