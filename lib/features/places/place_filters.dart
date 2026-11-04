import 'opening_hours.dart';

class PlaceFilters {
  const PlaceFilters({
    this.category,
    this.maxBudget,
    this.amenities = const {},
    this.setting,
    this.activity,
    this.openNow = false,
  });

  final String? category;

  /// Highest per-person budget in pesos, or null for no limit.
  ///
  /// Null is a real state, not a sentinel: "Any budget" must not exclude
  /// listings priced above whatever ceiling the control happens to stop at.
  final int? maxBudget;
  final Set<String> amenities;
  final String? setting;
  final String? activity;

  /// Keeps only listings confirmed open at the moment of evaluation.
  final bool openNow;

  int get activeCount {
    var count = 0;
    if (category != null) count++;
    if (maxBudget != null) count++;
    count += amenities.length;
    if (setting != null) count++;
    if (activity != null) count++;
    if (openNow) count++;
    return count;
  }

  /// [now] is injectable so tests never depend on the wall clock.
  bool matches(PlaceLike place, {DateTime? now}) {
    final budget = maxBudget;
    final priceMin = place.priceMin;
    final priceMax = place.priceMax;
    if (budget != null) {
      // A listing without a reliable range cannot be shown to fit a budget, so
      // it is excluded while a limit is active. Half-known ranges count as
      // unknown rather than guessed.
      if (priceMin == null || priceMax == null || priceMin > budget) {
        return false;
      }
    }
    if (openNow) {
      // Unknown hours cannot prove the place is open, so they are excluded
      // while this filter is on, matching the budget filter's behavior.
      final state = place.openingHours?.isOpenAt(now ?? DateTime.now());
      if (state != true) return false;
    }
    return (category == null || place.category == category) &&
        amenities.every(place.amenities.contains) &&
        (setting == null || place.setting == setting) &&
        (activity == null || place.activities.contains(activity));
  }
}

abstract interface class PlaceLike {
  String get category;

  /// Lowest estimated spend, or null when no reliable price is known.
  int? get priceMin;

  /// Highest estimated spend, or null when no reliable price is known.
  int? get priceMax;

  /// Structured per-day hours, or null when none were supplied.
  OpeningHours? get openingHours;

  List<String> get amenities;
  String get setting;
  List<String> get activities;
}
