import 'dart:math' as math;

import 'package:maplibre_gl/maplibre_gl.dart';

class CampusMapAnchor {
  const CampusMapAnchor({
    required this.id,
    required this.label,
    required this.location,
  });

  final String id;
  final String label;
  final LatLng location;
}

const campusMapAnchors = [
  CampusMapAnchor(
    id: 'plv-annex',
    label: 'PLV Annex',
    location: LatLng(14.695913580771446, 120.96765602534325),
  ),
  CampusMapAnchor(
    id: 'cpag',
    label: 'CPAG',
    location: LatLng(14.694196132789166, 120.96981742109614),
  ),
];

CampusMapAnchor anchorForCampus(String key) {
  final normalized = key.toLowerCase();
  if (normalized.contains('cpag')) return campusMapAnchors[1];
  return campusMapAnchors[0];
}

double distanceMetersBetween(LatLng point1, LatLng point2) {
  const earthRadius = 6371000.0;
  final dLat = _toRadians(point2.latitude - point1.latitude);
  final dLng = _toRadians(point2.longitude - point1.longitude);
  final a =
      math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_toRadians(point1.latitude)) *
          math.cos(_toRadians(point2.latitude)) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthRadius * c;
}

double _toRadians(double degree) => degree * math.pi / 180.0;

LatLng get initialCampusMapCenter => LatLng(
  campusMapAnchors
          .map((anchor) => anchor.location.latitude)
          .reduce((first, second) => first + second) /
      campusMapAnchors.length,
  campusMapAnchors
          .map((anchor) => anchor.location.longitude)
          .reduce((first, second) => first + second) /
      campusMapAnchors.length,
);
