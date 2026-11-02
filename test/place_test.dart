import 'package:flutter_test/flutter_test.dart';

import 'package:campus_tambayan_finder/features/places/place.dart';

void main() {
  test('maps a shared-table row with untyped array values', () {
    // PostgREST returns text[] columns as List<dynamic>, not List<String>.
    final place = Place.fromJson({
      'id': 'live-place',
      'name': 'Live Place',
      'category': 'coffee',
      'area': 'Malinta',
      'descriptionEn': 'English description.',
      'descriptionTl': 'Paglalarawan sa Filipino.',
      'priceMin': 50,
      'priceMax': 120,
      'hours': '8:00 AM–5:00 PM',
      'amenities': <dynamic>['wifi', 'outlets'],
      'setting': 'indoor',
      'activities': <dynamic>['study', 'eat'],
      'mapX': 0.5,
      'mapY': 0.4,
    });

    expect(place.amenities, ['wifi', 'outlets']);
    expect(place.activities, ['study', 'eat']);
    expect(place.mapX, 0.5);
    expect(place.priceMax, 120);
  });
}
