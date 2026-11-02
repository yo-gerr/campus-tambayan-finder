import 'dart:convert';

import 'package:flutter/services.dart';

import 'place.dart';
import 'places_repository.dart';

/// Reads the fictional listings bundled with the APK.
///
/// These stay in the build as the seed and offline fallback even when the
/// shared source is configured, and they are the canonical source the shared
/// table is imported from.
class SamplePlacesRepository implements PlacesRepository {
  @override
  Stream<PlacesSnapshot> watchPlaces() async* {
    yield PlacesSnapshot(
      places: await loadPlaces(),
      source: PlacesDataSource.bundledSeed,
    );
  }

  Future<List<Place>> loadPlaces() async {
    final content = await rootBundle.loadString(
      'assets/data/sample_places.json',
    );
    final records = jsonDecode(content) as List<dynamic>;
    return records
        .map((record) => Place.fromJson(record as Map<String, dynamic>))
        .toList(growable: false);
  }
}
