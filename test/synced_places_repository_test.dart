import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:campus_tambayan_finder/features/places/place.dart';
import 'package:campus_tambayan_finder/features/places/places_cache.dart';
import 'package:campus_tambayan_finder/features/places/places_remote_source.dart';
import 'package:campus_tambayan_finder/features/places/places_repository.dart';
import 'package:campus_tambayan_finder/features/places/synced_places_repository.dart';

const _bundledPlace = Place(
  id: 'bundled-place',
  name: 'Bundled Place',
  category: 'tambayan',
  area: 'Bundled area',
  descriptionEn: 'Bundled description.',
  descriptionTl: 'Naka-bundle na paglalarawan.',
  priceMin: 0,
  priceMax: 100,
  hours: 'Bundled hours',
  amenities: ['wifi'],
  setting: 'indoor',
  activities: ['study'],
);

const _livePlace = Place(
  id: 'live-place',
  name: 'Live Place',
  category: 'coffee',
  area: 'Live area',
  descriptionEn: 'Live description.',
  descriptionTl: 'Live na paglalarawan.',
  priceMin: 50,
  priceMax: 200,
  hours: 'Live hours',
  amenities: ['wifi', 'aircon'],
  setting: 'indoor',
  activities: ['study', 'eat'],
);

const _cachedPlace = Place(
  id: 'cached-place',
  name: 'Saved Place',
  category: 'park',
  area: 'Saved area',
  descriptionEn: 'Saved description.',
  descriptionTl: 'Naka-save na paglalarawan.',
  amenities: ['outlets'],
  setting: 'outdoor',
  activities: ['relax'],
);

class _BundledRepository implements PlacesRepository {
  @override
  Stream<PlacesSnapshot> watchPlaces() async* {
    yield const PlacesSnapshot(
      places: [_bundledPlace],
      source: PlacesDataSource.bundledSeed,
    );
  }
}

class _MemoryPlacesCache implements PlacesCache {
  _MemoryPlacesCache([this.places]);

  List<Place>? places;
  final writes = <List<Place>>[];

  @override
  Future<List<Place>?> read() async => places;

  @override
  Future<void> write(List<Place> places) async {
    this.places = places;
    writes.add(places);
  }
}

class _FakeRemote implements PlacesRemoteSource {
  _FakeRemote(this._create);

  final Stream<List<Place>> Function() _create;

  @override
  Stream<List<Place>> watchPlaces() => _create();
}

void main() {
  test('shows bundled listings first, then shared listings', () async {
    final snapshots = await SyncedPlacesRepository(
      local: _BundledRepository(),
      remote: _FakeRemote(() => Stream.value(const [_livePlace])),
    ).watchPlaces().toList();

    expect(snapshots.first.source, PlacesDataSource.bundledSeed);
    expect(
      snapshots.skip(1).map((snapshot) => snapshot.source),
      everyElement(PlacesDataSource.live),
    );
    expect(snapshots.last.places.single.name, 'Live Place');
  });

  test(
    'shows the saved copy first and refreshes it from shared listings',
    () async {
      final cache = _MemoryPlacesCache(const [_cachedPlace]);
      final snapshots = await SyncedPlacesRepository(
        local: _BundledRepository(),
        remote: _FakeRemote(() => Stream.value(const [_livePlace])),
        cache: cache,
      ).watchPlaces().toList();

      expect(snapshots.first.source, PlacesDataSource.cached);
      expect(snapshots.first.places.single.name, 'Saved Place');
      expect(snapshots.last.source, PlacesDataSource.live);
      expect(snapshots.last.places.single.name, 'Live Place');
      expect(cache.writes, [
        const [_livePlace],
      ]);
    },
  );

  test('uses the saved copy when the shared source is unavailable', () async {
    final snapshots = await SyncedPlacesRepository(
      local: _BundledRepository(),
      remote: _FakeRemote(() => Stream.error(Exception('offline'))),
      cache: _MemoryPlacesCache(const [_cachedPlace]),
    ).watchPlaces().toList();

    expect(snapshots.first.source, PlacesDataSource.cached);
    expect(snapshots.last.source, PlacesDataSource.offlineCache);
    expect(snapshots.last.places.single.name, 'Saved Place');
  });

  test('does not replace a saved copy with an empty shared table', () async {
    final cache = _MemoryPlacesCache(const [_cachedPlace]);
    final snapshots = await SyncedPlacesRepository(
      local: _BundledRepository(),
      remote: _FakeRemote(() => Stream.value(const <Place>[])),
      cache: cache,
    ).watchPlaces().toList();

    expect(snapshots.first.source, PlacesDataSource.cached);
    expect(snapshots.last.source, PlacesDataSource.offlineCache);
    expect(snapshots.last.places.single.name, 'Saved Place');
    expect(cache.writes, isEmpty);
  });

  test(
    'does not replace a saved copy when shared listings are empty',
    () async {
      final cache = _MemoryPlacesCache(const [_cachedPlace]);
      final snapshots = await SyncedPlacesRepository(
        local: _BundledRepository(),
        remote: _FakeRemote(
          () => Stream.fromIterable(const [
            <Place>[],
            [_livePlace],
          ]),
        ),
        cache: cache,
      ).watchPlaces().toList();

      expect(snapshots.last.source, PlacesDataSource.live);
      expect(snapshots.last.places.single.name, 'Live Place');
      expect(cache.writes, [
        const [_livePlace],
      ]);
    },
  );

  test('falls back to the bundled copy when the shared source fails', () async {
    final snapshots = await SyncedPlacesRepository(
      local: _BundledRepository(),
      remote: _FakeRemote(() => Stream.error(Exception('offline'))),
    ).watchPlaces().toList();

    expect(snapshots.first.source, PlacesDataSource.bundledSeed);
    expect(snapshots.last.source, PlacesDataSource.offlineFallback);
    expect(snapshots.last.places.single.name, 'Bundled Place');
  });

  test('falls back when the shared source does not answer in time', () async {
    final snapshots = await SyncedPlacesRepository(
      local: _BundledRepository(),
      remote: _FakeRemote(
        () => Stream.fromFuture(Completer<List<Place>>().future),
      ),
      firstUpdateTimeout: const Duration(milliseconds: 10),
    ).watchPlaces().toList();

    expect(snapshots.last.source, PlacesDataSource.offlineFallback);
  });

  test(
    'ignores an empty shared table and still accepts later updates',
    () async {
      final snapshots = await SyncedPlacesRepository(
        local: _BundledRepository(),
        remote: _FakeRemote(
          () => Stream.fromIterable(const [
            <Place>[],
            [_livePlace],
          ]),
        ),
      ).watchPlaces().toList();

      expect(snapshots.map((snapshot) => snapshot.source), [
        PlacesDataSource.bundledSeed,
        PlacesDataSource.live,
      ]);
      expect(snapshots.last.places.single.name, 'Live Place');
    },
  );
}
