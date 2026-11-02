import 'package:flutter_test/flutter_test.dart';

import 'package:campus_tambayan_finder/features/places/place.dart';

Map<String, dynamic> _row({Object? photoUrl, Object? photoAsset}) => {
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
  'photoUrl': photoUrl,
  'photoAsset': photoAsset,
};

void main() {
  test('maps a shared-table row with untyped array values', () {
    // PostgREST returns text[] columns as List<dynamic>, not List<String>.
    final place = Place.fromJson(_row());

    expect(place.amenities, ['wifi', 'outlets']);
    expect(place.activities, ['study', 'eat']);
    expect(place.mapX, 0.5);
    expect(place.priceMax, 120);
  });

  test('maps photo fields when the row supplies them', () {
    final place = Place.fromJson(
      _row(
        photoUrl: 'https://example.test/photo.jpg',
        photoAsset: 'assets/photos/photo.jpg',
      ),
    );

    expect(place.photoUrl, 'https://example.test/photo.jpg');
    expect(place.photoAsset, 'assets/photos/photo.jpg');
  });

  test('treats null, blank, and missing photo fields as no photo', () {
    expect(Place.fromJson(_row()).photoUrl, isNull);
    expect(Place.fromJson(_row()).photoAsset, isNull);
    expect(Place.fromJson(_row(photoUrl: '  ')).photoUrl, isNull);
    expect(Place.fromJson(_row(photoAsset: '')).photoAsset, isNull);

    final withoutKeys = _row()
      ..remove('photoUrl')
      ..remove('photoAsset');
    final place = Place.fromJson(withoutKeys);
    expect(place.photoUrl, isNull);
    expect(place.photoAsset, isNull);
  });
}
