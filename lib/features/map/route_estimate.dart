import 'dart:math' as math;

import 'package:maplibre_gl/maplibre_gl.dart';

import '../places/place.dart';
import 'campus_map_anchors.dart';

/// Calculates straight-line distance and travel time estimates between a campus
/// anchor (PLV Annex or CPAG) and a place destination.
class RouteEstimate {
  const RouteEstimate({
    required this.campusAnchor,
    required this.distanceMeters,
    required this.walkMinutes,
    required this.rideMinutes,
  });

  final CampusMapAnchor campusAnchor;
  final double distanceMeters;
  final int walkMinutes;
  final int rideMinutes;

  /// Distance formatted for UI display (e.g. "450 m" or "1.2 km").
  String get formattedDistance {
    if (distanceMeters < 1000) {
      return '${distanceMeters.round()} m';
    }
    return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
  }

  /// Returns the campus anchor with the shortest walk to [place].
  ///
  /// Falls back to the first anchor when the place has no coordinates; callers
  /// that need a distance should check [calculate] first.
  static CampusMapAnchor nearestAnchor(Place place) {
    var best = campusMapAnchors.first;
    int? bestMinutes;
    for (final anchor in campusMapAnchors) {
      final estimate = calculate(campusAnchor: anchor, place: place);
      if (estimate == null) continue;
      if (bestMinutes == null || estimate.walkMinutes < bestMinutes) {
        best = anchor;
        bestMinutes = estimate.walkMinutes;
      }
    }
    return best;
  }

  /// Calculates a route estimate from [campusAnchor] to [place].
  static RouteEstimate? calculate({
    required CampusMapAnchor campusAnchor,
    required Place place,
  }) {
    final coordinates = place.coordinates;
    if (coordinates == null) return null;

    final distanceMeters = _haversineDistance(
      campusAnchor.location,
      LatLng(coordinates.latitude, coordinates.longitude),
    );

    // Walking speed: ~4.5 km/h = 75 meters/min
    final walkMinutes = math.max(1, (distanceMeters / 75).round());

    // Riding (tricycle/jeepney) speed: ~18 km/h = 300 meters/min + 1 min buffer
    final rideMinutes = math.max(1, (distanceMeters / 300).round() + 1);

    return RouteEstimate(
      campusAnchor: campusAnchor,
      distanceMeters: distanceMeters,
      walkMinutes: walkMinutes,
      rideMinutes: rideMinutes,
    );
  }

  static double _haversineDistance(LatLng point1, LatLng point2) {
    const earthRadiusMeters = 6371000.0;
    final dLat = _toRadians(point2.latitude - point1.latitude);
    final dLng = _toRadians(point2.longitude - point1.longitude);

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(point1.latitude)) *
            math.cos(_toRadians(point2.latitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  static double _toRadians(double degrees) => degrees * (math.pi / 180.0);
}
