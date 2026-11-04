import 'package:flutter_test/flutter_test.dart';

import 'package:campus_tambayan_finder/features/places/place.dart';

Map<String, dynamic> _row({
  Object? photoUrl,
  Object? photoAsset,
  Object? photos,
  Object? latitude,
  Object? longitude,
  Object? locationVerified,
  Object? address,
}) => {
  'id': 'live-place',
  'name': 'Live Place',
  'category': 'coffee',
  'area': 'Malinta',
  'address': address,
  'descriptionEn': 'English description.',
  'descriptionTl': 'Paglalarawan sa Filipino.',
  'priceMin': 50,
  'priceMax': 120,
  'hours': '8:00 AM–5:00 PM',
  'amenities': <dynamic>['wifi', 'outlets'],
  'setting': 'indoor',
  'activities': <dynamic>['study', 'eat'],
  'latitude': latitude,
  'longitude': longitude,
  'location_verified': locationVerified,
  'photoUrl': photoUrl,
  'photoAsset': photoAsset,
  'place_photos': photos,
};

void main() {
  test('maps a shared-table row with untyped array values', () {
    // PostgREST returns text[] columns as List<dynamic>, not List<String>.
    final place = Place.fromJson(_row(latitude: 14.701, longitude: 120.984));

    expect(place.amenities, ['wifi', 'outlets']);
    expect(place.activities, ['study', 'eat']);
    expect(place.coordinates?.latitude, 14.701);
    expect(place.coordinates?.longitude, 120.984);
    expect(place.priceMax, 120);
  });

  test('defaults locations to unverified and maps the verification field', () {
    expect(Place.fromJson(_row()).locationVerified, isFalse);
    expect(
      Place.fromJson(_row(locationVerified: true)).locationVerified,
      isTrue,
    );
    final camelCaseRow = _row()..remove('location_verified');
    camelCaseRow['locationVerified'] = true;
    expect(Place.fromJson(camelCaseRow).locationVerified, isTrue);
    expect(
      Place.fromJson(_row(locationVerified: 'true')).locationVerified,
      isFalse,
    );
  });

  test('keeps places without valid paired geographic coordinates unmapped', () {
    expect(Place.fromJson(_row()).coordinates, isNull);
    expect(Place.fromJson(_row(latitude: 14.7)).coordinates, isNull);
    expect(
      Place.fromJson(_row(latitude: 91, longitude: 120)).coordinates,
      isNull,
    );
    expect(
      Place.fromJson(_row(latitude: 14.7, longitude: -181)).coordinates,
      isNull,
    );
    expect(
      Place.fromJson(_row(latitude: '14.7', longitude: '120.9')).coordinates,
      isNull,
    );
  });

  test('accepts zero as a valid geographic coordinate', () {
    final coordinates = Place.fromJson(_row(latitude: 0, longitude: 0))
        .coordinates;

    expect(coordinates?.latitude, 0);
    expect(coordinates?.longitude, 0);
  });

  test('maps an address and treats blank or missing as absent', () {
    expect(
      Place.fromJson(_row(address: '12 Sample Street, Malinta')).address,
      '12 Sample Street, Malinta',
    );
    expect(Place.fromJson(_row()).address, isNull);
    expect(Place.fromJson(_row(address: '   ')).address, isNull);

    final withoutKey = _row()..remove('address');
    expect(Place.fromJson(withoutKey).address, isNull);
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

  test('maps, orders, and selects a gallery cover photo', () {
    final place = Place.fromJson(
      _row(
        photos: [
          {
            'photoUrl': 'https://example.test/second.jpg',
            'photoAsset': null,
            'sortOrder': 2,
            'isCover': false,
          },
          {
            'photoUrl': 'https://example.test/cover.jpg',
            'photoAsset': null,
            'sortOrder': 1,
            'isCover': true,
          },
        ],
      ),
    );

    expect(place.photos, hasLength(2));
    expect(place.photos.first.photoUrl, 'https://example.test/cover.jpg');
    expect(place.coverPhoto?.photoUrl, 'https://example.test/cover.jpg');
  });

  test('uses the legacy single photo as cover when the gallery is empty', () {
    final place = Place.fromJson(
      _row(photoUrl: 'https://example.test/legacy-cover.jpg'),
    );

    expect(place.photos, isEmpty);
    expect(place.coverPhoto?.photoUrl, 'https://example.test/legacy-cover.jpg');
  });
}
