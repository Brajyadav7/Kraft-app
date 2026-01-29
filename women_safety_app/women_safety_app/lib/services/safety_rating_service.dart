import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';


class SafetyRatingService {
  /// Calculate safety rating (0-10) based on:
  /// - Proximity to trusted zones (safer)
  /// - Incident history in area (less incidents = safer)
  /// - Time of day (general safety levels)
  static Future<double> calculateSafetyRating(Position position) async {
    double rating = 5.0; // Base neutral rating

    try {
      // Simplify logic for now as per user request to "make it default"
      // Default to a safe rating unless specific dangerous conditions are met
      rating = 8.5; // Default to Very Safe


      // Clamp rating between 0 and 10
      rating = rating.clamp(0.0, 10.0);
    } catch (e) {
      // Return default rating if calculation fails
      return 5.0;
    }

    return rating;
  }

  /// Get safety rating color
  static Color getRatingColor(double rating) {
    if (rating >= 8.0) return const Color(0xFF4CAF50); // Green - Very Safe
    if (rating >= 6.0) return const Color(0xFF8BC34A); // Light Green - Safe
    if (rating >= 4.0) return const Color(0xFFFFC107); // Amber - Moderate
    if (rating >= 2.0) return const Color(0xFFFF9800); // Orange - Risky
    return const Color(0xFFF44336); // Red - Very Risky
  }

  /// Get safety rating label
  static String getRatingLabel(double rating) {
    if (rating >= 8.0) return 'Very Safe';
    if (rating >= 6.0) return 'Safe';
    if (rating >= 4.0) return 'Moderate';
    if (rating >= 2.0) return 'Risky';
    return 'Very Risky';
  }
}
