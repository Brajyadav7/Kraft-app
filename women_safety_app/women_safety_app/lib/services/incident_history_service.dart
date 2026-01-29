import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class IncidentEntry {
  final DateTime timestamp;
  final String type; // 'sos', 'shake', 'manual'
  final String? location;
  final List<String> contactsNotified;

  IncidentEntry({
    required this.timestamp,
    required this.type,
    this.location,
    required this.contactsNotified,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'location': location,
      'contactsNotified': contactsNotified,
    };
  }

  factory IncidentEntry.fromJson(Map<String, dynamic> json) {
    return IncidentEntry(
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'],
      location: json['location'],
      contactsNotified: List<String>.from(json['contactsNotified'] ?? []),
    );
  }
}

class IncidentHistoryService {
  static const String _key = 'incident_history';

  /// Save an incident to history
  static Future<void> logIncident(IncidentEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    history.add(entry);

    // Keep only last 50 incidents
    if (history.length > 50) {
      history.removeAt(0);
    }

    final jsonList = history.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_key, jsonList);
  }

  /// Get all incidents
  static Future<List<IncidentEntry>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];

    return jsonList
        .map((json) => IncidentEntry.fromJson(jsonDecode(json)))
        .toList();
  }

  /// Get incidents from last N days
  static Future<List<IncidentEntry>> getIncidentsFromDays(int days) async {
    final history = await getHistory();
    final cutoffDate = DateTime.now().subtract(Duration(days: days));

    return history
        .where((entry) => entry.timestamp.isAfter(cutoffDate))
        .toList();
  }

  /// Clear all history
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// Get statistics
  static Future<Map<String, dynamic>> getStatistics() async {
    final history = await getHistory();

    final sosCount = history.where((e) => e.type == 'sos').length;
    final shakeCount = history.where((e) => e.type == 'shake').length;
    final manualCount = history.where((e) => e.type == 'manual').length;

    return {
      'totalIncidents': history.length,
      'sosCount': sosCount,
      'shakeCount': shakeCount,
      'manualCount': manualCount,
      'lastIncident': history.isNotEmpty ? history.last.timestamp : null,
    };
  }
}
