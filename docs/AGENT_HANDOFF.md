# Agent Handoff

Shared, version-controlled handoff notes for agents working in this repository. Add new entries at the top. Keep this concise; the code and durable project documents remain the source of truth.

## Latest

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
