import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campus_tambayan_finder/app/app_copy.dart';
import 'package:campus_tambayan_finder/features/places/place.dart';
import 'package:campus_tambayan_finder/features/places/travel_estimate_card.dart';

void main() {
  const place = Place(
    id: 'near-cpag',
    name: 'Near CPAG',
    category: 'coffee',
    area: 'Malinta',
    descriptionEn: 'A place close to CPAG.',
    descriptionTl: 'Isang lugar malapit sa CPAG.',
    priceMin: 50,
    priceMax: 100,
    hours: '8:00 AM–5:00 PM',
    amenities: [],
    setting: 'indoor',
    activities: ['study'],
    latitude: 14.6942,
    longitude: 120.9698,
  );

  testWidgets('shows travel estimates and switches campus at large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: TravelEstimateCard(
              place: place,
              copy: const AppCopy(AppLanguage.english),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Travel estimate'), findsOneWidget);
    expect(find.text('From'), findsOneWidget);
    expect(find.text('PLV Annex'), findsOneWidget);
    expect(find.text('CPAG'), findsOneWidget);
    expect(find.text('Walk'), findsOneWidget);
    expect(find.text('Ride'), findsOneWidget);
    expect(find.textContaining('away'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('PLV Annex'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Walk'), findsOneWidget);
    expect(find.text('Ride'), findsOneWidget);
  });

  testWidgets('uses the Tagalog travel labels', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: TravelEstimateCard(
              place: place,
              copy: const AppCopy(AppLanguage.tagalog),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tinatayang biyahe'), findsOneWidget);
    expect(find.text('Mula sa'), findsOneWidget);
    expect(find.text('Lakad'), findsOneWidget);
    expect(find.text('Sakay'), findsOneWidget);
    expect(find.textContaining('ang layo'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
