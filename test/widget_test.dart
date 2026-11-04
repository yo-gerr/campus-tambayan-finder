import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'package:campus_tambayan_finder/app/app_copy.dart';
import 'package:campus_tambayan_finder/app/app_theme.dart';
import 'package:campus_tambayan_finder/app/tambayan_app.dart';
import 'package:campus_tambayan_finder/features/places/open_status_badge.dart';
import 'package:campus_tambayan_finder/features/places/opening_hours.dart';
import 'package:campus_tambayan_finder/features/places/place.dart';
import 'package:campus_tambayan_finder/features/places/place_card.dart';
import 'package:campus_tambayan_finder/features/places/place_categories.dart';
import 'package:campus_tambayan_finder/features/places/place_photo.dart';
import 'package:campus_tambayan_finder/features/places/places_repository.dart';

class _TestPlacesRepository implements PlacesRepository {
  @override
  Stream<PlacesSnapshot> watchPlaces() async* {
    yield PlacesSnapshot(
      places: await _places(),
      source: PlacesDataSource.bundledSeed,
    );
  }

  Future<List<Place>> _places() async => const [
    Place(
      id: 'sample-study-corner',
      name: 'Sample Study Corner',
      category: 'tambayan',
      area: 'Demo location near PLV Annex',
      address: 'Blk 1 Lot 2, Demo Street, Malinta, Valenzuela City (demo only)',
      descriptionEn:
          'A fictional quiet-place example for reviewing the app flow.',
      descriptionTl:
          'Kathang-halimbawang tahimik na lugar para masubukan ang app.',
      priceMin: 0,
      priceMax: 120,
      hours: 'Sample hours · 8:00 AM–8:00 PM',
      openingHours: OpeningHours({
        DateTime.monday: DayHours(openMinutes: 480, closeMinutes: 1200),
        DateTime.sunday: null,
      }),
      amenities: ['wifi', 'outlets'],
      setting: 'indoor',
      activities: ['study', 'relax'],
      latitude: null,
      longitude: null,
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
      latitude: null,
      longitude: null,
    ),
  ];
}

class _OfflinePlacesRepository extends _TestPlacesRepository {
  @override
  Stream<PlacesSnapshot> watchPlaces() async* {
    yield PlacesSnapshot(
      places: await _places(),
      source: PlacesDataSource.offlineFallback,
    );
  }
}

