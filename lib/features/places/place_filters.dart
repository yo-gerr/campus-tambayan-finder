class PlaceFilters {
  const PlaceFilters({
    this.category,
    this.maxBudget = 600,
    this.amenities = const {},
    this.setting,
    this.activity,
  });

  final String? category;
  final double maxBudget;
  final Set<String> amenities;
  final String? setting;
  final String? activity;

  int get activeCount {
    var count = 0;
    if (category != null) count++;
    if (maxBudget < 600) count++;
    count += amenities.length;
    if (setting != null) count++;
    if (activity != null) count++;
    return count;
  }

  bool matches(PlaceLike place) {
    return (category == null || place.category == category) &&
        place.priceMin <= maxBudget &&
        amenities.every(place.amenities.contains) &&
        (setting == null || place.setting == setting) &&
        (activity == null || place.activities.contains(activity));
  }
}

abstract interface class PlaceLike {
  String get category;
  int get priceMin;
  List<String> get amenities;
  String get setting;
  List<String> get activities;
}
