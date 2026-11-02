import 'package:flutter/foundation.dart';

import 'place.dart';
import 'places_remote_source.dart';
import 'places_repository.dart';

/// Shows bundled listings immediately, then replaces them with shared listings
/// when the shared source answers.
///
/// The bundled listings are never removed: if the shared source is unreachable,
/// the app keeps working and labels the copy as offline instead of showing an
/// error or inventing data.
class SyncedPlacesRepository implements PlacesRepository {
  SyncedPlacesRepository({
    required this.local,
    required this.remote,
    this.firstUpdateTimeout = const Duration(seconds: 5),
  });

  final PlacesRepository local;
  final PlacesRemoteSource remote;
  final Duration firstUpdateTimeout;

  @override
  Stream<PlacesSnapshot> watchPlaces() async* {
    final seed = await local.watchPlaces().first;
    yield seed;

    final List<Place> firstLive;
    try {
      firstLive = await remote.watchPlaces().first.timeout(firstUpdateTimeout);
    } catch (error) {
      debugPrint('Shared listings unavailable, using bundled copy: $error');
      yield PlacesSnapshot(
        places: seed.places,
        source: PlacesDataSource.offlineFallback,
      );
      return;
    }

    var hasLive = false;
    if (firstLive.isNotEmpty) {
      hasLive = true;
      yield PlacesSnapshot(places: firstLive, source: PlacesDataSource.live);
    }

    try {
      await for (final places in remote.watchPlaces()) {
        // An empty table usually means setup is incomplete; keep the bundled
        // copy rather than blanking the list in front of a reviewer.
        if (places.isEmpty) continue;
        hasLive = true;
        yield PlacesSnapshot(places: places, source: PlacesDataSource.live);
      }
    } catch (error) {
      debugPrint('Shared listing updates stopped: $error');
      if (!hasLive) {
        yield PlacesSnapshot(
          places: seed.places,
          source: PlacesDataSource.offlineFallback,
        );
      }
      // After live data has been shown, keep the newest listings on screen
      // instead of reverting to older bundled ones mid-session.
    }
  }
}
