# Proposed Architecture

## Scope

The agreed target is an Android application, initially serving students near PLV Annex and CPAG in Malinta, Valenzuela City, with Filipino (Tagalog) and English language support. The current delivery target is an installable APK for class presentation/testing; Google Play publication and a separate public webpage are not required. Flutter is the framework for the current class-demo MVP, although it is not school-mandated. A browser build of the same app is also published to GitHub Pages as a client review channel; it is not a deliverable and does not change the Android target. The class-demo MVP reads shared listings from a Supabase Free-plan table, with bundled local JSON as seed and offline fallback. Production framework, minimum Android version, production map stack, and any production backend remain undecided.

## Guiding boundaries

- **Feature-first organization:** group code by user capability so related behavior can evolve together.
- **Domain before framework:** represent core concepts and rules without depending on UI widgets, platform APIs, network clients, or a particular database.
- **Explicit adapters:** keep external systems (maps, geolocation, persistence, APIs) behind interfaces owned by the application/domain boundary.
- **Thin presentation:** Android screens should render state and translate user actions into application operations; avoid putting business rules in UI components.
- **Shared visual theme:** define shared semantic colors, typography, spacing, and component styles in Flutter's app-level theme for this MVP. Screens should consume theme values instead of duplicating hard-coded styling. This does not commit a later production app to Flutter.
- **Share only stable code:** share domain, validation, and use-case logic when useful. Keep platform-specific presentation and integrations in their platform layer rather than forcing artificial cross-platform abstractions.
- **Start small:** do not create empty packages, layers, or services just to match a diagram.

## Feature areas in the agreed direction

These are capabilities in the agreed product direction. Their presentation priority is recorded in the project brief; details still need definition:

- **Place discovery:** browse and filter student-friendly places by category, budget, amenities, environment, capacity, and intended activity. Search behavior remains to be specified.
- **Place details:** show verified-as-possible listing information such as address, photos, amenities, estimated prices, and operating hours.
- **Map and directions:** the owner approved MapLibre Flutter with OpenFreeMap public tiles/styles and OpenStreetMap-derived data for the current class demo, subject to an eligible representative accepting the terms and rechecking availability. Keep provider code in the map feature's presentation/infrastructure boundary and place coordinates in approved listing data. The app opens directions in Google Maps; no in-app ETA is included in the current phase. Preserve attribution and do not assume the public tile service has a guaranteed SLA.
- **Listing operations:** the team plans to provide approximately 15–20 initial entries with available photos and details. Authorized team members will edit listing information manually in the Supabase dashboard (no custom in-app admin screen). Listings are loaded from Supabase when configured, with bundled local JSON as the seed and offline fallback. Each listing can have an ordered, Storage-backed gallery with optional bundled fallbacks.
- **Bilingual experience and guidance:** support Filipino and English and provide first-use and in-app instructions.
- **Location-aware behavior:** request device location only when needed and provide a useful experience if permission is denied.
- **Optional mood check-in:** requested as an optional presentation feature, with no user profile linkage. Keep it separate from browsing; do not assume persistent storage, analytics, or research use. Privacy and data-handling decisions remain open.
- **Public product information:** no separate landing page is needed for the current APK presentation/testing delivery. Revisit only if the team later requests one.

## Possible feature-first shape

Adapt names and boundaries to the selected stack. Do not create these folders until implementation begins.

```text
src/
  app/                 # Composition, routing, and platform entry point
  shared/
    domain/            # Truly cross-feature concepts and primitives
    infrastructure/    # Shared external-service adapters, if any
  features/
    place-discovery/
      domain/          # Feature rules and models
      application/     # Use cases and ports
      data/            # Repository and service adapters
      presentation/    # Screens, components, and view state
    place-details/
    map-and-routing/
    localization/
    onboarding/
    mood-check-in/     # Optional; isolate until privacy and data handling are defined
  platform/
    android/           # Android-specific APIs, permissions, and composition
tests/
  ...                  # Mirror the chosen stack's test conventions
```

### Current Flutter MVP baseline layout

The prototype uses a deliberately small Flutter layout:

