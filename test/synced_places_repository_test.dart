import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:campus_tambayan_finder/features/places/place.dart';
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

class _BundledRepository implements PlacesRepository {
  @override
  Stream<PlacesSnapshot> watchPlaces() async* {
    yield const PlacesSnapshot(
      places: [_bundledPlace],
      source: PlacesDataSource.bundledSeed,
    );
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
