import 'package:flutter_test/flutter_test.dart';

import 'package:campus_tambayan_finder/features/map/campus_map_anchors.dart';
import 'package:campus_tambayan_finder/features/map/route_estimate.dart';
import 'package:campus_tambayan_finder/features/places/place.dart';

void main() {
  test('calculates distance and travel time estimates correctly', () {
    const place = Place(
      id: 'test-place',
      name: 'Test Place',
      category: 'coffee',
      area: 'Malinta',
      descriptionEn: 'Desc',
      descriptionTl: 'Paglalarawan',
      priceMin: 50,
      priceMax: 100,
      hours: '8:00 AM–5:00 PM',
      amenities: [],
      setting: 'indoor',
      activities: ['study'],
      latitude: 14.69635,
      longitude: 120.9674,
    );

    final estimate = RouteEstimate.calculate(
      campusAnchor: campusMapAnchors.first,
      place: place,
    );

    expect(estimate, isNotNull);
    expect(estimate!.distanceMeters, greaterThan(0));
    expect(estimate.walkMinutes, greaterThan(0));
    expect(estimate.rideMinutes, greaterThan(0));
    expect(estimate.formattedDistance, contains('m'));
  });

  test('returns null when place coordinates are missing', () {
    const unmappedPlace = Place(
      id: 'unmapped-place',
      name: 'Unmapped Place',
      category: 'coffee',
      area: 'Malinta',
      descriptionEn: 'Desc',
      descriptionTl: 'Paglalarawan',
      priceMin: 50,
      priceMax: 100,
      hours: '8:00 AM–5:00 PM',
      amenities: [],
      setting: 'indoor',
      activities: ['study'],
    );

    final estimate = RouteEstimate.calculate(
      campusAnchor: campusMapAnchors.first,
      place: unmappedPlace,
    );

    expect(estimate, isNull);
  });

  test('picks the campus with the shortest walk to the place', () {
    const nearCpag = Place(
      id: 'near-cpag',
      name: 'Near CPAG',
      category: 'coffee',
      area: 'Malinta',
      descriptionEn: 'Desc',
      descriptionTl: 'Paglalarawan',
      priceMin: 50,
      priceMax: 100,
      hours: '8:00 AM–5:00 PM',
      amenities: [],
      setting: 'indoor',
      activities: ['study'],
      latitude: 14.6942,
      longitude: 120.9698,
    );
    const nearPlvAnnex = Place(
      id: 'near-plv-annex',
      name: 'Near PLV Annex',
      category: 'coffee',
      area: 'Malinta',
      descriptionEn: 'Desc',
      descriptionTl: 'Paglalarawan',
      priceMin: 50,
      priceMax: 100,
      hours: '8:00 AM–5:00 PM',
      amenities: [],
      setting: 'indoor',
      activities: ['study'],
      latitude: 14.696,
      longitude: 120.9676,
    );

    expect(RouteEstimate.nearestAnchor(nearCpag).id, 'cpag');
    expect(RouteEstimate.nearestAnchor(nearPlvAnnex).id, 'plv-annex');
  });
}