```text
lib/
  app/                  # App shell, shared theme, bilingual copy, build config
  features/
    places/             # Place model, repository port, bundled and shared sources,
                        # sync/fallback policy, browse/filter/detail UI
    map/                # MapLibre renderer and verified-coordinate markers
    onboarding/         # Intro guide
assets/data/
  sample_places.json    # Canonical demo listings; also the offline fallback
test/
  widget_test.dart      # Main interaction smoke tests
  sample_places_repository_test.dart
  synced_places_repository_test.dart
```

This layout is an implementation detail for the current MVP, not a commitment to production architecture. Replace the sample repository only after scope and data decisions are confirmed.

### Listing data flow

- `PlacesRepository` is a read-only port that emits a `PlacesSnapshot`: the listings plus whether they are live, the bundled seed, or an offline fallback. UI code depends on this port, not on a vendor SDK.
- Category vocabulary is fixed in `lib/features/places/place_categories.dart`, not derived from loaded rows. All five agreed categories stay visible, selectable, and searchable before any listing uses them, and the filter chips, card labels, search, and no-photo placeholder all read that one list. An unrecognised stored key is shown verbatim rather than hidden, so an import mistake stays visible. When no listing exists in the selected category, the empty state says so instead of implying the filters are wrong.
- Price ranges are optional as a pair. A listing without both bounds shows a localized "not listed" label and is excluded while a budget limit is active; the null budget state means "any", so no preset acts as a hidden ceiling. Filtering currently compares the lowest estimated spend, and whether that bound is the right choice remains an open product question recorded in the brief.
- Opening hours are stored twice on purpose. `hoursByDay` is the structured weekly schedule and is the only source for the derived open/closed state; `hours` is an optional human-readable note. The derived state is computed from `opening_hours.dart` against Asia/Manila time (fixed UTC+8, no DST), opening minute inclusive and closing minute exclusive, and overnight windows are supported. Cards and the detail sheet recompute it from one shared timestamp, and the explore screen refreshes that timestamp every minute and on app resume so the badge does not go stale. Nothing is inferred from the free-text field, and days with no entry stay unknown rather than reading as closed.
- `SamplePlacesRepository` reads the bundled JSON. `PlacesRemoteSource` isolates the shared provider, implemented by `SupabasePlacesSource` against the `places` table.
- `SyncedPlacesRepository` composes them: it shows the bundled listings immediately, waits up to five seconds for the first shared snapshot, streams later updates, and labels the copy as an offline fallback when the shared source fails. An empty shared table never blanks the list.
- The client is read-only. The app ships the publishable key, row-level security permits `select` only, and there is no sign-in. No student account or profile is created.
- Shared listings are enabled with `--dart-define` build values. Without them the app runs on the bundled listings alone, so tests and offline builds need no network or credentials.
- The repository JSON is the bundled seed/offline fallback and is the source for Supabase imports. Its fictional sample rows have illustrative coordinates for the local map preview only; those coordinates must be replaced with verified values or omitted before importing real listings. Its nested offline `photos` entries map to the separate shared `place_photos` table, so dashboard edits to either table must be exported back before an APK build to prevent drift.
- Places may include a nullable latitude/longitude pair in decimal degrees. The map shows only places with a complete, in-range pair; old schematic `mapX`/`mapY` values are ignored. Fictional bundled rows use clearly labeled illustrative coordinates to preview the map, not as real destinations. Fixed PLV Annex and CPAG anchors, maintained separately from place listings in the map feature, keep the basemap available without geocoded places; the initial camera centers at the midpoint of the two supplied coordinates. Campus anchors use visually distinct markers and labels; place marker/label taps open place details, while campus-anchor taps do not.
- Google Maps directions are launched with a URL only for a place whose valid coordinates have an explicit `location_verified` confirmation. The flag defaults to false (including existing database rows and bundled illustrative samples); unverified or incomplete locations produce a localized explanation rather than a route.
- The map feature renders OpenFreeMap's Positron style with MapLibre and keeps the attribution control enabled. The full-body Map tab overlays a horizontal carousel of coordinate-valid places along the bottom with equal left/right insets, positioned above the attribution control, and a compact internet/coordinate note at the top-right; carousel cards and place markers open place details. The carousel is tall enough for its card content. Places without valid coordinates are omitted from both map pins and the carousel; the full place list stays on Explore. Map tiles require internet. The user supplied campus-anchor coordinates; confirm their pin placement visually before treating them as verified.
- Photos use a `place_photos` child table: up to 10 ordered entries per place, with one marked cover, public Storage URL, and optional bundled asset/captions. The detail interface displays an ordered swipeable gallery; cards use the cover. The existing optional `places.photoUrl` and `photoAsset` remain a compatibility fallback for bundled rows and older single-photo data. The interface prefers Storage and falls back to a bundled asset when it is missing or cannot load, then a neutral placeholder. Network photo loading uses an accessible, static skeleton styled from the app theme. Decoded image size is bounded to the rendered size, with a larger bound in the full-screen viewer, and visited gallery pages stay mounted so swiping back does not re-download or re-decode a photo. Detail-gallery and card photos use a consistent cover crop; gallery photos can open in a separate full-screen `InteractiveViewer` that contains the full image and overlays a transparent app bar with a dark readability gradient. This presentation behavior does not change the read-only data model. Mood and nickname data must never be added to the shared project as part of listing work.

