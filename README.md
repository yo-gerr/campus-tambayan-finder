# Kamus Tambay

A proposed Android application to help students find suitable places to study, eat, relax, and socialize in Malinta, Valenzuela City, particularly near PLV Annex and CPAG.

This repository README is for project contributors and agents; it is not a public-facing product landing page. The team does not require a separate webpage for the current class-presentation/testing delivery.

## Project status

The team has agreed on the Android and Filipino/English direction and requested an installable APK for class presentation/testing; Google Play publication is not required. Flutter is the framework for this MVP but is not school-mandated or a confirmed production choice. The team will provide an initial list of about 15–20 establishments. Listings load from a shared Supabase Free-plan table; the app caches the latest successful non-empty listing snapshot for offline browsing and uses bundled JSON before its first sync. Remote photos and map tiles may still need internet. The shipped baseline opens on a speech-bubble home hub and covers five place categories, optional price ranges with preset budget chips, structured per-day hours with an open/closed badge and filter, photo galleries, a MapLibre/OpenFreeMap map, and Google Maps directions for verified coordinates. In-app ETA and mood-data handling still need decisions.

## Start here

- [Project brief](docs/PROJECT_BRIEF.md) — current concept, assumptions, and questions to resolve.
- [Architecture](docs/ARCHITECTURE.md) — proposed framework-neutral, feature-first structure.
- [Flutter MVP plan](docs/MVP_PLAN.md) — phased implementation sequence, dependencies, and acceptance criteria.
- [Shared listings setup](docs/SUPABASE_SETUP.md) — Supabase table, read-only policy, realtime setup, and demo runbook.
- [Product and implementation references](docs/REFERENCES.md) — curated research links and notes; not code to copy.
- [Agent handoff](docs/AGENT_HANDOFF.md) — latest work, checks, blockers, and suggested next steps.
- [Agent instructions](AGENTS.md) — shared working agreement, documentation rules, and Git/commit conventions for coding agents.

## Working across agents

Before making changes, read `AGENTS.md`, `docs/PROJECT_BRIEF.md`, and the latest entry in `docs/AGENT_HANDOFF.md`. At the end of a meaningful task, update the handoff with what changed, validation performed, and any next steps or blockers. Update this README and the project brief only when their durable project facts or decisions change.

The handoff is a lightweight, version-controlled coordination log, not a live synchronization system. Keep changes and handoff updates committed or otherwise shared through the same repository so another agent can see them.

## Current decisions

| Topic | Status |
|---|---|
| Product direction | Student place finder with listings, filters, and a map; in-app travel estimates are deferred |
| Navigation | Home is the hub with three speech bubbles; the More bubble and home hamburger open the sidebar; no bottom bar. Every other screen has a Home control and system Back returns to the hub |
| Sidebar | Home, Instructions, Vision & Mission, Privacy, Terms & Conditions, English/Filipino switching, and version note. Vision/Mission, Privacy, and Terms are labelled placeholders pending reviewed client copy; About is removed |
| Visual direction (provisional) | Cream/sky/navy/blue speech-bubble palette, Fredoka headings with Nunito body text, flat shapes with hard undersides, 24 px margins (16 px on compact widths), 8 px grid, and 48 dp targets. Branding remains provisional |
| Initial coverage | Malinta, particularly near PLV Annex and CPAG |
| Platform | Android |
| Product name and wordmark | Confirmed November 5, 2026: the displayed app name and supplied home wordmark are "Kamus Tambay". The internal package/application ID and GitHub repository name remain unchanged; final logo treatment is open |
| App languages | Filipino (Tagalog) and English |
| Requested delivery | Installable Android APK for class presentation/testing; no Google Play release |
| Web preview | Browser build published to GitHub Pages so the client can review changes without reinstalling the APK. Review channel only; the APK remains the deliverable |
| Initial listings | About 15–20; compiled data and available photos supplied by the team |
| Place categories | Five static categories: tambayan, coffee shop, park/open space, karinderya/affordable eatery, and other place. All stay selectable before listings exist for them |
| Price display | Optional `priceMin`/`priceMax` pair; an unknown price shows "Price not listed" and is excluded while a budget limit is active |
| Budget filter | Preset chips from ₱50 to ₱500 plus "Any budget"; "Any budget" applies no limit |
| Operating hours | Structured `hoursByDay` drives the weekly list, the open/closed badge, and the "Open now" filter in Manila time; free-text `hours` is a note only |
| Listing storage for class demo | Confirmed: shared Supabase Free-plan table; latest successful non-empty snapshot cached on-device for offline browsing; bundled JSON is the first-sync seed/fallback |
| Directions | Open Google Maps, only for listings with verified coordinates; in-app ETA is deferred. Map renderer confirmed: MapLibre with OpenFreeMap tiles/styles |
| Optional mood check-in | Requested for presentation; nickname may be used, but no profile linkage; storage and privacy decisions open. The home bubble currently opens an informational preview that stores nothing |
| Listing edits | Authorized team members edit rows in the Supabase dashboard; no in-app admin screen |
| Listing photos | Hybrid gallery: up to 10 approved Storage images per place, with optional bundled offline fallbacks; accessible loading skeleton and separate full-image zoom viewer; detail and card images are consistently cropped |
| Public landing/information page | Not needed for current class-presentation/testing delivery |
| School framework requirement | None |
| Current class-demo MVP framework | Flutter |
| Backend for shared listings | Supabase Free plan; other providers undecided |

## Getting started

Requirements: Flutter SDK (Dart included) and an Android emulator or device.

```powershell
flutter pub get
flutter run
flutter test
flutter analyze
```

When changing the native splash configuration or artwork, regenerate its Android resources with `dart run flutter_native_splash:create`.

By default the app uses the bundled listings and needs no network or credentials. To load shared listings during a build, pass the Supabase values described in [Shared Listings Setup](docs/SUPABASE_SETUP.md):

```powershell
flutter run --dart-define=SUPABASE_URL=https://YOUR-PROJECT.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
```

The current app is a Flutter MVP baseline with fictional listings, an optional shared Supabase listing source, and a MapLibre/OpenFreeMap map. The bundled samples carry clearly unverified illustrative coordinates, so they appear as pins and in the map carousel, but their Directions button stays disabled with an explanation. See the [MVP plan](docs/MVP_PLAN.md) for remaining data and service prerequisites. Later production service choices remain open in the [project brief](docs/PROJECT_BRIEF.md).

## Web preview

A browser build of the same app is published to GitHub Pages so the client can review changes without reinstalling the APK. It is a review channel, not an additional deliverable: the Android APK remains what is presented and tested, and there is still no landing or marketing page.

`.github/workflows/web-preview.yml` rebuilds and redeploys it on every push to `master`. One-time setup after creating the repository: **Settings → Pages → Source: GitHub Actions**.

To reproduce the deployed build locally, pass the same base href and configuration the workflow uses:

```powershell
flutter build web --release --base-href "/campus-tambayan-finder/" --dart-define=SUPABASE_URL=https://YOUR-PROJECT.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
```

GitHub Pages serves project sites from `/<repository>/`, so `--base-href` must match the repository name or every asset request 404s. The preview has no password; treat anything the app can read as public.
