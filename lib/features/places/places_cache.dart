import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'place.dart';

abstract interface class PlacesCache {
  Future<List<Place>?> read();

  Future<void> write(List<Place> places);
}

/// Stores the last complete shared listing set on-device for offline browsing.
///
/// This cache contains listing data and remote photo URLs, not downloaded
/// images. It is a convenience copy and may be replaced by a later sync.
class SharedPreferencesPlacesCache implements PlacesCache {
  static const _cacheKey = 'places.last_synced.v1';

  Future<SharedPreferences> get _preferences => SharedPreferences.getInstance();

  @override
  Future<List<Place>?> read() async {
    final json = (await _preferences).getString(_cacheKey);
    if (json == null) return null;

    try {
      final records = jsonDecode(json);
      if (records is! List || records.isEmpty) {
        debugPrint('Saved listing cache is empty or has an invalid shape');
        return null;
      }
      return records
          .map(
            (record) =>
                Place.fromJson(Map<String, dynamic>.from(record as Map)),
          )
          .toList(growable: false);
    } on FormatException catch (error) {
      debugPrint('Saved listing cache is invalid JSON: $error');
      return null;
    } on TypeError catch (error) {
      debugPrint('Saved listing cache has an invalid shape: $error');
      return null;
    }
  }

  @override
  Future<void> write(List<Place> places) async {
    if (places.isEmpty) return;
    final json = jsonEncode(places.map((place) => place.toJson()).toList());
    await (await _preferences).setString(_cacheKey, json);
  }
}
