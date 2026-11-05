/// The destinations the shell can show.
///
/// Kept outside the shell so the drawer and the screen stack can share the
/// same ordered list without importing each other. The order must match the
/// `IndexedStack` children in `tambayan_app.dart`.
enum AppSection { home, explore, map, mood, visionMission, privacy, terms }
