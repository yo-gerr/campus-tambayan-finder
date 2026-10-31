import 'dart:convert';

import 'package:flutter/services.dart';

import 'place.dart';

abstract interface class PlacesRepository {
  Future<List<Place>> loadPlaces();
}

class SamplePlacesRepository implements PlacesRepository {
  @override
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
