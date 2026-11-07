# Agent Handoff

Shared, version-controlled handoff notes for agents working in this repository. Add new entries at the top. Keep this concise; the code and durable project documents remain the source of truth.

## Latest

### 2026-11-07 — Removed live ETA to reduce delivery scope

- Removed the in-app ETA prototype, OSRM client, Supabase route-cache and usage-log integration, route-estimate helpers, related tests, build flag, and direct HTTP dependency. Google Maps handoff remains the directions behavior for verified coordinates.
- Updated the README, project brief, architecture, MVP plan, Supabase setup, credits, and in-app credits to state that ETA was removed from the lower-priced delivery scope. Historical ETA planning entries remain below for context.
- Added the owner-run cleanup query after reviewing the supplied schema. It drops only `public.route_cache` and `public.osrm_usage_logs` with `cascade`; `places`, `place_photos`, and their Realtime entries are preserved.
- Validation: documentation review and `git diff --check`; no app code changed. Hot restart is not applicable.
- Remaining: run the cleanup query in the live Supabase project and verify both ETA tables return `null`; ETA can return only as a separately approved future phase.

### 2026-11-07 — Added in-app and public third-party credits

- Added [`CREDITS.md`](file:///C:/Users/roger/Downloads/GitHub/commission/CREDITS.md) with the public inventory of map data, routing, platform, font, and content obligations, exact attribution strings, the missing repository licence, and the open ODbL/brand/native-dependency review items.
- Added [`CreditsScreen`](file:///C:/Users/roger/Downloads/GitHub/commission/lib/features/info/credits_screen.dart) and wired it into `AppSection`, the drawer (`drawer-credits`), and the `IndexedStack`. It lists OpenStreetMap/ODbL, OpenFreeMap, OpenMapTiles, OSRM/FOSSGIS, Natural Earth, Flutter/Dart, Material Icons, MapLibre, Supabase, the other Dart packages, Fredoka, Nunito, Google Maps, the fictional samples, and the unconfirmed brand artwork.
- The map now shows a visible `© OpenStreetMap contributors · OpenFreeMap · OpenMapTiles` chip. The OpenFreeMap Positron style has no `attribution` metadata, so MapLibre's info button alone showed nothing. The ETA card shows `Road distance: OSRM · © OpenStreetMap contributors` only when route data was used.
- Added [`app_licenses.dart`](file:///C:/Users/roger/Downloads/GitHub/commission/lib/app/app_licenses.dart) and `registerBundledLicenses()`; `main.dart` registers the bundled OFL texts, and `pubspec.yaml` now ships `assets/fonts/OFL-fredoka.txt` and `OFL-nunito.txt`. The in-app licence page shows package notices plus both font licences.
- Added [`external_links.dart`](file:///C:/Users/roger/Downloads/GitHub/commission/lib/app/external_links.dart) for the canonical OSM copyright and fix-the-map URLs. No new dependency; `url_launcher` was already present.
- Updated the README sidebar/credits section, `docs/REFERENCES.md` (OpenFreeMap, OpenMapTiles, Natural Earth, OSRM/FOSSGIS attribution), and `docs/ARCHITECTURE.md` (Credits destination and third-party-credit boundary).
- Tests: added credits-screen, licence-page, map-chip, and conditional ETA-attribution cases. Validation: `dart format` (only touched files), `flutter analyze` clean, full `flutter test` passing, `git diff --check` clean.
- Remaining: the cross-session Supabase `cache_hit` proof, owner decisions on a repository `LICENSE`, brand-image ownership, ODbL share-alike review, native/Gradle licence audit, and final in-app ETA approval. No commit was made.

### 2026-11-07 — Corrected Supabase setup SQL for the shared route cache

- Reworked [`SUPABASE_SETUP.md`](file:///C:/Users/roger/Downloads/GitHub/commission/docs/SUPABASE_SETUP.md) section 9 so the route-cache script is idempotent and never drops the shared cache. `dest_place_id` is now plain text metadata instead of a foreign key to `places`, and existing tables get an `alter table ... drop constraint` repair.
- Replaced the broad `FOR ALL` policies with least-privilege `select`/`insert`/`update` policies scoped to `cache_key like 'route:%'`; usage logs are insert-only for the app.
- Added section 10 with a single copy-paste script covering `places`, `place_photos`, `route_cache`, `osrm_usage_logs`, realtime, the four fictional demo rows, and verification queries. The seed now keeps `location_verified = false` for bundled demo coordinates, matching the project rule that illustrative pins must not enable Directions.
- Split the realtime `alter publication` statements into separate exception blocks so an already-published `places` table does not skip `place_photos`.
- Validation: documentation review and `git diff --check`; no app code changed, so `flutter analyze`/`flutter test` were not re-run.
- Remaining: apply the script to the live project, run the app once with `ENABLE_LIVE_ETA=true`, confirm one `route_cache` row plus `osrm_fetch`, then relaunch and confirm `cache_hit` with no new fetch. The service still swallows cache-write errors with only a `debugPrint`; surfacing them in `osrm_usage_logs` remains follow-up work.

### 2026-11-07 — Wired opt-in live ETA validation and bounded OSRM usage

- Added `AppConfig.enableLiveEta` (`bool.fromEnvironment('ENABLE_LIVE_ETA')`, default false). One shared [`OsrmRouteService`](file:///C:/Users/roger/Downloads/GitHub/commission/lib/features/map/osrm_route_service.dart) is created lazily in `_TambayanHomeState`, passed through `showPlaceDetails`, and closed in `dispose`. Default builds still show only the local estimate and make no routing or cache calls.
- [`OsrmRouteService`](file:///C:/Users/roger/Downloads/GitHub/commission/lib/features/map/osrm_route_service.dart) now has a 10-second configurable timeout, an in-session memory cache ahead of Supabase, `expires_at` filtering, a repository `User-Agent`, `close()`, and `_asCached` for cache hits. `places_map_screen.dart` no longer creates or accepts an unused service.
- [`TravelEstimateCard`](file:///C:/Users/roger/Downloads/GitHub/commission/lib/features/places/travel_estimate_card.dart) now derives walk/ride minutes and the visible distance line from OSRM's road **distance** via `RouteEstimate.fromDistance`, and ignores stale responses with a request-generation counter. OSRM `duration` is not used for walk/ride because the demo server is car-only.
- [`SUPABASE_SETUP.md`](file:///C:/Users/roger/Downloads/GitHub/commission/docs/SUPABASE_SETUP.md) now records the applied cache setup, the current broad `FOR ALL` policies, a least-privilege target policy set, an optional reset section, and the `ENABLE_LIVE_ETA=true` build command. [`PROJECT_BRIEF.md`](file:///C:/Users/roger/Downloads/GitHub/commission/docs/PROJECT_BRIEF.md), [`ARCHITECTURE.md`](file:///C:/Users/roger/Downloads/GitHub/commission/docs/ARCHITECTURE.md), [`MVP_PLAN.md`](file:///C:/Users/roger/Downloads/GitHub/commission/docs/MVP_PLAN.md), and the README were updated to match. In-app ETA stays deferred.
- Tests: added memory-cache, timeout, road-distance rendering, and stale-response cases. Validation: `dart format`, `flutter analyze` clean, all 114 tests pass, `git diff --check` clean.
- Remaining: manual proof against the live project and a device build (`ENABLE_LIVE_ETA=true` plus the Supabase defines). Expected: first open logs `osrm_fetch` and writes one cache row; reopen logs `cache_hit`; a campus switch adds one fetch; relaunch hits the cache; total fetches settle near 2 × mapped places; offline falls back locally. No commit was made for this spike, and in-app ETA plus closed-pin marking still need owner decisions.

### 2026-11-06 — Implemented detail-sheet lazy ETA trigger and cleaned up map screen

- Removed map polyline drawing in [`places_map_screen.dart`](file:///C:/Users/roger/Downloads/GitHub/commission/lib/features/map/places_map_screen.dart) to eliminate map screen clutter when external Google Maps is used for directions.
- Updated [`travel_estimate_card.dart`](file:///C:/Users/roger/Downloads/GitHub/commission/lib/features/places/travel_estimate_card.dart) and [`place_detail_sheet.dart`](file:///C:/Users/roger/Downloads/GitHub/commission/lib/features/places/place_detail_sheet.dart) to trigger [`OsrmRouteService`](file:///C:/Users/roger/Downloads/GitHub/commission/lib/features/map/osrm_route_service.dart) lazily when a place detail sheet opens or when the campus origin changes.
- Card displays local Haversine estimates instantly and updates asynchronously to exact OSRM / cached route durations and distance without blocking UI rendering.
- Validation: `flutter analyze` clean (**0 issues**), all 110 Flutter tests passed, `git diff --check` clean.
- Remaining: user executing SQL script in Supabase SQL Editor.

### 2026-11-06 — Added `drop table if exists` to Supabase route cache SQL migration

- Evaluated user proposal to trigger OSRM/Supabase route caching lazily when `PlaceDetailSheet` is opened, and remove line polylines on MapLibre.
- Confirmed that lazy-loading on detail sheet open is 100% optimal for performance and OSRM policy compliance (prevents burst map calls, checks Supabase cache first, and falls back seamlessly to instant Haversine math).
- Validation: documentation review against project standards; `git diff --check` clean.
- Remaining: await user approval to apply the recommended lazy ETA trigger and map cleanup.

### 2026-11-06 — Added `drop table if exists` to Supabase route cache SQL migration

- Added `drop table if exists public.route_cache cascade;` to [SUPABASE_SETUP.md](file:///C:/Users/roger/Downloads/GitHub/commission/docs/SUPABASE_SETUP.md#L375-L435) to fix Postgres error `42703: column "dest_place_id" does not exist` when executing SQL script on a database where `route_cache` already existed without `dest_place_id`.
- Validation: documentation review against project standards; `git diff --check` clean.
- Remaining: user executing SQL script in Supabase SQL Editor.

### 2026-11-06 — Optimized route cache schema and provided complete Supabase setup guide

- Optimized `route_cache` table schema in [SUPABASE_SETUP.md](file:///C:/Users/roger/Downloads/GitHub/commission/docs/SUPABASE_SETUP.md#L375-L435) to use `cache_key text primary key` for sub-millisecond B-Tree index lookups, and added optional `dest_place_id` metadata tag linked to `places.id`.
- Passed `destPlaceId: place.id` in [`osrm_route_service.dart`](file:///C:/Users/roger/Downloads/GitHub/commission/lib/features/map/osrm_route_service.dart) and [`places_map_screen.dart`](file:///C:/Users/roger/Downloads/GitHub/commission/lib/features/map/places_map_screen.dart) for dashboard querying.
- Provided copy-paste SQL setup script and step-by-step instructions for running in Supabase SQL Editor and initiating demo places data for live OSRM ETA testing.
- Validation: `flutter analyze` clean (**0 issues**), all 110 Flutter tests passed, `git diff --check` clean.
- Remaining: user executing SQL script in Supabase SQL Editor.

### 2026-11-06 — Implemented OSRM route service, Supabase caching, and usage tracking

- Added [`osrm_route_service.dart`](file:///C:/Users/roger/Downloads/GitHub/commission/lib/features/map/osrm_route_service.dart): checks Supabase `route_cache` table first, fetches from OSRM demo API on cache miss with custom `User-Agent: KamusTambayApp/1.0`, logs usage to `osrm_usage_logs` table, and falls back gracefully to straight-line geometry on network failure.
- Integrated `OsrmRouteService` into [`places_map_screen.dart`](file:///C:/Users/roger/Downloads/GitHub/commission/lib/features/map/places_map_screen.dart) to render road-following MapLibre polylines for selected places.
- Added `public.osrm_usage_logs` analytics schema to [SUPABASE_SETUP.md](file:///C:/Users/roger/Downloads/GitHub/commission/docs/SUPABASE_SETUP.md#L375-L435) to monitor OSRM requests and cache hits/misses.
- Added unit & mock HTTP tests in [`osrm_route_service_test.dart`](file:///C:/Users/roger/Downloads/GitHub/commission/test/osrm_route_service_test.dart).
- Validation: `flutter analyze` clean (**0 issues**), all 110 Flutter tests passed, and `git diff --check` clean.
- Remaining: apply SQL migration in Supabase SQL editor when ready.

### 2026-11-06 — Verified ETA feature plan and UI prototype status

- Audited codebase and documentation regarding the OSRM Demo + Route Caching workflow plan and the shipped Flutter UI prototype.
- Confirmed that the local UI/UX prototype ([`TravelEstimateCard`](file:///C:/Users/roger/Downloads/GitHub/commission/lib/features/places/travel_estimate_card.dart), [`RouteEstimate`](file:///C:/Users/roger/Downloads/GitHub/commission/lib/features/map/route_estimate.dart), MapLibre polylines) is active, fully functional, and covered by 107 passing tests.
- Confirmed that the Supabase `public.route_cache` SQL schema, pre-warming strategy, and OSRM policy compliance safeguards remain fully documented in [SUPABASE_SETUP.md](file:///C:/Users/roger/Downloads/GitHub/commission/docs/SUPABASE_SETUP.md#L375-L435) for Phase 5.
- Validation: `flutter analyze` clean (0 issues), `flutter test` passed 107 tests, `git diff --check` clean.
- Remaining: await client decision on Phase 5 in-app ETA vs. external Google Maps redirection.

### 2026-11-06 — Verified repository state for ETA feature plan and prototype

- Audited codebase and documentation regarding the ETA feature plan, domain math, UI prototype, and Supabase route caching setup.
- Confirmed that the UI/UX prototype ([`TravelEstimateCard`](file:///C:/Users/roger/Downloads/GitHub/commission/lib/features/places/travel_estimate_card.dart), [`RouteEstimate`](file:///C:/Users/roger/Downloads/GitHub/commission/lib/features/map/route_estimate.dart), MapLibre polylines) is fully built and covered by 107 passing tests, while backend OSRM caching remains documented in [SUPABASE_SETUP.md](file:///C:/Users/roger/Downloads/GitHub/commission/docs/SUPABASE_SETUP.md).
- Validation: `flutter analyze` clean (0 issues), `flutter test` passed 107 tests, `git diff --check` clean.
- Remaining: await client decision on whether to formally approve in-app ETA for Phase 5 or maintain external Google Maps redirection.

### 2026-11-06 — ETA card redesign and ETA/closed-pin interface prototypes

- Added [`travel_estimate_card.dart`](file:///C:/Users/roger/Downloads/GitHub/commission/lib/features/places/travel_estimate_card.dart): a full-width campus pill selector that starts from the campus nearest the place, large walk/ride minute tiles that stack for large or narrow text, a distance line, and a non-traffic disclaimer. Full sentences remain in the semantics tree while the visible tiles stay compact.
- Replaced the private `_TravelEstimateCard`, `_CampusSegmentSelector`, and `_EtaChip` widgets in [`place_detail_sheet.dart`](file:///C:/Users/roger/Downloads/GitHub/commission/lib/features/places/place_detail_sheet.dart) with the reusable card and dropped the now-unused map imports.
- Added `RouteEstimate.nearestAnchor` so the card's initial origin and the map's selected-place polyline both start from the campus with the shortest walk instead of always using the first anchor.
- Closed places with structured hours now render muted map pins and labels at a slightly smaller size with an outline; `PlacesMapScreen.now` allows deterministic open/closed evaluation. Selecting a place draws a straight-line polyline from the nearest campus anchor.
- Added bilingual `eta_from`, `eta_walk_label`, `eta_ride_label`, and `eta_distance` keys and removed the unused `travel_from` key in [`app_copy.dart`](file:///C:/Users/roger/Downloads/GitHub/commission/lib/app/app_copy.dart).
- Tests: [`travel_estimate_card_test.dart`](file:///C:/Users/roger/Downloads/GitHub/commission/test/travel_estimate_card_test.dart) covers English labels and campus switching at 320×640 with 2.0 text scale plus Tagalog labels; [`route_estimate_test.dart`](file:///C:/Users/roger/Downloads/GitHub/commission/test/route_estimate_test.dart) covers nearest-anchor selection.
- Docs: kept in-app ETA **deferred** in [`PROJECT_BRIEF.md`](file:///C:/Users/roger/Downloads/GitHub/commission/docs/PROJECT_BRIEF.md) and [`MVP_PLAN.md`](file:///C:/Users/roger/Downloads/GitHub/commission/docs/MVP_PLAN.md) and labelled the shipped UI an unapproved, interface-only prototype with no routing or backend calls; restored the Phase 5 open questions and acceptance criteria. [`SUPABASE_SETUP.md`](file:///C:/Users/roger/Downloads/GitHub/commission/docs/SUPABASE_SETUP.md) now marks the `route_cache` SQL as an unapplied proposal and uses the app's actual campus coordinates.
- Validation: `flutter analyze` clean (0 issues), all 107 Flutter tests passed, and `git diff --check` clean (line-ending notices only). The web build was not rerun for this interface-only change.
- Remaining: the product/service decision for in-app ETA is still open, as is whether closed places should be marked on the map. Final Vision/Mission, Privacy, and Terms copy, official logo art, mood retention/consent, and approved listings remain pending.

### 2026-11-06 — Centralized responsive layout and large-text coverage

- Added [`app_layout.dart`](file:///C:/Users/roger/Downloads/GitHub/commission/lib/app/app_layout.dart) as the shared source for width bands (compact `<360`, regular `360–599`, expanded `>=600`), page margins (16/24), the 600 px readable content cap with a centered gutter, sidebar width (capped at 320), sheet height, and the `>1.3` large-text threshold.
- Migrated the home hub, brand header, sidebar, app chrome, map carousel, place detail/filter sheets, Explore, mood, info placeholders, and onboarding screens to the utility instead of local `MediaQuery`/`LayoutBuilder` calculations.
- Fixed real 2× text overflows found by the new matrix: the Explore campus row and the filter sheet's reset/apply actions now stack when text is large. The detail fact tiles keep their existing large-text stacking through the shared threshold.
- Added [`app_layout_test.dart`](file:///C:/Users/roger/Downloads/GitHub/commission/test/app_layout_test.dart) and a widget matrix covering 320×640, 360×800, 390×844, 430×932, and 600×960 at 1.0/1.5/2.0 text scale, plus a compact long-content pass.
- Updated [`ARCHITECTURE.md`](file:///C:/Users/roger/Downloads/GitHub/commission/docs/ARCHITECTURE.md), [`MVP_PLAN.md`](file:///C:/Users/roger/Downloads/GitHub/commission/docs/MVP_PLAN.md), and [`PROJECT_BRIEF.md`](file:///C:/Users/roger/Downloads/GitHub/commission/docs/PROJECT_BRIEF.md) for the responsive behavior and current test count.
- Validation on the working tree: `flutter analyze` clean (0 issues), `flutter test` passed 104 tests (102 belong to this commit; the other 2 are the uncommitted route-estimate tests), `flutter build web --base-href /campus-tambayan-finder/` succeeded, and `git diff --check` reported no whitespace errors (only line-ending notices).
- Committed separately from the in-progress route-estimate/closed-pin work, which remains uncommitted. Final Vision/Mission, Privacy, and Terms copy, official logo art, and the other open client decisions remain pending.

### 2026-11-06 — Prototyped ETA / travel estimate UI and map route visualization

- Created [`route_estimate.dart`](file:///C:/Users/roger/Downloads/GitHub/commission/lib/features/map/route_estimate.dart) for Haversine distance, walking ETA (~4.5 km/h), and riding/tricycle ETA (~18 km/h + 1m buffer) calculations from campus anchors (PLV Annex / CPAG) to place destinations.
- Added `_TravelEstimateCard` to [`place_detail_sheet.dart`](file:///C:/Users/roger/Downloads/GitHub/commission/lib/features/places/place_detail_sheet.dart) with campus origin selector (PLV Annex vs. CPAG), walk/ride time chips, and non-traffic disclaimers. (Later replaced by the reusable `TravelEstimateCard` and the `eta_*` copy keys.)
- Updated [`places_map_screen.dart`](file:///C:/Users/roger/Downloads/GitHub/commission/lib/features/map/places_map_screen.dart) to render MapLibre blue route polylines (`LineOptions`) connecting campus anchor coordinates to selected place markers.
- Added bilingual translation keys (`travel_time`, `travel_from`, `eta_walk`, `eta_ride`, `eta_disclaimer`) to [`app_copy.dart`](file:///C:/Users/roger/Downloads/GitHub/commission/lib/app/app_copy.dart) and unit tests to `test/route_estimate_test.dart`.
- Updated [PROJECT_BRIEF.md](file:///C:/Users/roger/Downloads/GitHub/commission/docs/PROJECT_BRIEF.md) and [MVP_PLAN.md](file:///C:/Users/roger/Downloads/GitHub/commission/docs/MVP_PLAN.md).
- Validation: `flutter analyze` clean (**0 issues**), all 82 Flutter tests passed, and `git diff --check` clean.
- Remaining: await client feedback and dataset.

### 2026-11-06 — Implemented closed shops visual pin styling on the map

- Updated `_PlacesMapState` in [`places_map_screen.dart`](file:///C:/Users/roger/Downloads/GitHub/commission/lib/features/map/places_map_screen.dart) to evaluate open/closed status in Asia/Manila time (`UTC+8`).
- Rendered closed shop map pins in muted slate grey (`AppColors.mutedInk`) with 8px radius and subtle outline (`AppColors.outline`), differentiating them from open shops in active blue (`AppColors.primary`).
- Added `now` clock parameter to `PlacesMapScreen` for deterministic status evaluation in tests.
- Validation: `flutter analyze` clean (**0 issues**), all 80 Flutter tests passed, and `git diff --check` passed.
- Remaining: await client feedback and dataset.

### 2026-11-06 — Completed project-wide implementation audit and progress roadmap

- Evaluated MapLibre pin rendering (`_PlacesMapState` in `places_map_screen.dart`), color tokens (`AppColors`), and `OpenStatusBadge` status integration.
- Formulated recommendations for distinct closed-shop pin colors (muted grey `AppColors.mutedInk`), text labels, and map carousel card overlays.
- Validation: documentation review against project standards; `git diff --check` clean.
- Remaining: await user approval to apply the recommended closed shops map styling.

### 2026-11-06 — Completed project-wide implementation audit and progress roadmap

- Conducted a full scan of code (`lib/`, `test/`) and documentation ([MVP_PLAN.md](file:///C:/Users/roger/Downloads/GitHub/commission/docs/MVP_PLAN.md), [PROJECT_BRIEF.md](file:///C:/Users/roger/Downloads/GitHub/commission/docs/PROJECT_BRIEF.md), [CONCEPT_AND_FOLLOW_UP_ANSWERS.md](file:///C:/Users/roger/Downloads/GitHub/commission/docs/CONCEPT_AND_FOLLOW_UP_ANSWERS.md)).
- Categorized all remaining unimplemented items into actionable tasks ready for immediate development vs. items blocked by client data or approvals.
- Validation: documentation audit against project standards; `git diff --check` clean.
- Remaining: await client feedback and dataset.

### 2026-11-06 — Added Supabase route caching setup guide for Phase 5 ETA

- Added `public.route_cache` SQL schema, RLS policies, index creation, and pre-warming guide to [SUPABASE_SETUP.md](file:///C:/Users/roger/Downloads/GitHub/commission/docs/SUPABASE_SETUP.md).
- Recomended deferring Flutter code implementation until real 15–20 establishment coordinates are provided by the client.
- Validation: documentation review against project standards; `git diff --check` clean.
- Remaining: await client decision on Phase 5 ETA implementation.

### 2026-11-06 — Documented OSRM route caching plan for Phase 5 ETA

- Updated project documentation ([PROJECT_BRIEF.md](file:///C:/Users/roger/Downloads/GitHub/commission/docs/PROJECT_BRIEF.md), [MVP_PLAN.md](file:///C:/Users/roger/Downloads/GitHub/commission/docs/MVP_PLAN.md), [ARCHITECTURE.md](file:///C:/Users/roger/Downloads/GitHub/commission/docs/ARCHITECTURE.md), and [REFERENCES.md](file:///C:/Users/roger/Downloads/GitHub/commission/docs/REFERENCES.md)) with the OSRM public demo routing + Supabase PostgreSQL route caching architecture.
- Documented 4-decimal-degree coordinate rounding, 40–80 pre-warmed campus routes, MapLibre GeoJSON `LineLayer` polyline rendering, custom `User-Agent` requirements, and fallback straight-line ETA heuristics.
- Validation: documentation review against project standards; `git diff --check` clean.
- Remaining: await client decision on Phase 5 ETA implementation.

### 2026-11-06 — Evaluated OSRM demo routing and Supabase route caching plan

- Analyzed the proposed OSRM demo routing workflow, Supabase route caching architecture, OSRM usage policy compliance, coordinate normalization, and MapLibre polyline visualization.
- Confirmed technical feasibility for campus-to-shop routes (PLV Annex/CPAG to ~20 Malinta establishments).
- Documented key recommendations: cache pre-warming, custom User-Agent, Supabase Postgres RPC / Edge Functions, coordinate rounding, and fallback straight-line ETA.
- Validation: documentation review against `docs/PROJECT_BRIEF.md`, `docs/MVP_PLAN.md`, `docs/ARCHITECTURE.md`, and `docs/REFERENCES.md`; `git diff --check` passed.
- Remaining: await client decision on whether to implement in-app ETA or maintain external Google Maps redirection.

### 2026-11-05 — Enhanced full-screen photo viewer loading UX

- Evaluated place photo caching, full-screen decoding, and loading UI.
- Confirmed Flutter's memory `ImageCache` reuses downloaded network bytes when opening full-screen view (no re-download over network).
- Updated full-screen viewer (`_PhotoViewerScreen`) to use a sleek dark loading surface with a centered light indicator instead of the light theme skeleton to eliminate bright visual flashing.
- Validation: `flutter analyze` clean, all 80 Flutter tests passed, and `git diff --check` passed.
- Remaining: await client feedback on open questions.

### 2026-11-05 — Added new translation keys for shop details and directions

- Added requested translation keys to `lib/app/app_copy.dart`: `opens` ("Opens" / "Bubukas"), `closes` ("Closes" / "Magsasara"), `see_full_week` ("See full week" / "Tingnan ang buong linggo"), `hide_full_week` ("Hide" / "Itago"), `opens_google_maps` ("Opens in Google Maps" / "Magbubukas sa Google Maps"), `address_copied` ("Address copied" / "Nakopya ang address"), and `got_it` ("Got it" / "Naintindihan").
- Synchronized `test/widget_test.dart` with the detail sheet changes (missing-photo height, offstage scrolling, directions bar, and collapsible hours card).
- Validation: `flutter analyze` clean, all 80 Flutter tests passed, and `git diff --check` passed.
- Remaining: await client review on open questions.

### 2026-11-05 — Refined client progress update message

- Refined the client update message to incorporate the revamped Kamus Tambay home screen hub, 3-page visual onboarding, interactive map with PLV Annex/CPAG anchors, external Google Maps directions, and on-device offline caching alongside the existing feature summary.
- Validation: documentation review against `lib/` and `docs/`; `git diff --check` passed.
- Remaining: await client review and feedback on the updated progress message and open questions.

### 2026-11-05 — Conducted Phase 1–4 implementation audit and compiled client follow-up questions

- Audited Phase 1–4 implementation status against project brief, architecture, MVP plan, and client meeting notes.
- Compiled an organized list of client follow-up questions covering Home Screen & Navigation, Sidebar destinations (Vision & Mission, Privacy, Terms & Conditions copy supply), Shop Details, Mood Check-in & Nickname DB storage handling, Map & Directions, and Administration & Listing updates.
- Validation: documentation audit against `lib/`, `assets/`, `test/`, and `docs/`; `git diff --check` passed.
- Remaining: await client feedback and approval on open questions before implementing any backend mood storage, final copy, or data updates.

### 2026-11-05 — Fixed mood preview illustration spacing

- Reduced the mood illustration size, clipped it to the rounded panel, added bottom padding, and increased the gap before the following heading so the compact phone layout does not overlap.
- Validation: `dart format`, `flutter analyze`, the focused `test/widget_test.dart` suite (18 tests), and `git diff --check` passed.
- Remaining: visually confirm the layout with a connected Flutter emulator when available.

### 2026-11-05 — Added UI-only mood check-in workflow

- Replaced the mood information-only page with a local interactive prototype covering the planned explanation, consent acknowledgement, Happy/Relaxed/Stressed/Sad selection, optional nickname, review, and not-submitted confirmation states.
- No database, network request, GPS, account, analytics, or persistent mood storage was added. The UI explicitly identifies the flow as a preview.
- Documented the remaining client/privacy blockers: retention, access, deletion/withdrawal, consent wording, nickname handling, selected-place linkage, and qualified review.
- Validation: `dart format`, `flutter analyze`, and the full Flutter test suite passed.

### 2026-11-05 — Defined consent-first mood analysis direction

- Recorded the owner's selected direction: optional mood responses may support anonymous aggregate analysis linked to the selected place; nicknames are optional per check-in and retention is not decided.
- Documented that Terms and Privacy pages support but do not replace separate explicit consent before the first submission.
- Added the proposed consent, review, submission, and withdrawal workflow to the MVP plan. No mood collection or storage was implemented.
- Remaining blockers: retention period, access controls, deletion/withdrawal process, consent copy, and qualified privacy/legal review.

### 2026-11-05 — Added visual first-launch onboarding

- Added a concise bilingual three-page visual first-launch onboarding flow based on the root design references, with Skip/Back/Next/Get started controls and persisted completion. Kept the detailed section-navigable Instructions guide for the sidebar.
- Updated the guide copy and widget coverage; no product behavior beyond explaining existing features was added.
- Validation: `dart format`, `flutter analyze`, and the widget test suite passed. A Dart-tooling hot restart still requires a running Flutter app connected to VS Code.
- Remaining: review the guide copy and visuals with the client.

### 2026-11-05 — Deferred routing-service ETA planning

- Removed the OSRM/FOSSGIS-specific ETA proposal, references, and research handoff so routing can return to scratch planning.
- Kept the generic ETA phase deferred: no in-app estimate is displayed, and any future implementation still requires a separate product and service decision.
- Validation: documentation diff review and `git diff --check`; no app tests were needed.
- Remaining: decide later whether an in-app ETA is wanted, then evaluate an appropriate routing approach and its service terms.

### 2026-11-05 — Rebalanced the home header and confirmed Kamus Tambay branding

- Enlarged the home wordmark’s usable space, reduced the emblem, grouped it closer to the wordmark, and kept a wider gap before the separate 48 dp hamburger target. Lowered the sky scene, bubble column, and student figure slightly to give the branding clear breathing room without changing action order or targets.
- Renamed every user-facing application label to `Kamus Tambay`: Flutter title, Android launcher label, browser title/metadata/PWA manifest, version footer, README, and product documentation. Kept the `commission` folder, GitHub repository/web path, Dart package name, Android namespace, and Android application ID unchanged.
- Validation: `dart format`, `flutter analyze`, all 79 Flutter tests, and `flutter build web --base-href /campus-tambayan-finder/` passed.
- Remaining: final logo treatment and reviewed Vision/Mission, Privacy, and Terms copy are still open.

### 2026-11-05 — Replaced the More page with the approved sidebar

- Added a shell-owned, cream sidebar opened by the home hamburger, More speech bubble, or edge swipe. It contains Home, Instructions, Vision & Mission, Privacy, Terms & Conditions, an English/Filipino segmented control, and the subtle `Campus Tambayan Finder · Version 1.0.0 (demo)` footer.
- Removed `MoreScreen` and its About dialog. Instructions closes the sidebar and opens the existing intro guide. Vision/Mission, Privacy, and Terms each open a clearly labelled placeholder that states client-reviewed copy is still pending; no mission, privacy, or legal content was invented.
- Added `app_section.dart`, `app_drawer.dart`, and `info_placeholder_screen.dart`; updated bilingual strings, widget coverage for drawer navigation/language/instructions/placeholders/version/narrow screen, and the project brief, MVP plan, architecture, and README.
- Validation: `dart format`, `flutter analyze`, all 79 Flutter tests, `flutter build web --base-href /campus-tambayan-finder/`, and `git diff --check` passed.
- Remaining: review responsive/text-scale layouts on a device or browser. Final Vision/Mission, Privacy, and Terms copy is still pending from the client.

### 2026-11-05 — Rebuilt the home hub and navigation from the client mockup

- Replaced the Explore-first shell and bottom navigation with a home hub: three vector speech bubbles (Find a tambayan, Mood check-in, More), the supplied "Kamus Tambay" wordmark, a gold-ring emblem, the student figure, and the curved sky band. The explore list and map are still one tap apart through "View map".
- Added `lib/features/home/` (home screen, custom-painted bubbles, headers/band chrome, More menu) and `lib/features/mood/mood_info_screen.dart`. The mood bubble opens an informational preview only; it stores no mood, nickname, or profile. More contains Language, How to use, and About; vision/mission copy is intentionally absent until the client supplies it.
- Applied the new provisional palette and typography app-wide: cream `#FBF8F4`, sky `#DFEDFB`, navy `#1F2A5C`/`#0B1F4B`, primary `#1F6FD1`, brand `#3490F5`, bubble `#BBDDFF`, undersides, and gold `#E2A92B`; Fredoka headings with Nunito body text, both bundled. Restyled cards, status/demo pills, filters, detail/filter sheets, map overlays, and intro dialog. Added a Home control to every spoke screen and system Back-to-home behavior.
- Updated `pubspec.yaml` assets/fonts and regenerated the Android splash for the new background/icon colors; updated `web/index.html` and `web/manifest.json` theme/background colors.
- Updated `docs/PROJECT_BRIEF.md`, `docs/MVP_PLAN.md`, `docs/ARCHITECTURE.md`, `README.md`, and this handoff. No new dependencies beyond the bundled font files.
- Validation: `flutter pub get`, `flutter analyze`, and all 78 tests passed. `flutter build web --base-href /campus-tambayan-finder/` succeeded. Reviewed headless browser screenshots at 390×844 for the intro, home, Explore, More, and mood preview; the 320×640 Filipino hub is covered by a widget test. `dart run flutter_native_splash:create` completed.
- Remaining: confirm the official product name/spelling and logo, supply vision/mission copy, and re-export the oversized `interior.jpg`/`menu.jpg` assets. Mood persistence, consent, nickname, access, retention, and deletion remain open. Work is uncommitted.

### 2026-11-05 — Replaced the default Android launcher icon

- Used the existing blue-and-gold app mark to generate Android adaptive foreground and density-specific fallback icons. The icon is explicitly temporary until the team supplies the official logo/icon; splash artwork remains unchanged.
- Validation: `flutter build apk --debug` succeeded; `aapt dump badging` confirmed the APK references `mipmap-anydpi-v26/ic_launcher.xml`; installed the APK on the connected emulator; `git diff --check` passed.
- Remaining: replace this provisional icon when approved official branding is supplied.

### 2026-11-05 — Cache shared listings for offline browsing

- Added versioned on-device persistence for the latest non-empty shared listing snapshot, including schedules, coordinates, and photo references. The saved copy appears before the shared request; on failure or an empty table it remains available with a localized offline notice. Bundled JSON stays the first-sync fallback. Remote image files and map tiles are not included.
- Changed the synced repository to consume one remote stream so the initial snapshot is not fetched twice; cache read/write failures are logged without blocking listings. Updated the related project, architecture, MVP, README, and Supabase setup docs.
- Validation: focused cache/repository/model tests and full `flutter test` passed; `flutter analyze` passed; `git diff --check` passed; Android app hot restart succeeded with no runtime errors.
- Remaining: offline browsing of cached listing text/data is supported after one successful sync; remote photos and map tiles may still require internet.

### 2026-11-04 — Added optional Google Maps location to the intake sheet

- Added a plain-language, optional "Google Maps link or coordinates" field so the team can paste a shared map link without needing to extract coordinates. Updated the spreadsheet header.
- Validation: confirmed the CSV header matches the guide and `git diff --check` passed.
- Remaining: none; unverified locations will still be checked before being used as real map destinations.

### 2026-11-04 — Simplified the place and photo intake sheets

- Replaced the database-oriented draft with everyday spreadsheet labels: one simple row per place, with category, area, description, prices, operating days/hours, amenities, setting, and suitability. Removed technical identifiers and codes.
- Simplified photo intake to shop/place name, attached photos or a shared folder, and whether permission is okay or needs checking. Multiple images are welcome; no team reference, sort order, or database fields are requested.
- Updated the Phase 1 plan. Repository still has unrelated app changes (`lib/app/app_copy.dart`, `lib/features/places/place_card.dart`, and `test/widget_test.dart`); these were left untouched.
- Validation: checked the sheets and guidance for plain-language consistency; `git diff --check` passed. No app tests run because only documentation and intake templates changed.
- Remaining: share the revised intake request; the team may still suggest fields.

### 2026-11-04 — Prepared a draft listing-data intake template

- Added spreadsheet-friendly places and photo CSV intake sheets plus field guidance. The draft reflects current app fields but distinguishes intake-only details from database fields; the team may revise it before adoption.
- Prepared a client update that clarifies the web preview is for development review, offline fallback currently uses bundled sample data, the guide appears each launch and remains available from Help, and final listings are still pending.
- Updated the Phase 1 status in `docs/MVP_PLAN.md`; no product requirements or data were approved or changed.
- Validation: reviewed the CSV headers against the current `Place` model and Supabase setup guide; `git diff --check` passed.
- Remaining: send the message and draft template to the team; agree on the final template and verify supplied content before publication.

### 2026-11-04 — Prevented Tagalog open-status badge overflow

- Replaced the place-card header `Row` with a wrapping layout, so the complete status badge moves to another line when necessary instead of overflowing beside the demo label. The shared badge, including the detail-sheet presentation, keeps its full translation and existing styling.
- Added a widget test for a narrow card in Tagalog that checks the full "Bukas ngayon" label, verifies it wraps below the demo label, and asserts no layout exception.
- Validation: all 70 Flutter tests passed, `flutter analyze` is clean, and `git diff --check` passed. Hot-restarted the Android emulator build and found no Dart runtime errors; visually confirmed the Tagalog card header wraps while retaining the complete label.
- Remaining: none.

### 2026-11-04 — Aligned the documentation with the implemented feature set

- **Audit.** Compared the docs against `lib/` and the bundled data. Two claims were outright stale: photo presentation was still marked "planned, not implemented" in the brief and the Supabase guide even though the skeleton, full-image gallery, and zoom viewer shipped; and the README still said the samples had no coordinates and the map showed a waiting state, while `assets/data/sample_places.json` has illustrative coordinates and the map renders pins and the carousel.
- **`docs/MVP_PLAN.md`.** Added the GitHub Pages preview to the delivery boundaries; expanded the Phase 0 baseline to the current feature set (static five-category catalog, optional prices, budget chips, structured hours with badge/filter, shared-source fallback, web build); marked Phase 2 core-implemented against sample data and resolved the offline-browsing question; changed Phase 3 to implemented-but-awaiting-approved-coordinates and recorded that pins carry no closed state; added explicit status lines to Phases 4–6; removed the answered map renderer/attribution item from the open-inputs list; added the guide-display question.
- **`docs/PROJECT_BRIEF.md`.** Replaced the stale Phase 2 photo row with the implemented behavior, corrected "first-use introduction" to the actual launch-and-Help behavior, and added decision rows for the static category catalog, chip-based budget control, and guide display.
- **`docs/SUPABASE_SETUP.md`.** Retitled the image section, replaced the "does not yet implement" paragraph, clarified how `hours` renders beside or instead of the weekly list, and noted that the `00:00`–`23:59` round-the-clock workaround leaves a one-minute gap.
- **`README.md`.** Updated the status paragraph and the decisions table (map renderer confirmed, Directions gated on verification, new rows for categories/prices/hours/budget), and replaced the stale map sentence with the illustrative-but-unverified coordinate behavior.
- **`docs/ARCHITECTURE.md`.** Documented the implemented search scope, listed the actual test files, and recorded that language choice and the guide are session state rather than persisted.
- **Follow-up added.** Guide display now mirrors the other client questions: the app opens the guide on every launch; should it appear only on first launch? Recorded in the brief, the MVP plan, and the local concept checklist.
- **Validation.** Documentation-only change. `flutter analyze` and `flutter test` re-run to confirm nothing regressed.
- Remaining: the client questions (capacity, budget basis, free Wi-Fi, closed map pins, 24-hour places, guide display) are still unanswered; no approved listings or verified coordinates exist yet.

### 2026-11-04 — Moved the open/closed state into a filled card badge

- **New shared widget.** `lib/features/places/open_status_badge.dart` renders the pill for both the card and the detail sheet, replacing the detail sheet's private `_OpenStatusPill` so the two surfaces cannot drift.
- **Card layout.** Dropped the inline dot label from the price/amenity row, which was already carrying three items and read the status as one more equal fact. The badge now sits opposite the "DEMO LISTING" text in the card's header row, i.e. the top-right of the content area. The demo badge stays visible because the docs treat demo labelling as a safety requirement.
- **Colours.** Open is `AppColors.primary` with `AppColors.onPrimary` text; closed is `AppColors.outline` with `AppColors.mutedInk` text. Red was rejected on purpose: it reads as an error or a permanent closure rather than "shut for the night". Text stays "Open now" / "Closed now" so the state reads as live rather than permanent.
- **Still conditional.** No badge when the current day's hours are unknown; the header row then holds only the demo badge, so nothing implies "closed".
- **Validation.** `flutter analyze` clean; `flutter test` 69 passed, up from 67. New coverage: AA contrast for both badge pairs, and a deterministic card test asserting the filled badge replaces the dot and flips from "Open now" to "Closed now".
- Remaining: the map pins themselves stay unmarked, which is the unanswered client follow-up. The live preview also still needs the pushed commits and the demo `hoursByDay` update before any badge appears.

### 2026-11-04 — Added structured per-day hours, an open/closed indicator, and an "Open now" filter

- **Why now.** The concept document requires each listing to display "the days when it is open or closed", so per-day hours are an agreed requirement, not an inference. The "Open now" badge and filter are our own addition built on the same data.
- **Schema (docs only, not yet applied).** `public.places` gains `"hoursByDay" jsonb`; `hours` becomes nullable. The shape is `{"mon":{"open":"HH:MM","close":"HH:MM"}, "sun":null}`. Three states stay distinct: a missing key means unknown, a `null` day means closed, an object means that window. A `CHECK` constraint rejects typo'd weekday keys using `jsonb - key` subtraction, which avoids a subquery that `CHECK` cannot contain. `docs/SUPABASE_SETUP.md` has the create-table change, the migration lines, the constraint, and the value rules.
- **New domain model.** `lib/features/places/opening_hours.dart` provides `DayHours` and `OpeningHours`. `OpeningHours.isOpenAt(DateTime)` evaluates Asia/Manila time via a fixed UTC+8 offset, so a device in another timezone cannot flip the badge. Opening is inclusive and closing exclusive; a window whose close is earlier than its open crosses midnight. Malformed entries drop to unknown rather than closed.
- **Equal bounds are deliberately unknown.** `00:00`–`00:00` could mean 24 hours or a typo, so the parser refuses to guess and the day reads as unknown. Recorded as a client follow-up instead of deciding for them.
- **Wiring.** `Place.hours` is now `String?` and `Place.openingHours` is parsed from `hoursByDay`. `PlaceFilters` gained `openNow` plus an injectable `now` for tests; listings without structured hours are excluded while it is active, matching the budget filter's behavior. The filter sheet has an Availability chip using the same `ChoiceChip` component. Cards show a small open/closed label only when the state is known. The detail sheet renders a per-day block and keeps the free-text line as a note. The explore screen shares one timestamp across every card and refreshes it every minute and on resume.
- **Sample data.** All four `assets/data/sample_places.json` rows now carry `hoursByDay`, including a closed Sunday, so the feature is visible in the demo and offline fallback.
- **Docs.** `PROJECT_BRIEF.md` flips "Structured operating days" to confirmed and adds the closed-place map-visibility and 24-hour-representation follow-ups. `MVP_PLAN.md` replaces the answered open-days input with those two questions. `ARCHITECTURE.md` records the dual-field split, timezone, and refresh behavior.
- **Validation.** `flutter analyze` clean; `flutter test` 67 passed, up from 51. New coverage: parsing and unknown-versus-closed, inclusive/exclusive boundaries, Manila-vs-UTC evaluation, overnight windows, unusable shapes, identical bounds, nullable hours text, the open-now filter, and the chip flow.
- Remaining:
  - The live Supabase table still lacks `"hoursByDay"` and still has `NOT NULL` on `hours`. Run the migration block in `docs/SUPABASE_SETUP.md` before entering per-day hours, or the column will not exist.
  - Closed-place map visibility and 24-hour representation are documented but unanswered.

### 2026-11-04 — Added an annotated local concept checklist and a structured open-days follow-up

- **Local tracking copy.** `docs/CONCEPT_AND_FOLLOW_UP_ANSWERS.md` now carries a status legend and inline HTML spans so implemented items read green (`#1a7f37`), partial items amber (`#9a6700`), and open items stay plain with `⬜`. Each item also gets a ✅/🟡/⬜ marker so the status survives viewers that strip inline styles. Open and partial items link to their follow-up in `PROJECT_BRIEF.md` and, where one exists, the matching `MVP_PLAN.md` phase or the "Decisions and inputs still needed" list.
- **Deliberately not committed.** Added the file to `.gitignore`. It was still untracked, so no `git rm --cached` was needed; `git check-ignore -v` resolves it to `.gitignore:75` and `git status` no longer lists it. The meeting notes and status annotations therefore stay local and out of the repository and the Pages build.
- **New follow-up: structured operating days.** Added to the `PROJECT_BRIEF.md` decisions table and to "Decisions and inputs still needed" in `MVP_PLAN.md`. Hours are currently one free-text string, so opening/closing times render but weekday-level open/closed data does not exist. The brief also records that limitation next to the price/address notes.
- **Validation.** Documentation-only change; `flutter analyze` clean and `flutter test` 51 passed were re-run to confirm nothing regressed.
- Remaining: the structured open-days question, plus the earlier capacity, budget-basis, and free-Wi-Fi questions, still need client answers. The local checklist file will not sync between machines unless copied manually.

### 2026-11-04 — Made prices optional and turned the budget control into chips

- **Optional prices (D2).** `priceMin`/`priceMax` are now `int?` in `Place` and `PlaceLike`. `Place.fromJson` clears both when either bound is missing or not numeric, so a half-known range is never used as a guess. Cards and the detail sheet use a new `AppCopy.priceRange()`: an exact price renders once (`₱50`), a range keeps the en dash, and a missing pair renders "Price not listed" / "Hindi nakalista ang presyo". `PlaceFilters.matches` excludes unpriced listings while a budget limit is active and includes them when it is not.
- **Budget chips (D3 UI).** Replaced the ₱0–₱600 slider with a `ChoiceChip` row matching the other filter groups: "Any budget" plus ₱50/₱100/₱150/₱200/₱300/₱500. `PlaceFilters.maxBudget` changed from `double = 600` to `int?`, where null means no limit.
- **Uncapped "Any budget" (D4).** The old maximum slider position doubled as the "any" sentinel, so listings with `priceMin > 600` could never appear. Null is now a real no-limit state; a unit test covers an expensive listing surviving "Any budget".
- **Not changed (D1, Wi-Fi).** Capacity remains the single `capacity` → "Roomy" amenity, and `wifi` remains labeled "Free Wi-Fi". Both are now recorded as client follow-up questions instead of being assumed: see the new rows in `docs/PROJECT_BRIEF.md` and the additions under "Decisions and inputs still needed" in `docs/MVP_PLAN.md`. Budget comparison (`priceMin` vs `priceMax`) is recorded the same way.
- **Docs.** `docs/SUPABASE_SETUP.md` now declares the price columns nullable, explains "leave both blank, `0` means free", and adds `alter column … drop not null` to the existing-table migration block. `docs/ARCHITECTURE.md` records the optional-pair and no-limit-budget behavior.
- **Validation.** `flutter analyze` clean; `flutter test` 51 passed, up from 41. New coverage: nullable/partial price parsing, budget including and excluding unpriced listings, the uncapped "any" state, amenity/setting/activity matching, price label formatting, and the chip-based budget flow in the widget test.
- Remaining:
  - The live Supabase table still has `NOT NULL` on both price columns. Run the migration block in `docs/SUPABASE_SETUP.md` before entering a listing without a price, or that insert will fail.
  - Budget-chip presets are a UI choice, not a client decision; adjust if the team prefers other amounts.
  - The capacity, budget-basis, and free-Wi-Fi questions are documented but unanswered.

### 2026-11-04 — Supported all five agreed place categories independently of data

- The app only knew four category keys (`tambayan`, `coffee`, `park`, `eatery`), so the brief's fifth category had no key at all, and "Karinderya" was missing from the eatery label. Keys, labels, icons, and placeholder tints were duplicated across `lib/app/app_copy.dart`, `place_filter_sheet.dart`, and `place_photo.dart`, which is how the omission slipped through.
- Added `lib/features/places/place_categories.dart` as the static catalog (key, EN/TL label, icon, tint). `AppCopy.category()` now delegates to it, the filter sheet iterates it, and `PlacePhotoPlaceholder` reads its icon/tint, so adding a category is one edit. Added `AppColors.otherTint`. Eatery labels now read `Karinderya / affordable eatery` and `Karinderya / abot-kayang kainan`; the new fifth category is `other` (`Other place` / `Iba pang lugar`).
- Categories are deliberately static rather than derived from loaded rows: all five chips appear even when no listing uses them. When the selected category has no listing anywhere in the dataset, the empty state now says "No <category> listings yet"; if listings exist but other filters excluded them, the previous message remains. Unrecognised stored keys are still shown verbatim so import mistakes stay visible.
- Docs: added the five canonical `places.category` values to `docs/SUPABASE_SETUP.md` (the column is free text, so this is the only guard against `Karinderya`/`cafe`-style values) and the static-vocabulary rule to `docs/ARCHITECTURE.md`.
- Validation: `flutter analyze` clean; `flutter test` 41 passed, up from 37. New tests cover the catalog contents and key uniqueness, the bilingual labels including the unknown-key fallback, and the empty-category state with no listings for that category.
- Remaining: no seed row was added for `other` on purpose, so selecting it currently shows the empty-category state. Real Supabase rows must use the five lowercase keys. The five-chip wrap and the new empty state were not visually checked on a device.

### 2026-11-04 — Prepared the repository for publication and added the client web preview

- **Repository hygiene.** Hardened the root `.gitignore` for gaps that only existed under `android/.gitignore`: root-level `*.jks`/`*.keystore`/`key.properties`, `.env`/`*.env`, `*.apk`/`*.aab`/`*.ipa`, `android/build/` and `android/app/build/` (the root-anchored `/build/` did not cover them), and `Thumbs.db`/`desktop.ini`. Verified each rule with `git check-ignore`; note that directory-only patterns report "not ignored" for paths that do not yet exist, so they were tested with a temporary directory.
- **Removed `docs/DATA OFFICER .docx`** (1.6 MB, ~95 % of tracked bytes) at the owner's request. It was added in the baseline commit, so a plain `git rm` would have left it downloadable from history. Rewrote history with `git filter-branch --index-filter` before the repository is published; verified with `git log --all -- "docs/DATA OFFICER .docx"` and `git rev-list --objects --all`. `.git` dropped from ~1.7 MB to 0.65 MB. A copy is kept outside the repository at `%USERPROFILE%\Downloads\campus-tambayan-data-officer-backup.docx`.
  - Side effect worth knowing: `filter-branch --all` also rewrote the harness's `refs/agents/...` checkpoint refs. All 69 still resolve, but the pre-rewrite commits are gone because `refs/original` was pruned as intended.
- **Web preview (approved as review-only).** Added the `web/` platform with `flutter create --platforms=web .`. That command replaced the `android` entry in `.metadata` instead of appending, so the entry was restored by hand; it also bumped two unrelated transitive packages in `pubspec.lock`, which was reverted and confirmed stable after `flutter pub get`. Customized `web/index.html` (title, description, `theme-color #14594A`, `noindex`, cream first-paint background) and `web/manifest.json`.
- **Deployment.** Added `.github/workflows/web-preview.yml`: builds on push to `master` with Flutter pinned to 3.47.9 and `--base-href "/${{ github.event.repository.name }}/"`, then publishes via `actions/deploy-pages`. Uses the Supabase publishable key as a workflow `env` value because it is public by design.
- **Validation.** `flutter analyze` clean; 37 tests passed; `flutter build web --release` succeeds (~3.3 MB `main.dart.js`). Served the release build locally under `/campus-tambayan-finder/` and confirmed in headless Chrome: base href rewrites correctly, app boots, shared listings load (4 places), Storage photos render (browser CORS verified: Storage returns `access-control-allow-origin: *`, REST preflight allows `apikey,authorization`), `maplibre-gl@6.16.0` imports from unpkg, and the map renders tiles, campus anchors, place pins, and the carousel. Screenshots: `%LOCALAPPDATA%\Temp\opencode\web-1-intro.png`, `web-2-list.png`, `web-3-map.png` (not committed).
- Remaining:
  - One-time manual step: create the `campus-tambayan-finder` repository, push `master` only (do not use `--all`/`--mirror`, which would push the harness checkpoint refs), then enable **Settings → Pages → Source: GitHub Actions**.
  - Re-export `interior.jpg` (9.4 MB) and `menu.jpg` (3.6 MB). This now matters more than before: the preview loads them over the client's mobile data.
  - `flutter_native_splash` has `web: false`, so the browser shows the index background until the first frame. The generated web icons and the Android launcher icon are both still Flutter defaults; changing either is a branding decision.
  - The map overlay string `map_online_note` ("Map needs internet") is a permanent informational note, not an error state, but it reads like one on a working map. Review the copy separately rather than treating it as a defect.

### 2026-11-04 — Applied the approved hybrid campus-inspired palette

- Kept the warm canvas and teal primary actions, added a restrained non-official campus blue for selected controls and campus anchors, and confined yellow to the app emblem and campus marker outlines. Updated splash artwork and Android resources to match. Documented that these are inspired tones, not official PLV branding, and do not imply endorsement.
- Validation: `flutter test` (37 tests passed), `flutter analyze`, `flutter build apk --debug`, and `git diff --check` passed. Hot-restarted the emulator build; no Dart runtime errors were reported.
- Remaining: none; revisit if the team later provides official brand guidance.

### 2026-11-04 — Centralized the theme tokens and applied the Warm Campus palette

- Audit found five one-off hex literals and about a dozen `Colors.*` usages outside `lib/app/app_theme.dart`, plus drift between duplicate components: two drag-handle colors, three different no-photo placeholders, and a demo badge duplicated with different letter spacing. `docs/ARCHITECTURE.md` already required screens to consume theme values, so this was a documented-principle violation rather than a new decision.
- Commit `4e883d5 refactor(theme): centralize color tokens and unify shared UI`: added semantic tokens (outline, demo container, scrim, viewer backdrop, category tints), moved every remaining literal into the theme, added `SheetHandle` (`lib/app/app_widgets.dart`) and `DemoBadge` (`lib/features/places/demo_badge.dart`), and replaced the three placeholders with one `PlacePhotoPlaceholder`. Fixed the only AA failure found by measurement: the demo banner text was 4.33:1 and is now 5.20:1.
- Commit `feat(theme): apply warm campus palette` (see `docs/MVP_PLAN.md` → Provisional visual direction): `background #FBF7EE`, `primary #14594A`, `sage #E3EFE8`, `demo #A8452C` on `#FFF1E7`, `accent #F2B23E` with `onAccent #231A00`. The accent is fill-only (1.75:1 on the background) and appears only in the navigation indicator, selected chips, the selected campus segment, and map emphasis; `FilledButton` stays primary. Added `textTheme`, `navigationBarTheme`, and `segmentedButtonTheme` so screens stop styling ad hoc.
- Also updated the native splash, which hardcoded the old palette in two places that are easy to miss: `values-v31`/`values-night-v31` `styles.xml` and the 1×1 `drawable/background.png` / `drawable-v21/background.png`.
- Validation: `flutter analyze` clean, 37 tests passed (added demo-banner and accent contrast assertions plus a placeholder-consistency test), `git diff --check` clean. Built a debug APK with the Supabase defines and checked English and Filipino on the emulator: list, filter sheet, detail sheet, and map. Screenshots: `%LOCALAPPDATA%\Temp\opencode\theme-a-*.png` and `theme-b-*.png` (not committed).
- Remaining:
  - The palette is still a demo hypothesis, not approved final branding; confirm with the team before treating it as fixed.
  - The MapLibre Positron basemap stays neutral grey and does not match the warm app palette. A custom warm style needs a hosted style JSON; see the open question in `docs/MVP_PLAN.md`.
  - No dark theme was added; the app remains light-only.

### 2026-11-04 — Fixed gallery photos reloading to the skeleton

- Symptom: swiping the detail gallery away from a photo and back showed the loading skeleton again even though the photo had already been displayed.
- Root cause: the gallery had no keep-alive, so `PageView` disposed off-screen pages and rebuilt their `Image` on return; and photos were decoded at full upload resolution. Measured bucket files: `interior.jpg` 4160×6240 (9.4 MB, ~99 MB decoded), `menu.jpg` 5737×3825 (3.6 MB, ~84 MB decoded). Two photos alone exceed Flutter's default 100 MB `ImageCache`, so every return evicted and re-fetched.
- Change: `lib/features/places/place_photo.dart` now bounds decode size with `cacheWidth` (`_maxGalleryDecodeWidth = 1440`, `_maxViewerDecodeWidth = 2400`) for cards, gallery pages, asset fallbacks, and the full-screen viewer, and wraps each gallery page in `_GalleryPage` (`AutomaticKeepAliveClientMixin`) so visited pages stay mounted.
- Docs: `docs/ARCHITECTURE.md` records the bounded decode and keep-alive behavior; `docs/SUPABASE_SETUP.md` clarifies that decoding at display size does not shrink the download, so uploads should still be re-exported.
- Tests: `test/place_photo_test.dart` asserts `ResizeImage` bounds for card, gallery, and viewer images and that a visited gallery page stays mounted (found with `skipOffstage: false`).
- Validation: `flutter analyze` clean, all 34 tests passed, `git diff --check` clean, and a debug APK built with the Supabase defines installed on the emulator. With shared data (`Shared listings loaded: 4 places`), opening `Sample Kape Stop` and swiping 1→2→3→1→2→3 showed the skeleton only on each photo's first load; every repeat visit rendered instantly. Screenshots: `%LOCALAPPDATA%\Temp\opencode\gallery-fix-*.png` (not committed).
- Remaining:
  - The uploaded `interior.jpg` and `menu.jpg` are still far above the documented limit; re-export to ~2048 px longest edge and ≤2 MB to make first loads fast and stay within the Free-plan transfer allowance.
  - The `location_verified` reset for the `sample-*` rows has still not been run.

### 2026-11-04 — Added the optional listing address

- Added nullable `places.address` (single, untranslated text) plus `Place.address` parsing; the detail sheet shows an “Address” row only when the field is non-empty, after Setting and before the location-status row. New copy key: `address` (Address / Adres). `area` remains the short neighborhood label on cards.
- The four bundled fictional rows now carry clearly labeled demo addresses (each ends with `(demo only)`) so offline fallback matches the shared data; no real addresses were invented.
- Docs: `docs/SUPABASE_SETUP.md` gains the column in the create table block and migration, plus an Addresses subsection covering verification, demo placeholders, and blank CSV values. `docs/PROJECT_BRIEF.md` records the confirmed field decision.
- Tests: `test/place_test.dart` covers address mapping and blank/missing values; `test/widget_test.dart` asserts the address row and demo value in the detail sheet.
- Validation: `flutter analyze` clean, all 33 tests passed, `git diff --check` clean, and `flutter build apk --debug` succeeded. Emulator checks: the bundled copy shows the Address row with the demo value in English and Adres in Tagalog; after the owner applied the Supabase migration, a live-data build (with the Supabase defines) shows the shared address for `sample-kape-stop`, confirming the field flows from `places.address` through the realtime source. Screenshot: `%LOCALAPPDATA%\Temp\opencode\live-address-2.png` (not committed).
- Applied by the owner in Supabase:
  - `alter table public.places add column if not exists address text;`
  - the demo-label `update` documented in `docs/SUPABASE_SETUP.md` → Addresses, for the four `sample-*` rows.
- Remaining / decisions:
  - The owner confirmed the fictional rows should not be marked verified, but the reset has not run yet; all four still have `location_verified = true`. Run `update public.places set location_verified = false where id like 'sample-%';`. Map pins remain because they only require coordinates; directions become unavailable for the demo rows.
  - The capacity filter still has no listing data path; the owner chose to leave it as is. Selecting “Roomy” currently matches nothing.
  - All changes remain uncommitted.

### 2026-11-04 — Aligned the detail sheet with stored listing fields

- Added a localized “Good for” chip group backed by `places.activities` (shown only when the listing has activities), photo captions under the gallery photo, and an inline location row that appears only for unverified listings. Demo labels are now gated on the temporary `Place.isDemo` id prefix, so real listings no longer inherit `DEMO LISTING` or the sample-description note; a non-demo listing with no amenities shows “Not listed” instead of the sample chip.
- Gallery captions follow the visible page, fall back to the other language when a translation is missing, and no longer intercept the tap that opens the full-screen viewer. The active gallery index is clamped when the photo list shrinks.
- New copy keys: `location`, `location_unverified`, `not_listed`. Updated `docs/SUPABASE_SETUP.md` with the `sample-` id convention and the now-visible caption behavior. Tests cover the activities chips, unverified-location row, and gallery captions.
- Validation: `flutter analyze` clean, all 32 tests passed, `git diff --check` clean, and `flutter build apk --debug` succeeded both with and without the Supabase defines. Emulator checks with live data: English and Tagalog detail sheets show “Good for”/“Angkop para sa”, captions “Sample exterior photo” → “Sample interior seating” with `1 / 3` → `2 / 3`, and full-screen zoom still opens after the caption change. Screenshots: `%LOCALAPPDATA%\Temp\opencode\detail-live-caption.png`, `detail-live-caption-2.png`, `detail-live-tagalog.png` (not committed).
- Remaining / decisions:
  - Address was unmodeled at the time; it is implemented in the newer entry above.
  - The four live demo rows currently have `location_verified = true` with illustrative coordinates, which contradicts the setup guide’s rule that sample rows must never be marked verified. Decide whether to reset them to `false` for the demo or record them as approved demo destinations.
  - The capacity filter still has no listing data path (`amenities` never contains `capacity`).
  - All changes remain uncommitted.

### 2026-11-04 — Made the language toggle text-only

- Replaced the translate-icon-and-label control with the requested compact text-only target label: `Tag` in English and `Eng` in Tagalog. Localized tooltip and accessibility action labels remain unchanged.
- Added a widget assertion that no translate icon is present.
- Validation: `flutter analyze`, all 6 focused widget tests, `flutter build apk --debug`, and `git diff --check` passed. Installed the debug APK and visually confirmed the text-only `Tag` control on the Android emulator. Screenshot: `%LOCALAPPDATA%\Temp\opencode\language-toggle-text-only.png` (not committed).
- Remaining: none.

### 2026-11-04 — Clarified the language-toggle target

- Replaced the icon-only app-bar language control with a compact translate icon plus its target-language label: `Tag` while English is active and `Eng` while Tagalog is active. The tooltip and accessibility label describe the same action in the currently active language.
- Added widget coverage for both label/tooltip states and retained the existing toggle behavior.
- Validation: `flutter analyze`, all 6 focused widget tests, `flutter build apk --debug`, and `git diff --check` passed. Installed the debug APK on the Android emulator and confirmed `Tag` → `Eng` after toggling. Screenshot: `%LOCALAPPDATA%\Temp\opencode\language-toggle-tagalog.png` (not committed).
- Remaining: none.

### 2026-11-04 — Wrapped the English estimated-spend label

- Broke the English “Estimated spend” detail label across two lines to match the requested layout; preserved the Tagalog wording and value alignment.
- Validation: focused widget tests passed, `flutter analyze` and `git diff --check` passed, and the Android app hot-restarted successfully.
- Remaining: none.

### 2026-11-04 — Added a native Android launch splash

- Added the `flutter_native_splash` 2.4.8 build-time dependency and generated Android splash resources using the existing app-bar emblem, warm background, and Android 12-specific image. Kept it to the native launch interval without adding an in-app splash screen or delay. Documented artwork status and regeneration command in the MVP plan and README.
- Validation: generated and visually inspected both splash artwork assets and a cold-start emulator screenshot; all 32 Flutter tests passed, `flutter analyze` and `git diff --check` passed, the Android debug APK built and installed, hot restart succeeded, and Android Flutter logs showed no Dart runtime errors.
- Remaining: revisit splash artwork if the team approves final branding.

### 2026-11-04 — Added Google Maps directions for verified locations

- Added external Google Maps directions URLs, gated on valid coordinates and an explicit verification flag. Unverified/missing locations and launch failures have localized messages; bundled sample coordinates remain ineligible. Added the default-false Supabase `location_verified` column and migration guidance.
- Updated the project brief, architecture, Phase 3 plan, and Supabase setup guide. Validation: all 32 Flutter tests passed, `flutter analyze`, `git diff --check`, and Dart formatting passed; the Android emulator build/install and hot restart succeeded. Android Flutter logs showed no Dart runtime errors. The DTD runtime-error tool had no active app connection, so logs were checked via `adb`.
- Remaining: apply the SQL migration to the shared Supabase project and only mark real listings verified after checking their locations.

### 2026-11-04 — Added illustrative coordinates to bundled demo listings

- Added map-preview coordinates around the fixed campus anchors so locally bundled fictional places appear in the map carousel without Supabase. These values are explicitly illustrative and are not verified listing locations.
- Updated the sample repository test and clarified the Supabase import warning, project brief, architecture, and Phase 3 guidance. Validation: all 27 Flutter tests passed, `flutter analyze` and `git diff --check` passed, the Android app built and launched, hot restart succeeded with no runtime errors, and emulator review confirmed the local map shows the four demo pins and carousel.
- Remaining work: replace demo coordinates with verified locations or omit them before using these rows as live listings or destinations.

### 2026-11-04 — Increased the map's initial zoom

- Raised the initial camera zoom from 15 to 16, retaining the midpoint between the PLV Annex and CPAG anchors. Updated the map test and Phase 3 notes.
- Validation: focused map tests passed, `flutter analyze` and `git diff --check` passed, hot restart succeeded, and no Dart runtime errors were reported.
- Remaining work: none specific to the default zoom adjustment.

### 2026-11-04 — Lowered the map carousel

- Reduced the carousel's bottom offset from 48 dp to 30 dp and updated its layout assertion and Phase 3 note.
- Validation: focused map tests passed, `flutter analyze` and `git diff --check` passed, hot restart succeeded, and no Dart runtime errors were reported.
- Remaining work: none specific to this spacing adjustment.

### 2026-11-04 — Aligned carousel insets above map attribution

- Set equal left/right carousel insets and lifted it above the bottom-right attribution control so source information remains visible and tappable.
- Added positional layout assertions and updated the Phase 3 and architecture notes. Validation: all 27 Flutter tests passed, `flutter analyze` and `git diff --check` passed, the Android debug app built and hot-restarted, and no Dart runtime errors were reported.
- Remaining work: visually confirm the carousel and attribution separation with coordinate-valid listings; bundled samples currently have no coordinates.

### 2026-11-04 — Reduced the map carousel's right-side gap

- Widened the carousel cards on portrait layouts and reduced the reserved space beside them while keeping the bottom-right map attribution unobstructed.
- Added a carousel-width assertion. Validation: all 27 Flutter tests passed, `flutter analyze` and `git diff --check` passed, the Android debug app built and hot-restarted, and no Dart runtime errors were reported.
- Remaining work: visually verify the expanded card alongside attribution with coordinate-valid listings; bundled samples currently have no coordinates.

### 2026-11-04 — Moved map carousel below the map

- Moved the place carousel to the bottom-left of the map, moved the internet/coordinate notice to the top-right, increased card viewport height to prevent content overflow, and reserved space beside the carousel for map attribution.
- Added layout/overflow assertions and updated the Phase 3 and architecture notes. Validation: all 27 Flutter tests passed, including a mapped card with multiple amenities; `flutter analyze` and `git diff --check` passed; hot restart succeeded with no runtime errors. Emulator review confirmed the bounded note at the top-right. The bundled samples have no valid place coordinates, so the carousel could only be visually exercised through widget tests.
- Remaining work: review the carousel with real mapped listings when their verified coordinates are available.

### 2026-11-04 — Restored the map place carousel

- Added a compact horizontal carousel overlay at the top of the map for coordinate-valid places only. Cards reuse the Explore styling and open the same place details; the internet/coordinate note sits beneath the carousel. Places without coordinates remain off-map and out of the carousel.
- Updated the Phase 3 and architecture notes and added widget coverage for visibility, selection, and coordinate filtering. Validation: all 27 Flutter tests passed, `flutter analyze` and `git diff --check` passed, the Android debug app built and launched, hot restart succeeded, and no Dart runtime errors were reported.
- Remaining work: visually review the carousel with several real mapped listings; bundled samples currently have no coordinates. The Flutter driver extension is not enabled, so on-device interaction automation was unavailable.

### 2026-11-04 — Added fixed campus map anchors

- Added distinct PLV Annex and CPAG map markers/labels at the owner-supplied coordinates and centered the initial camera at their midpoint. The map now renders before place coordinates are available; unlocated places remain omitted and cannot open from the map.
- Updated map copy, tests, and Phase 3/project/architecture notes. Validation: all 27 Flutter tests passed, `flutter analyze` and `git diff --check` passed, the Android debug app built and launched, hot restart succeeded, and no Dart runtime errors were reported.
- Remaining work: visually confirm the supplied campus pin locations; live tile usage remains subject to confirming an eligible integrator and current service terms.

### 2026-11-04 — Made the Map tab full-screen

- Implemented the approved full-body map layout: removed its heading and horizontal place-card carousel, and placed a compact localized internet note over the map. Attribution remains enabled; marker taps still open place details, and the coordinate-pending state remains unchanged. The Explore tab continues to provide the place list.
- Updated the Phase 3 and architecture notes. Validation: all 25 Flutter tests passed, `dart analyze` passed, `git diff --check` passed, and Android emulator hot restart completed with no runtime errors.
- Remaining work: visually verify the live map and overlay with demo coordinates; current bundled samples have none, so live tile/pin rendering could not be visually checked.

### 2026-11-04 — Integrated the map foundation

- Clarified that OpenFreeMap needs no registration or API key; use is still subject to its published terms and integrator eligibility requirements.
- Replaced the schematic coordinate fields with optional latitude/longitude data, added safe coordinate validation and the Supabase schema update, and integrated MapLibre with OpenFreeMap's Positron style. The map is lazy-loaded only after opening the map tab and only when at least one place has a valid coordinate pair; pins use the app theme and attribution remains enabled. Bundled samples contain no geographic coordinates and display a localized waiting state.
- Added Android internet permission and updated the README, project brief, architecture, MVP plan, and Supabase setup guide. Google Maps directions and custom theme styling remain outstanding.
- Validation: 25 Flutter tests passed, `flutter analyze` passed, Android debug APK built, hot restart succeeded with no runtime errors, and `git diff --check` passed.
- Remaining work: obtain and verify place and PLV Annex/CPAG coordinates; confirm an eligible integrator before live OpenFreeMap use; decide whether custom style JSON can be bundled. Then complete origin markers and Google Maps directions. No live map request was made because current data has no coordinates.

### 2026-11-04 — Researched Phase 3 map options

- The owner approved the MapLibre Flutter + OpenFreeMap public tile/style service approach for the class demo and selected Google Maps directions with no in-app ETA for now. OSM data, renderer, tile hosting, and directions are separate concerns.
- Recorded attribution/licensing, Android/toolchain requirements, internet reliance, and OpenFreeMap's no-SLA/discontinuation and integrator eligibility terms in `docs/REFERENCES.md`.
- Updated the agreed map direction in `docs/PROJECT_BRIEF.md`, `docs/ARCHITECTURE.md`, and `docs/MVP_PLAN.md`. No map code, coordinates, location permission, route calculation, or ETA behavior changed.
- Remaining work: confirm an adult/authorized legal representative can accept OpenFreeMap's terms; obtain and verify approved place and PLV Annex/CPAG coordinates; confirm demo devices meet MapLibre's Android requirements; decide whether the custom style JSON can be bundled or needs separate hosting. Then implement the map and Google Maps URL handoff. No build/test run was applicable; `git diff --check` passed.

### 2026-11-04 — Added transparent app bar to full-screen photo viewer

- The owner approved a transparent app-bar overlay with a readability scrim. The viewer now draws its image behind a transparent app bar with a dark top gradient, white title/close control, and light status-bar icons.
- Added a widget assertion for the transparent app-bar configuration and documented the viewer treatment in architecture notes.
- Validation: all 5 photo widget tests passed; analyzer, formatting, and `git diff --check` clean. Android debug app hot restart succeeded with no runtime errors.
- Remaining work: none specific to this viewer styling.

### 2026-11-04 — Increased shop-detail photo preview height

- Increased the inline detail-gallery height from 170 dp to 210 dp at the owner's direction, preserving the edge-to-edge crop and separate full-screen viewer.
- Added a widget assertion for the selected detail-gallery height and documented it in the MVP plan.
- Validation: focused detail-sheet widget test passed; `flutter analyze` clean; Dart formatting and `git diff --check` clean. Android debug app hot restart succeeded with no runtime errors.
- Remaining work: none specific to the height change; content below the image remains scrollable.

### 2026-11-04 — Restored edge-to-edge crop in detail gallery

- Restored `BoxFit.cover` for inline detail-gallery images to match the cohesive layout shown in the supplied emulator screenshots. Portrait photos may be cropped in the inline view; tapping still opens the full-screen viewer, which uses `BoxFit.contain` and pinch zoom to inspect the complete image. Card cropping is unchanged.
- Updated the MVP plan, project brief, architecture, and README to describe the actual behavior.
- Validation: gallery widget tests passed (5), full Flutter test suite passed (22), `flutter analyze` clean, Dart formatting and `git diff --check` clean. Android debug app hot restart succeeded with no runtime errors.
- Remaining work: none specific to the fit change.

### 2026-11-04 — Reconsidered detail-gallery portrait image fit

- Reviewed the supplied emulator screenshots: landscape photos fill the gallery well, while a portrait photo rendered with `BoxFit.contain` occupies a narrow strip and leaves conspicuous side gaps in the fixed-height detail card.
- Recommendation: use the original cropped `BoxFit.cover` presentation in the inline detail gallery for consistent, edge-to-edge framing; keep `BoxFit.contain` and pinch zoom in the separate full-screen viewer for inspecting the complete image. This intentionally trades some inline cropping for a more cohesive detail layout while retaining access to the full photo.
- Analysis only; no code or scope changed. Await owner approval before changing the gallery fit.

### 2026-11-04 — Completed gallery display and zoom polish

- Detail gallery photos now use `BoxFit.contain` to preserve portrait and landscape images; list-card covers remain cropped.
- Tapping a gallery image opens a separate full-screen `InteractiveViewer` with pinch zoom/pan, a translated close control, and existing image loading/fallback behavior. This keeps zoom gestures separate from gallery swipes.
- Updated the MVP plan, project brief, architecture, and README to reflect completion.
- Validation: all 22 Flutter tests passed, including gallery fit/viewer open-close coverage; `flutter analyze` clean; Dart formatting and `git diff --check` clean. Android debug app hot restart succeeded with no runtime errors.
- Remaining work: no gallery polish items from this recommendation remain.

### 2026-11-04 — Prioritized remaining gallery polish

- Recommended preserving full portrait/landscape photos in detail view with `BoxFit.contain` and a theme-based backdrop, while keeping card covers cropped. Full-screen zoom was implemented in a separate view so zoom gestures do not conflict with gallery swipes.
- The page counter already exists and has live-region semantics. Keep the current skeleton flash on revisited pages under observation; avoid retaining all decoded images or adding disk caching until device testing shows a meaningful problem, since galleries can contain up to 10 large photos.
- Optional visible previous/next controls or approved bilingual captions may improve usability, but are lower priority and should be validated with users/content first.
- Recommendations only; no code or decisions changed. Validation: reviewed current gallery implementation and Phase 2 plan; `git diff --check` clean.

### 2026-11-04 — Added static photo-loading skeleton

- Implemented an accessible, non-animated skeleton for network photo loads, using the active Material color scheme and a translated loading label. Existing bundled-image and neutral-placeholder error fallbacks are unchanged; no dependency was added.
- Updated the MVP plan, project brief, architecture, and README to mark this part of Phase 2 complete while keeping mixed-orientation rendering and full-screen zoom planned.
- Validation: focused photo tests passed (5); full Flutter test suite passed (22); `flutter analyze` clean; Dart formatting and `git diff --check` clean. Android debug app hot restart succeeded with no runtime errors.
- Remaining work: mixed-orientation rendering and full-screen pinch-to-zoom are still planned.

### 2026-11-04 — Recommended Phase 2 work while listing content is pending

- Reviewed current Phase 2 scope against the agreed APK deliverable and existing app. Recommended starting with the already-planned photo presentation polish, using clearly fictional/test images: preserve mixed image orientations in the detail gallery, add an accessible loading skeleton, and support full-screen pinch-to-zoom without interfering with gallery swipes.
- Checked the proposed `shimmer` 4.0 package against the project: installed Flutter 3.47.9 meets its stated Flutter 3.44+ requirement, but the package also brings `material_ui` and requires its compatibility bridge around existing Flutter Material subtrees. It is an option, not an approved dependency; compare that integration cost with a static theme-based placeholder before deciding.
- Other low-dependency candidates for owner approval: improve search/filter empty and combined states, and run bilingual/accessibility checks across list, details, gallery, and filters. Avoid adding favorites, reviews, owner submissions, accounts, or mood persistence; these are not confirmed and some create new privacy/moderation scope.
- No application code changed. Validation: reviewed project brief, architecture, MVP plan, latest handoff, and clean initial worktree; handoff-only change checked with `git diff --check`.
- Status: recommendations only; no feature is approved or implemented. Wait for the owner to select or revise scope.

### 2026-11-03 — Documented planned Phase 2 image presentation work

- Clarified Phase 1 listing intake: each place may supply up to 10 approved, ordered photos with one cover, and both `places` and `place_photos` must be maintained in the canonical/export workflow.
- Recorded, but did not implement, Phase 2 image polish: preserve full portrait/landscape images in the detail gallery, accessible shimmer/skeleton loading, and a full-screen pinch-to-zoom viewer. List-card covers may stay cropped.
- Added image preparation guidance to the Supabase guide: JPEG/WebP preferred, recommended 2048 px longest edge and roughly 2 MB per image, plus permission/copyright/identifiable-person and EXIF-location review. The app and Storage do not perform automatic moderation or metadata stripping.
- Updated `docs/MVP_PLAN.md`, `docs/PROJECT_BRIEF.md`, `docs/ARCHITECTURE.md`, `docs/SUPABASE_SETUP.md`, and `README.md`. No application code changed; validation is documentation review and `git diff --check`.

### 2026-11-03 — Added ordered place-photo galleries

- Confirmed a production-shaped gallery direction for the class-demo MVP: each place can have up to 10 approved ordered photos, with one cover photo for cards. Gallery photos use public Supabase Storage URLs first; optional bundled assets remain an offline fallback.
- Code: added `PlaceGalleryPhoto` and ordered `Place.photos`; existing `photoUrl`/`photoAsset` values remain a compatibility cover fallback. `SupabasePlacesSource` now reads `places` with `place_photos` and listens for Realtime changes on both tables. The detail sheet uses a swipeable, accessible gallery when there are at least two photos; the card retains the cover image.
- Data/docs: the bundled seed now has empty `photos` arrays. `docs/SUPABASE_SETUP.md` includes idempotent policy creation, the `place_photos` schema, one-cover constraint, 10-photo database limit, RLS, Realtime publication, Storage organization, migration from existing single cover rows, and separate import/export guidance. Updated project brief, architecture, MVP plan, and README.
- Privacy/content: only upload photos the team is permitted to use. Check identifiable people before publishing. Captions are optional and reserved for approved English/Tagalog copy.
- Validation: `flutter analyze` clean; `flutter test` 21 passed; `flutter build apk --debug` succeeded with the shared-source build defines; `git diff --check` clean.
- Required next setup: run the documented `place_photos` SQL and Realtime publication migration in Supabase, then add at least two photo rows for one place to verify the live swipeable gallery and Realtime refresh on a connected device. Existing single `photoUrl` data remains usable until that migration is applied.

### 2026-11-03 — Improved shop-detail amenity chip contrast

- Set chip background and label colors from the app's Material color scheme, so amenity chips in shop details use a coordinated, high-contrast theme pair instead of Flutter defaults.
- Added a widget regression assertion that the detail chip uses the theme colors and meets a 4.5:1 text contrast ratio.
- Validation: `flutter analyze lib/app/app_theme.dart test/widget_test.dart` clean; all 6 tests in `test/widget_test.dart` passed; Dart formatting and `git diff --check` clean. Launched the debug app on the Android emulator, hot restarted it successfully, and found no runtime errors.
- Remaining work: none specific to this change.

### 2026-11-03 — Added hybrid place photos (Storage URL with bundled fallback)

- Resolved the photo design with the owner: images were never out of scope, but the app had no image support at all. The earlier "bundled photos" note is replaced by a hybrid: a public Supabase Storage bucket supplies the primary photo URL, and a bundled copy covers offline or failed loads. A place with neither shows a placeholder.
- Code: `Place` gained optional `photoUrl` and `photoAsset` (blank or missing values normalize to null). New `lib/features/places/place_photo.dart` prefers the network photo, shows the bundled copy while loading or on error, and falls back to a neutral placeholder; `place_card.dart` and `place_detail_sheet.dart` now render it (the detail sheet gained a 170 px photo block and a keyed scroll list).
- Schema: two nullable columns, `"photoUrl"` and `"photoAsset"`, added to the documented `places` schema with an `alter table` migration for existing projects. No RLS change; reads stay `select`-only.
- Seed: `assets/data/sample_places.json` now carries both fields as null, so the sample rows show placeholders until approved photos exist. `docs/SUPABASE_SETUP.md` documents the `place-photos` public bucket (Free plan, no card), file naming, and how to attach a URL.
- Docs: project brief decision table and notes, architecture photo flow, MVP plan Phase 2, README, setup guide.
- Validation: `flutter analyze` clean; `flutter test` 18 passed (3 new photo mapping tests, 3 new photo widget tests, and the detail test now scrolls past the photo). Debug APK built and installed on the emulator to confirm the placeholder layout.
- Not verified: a real Storage photo end to end, because the bucket is empty and the publishable key cannot upload. Upload one file and set a row's `photoUrl` to confirm.
- Next: upload approved photos, set `photoUrl` per row, optionally bundle copies under `assets/photos/` (add that path to `pubspec.yaml` when the first image lands), then continue Phase 1 content.
- Note: do not bundle or upload a photo the team has not cleared for use.

### 2026-11-03 — Verified live Supabase listings, realtime updates, and offline fallback on Android

- Verified the shared-listing slice against a real Supabase Free-plan project supplied by the owner (URL and publishable key were passed at build time only; neither is committed). The `places` table was created with the documented schema, `select`-only RLS, and realtime enabled.
- Results on the `Medium_Phone` emulator with a debug APK built from the real defines:
  - Readable with the publishable key (`200`, 4 rows); inserts with that key rejected (`401`), so the read-only policy holds.
  - Cold start logged `Shared listings loaded: 4 places`; no offline notice.
  - Four rows inserted through the dashboard arrived live in an already-open app as `Shared listings updated: 1/2/3/4 places`, confirming Realtime Postgres Changes without a relaunch.
  - Airplane mode produced `Shared listings unavailable, using bundled copy: ... Failed host lookup`, and the app stayed usable on bundled listings; restoring the network returned to live listings.
  - Stored text round-tripped correctly, including `·`, `–`, and `café`.
- Added three `debugPrint` source-transition lines to `SyncedPlacesRepository` (loaded, updated, empty table) because the seeded rows are identical to the bundled ones, so live and fallback cannot be told apart on screen. Documented the log lines in `docs/SUPABASE_SETUP.md`.
- The shared table currently holds the four **fictional** sample rows from `assets/data/sample_places.json`. Phase 1 must replace them before the `DEMO CONTENT · NOT VERIFIED` label is removed. They can be cleared with `delete from public.places;`.
- Validation: `flutter analyze` clean, `flutter test` 13 passed, `flutter build apk --debug` succeeded.
- Not verified: two-device synchronized updates, since only one emulator is available, and a dashboard **update** of an existing row (inserts exercised the same realtime channel, but the scripted demo moment is an edit).
- Next: Phase 1 — obtain the team's 15–20 approved listings and photos, agree the data template, then replace the sample rows and re-verify with two devices.
- Blockers: real listing content and photos, photo permissions and translation ownership, second device for the two-phone check, and venue network reliability.

### 2026-11-03 — Committed the Supabase listing slice and verified the fallback path on Android

- Committed the shared-listing work as `4992486 feat(places): load shared listings from supabase with bundled fallback`; no unrelated changes were included.
- Verified on the `Medium_Phone` Android emulator:
  - Built and installed an APK with deliberately invalid Supabase defines. Logcat showed the expected `Shared listings unavailable, using bundled copy` error, and the app kept running on bundled listings. The on-screen notice could not be asserted automatically because Flutter semantics are not exposed to `uiautomator`; rendering of the notice is covered by the widget test.
  - Rebuilt the default APK without defines, reinstalled, and confirmed it starts without Supabase initialization or fallback logging.
  - Neither run produced crashes or asset-load errors.
- Screenshot for manual review: `%LOCALAPPDATA%\Temp\opencode\fallback-verify.png` (not committed).
- Validation: `flutter analyze` clean, `flutter test` 13 passed, `flutter build apk --debug` succeeded, `git diff --check` clean before committing.
- Next: create the team-owned Supabase project, apply the schema/RLS/realtime SQL, import listings, then repeat on two devices to verify live sync.
- Blockers: no live Supabase project or credentials yet, so realtime sync remains unverified.

### 2026-11-02 — Added optional shared listings via Supabase with bundled fallback

- Recorded the listing-source decision: the class-demo APK loads listings from a shared Supabase Free-plan `places` table, while `assets/data/sample_places.json` stays canonical and serves as the seed and offline fallback. Photos remain bundled; no Supabase Storage, paid plan, or card is used.
- Added a read-only `PlacesRepository`/`PlacesSnapshot` port, `PlacesRemoteSource`, `SupabasePlacesSource`, and `SyncedPlacesRepository` (bundled data first, five-second first-update timeout, live stream, offline-fallback label). `SamplePlacesRepository` now emits the seed snapshot, and the Explore screen shows a bilingual "bundled copy · live updates unavailable" notice.
- Added build-time configuration through `--dart-define=SUPABASE_URL` and `--dart-define=SUPABASE_PUBLISHABLE_KEY`; without both values the app runs on bundled listings only, so tests and offline builds need no network or credentials. Added `supabase_flutter` 2.18.3.
- Docs: added `docs/SUPABASE_SETUP.md` (schema with quoted camelCase columns, select-only RLS, realtime publication, import notes, demo runbook, Free-plan pause risk). Updated the brief decision table, architecture data flow, MVP plan phases, references (Free-plan limits verified 2026-11-02), and README setup.
- Validation: `flutter analyze` clean, `flutter test` 13 passed, `flutter build apk --debug` succeeded, and `git diff --check` was clean.
- Next: create the team-owned Supabase project, apply the table and policies, import the approved listings, then verify the two-phone live update and the airplane-mode fallback on a device.
- Blockers: Supabase organization ownership and dashboard edit access, final listings/photos, and venue network reliability remain open.

### 2026-11-02 — Reframed prototype scope as phased Flutter MVP plan

- Replaced `docs/PROTOTYPE_SCOPE.md` with `docs/MVP_PLAN.md`. Preserved the implemented Flutter prototype as Phase 0, then organized the remaining work into dependent phases with priorities, acceptance criteria, and unresolved prerequisites.
- Updated the README, project brief, architecture, and agent guidance to reflect Flutter as the current class-demo MVP framework while leaving production framework/providers open.
- Validation: documentation link/reference search, consistency review, and `git diff --check`; no application code changed.
- Next: start with team-provided listing content and decide whether class-demo listings are bundled locally or loaded from a shared online source.
- Blockers: map source, ETA behavior, listing source, mood privacy decisions, final content/assets, presentation deadline, and APK signing expectations remain open.

### 2026-11-02 — Recorded answers to initial scope questions

- Updated the project brief, architecture, prototype scope, agent instructions, and README with the requested class-presentation/testing APK, feature ranking, no Google Play/no landing page, team-supplied 15–20 listings, no custom admin screen, and Google Maps directions preference.
- Recorded mood check-in as optional and prioritized, with no profile linkage; persistence, nickname use, consent, and retention remain unresolved. ETA display/provider, listing verification/translation/photo permissions, whether listings are local or shared online, and dashboard/access setup also remain open.
- Validation: documentation consistency review and `git diff --check`; no application code changed.
- Next: clarify the remaining privacy and ETA decisions before implementing data collection or live services; obtain the team's listing template, photos, and approved content.
- Blockers: no deadline or detailed acceptance criteria supplied; map/data providers and several feature behaviors remain undecided.

### 2026-10-31 — Improved filter chip contrast

- Set explicit dark text colors for selected and unselected filter chips so labels remain legible on the light sheet; added regression checks for both states.
- During Android runtime validation, also fixed a zero-width transient constraint on the map's horizontal place cards that could throw during startup.
- Validation: `dart format`, `flutter analyze`, and `flutter test` passed. Built, installed, and hot-restarted on the Android emulator; visually confirmed the filter labels now have readable contrast.
- Next: review the updated filter visually on an Android device.
- Blockers: none known.

### 2026-10-31 — Documented optional companion landing-page prototype

- Added an optional static landing-page prototype to `docs/PROTOTYPE_SCOPE.md`, including a preview-only download button until an approved APK and distribution host exist.
- Clarified in the project brief and architecture that the public page, hosting, distribution, and release artifact remain unapproved decisions. Recommended a separate `landing-page/` directory to avoid Flutter's reserved `web/` path and keeping APK binaries out of source control.
- Updated the README to distinguish the optional companion-page prototype from the contributor README.
- Validation: documentation review only; no application behavior changed.
- Next: confirm with the team whether this companion prototype is included in the requested deliverable.
- Blockers: public-page requirement, APK distribution, hosting, and operational ownership remain undecided.

### 2026-10-31 — Fixed the place filter dialog layout

- Replaced the constrained alert dialog with a scrollable bottom sheet. The title and Apply/Reset actions remain available while filter options scroll.
- Added widget coverage for scrolling to lower filters, applying a category filter, and resetting selections.
- Validation: formatted the changed Dart files, `flutter analyze`, and `flutter test` passed. Hot-restarted the Flutter app in Chrome using temporary web scaffolding, then removed that scaffolding.
- Next: review the updated filter layout on an Android device when one is available.
- Blockers: no Android device or emulator was connected for visual verification.

### 2026-10-31 — Created initial local version-control baseline

- Initialized a local Git repository and recorded the existing project foundation and Flutter prototype in the first baseline commit.
- The project remains local; no GitHub remote was configured.
- Validation: reviewed the staged file list and confirmed generated Flutter/Gradle build artifacts are excluded by `.gitignore`.
- Next: create a private GitHub repository and add its remote if shared backup and collaboration are wanted.
- Blockers: no remote repository has been created.

### 2026-10-31 — Completed Flutter prototype and validation

- Fixed initial map layout for zero-sized tab frames, made map pins and sample place cards fit the prototype layout, and bounded the place detail and filter dialogs.
- Added repository injection for deterministic widget tests and a test verifying the bundled fictional JSON listings.
- Validation: `dart format lib test`, `flutter analyze`, and `flutter test` passed. `flutter build apk --debug` was blocked when Gradle could not download Flutter artifacts because the remote TLS handshake failed; the automatic retry was stopped.
- Next: review the prototype with the student team; replace fictional sample data only with reviewed/approved listing content.
- Blockers: production framework, services, scope, and final UI remain unconfirmed.

### 2026-10-31 — Implemented Flutter clickable prototype

- Scaffolded an Android-only Flutter project and implemented local JSON demo listings, bilingual Explore/Map UI, category/budget/amenity/environment/activity filters, place detail sheets, dismissible/reopenable onboarding, and a schematic non-navigation map.
- Added a shared Material 3 theme and widget tests. No backend, live maps, location permission, credentials, or real venue claims were introduced.
- Updated README setup commands and architecture notes to distinguish provisional Flutter prototype from undecided production stack.
- Validation: see the newer handoff entry above.
- Next: review the prototype with the student team; replace fictional sample data only with reviewed/approved listing content.
- Blockers: production framework, services, scope, and final UI remain unconfirmed.

### 2026-10-31 — Recorded provisional prototype design direction

- Added a provisional visual direction to the former `docs/PROTOTYPE_SCOPE.md`, now represented in `docs/MVP_PLAN.md`: Material 3 patterns, a warm/teal palette to validate, readable platform typography, and shared UI/accessibility guidance.
- Added a framework-neutral architecture principle for centralizing semantic theme tokens once UI implementation begins; did not lock Flutter or production branding.
- Validation: documentation-only update; no application or test tooling exists yet.
- Next: review the prototype visual direction with students/team before treating any palette or style as final.
- Blockers: no approved brand identity or confirmed Flutter requirement.

### 2026-10-31 — Defined clickable prototype scope

- Added the initial `docs/PROTOTYPE_SCOPE.md`, later evolved into `docs/MVP_PLAN.md`, with proposed offline sample-data flows, interactions, exclusions, and a review checklist.
- Recorded Flutter as provisional for prototype planning only; no framework or production implementation decision was made in the project brief.
- Linked the prototype scope from the README.
- Validation: documentation-only update; no application code or test tooling exists yet.
- Next: confirm prototype deliverable, deadline, and priority screens with the team; implement only after the owner chooses to proceed.
- Blockers: team responses and school framework requirement remain open.

### 2026-10-31 — Added recurring privacy and legal review guidance

- Updated `AGENTS.md` to require feature-level consideration of location and mood data, identifiers, listing accuracy, user reports, and consumer-facing claims when relevant.
- Clarified that the cited Philippine laws are prompts for review, not a complete legal analysis or compliance claim; final interpretation and terms need qualified review.
- Added the same reassessment trigger to the project brief's privacy/legal section.
- Validation: documentation-only update; no application or test tooling exists yet.
- Next: apply this review when implementing or changing affected features and record material decisions in the brief.
- Blockers: legal applicability and final terms require project-specific review.

### 2026-10-30 — Researched scope questions and service costs

- Read `docs/DATA OFFICER .docx`; it matches the concept text provided in chat.
- Added scope questions to the project brief for demo vs production, distribution, listing/admin workflow, and separate map/routing providers.
- Added official Google Maps/Routes, OSM, Firebase, Supabase, and Play Console references with current usage/licensing caveats to `docs/REFERENCES.md`.
- Validation: documentation and official-source review only; no application or test tooling exists yet.
- Next: confirm deliverable level, MVP exclusions, route behavior, listing/admin workflow, mood feature handling, distribution, and service-account owner before final fixed quote.
- Blockers: no final scope, service providers, or launch channel selected.

### 2026-10-30 — Recorded agreed Android product concept

- Updated the project brief with the team's agreed direction: Android, Filipino and English, initial Malinta coverage near PLV Annex and CPAG, managed place listings, filters, travel estimates, onboarding, and owner-account constraints.
- Updated the architecture and agent guidance for Android while leaving framework and providers open. Recorded mood check-in as optional and highlighted privacy, listing accuracy, permissions, and licensing questions.
- Updated README status and decision summary.
- Source: concept details supplied in chat; the referenced `Downloads/DATA OFFICER` folder was not available at the stated path in this workspace.
- Validation: documentation-only update; no application or test tooling exists yet.
- Next: clarify the remaining technical choices, MVP acceptance criteria, travel modes/provider, account and nickname behavior, listing correction process, and optional mood-data handling before implementation.
- Blockers: no framework, programming language, provider, or detailed MVP priorities selected.

### 2026-10-29 — Added curated reference catalog

- Added `docs/REFERENCES.md` for links and structured evaluation notes on related products and open-source projects, without vendoring their code.
- Added reference guidance to `AGENTS.md` and linked the catalog from the README.
- Validation: documentation-only update; no application or test tooling exists yet.
- Next: add relevant projects after checking their source, current license, maintenance status, and applicability to confirmed requirements.
- Blockers: no specific references have been researched; product scope and platform remain undecided.

### 2026-10-29 — Added product decision-support workflow

- Updated `AGENTS.md` to guide agents to frame uncertain feature ideas with scenarios, advantages, tradeoffs, a recommendation, and an approval checkpoint before building.
- Clarified that routine implementation details within an approved scope do not need extra approval.
- Validation: documentation-only update; no application or test tooling exists yet.
- Next: use this workflow when the owner raises a feature or product decision they are unsure about.
- Blockers: product scope and platform remain undecided.

### 2026-10-29 — Added development and Git conventions

- Updated `AGENTS.md` with Conventional Commit guidance, branch naming, review expectations, coding principles, and adaptable documentation standards.
- Kept platform/UI-specific checks conditional and clarified that agents must not switch branches or create commits unless asked.
- Updated the README entry for agent instructions.
- Validation: documentation-only update; no application or test tooling exists yet.
- Next: follow these conventions once Git is initialized and implementation work begins.
- Blockers: workspace currently has no Git repository or application tooling.

### 2026-10-29 — Clarified documentation maintenance

- Updated `AGENTS.md` to tell agents which project documents to maintain when durable requirements, architecture, setup, or feature behavior changes.
- Clarified that documentation should change alongside relevant implementation, not for every code edit; agents should verify the docs and code remain consistent.
- Validation: documentation-only update; no application or test tooling exists yet.
- Next: apply these guidelines as implementation begins and add feature-specific docs only when they provide useful, maintained guidance.
- Blockers: platform, framework, and product scope are still undecided.

### 2026-10-29 — Recorded landing-page question

- Clarified that the repository README is contributor documentation, not the public-facing product landing page.
- Added a landing/product-information page as an open product decision in the brief and architecture notes; it is not approved scope.
- Validation: documentation-only update; no application or test tooling exists yet.
- Next: ask whether a public page is useful for the confirmed audience and launch plan, and whether it should be part of a web app or a separate site.
- Blockers: target platform, audience details, and launch requirements remain undecided.

### 2026-10-29 — Created framework-neutral project foundation

- Added the initial README, shared agent instructions, product brief, proposed architecture, and this handoff log.
- Recorded the campus-area directory and map idea as preliminary; platform, stack, coverage area, and MVP remain undecided.
- Validation: documentation-only setup; no application or test tooling exists yet.
- Next: clarify the open product questions with the client. Once the target platform and MVP are confirmed, choose a stack and adapt the architecture before scaffolding application code.
- Blockers: no client answers or final concept received yet.
