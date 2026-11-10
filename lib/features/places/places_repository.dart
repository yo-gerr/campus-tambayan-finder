import 'place.dart';

/// Where the listings currently on screen came from.
enum PlacesDataSource {
  /// The shared online listing source answered and returned data.
  live,

  /// A saved listing snapshot shown while checking for a fresh online copy.
  cached,

  /// Bundled local listings. This build has no shared source configured.
  bundledSeed,

  /// Bundled local listings shown because the shared source was unreachable.
  offlineFallback,

  /// The last saved shared listing snapshot shown because the source is offline.
  offlineCache,
}

/// A set of listings plus where they came from, so the interface can be honest
/// about showing an offline copy instead of silently presenting stale data.
class PlacesSnapshot {
  const PlacesSnapshot({required this.places, required this.source});

  final List<Place> places;
  final PlacesDataSource source;

  bool get isOfflineFallback =>
      source == PlacesDataSource.offlineFallback ||
      source == PlacesDataSource.offlineCache;

  bool get isSavedOfflineCopy => source == PlacesDataSource.offlineCache;
}

/// Read-only listing source for the app.
///
/// Browsing never writes shared data, so implementations only need to expose
/// reads. Listing edits happen outside the app, by the team, in the provider's
/// dashboard.
abstract interface class PlacesRepository {
  /// Emits the bundled listings first, then shared updates when available.
  Stream<PlacesSnapshot> watchPlaces();

  /// Forces a fresh fetch from the remote shared listing source if supported.
  Future<void> refresh() async {}
}
