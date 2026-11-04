import 'package:flutter_test/flutter_test.dart';

import 'package:campus_tambayan_finder/app/app_copy.dart';
import 'package:campus_tambayan_finder/features/places/place_filters.dart';

/// Minimal [PlaceLike] so filter rules can be tested without building a full
/// listing.
class _FakePlace implements PlaceLike {
  const _FakePlace({
    required this.category,
    this.priceMin,
    this.priceMax,
    this.amenities = const [],
    this.setting = 'indoor',
    this.activities = const [],
  });

  @override
  final String category;

  @override
  final int? priceMin;

  @override
  final int? priceMax;

  @override
  final List<String> amenities;

  @override
  final String setting;

  @override
  final List<String> activities;
}

void main() {
  const cheap = _FakePlace(
    category: 'tambayan',
    priceMin: 0,
    priceMax: 120,
    amenities: ['wifi', 'outlets'],
    setting: 'indoor',
    activities: ['study', 'relax'],
  );

  const premium = _FakePlace(
    category: 'coffee',
    priceMin: 700,
    priceMax: 900,
    amenities: ['aircon'],
    setting: 'indoor',
    activities: ['study', 'socialize'],
  );

  const unpriced = _FakePlace(
    category: 'other',
    priceMin: null,
    priceMax: null,
    setting: 'outdoor',
    activities: ['relax'],
  );

  group('budget filter', () {
    test('"any budget" is uncapped and keeps expensive listings', () {
      const filters = PlaceFilters();

      expect(filters.matches(cheap), isTrue);
      expect(filters.matches(premium), isTrue);
      expect(filters.matches(unpriced), isTrue);
    });

    test('compares the lowest estimated spend', () {
      const filters = PlaceFilters(maxBudget: 100);

      expect(filters.matches(cheap), isTrue);
      expect(filters.matches(premium), isFalse);
    });

    test('excludes listings with no reliable price while a limit is active', () {
      expect(const PlaceFilters(maxBudget: 200).matches(unpriced), isFalse);
      expect(const PlaceFilters().matches(unpriced), isTrue);
    });

    test('counts only an explicit limit as an active filter', () {
      expect(const PlaceFilters().activeCount, 0);
      expect(const PlaceFilters(maxBudget: 100).activeCount, 1);
    });
  });

  group('comfort filters', () {
    test('amenities must all be present', () {
      expect(
        const PlaceFilters(amenities: {'wifi', 'outlets'}).matches(cheap),
        isTrue,
      );
      expect(const PlaceFilters(amenities: {'wifi'}).matches(cheap), isTrue);
      expect(const PlaceFilters(amenities: {'aircon'}).matches(cheap), isFalse);
      expect(
        const PlaceFilters(amenities: {'wifi', 'aircon'}).matches(cheap),
        isFalse,
      );
    });

    test('setting and activity narrow the result', () {
      expect(const PlaceFilters(setting: 'indoor').matches(cheap), isTrue);
      expect(const PlaceFilters(setting: 'outdoor').matches(cheap), isFalse);
      expect(const PlaceFilters(activity: 'study').matches(cheap), isTrue);
      expect(const PlaceFilters(activity: 'socialize').matches(cheap), isFalse);
    });
  });

  group('price display', () {
    const english = AppCopy(AppLanguage.english);
    const tagalog = AppCopy(AppLanguage.tagalog);

    test('collapses an exact price and keeps a range otherwise', () {
      expect(english.priceRange(50, 50), '₱50');
      expect(english.priceRange(80, 250), '₱80–₱250');
    });

    test('uses a localized label when no reliable price exists', () {
      expect(english.priceRange(null, null), 'Price not listed');
      expect(tagalog.priceRange(null, null), 'Hindi nakalista ang presyo');
      expect(english.priceRange(80, null), 'Price not listed');
    });
  });
}
