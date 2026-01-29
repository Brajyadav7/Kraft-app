import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';

class TrustedZone {
  final String name;
  final double latitude;
  final double longitude;
  final double radiusInMeters; // Radius of the zone

  TrustedZone({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.radiusInMeters = 500, // Default 500 meters
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'radiusInMeters': radiusInMeters,
    };
  }

  factory TrustedZone.fromJson(Map<String, dynamic> json) {
    return TrustedZone(
      name: json['name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      radiusInMeters: json['radiusInMeters'] ?? 500,
    );
  }
}

class TrustedZoneService {
  static const String _key = 'trusted_zones';

  /// Add a trusted zone (e.g., home, workplace)
  static Future<void> addZone(TrustedZone zone) async {
    final prefs = await SharedPreferences.getInstance();
    final zones = await getZones();
    zones.add(zone);

    final jsonList = zones.map((z) => jsonEncode(z.toJson())).toList();
    await prefs.setStringList(_key, jsonList);
  }

  /// Get all trusted zones
  static Future<List<TrustedZone>> getZones() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];

    return jsonList
        .map((json) => TrustedZone.fromJson(jsonDecode(json)))
        .toList();
  }

  /// Remove a zone by name
  static Future<void> removeZone(String zoneName) async {
    final prefs = await SharedPreferences.getInstance();
    final zones = await getZones();
    zones.removeWhere((z) => z.name == zoneName);

    final jsonList = zones.map((z) => jsonEncode(z.toJson())).toList();
    await prefs.setStringList(_key, jsonList);
  }

  /// Check if current location is in any trusted zone
  static Future<bool> isInTrustedZone(Position currentPosition) async {
    final zones = await getZones();

    for (var zone in zones) {
      final distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        zone.latitude,
        zone.longitude,
      );

      if (distance <= zone.radiusInMeters) {
        return true;
      }
    }

    return false;
  }

  /// Get the nearest trusted zone
  static Future<TrustedZone?> getNearestZone(Position currentPosition) async {
    final zones = await getZones();
    if (zones.isEmpty) return null;

    TrustedZone? nearest;
    double minDistance = double.infinity;

    for (var zone in zones) {
      final distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        zone.latitude,
        zone.longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearest = zone;
      }
    }

    return nearest;
  }

  /// Clear all zones
  static Future<void> clearZones() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// Initialize with default zones if empty
  static Future<void> initializeDefaultZones() async {
    final zones = await getZones();
    if (zones.isEmpty) {
      // Chandigarh University coordinates
      await addZone(
        TrustedZone(
          name: 'Chandigarh University',
          latitude: 30.7575,
          longitude: 76.7733,
          radiusInMeters: 1000, // 1 km radius
        ),
      );
    }
  }

  /// Get location name from trusted zones (if in zone)
  static Future<String?> getLocationName(Position currentPosition) async {
    final zones = await getZones();

    for (var zone in zones) {
      final distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        zone.latitude,
        zone.longitude,
      );

      if (distance <= zone.radiusInMeters) {
        return zone.name;
      }
    }

    return null;
  }
}
