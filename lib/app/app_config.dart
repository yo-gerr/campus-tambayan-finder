/// Build-time configuration.
///
/// Values are supplied with `--dart-define` so no project URL or key is
/// committed to the repository. Both must be present to enable shared
/// listings; otherwise the app runs on the bundled listings alone.
///
/// Use the publishable (anon) key: it is public by design and safe to ship.
/// A secret or service-role key must never be passed here.
abstract final class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static bool get hasSharedListings =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;
}
