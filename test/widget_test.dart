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

  @override
  Future<void> refresh() async {}

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
    bool openExplore = true,
    Size surface = const Size(390, 844),
    double textScale = 1,
  }) async {
    tester.view.physicalSize = surface;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      TambayanApp(
        showIntroOnStart: showIntroOnStart,
        placesRepository: _TestPlacesRepository(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    if (showIntroOnStart) return;
    if (openExplore) {
      await tester.tap(find.byKey(const Key('home-find-tambayan')));
      await tester.pumpAndSettle();
      expect(find.text('Sample Study Corner'), findsOneWidget);
    }
  }

  testWidgets('shows places and opens a place detail', (tester) async {
    await pumpPrototype(tester);

    expect(find.text('Sample Study Corner'), findsOneWidget);
    expect(find.text('DEMO CONTENT · NOT VERIFIED'), findsNothing);

    await tester.tap(find.byKey(const Key('place-card-sample-study-corner')));
    await tester.pumpAndSettle();

    expect(
      tester.widget<PlacePhotoGallery>(find.byType(PlacePhotoGallery)).height,
      112,
    );
    expect(find.text('Estimated\nspend'), findsOneWidget);
    expect(find.textContaining('DEMO CONTENT', skipOffstage: false), findsNothing);
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

    expect(
      find.text('Not yet verified; directions are unavailable.'),
      findsOneWidget,
    );
    expect(find.text('Directions'), findsOneWidget);

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
    expect(
      find.descendant(of: detailList, matching: find.text('Free Wi-Fi')),
      findsOneWidget,
    );

    // Structured days render as a weekly block when expanded.
    await tester.scrollUntilVisible(
      find.text('See full week'),
      100,
      scrollable: detailScrollable,
    );
    await tester.tap(find.text('See full week'));
    await tester.pumpAndSettle();
    expect(find.text('Monday'), findsOneWidget);
    expect(find.text('Closed'), findsAtLeast(1));
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

  test('brand palette text pairs clear AA contrast', () {
    expect(
      _contrastRatio(AppColors.inkStrong, AppColors.bubble),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(AppColors.onPrimary, AppColors.primary),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(AppColors.mutedInk, AppColors.outline),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(AppColors.ink, AppColors.surface),
      greaterThanOrEqualTo(4.5),
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
    expect(allChip.labelStyle?.color, AppColors.inkStrong);
    expect(coffeeChip.labelStyle?.color, AppColors.ink);
    expect(
      Theme.of(tester.element(find.byKey(const Key('category-any-filter'))))
          .chipTheme
          .selectedColor,
      AppColors.bubble,
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
    await tester.ensureVisible(find.byKey(const Key('open-now-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-now-filter')));
    await tester.tap(find.byKey(const Key('apply-filters')));
    await tester.pumpAndSettle();

    // Kape Stop has no structured hours, so it cannot be proven open.
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

  testWidgets('hub navigation, drawer language, and spoke menu controls', (
    tester,
  ) async {
    await pumpPrototype(tester);
    expect(find.text('Sample Kape Stop'), findsOneWidget);

    // Open the shared drawer and switch language there.
    await tester.tap(find.byKey(const Key('menu-button')).hitTestable());
    await tester.pumpAndSettle();
    expect(find.text('Language'), findsOneWidget);
    await tester.tap(find.byKey(const Key('drawer-language-filipino')));
    await tester.pumpAndSettle();
    expect(find.text('Wika'), findsOneWidget);

    // Return home, open Explore, then the map from there.
    await tester.tap(find.byKey(const Key('drawer-home')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-find-tambayan')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tingnan ang mapa'));
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

    // The map menu opens the shared sidebar without leaving the map.
    await tester.tap(find.byKey(const Key('map-menu')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('drawer-language')), findsOneWidget);
    await tester.tap(find.byKey(const Key('drawer-home')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('home-find-tambayan')), findsOneWidget);
  });

  testWidgets('home is the hub and the mood page stores nothing', (
    tester,
  ) async {
    await pumpPrototype(tester, openExplore: false);

    expect(find.byKey(const Key('home-find-tambayan')), findsOneWidget);
    expect(find.byKey(const Key('home-mood')), findsOneWidget);
    expect(find.byKey(const Key('home-more')), findsOneWidget);

    await tester.tap(find.byKey(const Key('home-mood')));
    await tester.pumpAndSettle();
    expect(find.text('Share your visit mood'), findsOneWidget);
    expect(find.textContaining('no GPS tracking'), findsOneWidget);
    await tester.tap(find.byKey(const Key('mood-start-checkin')));
    await tester.pumpAndSettle();
    expect(find.text('Before you continue'), findsOneWidget);
    expect(find.byKey(const Key('mood-consent')), findsOneWidget);

    await tester.tap(find.byKey(const Key('menu-button')).hitTestable());
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('drawer-language')), findsOneWidget);
    await tester.tap(find.byKey(const Key('drawer-home')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('home-find-tambayan')), findsOneWidget);
  });

  testWidgets('home hub fits a narrow phone in Filipino', (tester) async {
    await pumpPrototype(
      tester,
      openExplore: false,
      surface: const Size(320, 640),
    );
    await tester.tap(find.byKey(const Key('open-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('drawer-language-filipino')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('drawer-home')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('home-find-tambayan')), findsOneWidget);
  });

  for (final surface in const [
    Size(320, 640),
    Size(360, 800),
    Size(390, 844),
    Size(430, 932),
    Size(600, 960),
  ]) {
    for (final textScale in const [1.0, 1.5, 2.0]) {
      testWidgets(
        'home and drawer fit ${surface.width.toInt()}x${surface.height.toInt()} at ${textScale}x text',
        (tester) async {
          await pumpPrototype(
            tester,
            openExplore: false,
            surface: surface,
            textScale: textScale,
          );

          expect(tester.takeException(), isNull);
          expect(find.byKey(const Key('home-find-tambayan')), findsOneWidget);

          await tester.tap(find.byKey(const Key('open-menu')));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(find.byKey(const Key('drawer-home')), findsOneWidget);

          final drawerScrollable = find.descendant(
            of: find.byType(Drawer),
            matching: find.byType(Scrollable),
          );
          await tester.scrollUntilVisible(
            find.byKey(const Key('drawer-language')),
            120,
            scrollable: drawerScrollable,
          );
          expect(find.byKey(const Key('drawer-language')), findsOneWidget);
        },
      );
    }
  }

  testWidgets('compact screen keeps long content usable at 2x text', (
    tester,
  ) async {
    await pumpPrototype(
      tester,
      openExplore: false,
      surface: const Size(320, 640),
      textScale: 2.0,
    );
    expect(tester.takeException(), isNull);

    // Open Explore from the hub instead of relying on the card list being
    // laid out above the fold at this text scale.
    await tester.tap(find.byKey(const Key('home-find-tambayan')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // The search field and its filter button sit below the welcome copy at
    // this text scale, so scroll the Explore list to reach them.
    await tester.dragUntilVisible(
      find.byKey(const Key('open-filters')),
      find.byType(ListView).first,
      const Offset(0, -160),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('open-filters')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('menu-button')).hitTestable());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('drawer-vision')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Vision & Mission'), findsOneWidget);
    expect(find.text('Pending review'), findsOneWidget);
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
    expect(find.text('Try changing or clearing your filters.'), findsOneWidget);
  });

  testWidgets('visual onboarding can be skipped and instructions reopened', (
    tester,
  ) async {
    await pumpPrototype(tester, showIntroOnStart: true);

    expect(find.text('Find your next tambayan'), findsOneWidget);
    expect(find.byKey(const Key('visual-onboarding-skip')), findsOneWidget);
    await tester.tap(find.byKey(const Key('visual-onboarding-skip')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('open-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('drawer-instructions')));
    await tester.pumpAndSettle();
    expect(find.text('Find your next tambayan'), findsOneWidget);
    expect(find.byKey(const Key('onboarding-contents')), findsOneWidget);
  });

  testWidgets('visual onboarding moves through pages', (tester) async {
    await pumpPrototype(tester, showIntroOnStart: true);

    expect(find.text('Find your next tambayan'), findsOneWidget);
    expect(find.byKey(const Key('visual-onboarding-skip')), findsOneWidget);
    await tester.tap(find.byKey(const Key('visual-onboarding-next')));
    await tester.pumpAndSettle();
    expect(find.text('Pick what fits you'), findsOneWidget);

    await tester.tap(find.byKey(const Key('visual-onboarding-next')));
    await tester.pumpAndSettle();
    expect(find.text('Check it, then go'), findsOneWidget);
    expect(find.byKey(const Key('visual-onboarding-start')), findsOneWidget);
  });

  testWidgets(
    'drawer opens approved placeholder destinations and shows version',
    (tester) async {
      await pumpPrototype(tester, openExplore: false);

      await tester.tap(find.byKey(const Key('open-menu')));
      await tester.pumpAndSettle();
      expect(find.text('Kamus Tambay · Version 1.0.0'), findsOneWidget);

      await tester.tap(find.byKey(const Key('drawer-vision')));
      await tester.pumpAndSettle();
      expect(find.text('Vision & Mission'), findsOneWidget);
      expect(find.text('Pending review'), findsOneWidget);
      expect(
        find.textContaining('Draft for Class Presentation'),
        findsOneWidget,
      );

      await tester.dragFrom(const Offset(2, 300), const Offset(280, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('drawer-privacy')));
      await tester.pumpAndSettle();
      expect(find.text('Privacy'), findsOneWidget);
      expect(find.textContaining('Draft for Class Presentation'), findsOneWidget);

      await tester.dragFrom(const Offset(2, 300), const Offset(280, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('drawer-terms')));
      await tester.pumpAndSettle();
      expect(find.text('Terms & Conditions'), findsOneWidget);
      expect(find.textContaining('Draft for Class Presentation'), findsOneWidget);
    },
  );

  testWidgets('labels the bundled copy when shared listings are unavailable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      TambayanApp(
        showIntroOnStart: false,
        placesRepository: _OfflinePlacesRepository(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    await tester.tap(find.byKey(const Key('home-find-tambayan')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('offline-notice')), findsOneWidget);
    expect(
      find.text('Showing the bundled sample copy · live updates unavailable'),
      findsOneWidget,
    );
  });
}
