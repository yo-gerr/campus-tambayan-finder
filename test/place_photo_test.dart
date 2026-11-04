import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campus_tambayan_finder/app/app_theme.dart';
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
  photoUrl: photoUrl,
  photoAsset: photoAsset,
  photos: photos,
);

Widget _wrap(Place place) => MaterialApp(
  theme: buildAppTheme(),
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

  testWidgets('shows an accessible theme-based photo loading skeleton', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: const PlacePhotoLoadingSkeleton(
            key: Key('photo-loading-skeleton'),
            label: 'Naglo-load ang larawan',
          ),
        ),
      ),
    );

    final skeleton = find.byKey(const Key('photo-loading-skeleton'));
    expect(skeleton, findsOneWidget);
    expect(
      tester.getSemantics(skeleton),
      matchesSemantics(label: 'Naglo-load ang larawan', isLiveRegion: true),
    );
    final background = tester.widget<ColoredBox>(
      find.descendant(
        of: skeleton,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is ColoredBox &&
              widget.color ==
                  buildAppTheme().colorScheme.surfaceContainerHighest,
        ),
      ),
    );
    expect(
      background.color,
      buildAppTheme().colorScheme.surfaceContainerHighest,
    );
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
            captionEn: 'Sample cover caption',
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
              viewPhotoLabel: 'View photo full screen',
              closeLabel: 'Close',
              photoCaption: (photo) => photo.captionEn,
            ),
          ),
        ),
      );

      expect(
        find.byKey(const Key('place-photo-gallery-photo-place')),
        findsOneWidget,
      );
      expect(find.text('1 / 2'), findsOneWidget);
      expect(find.text('Sample cover caption'), findsOneWidget);
      expect(tester.widget<Image>(find.byType(Image).first).fit, BoxFit.cover);

      await tester.tap(
        find.byKey(const Key('photo-gallery-open-photo-place-0')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(find.text('Photo Place'), findsOneWidget);
      expect(tester.widget<Image>(find.byType(Image).last).fit, BoxFit.contain);
      final viewerAppBar = tester.widget<AppBar>(
        find.byKey(const Key('photo-viewer-app-bar')),
      );
      expect(viewerAppBar.backgroundColor, Colors.transparent);
      expect(viewerAppBar.systemOverlayStyle, SystemUiOverlayStyle.light);
      expect(viewerAppBar.flexibleSpace, isA<IgnorePointer>());
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();

      await tester.drag(
        find.byKey(const Key('place-photo-gallery-photo-place')),
        const Offset(-200, 0),
      );
      await tester.pumpAndSettle();

      expect(find.text('2 / 2'), findsOneWidget);
    },
  );
}