In smaller projects, combine layers where the framework makes separate files clearer than separate packages. Keep dependencies directed inward: presentation and adapters may depend on application/domain contracts; domain rules should not depend on presentation or vendor SDKs.

## Android and cross-platform considerations

The Android target is agreed and Flutter is the framework for the current class-demo MVP; the production framework is not decided. Keep Android permission handling, lifecycle behavior, navigation, map SDKs, connectivity behavior, and deployment details in the Android platform layer. Avoid introducing cross-platform abstractions unless a confirmed need emerges.

Shared listings require connectivity. The app must stay usable on the bundled copy when the network is unavailable, and it currently does not cache shared listings across restarts. Directions should open in Google Maps externally rather than adding a Maps SDK, API key, or billing account for this delivery.

Request location access only when needed, explain why it is requested, and provide useful discovery from the known PLV Annex/CPAG anchors when permission is denied. Avoid collecting or retaining precise location unless a confirmed requirement justifies it.

Mood check-ins and precise location can reveal sensitive information about a person. Keep mood functionality optional and isolated; before implementing it, define consent, purpose, data linkage, storage, access, retention, deletion, and whether any aggregate analysis is intended. Do not frame correlations as diagnoses or causal conclusions.

Listing photos, map data, and route estimates may have separate permission, attribution, licensing, or provider terms. Verify the applicable terms and obtain appropriate permissions before publication.

### Web preview target

The browser build exists only so the client can review changes without reinstalling the APK. Add web platform files (`web/`) and a GitHub Actions workflow; keep application code platform-neutral so this does not fork the Android implementation.

- **Platform support:** `maplibre_gl` declares web support through its `maplibre_gl_web` implementation, and the existing `MapLibreMap` usage works unchanged. The web build injects `maplibre-gl` as an ES module from `unpkg.com` by default; a strict Content-Security-Policy or a blocked CDN breaks the map, and `MapLibreMap.webLibrarySource` is the escape hatch if the library must be self-hosted.
- **Hosting:** GitHub Pages serves the release build from `/<repo>/`, so builds must pass `--base-href` matching the repository name. Deployment uses GitHub Actions, so the preview updates on every push to `master` without a manual step.
- **Data access:** the Supabase REST and Storage endpoints return permissive CORS headers, so the same read-only publishable key works from the browser. This is what makes the key's public exposure meaningful: row-level security must remain read-only, since anyone can call it.
- **Known gaps:** `flutter_native_splash` is disabled for web, so the browser shows the index background until Flutter's first frame. `url_launcher` ignores `LaunchMode.externalApplication` on web and simply opens a new tab. The generated web icons are still the Flutter defaults.
- **Scope discipline:** do not treat the preview as a second product surface. No analytics, no landing content, and no web-only features get added without a separate decision.

## Revisit when

Update this document when the selected Android stack or a confirmed requirement changes module boundaries, dependencies, data flow, privacy assumptions, or other architectural decisions. Keep the structure proportionate to the actual implementation.
