import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GooglePlacesSafetyService {
  static final GooglePlacesSafetyService _instance =
      GooglePlacesSafetyService._internal();

  factory GooglePlacesSafetyService() {
    return _instance;
  }

  GooglePlacesSafetyService._internal();

  // Replace with your actual Google API Key from Google Cloud Console
  String _googleApiKey = '';
  bool _isInitialized = false;

  // Safety indicators based on place types and ratings
  static const Map<String, int> _safetyScores = {
    'police': 100,
    'hospital': 95,
    'fire_station': 95,
    'shopping_mall': 80,
    'grocery_or_supermarket': 75,
    'cafe': 70,
    'restaurant': 70,
    'bank': 75,
    'atm': 60,
    'parking': 50,
    'parking_lot': 50,
    'gas_station': 65,
    'transit_station': 65,
    'bus_station': 65,
    'train_station': 65,
    'park': 40,
    'night_club': 30,
    'bar': 35,
    'liquor_store': 25,
    'movie_theater': 75,
  };

  /// Initialize with Google API Key
  void initialize(String googleApiKey) {
    _googleApiKey = googleApiKey;
    _isInitialized = true;
    debugPrint('✅ Google Places API initialized');
  }

  /// Check area safety based on nearby places and ratings
  Future<Map<String, dynamic>> checkAreaSafety({
    required double latitude,
    required double longitude,
    required String radius,
  }) async {
    if (!_isInitialized) {
      return {
        'isSafe': null,
        'safetyScore': 0,
        'message': 'Google API not initialized. Please configure API key.',
        'details': {},
      };
    }

    try {
      final nearbyPlaces = await _getNearbyPlaces(latitude, longitude, radius);
      final placeDetails = await _getPlaceDetails(nearbyPlaces);

      final safetyAnalysis = _analyzeSafety(placeDetails);

      return safetyAnalysis;
    } catch (e) {
      debugPrint('❌ Error checking area safety: $e');
      return {
        'isSafe': null,
        'safetyScore': 0,
        'message': 'Unable to analyze area safety at this moment.',
        'error': e.toString(),
      };
    }
  }

  /// Get nearby places using Google Places API
  Future<List<Map<String, dynamic>>> _getNearbyPlaces(
    double latitude,
    double longitude,
    String radius,
  ) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=$latitude,$longitude'
        '&radius=$radius'
        '&key=$_googleApiKey',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results =
            (data['results'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        debugPrint('📍 Found ${results.length} nearby places');
        return results;
      } else {
        throw Exception('Google API error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching nearby places: $e');
      rethrow;
    }
  }

  /// Get detailed information about places
  Future<List<Map<String, dynamic>>> _getPlaceDetails(
    List<Map<String, dynamic>> places,
  ) async {
    final details = <Map<String, dynamic>>[];

    for (final place in places.take(10)) {
      // Limit to 10 places to avoid quota issues
      try {
        final name = place['name'] ?? 'Unknown';
        final placeId = place['place_id'];
        final types = (place['types'] as List?)?.cast<String>() ?? [];
        final rating = (place['rating'] as num?)?.toDouble() ?? 0.0;
        final openNow = place['opening_hours']?['open_now'];

        details.add({
          'name': name,
          'placeId': placeId,
          'types': types,
          'rating': rating,
          'openNow': openNow,
        });
      } catch (e) {
        debugPrint('Error processing place: $e');
      }
    }

    return details;
  }

  /// Analyze safety based on nearby places and their characteristics
  Map<String, dynamic> _analyzeSafety(List<Map<String, dynamic>> places) {
    if (places.isEmpty) {
      return {
        'isSafe': false,
        'safetyScore': 30,
        'message': 'Area appears isolated with no nearby places.',
        'recommendation': 'Avoid this area, especially at night.',
        'details': {'totalPlaces': 0},
      };
    }

    int totalScore = 0;
    int safetyPlaces = 0;
    int riskyPlaces = 0;
    int neutralPlaces = 0;

    final placesByType = <String, int>{};

    for (final place in places) {
      final types = (place['types'] as List?)?.cast<String>() ?? [];
      final rating = (place['rating'] as double?) ?? 0.0;
      int placeScore = 50; // Default neutral score

      // Check against safety scores
      for (final type in types) {
        if (_safetyScores.containsKey(type)) {
          placeScore = _safetyScores[type]!;
          placesByType[type] = (placesByType[type] ?? 0) + 1;
          break;
        }
      }

      // Adjust score based on rating
      if (rating > 0) {
        placeScore = (placeScore * (rating / 5.0)).toInt();
      }

      totalScore += placeScore;

      if (placeScore >= 70) {
        safetyPlaces++;
      } else if (placeScore < 40) {
        riskyPlaces++;
      } else {
        neutralPlaces++;
      }
    }

    final averageScore = (totalScore / places.length).toInt();
    final isSafe = averageScore >= 60 && safetyPlaces > riskyPlaces;

    String message = '';
    String recommendation = '';

    if (averageScore >= 80) {
      message = 'Area is VERY SAFE with good infrastructure and businesses.';
      recommendation = 'Good area to be in. Maintain normal precautions.';
    } else if (averageScore >= 60) {
      message = 'Area is MODERATELY SAFE with decent infrastructure.';
      recommendation =
          'Area is reasonably safe. Stay alert and avoid late night visits.';
    } else if (averageScore >= 40) {
      message = 'Area has MIXED SAFETY with some concerning locations.';
      recommendation =
          'Use caution. Avoid isolated areas and travel in groups if possible.';
    } else {
      message = 'Area has POOR SAFETY indicators.';
      recommendation =
          'Avoid this area if possible. If you must go, use extreme caution and inform others.';
    }

    return {
      'isSafe': isSafe,
      'safetyScore': averageScore,
      'message': message,
      'recommendation': recommendation,
      'details': {
        'totalPlaces': places.length,
        'safePlaces': safetyPlaces,
        'riskyPlaces': riskyPlaces,
        'neutralPlaces': neutralPlaces,
        'placeTypes': placesByType,
      },
    };
  }

  /// Get safety rating for a specific location
  Future<Map<String, dynamic>> getLocationSafetyRating({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Check with 500m radius for immediate area
      return await checkAreaSafety(
        latitude: latitude,
        longitude: longitude,
        radius: '500',
      );
    } catch (e) {
      debugPrint('❌ Error getting safety rating: $e');
      return {
        'isSafe': null,
        'safetyScore': 0,
        'message': 'Unable to determine safety rating.',
      };
    }
  }

  /// Get nearby safe places (police, hospital, etc.)
  Future<List<Map<String, dynamic>>> getNearbyEmergencyServices({
    required double latitude,
    required double longitude,
  }) async {
    if (!_isInitialized) {
      return [];
    }

    try {
      final places = await _getNearbyPlaces(latitude, longitude, '1000');
      final emergency = places
          .where((place) {
            final types = (place['types'] as List?)?.cast<String>() ?? [];
            return types.contains('police') ||
                types.contains('hospital') ||
                types.contains('fire_station');
          })
          .map(
            (place) => {
              'name': place['name'],
              'type': ((place['types'] as List?)?.cast<String>() ?? []).first,
              'openNow': place['opening_hours']?['open_now'],
              'rating': place['rating'],
            },
          )
          .toList();

      return emergency;
    } catch (e) {
      debugPrint('❌ Error fetching emergency services: $e');
      return [];
    }
  }

  bool get isInitialized => _isInitialized;
}
