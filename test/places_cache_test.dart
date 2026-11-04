import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:campus_tambayan_finder/features/places/opening_hours.dart';
import 'package:campus_tambayan_finder/features/places/place.dart';
import 'package:campus_tambayan_finder/features/places/places_cache.dart';

const _place = Place(
  id: 'saved-place',
  name: 'Saved Place',
  category: 'coffee',
  area: 'Malinta',
  address: '12 Sample Street',
  descriptionEn: 'A place to study.',
  descriptionTl: 'Lugar para mag-aral.',
  priceMin: 50,
  priceMax: 120,
  hours: 'Closed on holidays',
  openingHours: OpeningHours({
    DateTime.monday: DayHours(openMinutes: 480, closeMinutes: 1200),
    DateTime.sunday: null,
  }),
  amenities: ['wifi', 'outlets'],
  setting: 'indoor',
  activities: ['study'],
  latitude: 14.7,
  longitude: 120.98,
  locationVerified: true,
  photoUrl: 'https://example.test/cover.jpg',
  photos: [
    PlaceGalleryPhoto(
      photoUrl: 'https://example.test/cover.jpg',
      photoAsset: null,
      sortOrder: 1,
      isCover: true,
      captionEn: 'Front seating',
      captionTl: 'Upuang nasa harap',
    ),
  ],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'round-trips listings, hours, coordinates, and gallery details',
    () async {
      SharedPreferences.setMockInitialValues({});
      final cache = SharedPreferencesPlacesCache();

      await cache.write(const [_place]);
      final saved = (await cache.read())!.single;

      expect(saved.id, _place.id);
      expect(saved.descriptionTl, _place.descriptionTl);
      expect(saved.priceMin, 50);
      expect(saved.openingHours?.hoursFor(DateTime.monday)?.openMinutes, 480);
      expect(saved.openingHours?.isClosedOn(DateTime.sunday), isTrue);
      expect(saved.coordinates?.latitude, 14.7);
      expect(saved.locationVerified, isTrue);
      expect(saved.photos.single.captionTl, 'Upuang nasa harap');
    },
  );

  test('does not replace a saved snapshot with an empty listing set', () async {
    SharedPreferences.setMockInitialValues({});
    final cache = SharedPreferencesPlacesCache();

    await cache.write(const [_place]);
    await cache.write(const []);

    expect((await cache.read())!.single.id, _place.id);
  });

  test('ignores a corrupted saved snapshot', () async {
    SharedPreferences.setMockInitialValues({
      'places.last_synced.v1': '{invalid',
    });

    expect(await SharedPreferencesPlacesCache().read(), isNull);
  });
}
