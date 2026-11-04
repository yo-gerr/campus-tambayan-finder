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
