import 'place.dart';

/// Read-only adapter for the shared listing source.
///
/// Kept separate from [PlacesRepository] so the synchronization policy can be
/// tested without a network client.
abstract interface class PlacesRemoteSource {
  /// Emits the current listings, then new sets whenever the source changes.
  Stream<List<Place>> watchPlaces();
}