double _contrastRatio(Color first, Color second) {
  final luminances = [first.computeLuminance(), second.computeLuminance()]
    ..sort();
  return (luminances[1] + 0.05) / (luminances[0] + 0.05);
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
      tester.widget<PlacePhotoGallery>(find.byType(PlacePhotoGallery)).height,
      210,
    );
    expect(find.text('Estimated\nspend'), findsOneWidget);
    expect(
      find.textContaining('Sample information for prototype review only.'),
      findsOneWidget,
    );
    final detailList = find.byKey(const Key('place-detail-list'));
    final detailScrollable = find.descendant(
      of: detailList,
      matching: find.byType(Scrollable),
    );

    // The photo pushes these rows below the lazily built part of the list.
    await tester.scrollUntilVisible(
      find.text(
        'Blk 1 Lot 2, Demo Street, Malinta, Valenzuela City (demo only)',
      ),
      100,
      scrollable: detailScrollable,
    );
    expect(find.text('Address'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Not yet verified; directions are unavailable.'),
      100,
      scrollable: detailScrollable,
    );
    expect(find.text('Location'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Good for'),
      100,
      scrollable: detailScrollable,
    );
    expect(find.text('Study'), findsOneWidget);
    expect(find.text('Relax'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.descendant(of: detailList, matching: find.text('Free Wi-Fi')),
      100,
      scrollable: detailScrollable,
    );
    final amenityChip = find.widgetWithText(Chip, 'Free Wi-Fi');
    expect(amenityChip, findsOneWidget);
    final detailTheme = Theme.of(tester.element(amenityChip));
    expect(
      detailTheme.chipTheme.backgroundColor,
      detailTheme.colorScheme.secondaryContainer,
    );
    expect(
      detailTheme.chipTheme.labelStyle?.color,
      detailTheme.colorScheme.onSecondaryContainer,
    );
    expect(
      _contrastRatio(
        detailTheme.colorScheme.onSecondaryContainer,
        detailTheme.colorScheme.secondaryContainer,
      ),
      greaterThanOrEqualTo(4.5),
    );

    // The photo pushes the hours row below the lazily built part of the list.
    await tester.dragUntilVisible(
      find.text('Sample hours · 8:00 AM–8:00 PM'),
      find.byKey(const Key('place-detail-list')),
      const Offset(0, -150),
    );
    expect(find.text('Sample hours · 8:00 AM–8:00 PM'), findsOneWidget);
    // Structured days render as a weekly block, with a closed day named.
    expect(find.text('Monday'), findsOneWidget);
    expect(find.text('Closed'), findsOneWidget);
    // Scroll back so the header's close button is reachable again.
    await tester.scrollUntilVisible(
      find.byTooltip('Close'),
      -100,
      scrollable: detailScrollable,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
  });

  test('demo status text clears AA contrast on its container', () {
    expect(
      _contrastRatio(AppColors.onDemoContainer, AppColors.demoContainer),
      greaterThanOrEqualTo(4.5),
    );
  });

  test('open and closed status badges clear AA contrast', () {
    expect(
      _contrastRatio(AppColors.onPrimary, AppColors.primary),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(AppColors.mutedInk, AppColors.outline),
      greaterThanOrEqualTo(4.5),
    );
  });

  testWidgets('card replaces the inline dot with a filled status badge', (
    tester,
  ) async {
    const place = Place(
      id: 'badge-place',
      name: 'Badge Place',
      category: 'coffee',
      area: 'Malinta',
      descriptionEn: 'English description.',
      descriptionTl: 'Paglalarawan sa Filipino.',
      hours: 'Mon 8:00 AM–8:00 PM',
      openingHours: OpeningHours({
        DateTime.monday: DayHours(openMinutes: 480, closeMinutes: 1200),
      }),
      amenities: ['wifi'],
      setting: 'indoor',
      activities: ['study'],
    );

    Future<void> pumpCard(DateTime now) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: Scaffold(
            body: PlaceCard(
              place: place,
              copy: const AppCopy(AppLanguage.english),
              now: now,
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pump();
    }

    // Manila Monday 10:00 is UTC 02:00.
    await pumpCard(DateTime.utc(2026, 11, 2, 2));
    expect(find.byType(OpenStatusBadge), findsOneWidget);
    expect(find.text('Open now'), findsOneWidget);
    expect(find.byIcon(Icons.circle), findsNothing);

    // Manila Monday 21:00 is UTC 13:00.
    await pumpCard(DateTime.utc(2026, 11, 2, 13));
    expect(find.text('Closed now'), findsOneWidget);
  });

  test('campus-blue selected states clear AA contrast', () {
    expect(
      _contrastRatio(
        AppColors.onCampusBlueContainer,
        AppColors.campusBlueContainer,
      ),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(AppColors.onPrimary, AppColors.campusBlue),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(AppColors.accent, AppColors.campusBlue),
      greaterThan(3),
    );
  });

  testWidgets('cards and details share one no-photo placeholder', (
    tester,
  ) async {
    await pumpPrototype(tester);

    final cardPlaceholder = tester.widget<PlacePhotoPlaceholder>(
      find.descendant(
        of: find.byKey(const Key('place-card-sample-study-corner')),
        matching: find.byType(PlacePhotoPlaceholder),
      ),
    );

    await tester.tap(find.byKey(const Key('place-card-sample-study-corner')));
    await tester.pumpAndSettle();

    final detailPlaceholder = tester.widget<PlacePhotoPlaceholder>(
      find.descendant(
        of: find.byType(PlacePhotoGallery),
        matching: find.byType(PlacePhotoPlaceholder),
      ),
    );

    expect(cardPlaceholder.category, 'tambayan');
    expect(detailPlaceholder.category, cardPlaceholder.category);
  });

  testWidgets('filters local places by category', (tester) async {
    await pumpPrototype(tester);

    await tester.tap(find.byKey(const Key('open-filters')));
    await tester.pumpAndSettle();

    final allChip = tester.widget<ChoiceChip>(
      find.byKey(const Key('category-any-filter')),
    );
    final coffeeChip = tester.widget<ChoiceChip>(
      find.byKey(const Key('category-coffee-filter')),
    );
    expect(allChip.labelStyle?.color, AppColors.onCampusBlueContainer);
    expect(coffeeChip.labelStyle?.color, AppColors.ink);
    expect(
      Theme.of(tester.element(find.byKey(const Key('category-any-filter'))))
          .chipTheme
          .selectedColor,
      AppColors.campusBlueContainer,
    );

    await tester.tap(find.byKey(const Key('category-coffee-filter')));
    final applyButton = find.byKey(const Key('apply-filters'));
    final applyButtonTop = tester.getTopLeft(applyButton).dy;
    await tester.scrollUntilVisible(
      find.text('What do you want to do?'),
      100,
      scrollable: find.descendant(
        of: find.byKey(const Key('filter-options')),
        matching: find.byType(Scrollable),
      ),
    );
    expect(tester.getTopLeft(applyButton).dy, applyButtonTop);
    expect(
      tester.getRect(applyButton).bottom,
      lessThanOrEqualTo(
        tester.getRect(find.byKey(const Key('place-filter-sheet'))).bottom,
      ),
    );
    await tester.tap(find.byKey(const Key('apply-filters')));
    await tester.pumpAndSettle();

    expect(find.text('Sample Kape Stop'), findsOneWidget);
    expect(find.text('Sample Study Corner'), findsNothing);
  });

  testWidgets('budget uses chips and applies the cheapest estimated spend', (
    tester,
  ) async {
    await pumpPrototype(tester);

    await tester.tap(find.byKey(const Key('open-filters')));
    await tester.pumpAndSettle();

    // Uniform controls: the budget group is a chip row, not a slider.
    expect(find.byKey(const Key('budget-filter')), findsNothing);
    expect(find.byKey(const Key('budget-any-filter')), findsOneWidget);

    await tester.tap(find.byKey(const Key('budget-50-filter')));
    await tester.tap(find.byKey(const Key('apply-filters')));
    await tester.pumpAndSettle();

    // Study Corner starts at ₱0; Kape Stop starts at ₱80.
    expect(find.text('Sample Study Corner'), findsOneWidget);
    expect(find.text('Sample Kape Stop'), findsNothing);
  });

  testWidgets('open-now filter excludes listings without structured hours', (
    tester,
  ) async {
    await pumpPrototype(tester);

    await tester.tap(find.byKey(const Key('open-filters')));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('open-now-filter')),
      100,
      scrollable: find.descendant(
        of: find.byKey(const Key('filter-options')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.tap(find.byKey(const Key('open-now-filter')));
    await tester.tap(find.byKey(const Key('apply-filters')));
    await tester.pumpAndSettle();

    // Kape Stop has no structured hours, so it cannot be proven open.
    expect(find.text('No places match those filters'), findsOneWidget);
    expect(find.text('Sample Kape Stop'), findsNothing);
  });

  testWidgets('reset clears selected filters before applying', (tester) async {
    await pumpPrototype(tester);

    await tester.tap(find.byKey(const Key('open-filters')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('category-coffee-filter')));
    await tester.tap(find.text('Reset'));
    await tester.tap(find.byKey(const Key('apply-filters')));
    await tester.pumpAndSettle();

    expect(find.text('Sample Kape Stop'), findsOneWidget);
    expect(find.text('Sample Study Corner'), findsOneWidget);
  });

  testWidgets('shows campus anchors without fictional sample place pins', (
    tester,
  ) async {
    await pumpPrototype(tester);

    expect(find.text('Tag'), findsOneWidget);
    expect(find.byIcon(Icons.translate), findsNothing);
    expect(find.byTooltip('Switch to Filipino'), findsOneWidget);
    await tester.tap(find.byKey(const Key('language-toggle')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Mag-explore'), findsOneWidget);
    expect(find.text('Eng'), findsOneWidget);
    expect(find.byTooltip('Lumipat sa English'), findsOneWidget);

    await tester.tap(find.text('Mapa'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(MapLibreMap), findsOneWidget);
    expect(find.text('Kailangan ng internet ang mapa'), findsOneWidget);
    expect(
      find.text(
        'Hindi ipinapakita sa mapa ang mga lugar na walang wastong pares ng coordinate.',
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('map-place-carousel')), findsNothing);
    expect(find.text('Sample Kape Stop'), findsNothing);
  });

  testWidgets('offers every agreed category even with no listing for it', (
    tester,
  ) async {
    await pumpPrototype(tester);

    await tester.tap(find.byKey(const Key('open-filters')));
    await tester.pumpAndSettle();

    for (final category in PlaceCategory.values) {
      expect(
        find.byKey(Key('category-${category.key}-filter')),
        findsOneWidget,
      );
    }

    await tester.tap(find.byKey(const Key('category-other-filter')));
    await tester.tap(find.byKey(const Key('apply-filters')));
    await tester.pumpAndSettle();

    expect(find.text('No Other place listings yet'), findsOneWidget);
    expect(
      find.text('Try changing or clearing your filters.'),
      findsOneWidget,
    );
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

  testWidgets('labels the bundled copy when shared listings are unavailable', (
    tester,
  ) async {
    await tester.pumpWidget(
      TambayanApp(
        showIntroOnStart: false,
        placesRepository: _OfflinePlacesRepository(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(find.byKey(const Key('offline-notice')), findsOneWidget);
    expect(
      find.text('Showing the bundled sample copy · live updates unavailable'),
      findsOneWidget,
    );
  });
}
