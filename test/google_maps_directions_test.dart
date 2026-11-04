import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campus_tambayan_finder/app/app_copy.dart';
import 'package:campus_tambayan_finder/features/places/google_maps_directions.dart';
import 'package:campus_tambayan_finder/features/places/place.dart';
import 'package:campus_tambayan_finder/features/places/place_detail_sheet.dart';

const _place = Place(
  id: 'verified-place',
  name: 'Verified Place',
  category: 'coffee',
  area: 'Malinta',
  descriptionEn: 'A place with verified coordinates.',
  descriptionTl: 'Lugar na may beripikadong coordinate.',
  priceMin: 50,
  priceMax: 120,
  hours: '8:00 AM–5:00 PM',
  amenities: [],
  setting: 'indoor',
  activities: ['study'],
  latitude: 14.701,
  longitude: 120.984,
  locationVerified: true,
);

void main() {
  test('builds a Google Maps directions URL for verified coordinates', () {
    final uri = googleMapsDirectionsUri(_place);

    expect(uri?.scheme, 'https');
    expect(uri?.host, 'www.google.com');
    expect(uri?.path, '/maps/dir/');
    expect(uri?.queryParameters, {'api': '1', 'destination': '14.701,120.984'});
  });

  test(
    'does not build a directions URL for unverified or missing locations',
    () {
      expect(
        googleMapsDirectionsUri(
          Place(
            id: _place.id,
            name: _place.name,
            category: _place.category,
            area: _place.area,
            descriptionEn: _place.descriptionEn,
            descriptionTl: _place.descriptionTl,
            priceMin: _place.priceMin,
            priceMax: _place.priceMax,
            hours: _place.hours,
            amenities: _place.amenities,
            setting: _place.setting,
            activities: _place.activities,
            latitude: _place.latitude,
            longitude: _place.longitude,
          ),
        ),
        isNull,
      );
      expect(
        googleMapsDirectionsUri(
          const Place(
            id: 'missing-coordinate',
            name: 'Missing Coordinate',
            category: 'coffee',
            area: 'Malinta',
            descriptionEn: '',
            descriptionTl: '',
            priceMin: 0,
            priceMax: 0,
            hours: '',
            amenities: [],
            setting: 'indoor',
            activities: [],
            locationVerified: true,
          ),
        ),
        isNull,
      );
    },
  );

  testWidgets('unverified locations explain why directions cannot open', (
    tester,
  ) async {
    var launchCalled = false;
    final unverifiedPlace = Place(
      id: _place.id,
      name: _place.name,
      category: _place.category,
      area: _place.area,
      descriptionEn: _place.descriptionEn,
      descriptionTl: _place.descriptionTl,
      priceMin: _place.priceMin,
      priceMax: _place.priceMax,
      hours: _place.hours,
      amenities: _place.amenities,
      setting: _place.setting,
      activities: _place.activities,
      latitude: _place.latitude,
      longitude: _place.longitude,
    );
    await _openDetails(tester, unverifiedPlace, (uri) async {
      launchCalled = true;
      return true;
    });

    expect(launchCalled, isFalse);
    expect(
      find.text(
        'Directions are unavailable because this listing’s location has not been verified yet.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('launches verified coordinates and reports an opening failure', (
    tester,
  ) async {
    Uri? launchedUri;
    await _openDetails(tester, _place, (uri) async {
      launchedUri = uri;
      return false;
    });

    expect(launchedUri, googleMapsDirectionsUri(_place));
    expect(
      find.text(
        'Could not open Google Maps. Check that a maps app or browser is available, then try again.',
      ),
      findsOneWidget,
    );
  });
}

Future<void> _openDetails(
  WidgetTester tester,
  Place place,
  DirectionsUrlLauncher launchDirections,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => FilledButton(
            onPressed: () => showPlaceDetails(
              context: context,
              place: place,
              copy: const AppCopy(AppLanguage.english),
              launchDirections: launchDirections,
            ),
            child: const Text('Open details'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open details'));
  await tester.pumpAndSettle();
  final detailList = find.byKey(const Key('place-detail-list'));
  await tester.scrollUntilVisible(
    find.byKey(const Key('place-directions')),
    100,
    scrollable: find.descendant(
      of: detailList,
      matching: find.byType(Scrollable),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('place-directions')));
  await tester.pumpAndSettle();
}
