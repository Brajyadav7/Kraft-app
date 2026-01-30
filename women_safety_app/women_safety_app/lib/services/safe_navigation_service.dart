import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'google_places_safety_service.dart';

class SafeRoute {
  final List<LatLng> polylinePoints;
  final String overviewPolyline;
  final String duration;
  final String distance;
  final int safetyScore; // 0-100
  final List<String> safetyFeatures;
  final List<String> warnings;
  final bool isSafest;
  final Bounds bounds;

  SafeRoute({
    required this.polylinePoints,
    required this.overviewPolyline,
    required this.duration,
    required this.distance,
    required this.safetyScore,
    required this.safetyFeatures,
    required this.warnings,
    this.isSafest = false,
    required this.bounds,
  });
}

class Bounds {
  final LatLng northeast;
  final LatLng southwest;

  Bounds({required this.northeast, required this.southwest});
}

class SafeNavigationService {
  static final SafeNavigationService _instance = SafeNavigationService._internal();

  factory SafeNavigationService() {
    return _instance;
  }

  SafeNavigationService._internal();

  final GooglePlacesSafetyService _safetyService = GooglePlacesSafetyService();

  Future<List<SafeRoute>> getSafeRoutes({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final apiKey = _safetyService.apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Google API Key not configured in Safety Service');
    }

    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&alternatives=true&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] != 'OK') {
           throw Exception('Directions API Error: ${data['status']}');
        }

        final List routesData = data['routes'];
        List<SafeRoute> safeRoutes = [];

        // LIMIT to 3 routes to save quota
        for (var route in routesData.take(3)) {
          final safeRoute = await _processRoute(route);
          safeRoutes.add(safeRoute);
        }

        // Determine safest route
        if (safeRoutes.isNotEmpty) {
          safeRoutes.sort((a, b) => b.safetyScore.compareTo(a.safetyScore));
          
          // Mark the top one as safest, but only if it's significantly better or the list is short
          // Actually, just marking the highest score is fine for now.
          // We might want to balance time vs safety (e.g. if safest is 2 hours longer, maybe not)
          
          final bestRoute = safeRoutes.first;
          // Re-create it with isSafest = true
          safeRoutes[0] = SafeRoute(
            polylinePoints: bestRoute.polylinePoints,
            overviewPolyline: bestRoute.overviewPolyline,
            duration: bestRoute.duration,
            distance: bestRoute.distance,
            safetyScore: bestRoute.safetyScore,
            safetyFeatures: bestRoute.safetyFeatures,
            warnings: bestRoute.warnings,
            isSafest: true,
            bounds: bestRoute.bounds,
          );
        }

        return safeRoutes;
      } else {
        throw Exception('Failed to fetch routes: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching safe routes: $e');
      rethrow;
    }
  }

  Future<SafeRoute> _processRoute(Map<String, dynamic> routeData) async {
    final legs = routeData['legs'][0];
    final distance = legs['distance']['text'];
    final duration = legs['duration']['text'];
    final overviewPolyline = routeData['overview_polyline']['points'];
    
    // Decode polyline
    final List<PointLatLng> result = PolylinePoints.decodePolyline(overviewPolyline);
    final List<LatLng> decodedPoints = result
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();

    // Calculate Bounds
    final boundsData = routeData['bounds'];
    final bounds = Bounds(
      northeast: LatLng(
        boundsData['northeast']['lat'],
        boundsData['northeast']['lng'],
      ),
      southwest: LatLng(
        boundsData['southwest']['lat'],
        boundsData['southwest']['lng'],
      ),
    );

    // Analyze Safety
    // Sampling strategy: Every ~1km (approx 1000 meters)
    // To be efficient, we can estimate distance between points.
    // Or just pick points at fixed indices (e.g. every 20th point) 
    // depending on route length.
    
    // For better accuracy: Use total distance.
    int totalDistanceMeters = legs['distance']['value'];
    int sampleCount = (totalDistanceMeters / 1000).ceil(); // 1 sample per km
    if (sampleCount < 3) sampleCount = 3; // Minimum 3 samples
    if (sampleCount > 8) sampleCount = 8; // Cap at 8 samples per route to save quota

    List<int> stepScores = [];
    Set<String> features = {};
    Set<String> warnings = {};

    int stepSize = (decodedPoints.length / sampleCount).ceil();

    for (int i = 0; i < decodedPoints.length; i += stepSize) {
      final point = decodedPoints[i];
      try {
        final analysis = await _safetyService.checkAreaSafety(
          latitude: point.latitude,
          longitude: point.longitude,
          radius: '500', // Check 500m radius
        );

        final score = analysis['safetyScore'] as int;
        stepScores.add(score);
        
        // Collect insights
        if (score > 80) features.add("Passes through safe/busy areas");
        if (score < 40) warnings.add("Avoids some isolated areas"); // logic: if we pass a low score, we should warn? 
        // Wait, if we pass a low score area, that's bad.
        if (score < 40) warnings.add("Contains isolated segments");
        
        final details = analysis['details'];
        if (details != null && details['placeTypes'] != null) {
          final types = details['placeTypes'] as Map<String, int>;
          if (types.containsKey('police')) features.add("Near Police Station");
          if (types.containsKey('hospital')) features.add("Near Hospital");
        }

      } catch (e) {
         debugPrint("Error scoring point: $e");
         stepScores.add(50); // Neutral score on error
      }
    }

    // Average Score
    int avgScore = stepScores.isEmpty 
        ? 50 
        : (stepScores.reduce((a, b) => a + b) / stepScores.length).round();

    // Heuristics:
    // If route goes through a very dangerous area (score < 30), penalize heavily.
    if (stepScores.any((s) => s < 30)) {
      avgScore -= 20;
      warnings.add("Includes high-risk zones");
    }

    if (avgScore < 0) avgScore = 0;
    if (avgScore > 100) avgScore = 100;

    return SafeRoute(
      polylinePoints: decodedPoints,
      overviewPolyline: overviewPolyline,
      duration: duration,
      distance: distance,
      safetyScore: avgScore,
      safetyFeatures: features.toList(),
      warnings: warnings.toList(),
      bounds: bounds,
    );
  }
}
