# Campus Tambayan Finder

A proposed Android application to help students find suitable places to study, eat, relax, and socialize in Malinta, Valenzuela City, particularly near PLV Annex and CPAG.

This repository README is for project contributors and agents; it is not a public-facing product landing page. The team does not require a separate webpage for the current class-presentation/testing delivery.

## Project status

The team has agreed on the Android and Filipino/English direction and requested an installable APK for class presentation/testing; Google Play publication is not required. Flutter is the framework for this MVP but is not school-mandated or a confirmed production choice. The team will provide an initial list of about 15–20 establishments. Listings can load from a shared Supabase Free-plan table, with the bundled JSON kept as seed and offline fallback; in-app map rendering, ETA presentation, and mood-data handling still need decisions.

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
| Product direction | Student place finder with listings, filters, map, and travel estimates |
| Initial coverage | Malinta, particularly near PLV Annex and CPAG |
| Platform | Android |
| App languages | Filipino (Tagalog) and English |
| Requested delivery | Installable Android APK for class presentation/testing; no Google Play release |
| Initial listings | About 15–20; compiled data and available photos supplied by the team |
| Listing storage for class demo | Confirmed: shared Supabase Free-plan table with bundled JSON as seed and offline fallback |
| Directions | Open Google Maps; in-app ETA and map provider remain undecided |
| Optional mood check-in | Requested for presentation; nickname may be used, but no profile linkage; storage and privacy decisions open |
| Listing edits | Authorized team members edit rows in the Supabase dashboard; no in-app admin screen |
| Listing photos | Hybrid: Supabase Storage URL preferred, bundled copy as offline fallback |
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

By default the app uses the bundled listings and needs no network or credentials. To load shared listings during a build, pass the Supabase values described in [Shared Listings Setup](docs/SUPABASE_SETUP.md):

```powershell
flutter run --dart-define=SUPABASE_URL=https://YOUR-PROJECT.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
```

The current app is a Flutter MVP baseline with fictional listings, an optional shared Supabase listing source, and an illustrative map; it has no live map integration. See the [MVP plan](docs/MVP_PLAN.md) for phased work and remaining dependencies. Later production service choices remain open in the [project brief](docs/PROJECT_BRIEF.md).
