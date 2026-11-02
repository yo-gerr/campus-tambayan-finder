import 'package:supabase_flutter/supabase_flutter.dart';

import 'place.dart';
import 'places_remote_source.dart';

/// Reads listings from the Supabase `places` table.
///
/// The client uses the public anon key and the table's row-level security
/// policies only allow reads. Never ship a service-role key in the app.
class SupabasePlacesSource implements PlacesRemoteSource {
  SupabasePlacesSource(this._client);

  final SupabaseClient _client;

  @override
  Stream<List<Place>> watchPlaces() {
    return _client
        .from('places')
        .stream(primaryKey: ['id'])
        .order('name')
        .map((rows) => rows.map(Place.fromJson).toList(growable: false));
  }
}
