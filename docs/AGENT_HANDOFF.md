# Agent Handoff

Shared, version-controlled handoff notes for agents working in this repository. Add new entries at the top. Keep this concise; the code and durable project documents remain the source of truth.

## Latest

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
