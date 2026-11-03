import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campus_tambayan_finder/features/places/place.dart';
import 'package:campus_tambayan_finder/features/places/place_photo.dart';

Place _place({
  String? photoUrl,
  String? photoAsset,
  List<PlaceGalleryPhoto> photos = const [],
}) => Place(
  id: 'photo-place',
  name: 'Photo Place',
  category: 'coffee',
  area: 'Malinta',
  descriptionEn: 'Description.',
  descriptionTl: 'Paglalarawan.',
  priceMin: 0,
  priceMax: 100,
  hours: '8:00 AM–5:00 PM',
  amenities: const [],
  setting: 'indoor',
  activities: const ['study'],
  mapX: 0.5,
  mapY: 0.5,
  photoUrl: photoUrl,
  photoAsset: photoAsset,
  photos: photos,
);

Widget _wrap(Place place) => MaterialApp(
  home: Scaffold(
    body: PlacePhoto(place: place, width: 100, height: 100, borderRadius: 8),
  ),
);

void main() {
  test('prefers the shared photo, then the bundled copy', () {
    expect(
      placePhotoSource(_place(photoUrl: 'https://example.test/a.jpg')),
      PlacePhotoSource.network,
    );
    expect(
      placePhotoSource(_place(photoAsset: 'assets/photos/a.jpg')),
      PlacePhotoSource.asset,
    );
    expect(placePhotoSource(_place()), PlacePhotoSource.none);
  });

  testWidgets('shows the placeholder when a place has no photo', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(_place()));

    expect(find.byKey(const Key('place-photo-fallback')), findsOneWidget);
  });

  testWidgets('falls back when the shared photo cannot load', (tester) async {
    // Widget tests cannot reach the network, so this exercises the same error
    // path a disconnected phone takes.
    await tester.pumpWidget(
      _wrap(_place(photoUrl: 'https://example.test/missing.jpg')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(const Key('place-photo-fallback')), findsOneWidget);
  });

  testWidgets(
    'shows an ordered, swipeable gallery when multiple photos exist',
    (tester) async {
      final place = _place(
        photos: const [
          PlaceGalleryPhoto(
            photoUrl: 'https://example.test/cover.jpg',
            photoAsset: null,
            sortOrder: 0,
            isCover: true,
          ),
          PlaceGalleryPhoto(
            photoUrl: 'https://example.test/inside.jpg',
            photoAsset: null,
            sortOrder: 1,
            isCover: false,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlacePhotoGallery(
              place: place,
              width: 200,
              height: 120,
              borderRadius: 8,
              placeholder: const ColoredBox(color: Colors.grey),
              photoPosition: (current, total) => 'Photo $current of $total',
            ),
          ),
        ),
      );

      expect(
        find.byKey(const Key('place-photo-gallery-photo-place')),
        findsOneWidget,
      );
      expect(find.text('1 / 2'), findsOneWidget);

      await tester.drag(
        find.byKey(const Key('place-photo-gallery-photo-place')),
        const Offset(-200, 0),
      );
      await tester.pumpAndSettle();

      expect(find.text('2 / 2'), findsOneWidget);
    },
  );
}
