import 'package:flutter_test/flutter_test.dart';

import 'package:campus_tambayan_finder/features/places/places_repository.dart';
import 'package:campus_tambayan_finder/features/places/sample_places_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads the bundled fictional sample places', () async {
    final places = await SamplePlacesRepository().loadPlaces();

    expect(places, hasLength(4));
    expect(places.first.name, 'Sample Study Corner');
    expect(places.every((place) => place.id.startsWith('sample-')), isTrue);
    expect(places.every((place) => place.coordinates != null), isTrue);
    expect(
      places.every(
        (place) =>
            place.area.startsWith('Demo') ||
            place.descriptionEn.contains('fictional'),
      ),
      isTrue,
    );
  });

  test('serves the bundled listings as the seed snapshot', () async {
    final snapshot = await SamplePlacesRepository().watchPlaces().first;

    expect(snapshot.source, PlacesDataSource.bundledSeed);
    expect(snapshot.places, hasLength(4));
    expect(snapshot.isOfflineFallback, isFalse);
  });
}
