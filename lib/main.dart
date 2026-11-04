import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app_config.dart';
import 'app/tambayan_app.dart';
import 'features/places/places_repository.dart';
import 'features/places/sample_places_repository.dart';
import 'features/places/places_cache.dart';
import 'features/places/supabase_places_source.dart';
import 'features/places/synced_places_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  PlacesRepository? placesRepository;
  if (AppConfig.hasSharedListings) {
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        publishableKey: AppConfig.supabasePublishableKey,
      );
      placesRepository = SyncedPlacesRepository(
        local: SamplePlacesRepository(),
        remote: SupabasePlacesSource(Supabase.instance.client),
        cache: SharedPreferencesPlacesCache(),
      );
    } catch (error) {
      // A bad or unreachable configuration must not stop the app from opening
      // with the bundled listings.
      debugPrint(
        'Supabase initialization failed, using bundled places: $error',
      );
    }
  }

  runApp(TambayanApp(placesRepository: placesRepository));
}
