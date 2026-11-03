import 'dart:async';

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
    late final StreamController<List<Place>> controller;
    RealtimeChannel? channel;
    var closed = false;
    var loading = false;
    var refreshQueued = false;

    Future<void> refresh() async {
      if (closed) return;
      if (loading) {
        refreshQueued = true;
        return;
      }

      loading = true;
      do {
        refreshQueued = false;
        try {
          final rows = await _client
              .from('places')
              .select('*, place_photos(*)')
              .order('name');
          if (!closed) {
            controller.add(
              (rows as List<dynamic>)
                  .cast<Map<String, dynamic>>()
                  .map(Place.fromJson)
                  .toList(growable: false),
            );
          }
        } catch (error, stackTrace) {
          if (!closed) controller.addError(error, stackTrace);
        }
      } while (refreshQueued && !closed);
      loading = false;
    }

    controller = StreamController<List<Place>>(
      onListen: () {
        channel = _client
            .channel('public:places-with-photos')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'places',
              callback: (_) => unawaited(refresh()),
            )
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'place_photos',
              callback: (_) => unawaited(refresh()),
            )
            .subscribe();
        unawaited(refresh());
      },
      onCancel: () async {
        closed = true;
        if (channel != null) await _client.removeChannel(channel!);
      },
    );
    return controller.stream;
  }
}
