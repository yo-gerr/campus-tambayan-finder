import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campus_tambayan_finder/app/tambayan_app.dart';
import 'package:campus_tambayan_finder/features/places/place.dart';
import 'package:campus_tambayan_finder/features/places/sample_places_repository.dart';

class _TestPlacesRepository implements PlacesRepository {
  @override
  Future<List<Place>> loadPlaces() async => const [
    Place(
      id: 'sample-study-corner',
      name: 'Sample Study Corner',
      category: 'tambayan',
      area: 'Demo location near PLV Annex',
      descriptionEn:
          'A fictional quiet-place example for reviewing the app flow.',
      descriptionTl:
          'Kathang-halimbawang tahimik na lugar para masubukan ang app.',
      priceMin: 0,
      priceMax: 120,
      hours: 'Sample hours · 8:00 AM–8:00 PM',
      amenities: ['wifi', 'outlets'],
      setting: 'indoor',
      activities: ['study', 'relax'],
      mapX: 0.26,
      mapY: 0.34,
    ),
    Place(
      id: 'sample-kape-stop',
      name: 'Sample Kape Stop',
      category: 'coffee',
      area: 'Demo location near CPAG',
      descriptionEn:
          'A fictional café example with sample prices and amenities.',
      descriptionTl:
          'Kathang-halimbawang kapihan na may halimbawang presyo at amenity.',
      priceMin: 80,
      priceMax: 250,
      hours: 'Sample hours · 9:00 AM–9:00 PM',
      amenities: ['wifi', 'aircon', 'outlets'],
      setting: 'indoor',
      activities: ['study', 'eat', 'socialize'],
      mapX: 0.67,
      mapY: 0.25,
    ),
  ];
}

void main() {
  Future<void> pumpPrototype(
    WidgetTester tester, {
    bool showIntroOnStart = false,
  }) async {
    await tester.pumpWidget(
      TambayanApp(
        showIntroOnStart: showIntroOnStart,
        placesRepository: _TestPlacesRepository(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    expect(find.text('Sample Study Corner'), findsOneWidget);
  }

  testWidgets('shows demo places and opens a place detail', (tester) async {
    await pumpPrototype(tester);

    expect(find.text('Sample Study Corner'), findsOneWidget);
    expect(find.text('DEMO CONTENT · NOT VERIFIED'), findsOneWidget);

    await tester.tap(find.byKey(const Key('place-card-sample-study-corner')));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Sample information for prototype review only.'),
      findsOneWidget,
    );
    expect(find.text('Sample hours · 8:00 AM–8:00 PM'), findsOneWidget);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
  });

  testWidgets('filters local places by category', (tester) async {
    await pumpPrototype(tester);

    await tester.tap(find.byKey(const Key('open-filters')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('category-coffee-filter')));
    await tester.tap(find.byKey(const Key('apply-filters')));
    await tester.pumpAndSettle();

    expect(find.text('Sample Kape Stop'), findsOneWidget);
    expect(find.text('Sample Study Corner'), findsNothing);
  });

  testWidgets('switches language and opens the illustrative map', (
    tester,
  ) async {
    await pumpPrototype(tester);

    await tester.tap(find.byKey(const Key('language-toggle')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Mag-explore'), findsOneWidget);

    await tester.tap(find.text('Mapa'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Guhit na mapa · hindi para sa nabigasyon'), findsWidgets);

    final mapPin = find.byKey(const Key('map-pin-sample-kape-stop'));
    await tester.tapAt(tester.getTopLeft(mapPin) + const Offset(12, 12));
    await tester.pumpAndSettle();
    expect(find.text('Sample Kape Stop'), findsNWidgets(2));
  });

  testWidgets('onboarding can be dismissed and opened again', (tester) async {
    await pumpPrototype(tester, showIntroOnStart: true);

    expect(find.text('Find your next tambayan'), findsOneWidget);
    await tester.tap(find.byKey(const Key('dismiss-intro')));
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.byKey(const Key('open-guide')));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Find your next tambayan'), findsOneWidget);
  });
}
