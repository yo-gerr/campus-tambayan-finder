import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'package:campus_tambayan_finder/app/app_copy.dart';
import 'package:campus_tambayan_finder/app/app_theme.dart';
import 'package:campus_tambayan_finder/features/map/campus_map_anchors.dart';
import 'package:campus_tambayan_finder/features/map/places_map_screen.dart';
import 'package:campus_tambayan_finder/features/places/place.dart';

void main() {
  test('campus anchors use the supplied coordinates and midpoint', () {
    expect(campusMapAnchors, hasLength(2));
    expect(campusMapAnchors[0].id, 'plv-annex');
    expect(
      campusMapAnchors[0].location.latitude,
      closeTo(14.695913580771446, 1e-12),
    );
    expect(
      campusMapAnchors[0].location.longitude,
      closeTo(120.96765602534325, 1e-12),
    );
    expect(campusMapAnchors[1].id, 'cpag');
    expect(
      campusMapAnchors[1].location.latitude,
      closeTo(14.694196132789166, 1e-12),
    );
    expect(
      campusMapAnchors[1].location.longitude,
      closeTo(120.96981742109614, 1e-12),
    );
    expect(initialCampusMapCenter.latitude, closeTo(14.695054856780306, 1e-12));
    expect(initialCampusMapCenter.longitude, closeTo(120.9687367232197, 1e-12));
  });

  testWidgets('renders the MapLibre map for places with coordinates', (
    tester,
  ) async {
    const place = Place(
      id: 'mapped-place',
      name: 'Mapped Place',
      category: 'coffee',
      area: 'Test area',
      descriptionEn: 'Test description.',
      descriptionTl: 'Pagsubok.',
      priceMin: 50,
      priceMax: 100,
      hours: 'Test hours',
      amenities: ['wifi', 'outlets'],
      setting: 'indoor',
      activities: ['study'],
      latitude: 14.7,
      longitude: 120.9,
    );
    const unmappedPlace = Place(
      id: 'unmapped-place',
      name: 'Unmapped Place',
      category: 'coffee',
      area: 'Test area',
      descriptionEn: 'Test description.',
      descriptionTl: 'Pagsubok.',
      priceMin: 50,
      priceMax: 100,
      hours: 'Test hours',
      amenities: [],
      setting: 'indoor',
      activities: ['study'],
    );

    Place? selectedPlace;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: PlacesMapScreen(
            places: const [place, unmappedPlace],
            copy: const AppCopy(AppLanguage.english),
            onPlaceSelected: (selected) => selectedPlace = selected,
          ),
        ),
      ),
    );
    await tester.pump();

    final map = tester.widget<MapLibreMap>(find.byType(MapLibreMap));
    expect(map.styleString, 'https://tiles.openfreemap.org/styles/positron');
    expect(map.attributionEnabled, isTrue);
    expect(map.myLocationEnabled, isFalse);
    expect(map.annotationOrder, [AnnotationType.symbol, AnnotationType.circle]);
    expect(
      map.initialCameraPosition?.target.latitude,
      closeTo(initialCampusMapCenter.latitude, 1e-12),
    );
    expect(
      map.initialCameraPosition?.target.longitude,
      closeTo(initialCampusMapCenter.longitude, 1e-12),
    );
    expect(map.initialCameraPosition?.zoom, 16);
    expect(find.text('Map needs internet'), findsOneWidget);
    expect(find.text('Map'), findsNothing);
    expect(find.text('Places'), findsNothing);
    expect(find.byKey(const Key('map-place-carousel')), findsOneWidget);
    expect(find.byKey(const Key('place-card-mapped-place')), findsOneWidget);
    expect(find.byKey(const Key('place-card-unmapped-place')), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const Key('map-place-carousel')),
        matching: find.byType(ListView),
      ),
      findsOneWidget,
    );
    final carouselRect = tester.getRect(
      find.byKey(const Key('map-place-carousel')),
    );
    final cardRect = tester.getRect(
      find.byKey(const Key('place-card-mapped-place')),
    );
    final statusRect = tester.getRect(
      find.byKey(const Key('map-status-overlay')),
    );
    final screenSize = tester.getSize(find.byType(Scaffold));
    expect(carouselRect.top, greaterThan(statusRect.bottom));
    expect(carouselRect.bottom, lessThanOrEqualTo(screenSize.height - 30));
    expect(carouselRect.left, 12);
    expect(carouselRect.right, screenSize.width - 12);
    expect(cardRect.width, 360);
    expect(cardRect.right, lessThan(carouselRect.right));
    expect(statusRect.width, lessThanOrEqualTo(280));
    expect(statusRect.right, lessThan(screenSize.width));
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('place-card-mapped-place')));
    expect(selectedPlace, place);
  });

  testWidgets('renders campus map when no place has coordinates', (
    tester,
  ) async {
    const place = Place(
      id: 'unmapped-place',
      name: 'Unmapped Place',
      category: 'coffee',
      area: 'Test area',
      descriptionEn: 'Test description.',
      descriptionTl: 'Pagsubok.',
      priceMin: 50,
      priceMax: 100,
      hours: 'Test hours',
      amenities: [],
      setting: 'indoor',
      activities: ['study'],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: PlacesMapScreen(
            places: const [place],
            copy: const AppCopy(AppLanguage.english),
            onPlaceSelected: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();

    final map = tester.widget<MapLibreMap>(find.byType(MapLibreMap));
    expect(
      map.initialCameraPosition?.target.latitude,
      initialCampusMapCenter.latitude,
    );
    expect(
      map.initialCameraPosition?.target.longitude,
      initialCampusMapCenter.longitude,
    );
    expect(find.text('Map needs internet'), findsOneWidget);
    expect(
      find.text(
        'Places without a valid coordinate pair are not shown on the map.',
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('map-place-carousel')), findsNothing);
    expect(find.text('Unmapped Place'), findsNothing);
  });
}
