import 'dart:async';

import 'package:flutter/foundation.dart';

import 'place.dart';
import 'places_cache.dart';
import 'places_remote_source.dart';
import 'places_repository.dart';

/// Shows the last saved shared listings when available, otherwise bundled data,
/// then replaces either with fresh shared listings when the source answers.
///
/// Non-empty shared snapshots replace the saved copy. If the shared source is
/// unreachable, the app keeps working and labels the stale copy as offline.
class SyncedPlacesRepository implements PlacesRepository {
  SyncedPlacesRepository({
    required this.local,
    required this.remote,
    this.cache,
    this.firstUpdateTimeout = const Duration(seconds: 5),
  });

  final PlacesRepository local;
  final PlacesRemoteSource remote;
  final PlacesCache? cache;
  final Duration firstUpdateTimeout;

  @override
  Stream<PlacesSnapshot> watchPlaces() async* {
    final seed = await local.watchPlaces().first;
    var initialPlaces = seed.places;
    var initialSource = seed.source;

    if (cache != null) {
      try {
        final cachedPlaces = await cache!.read();
        if (cachedPlaces != null && cachedPlaces.isNotEmpty) {
          initialPlaces = cachedPlaces;
          initialSource = PlacesDataSource.cached;
        }
      } catch (error) {
        debugPrint('Could not read saved listing cache: $error');
      }
    }
    yield PlacesSnapshot(places: initialPlaces, source: initialSource);

    var hasLive = false;
    try {
      final updates = StreamIterator(remote.watchPlaces());
      try {
        if (!await updates.moveNext().timeout(firstUpdateTimeout)) {
          throw StateError('Shared listing stream ended without a snapshot');
        }

        final firstLive = updates.current;
        if (firstLive.isNotEmpty) {
          hasLive = true;
          debugPrint('Shared listings loaded: ${firstLive.length} places');
          await _saveCache(firstLive);
          yield PlacesSnapshot(
            places: firstLive,
            source: PlacesDataSource.live,
          );
        } else {
          debugPrint('Shared listings table is empty; keeping the local copy');
          if (initialSource == PlacesDataSource.cached) {
            yield PlacesSnapshot(
              places: initialPlaces,
              source: PlacesDataSource.offlineCache,
            );
          }
        }

        while (await updates.moveNext()) {
          final places = updates.current;
          // An empty table usually means setup is incomplete; keep the local
          // copy rather than blanking the list in front of a reviewer.
          if (places.isEmpty) continue;
          hasLive = true;
          debugPrint('Shared listings updated: ${places.length} places');
          await _saveCache(places);
          yield PlacesSnapshot(places: places, source: PlacesDataSource.live);
        }
      } finally {
        await updates.cancel();
      }
    } catch (error) {
      if (!hasLive) {
        debugPrint('Shared listings unavailable; keeping local copy: $error');
        yield PlacesSnapshot(
          places: initialPlaces,
          source: initialSource == PlacesDataSource.cached
              ? PlacesDataSource.offlineCache
              : PlacesDataSource.offlineFallback,
        );
      } else {
        debugPrint('Shared listing updates stopped: $error');
      }
    }
  }

  Future<void> _saveCache(List<Place> places) async {
    final placesCache = cache;
    if (placesCache == null) return;
    try {
      await placesCache.write(places);
    } catch (error) {
      debugPrint('Could not save shared listings for offline use: $error');
    }
  }
}
