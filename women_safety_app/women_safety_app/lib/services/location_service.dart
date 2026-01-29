import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

class LocationService {
  static Future<String> getCurrentLocationString() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        return 'Location: Disabled';
      }

      // Get permission status
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied');
          return 'Location: Permission denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied');
        return 'Location: Permission denied forever';
      }

      // Get current position with timeout
      Position position =
          await Geolocator.getCurrentPosition(
            timeLimit: const Duration(seconds: 10),
            forceAndroidLocationManager: true,
          ).onError((error, stackTrace) {
            debugPrint('Error getting location: $error');
            return Position(
              latitude: 0,
              longitude: 0,
              timestamp: DateTime.now(),
              accuracy: 0,
              altitude: 0,
              heading: 0,
              speed: 0,
              speedAccuracy: 0,
              altitudeAccuracy: 0,
              headingAccuracy: 0,
            );
          });

      // Format location string
      String locationUrl =
          'https://maps.google.com/?q=${position.latitude},${position.longitude}';
      String locationString =
          'Location: ${position.latitude}, ${position.longitude}\nGoogle Maps: $locationUrl';

      debugPrint('Location obtained: $locationString');
      return locationString;
    } catch (e) {
      debugPrint('Exception in getCurrentLocationString: $e');
      return 'Location: Unable to get location - $e';
    }
  }

  static Future<Map<String, dynamic>> getCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return {
          'success': false,
          'latitude': null,
          'longitude': null,
          'error': 'Location services disabled',
        };
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        return {
          'success': false,
          'latitude': null,
          'longitude': null,
          'error': 'Permission denied',
        };
      }

      Position position = await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 10),
        forceAndroidLocationManager: true,
      );

      return {
        'success': true,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
      };
    } catch (e) {
      debugPrint('Error getting position: $e');
      return {
        'success': false,
        'latitude': null,
        'longitude': null,
        'error': e.toString(),
      };
    }
  }
}
