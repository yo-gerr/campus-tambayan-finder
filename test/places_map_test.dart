import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'package:campus_tambayan_finder/app/app_copy.dart';
import 'package:campus_tambayan_finder/app/app_theme.dart';
import 'package:campus_tambayan_finder/features/map/places_map_screen.dart';
import 'package:campus_tambayan_finder/features/places/place.dart';

void main() {
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
      amenities: [],
      setting: 'indoor',
      activities: ['study'],
      latitude: 14.7,
      longitude: 120.9,
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
    expect(map.styleString, 'https://tiles.openfreemap.org/styles/positron');
    expect(map.attributionEnabled, isTrue);
    expect(map.myLocationEnabled, isFalse);
    expect(map.annotationOrder, [AnnotationType.symbol, AnnotationType.circle]);
    expect(map.initialCameraPosition?.target.latitude, closeTo(14.7, 0.000001));
    expect(
      map.initialCameraPosition?.target.longitude,
      closeTo(120.9, 0.000001),
    );
  });
}
