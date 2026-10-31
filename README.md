# Campus Tambayan Finder

A proposed Android application to help students find suitable places to study, eat, relax, and socialize in Malinta, Valenzuela City, particularly near PLV Annex and CPAG.

This repository README is for project contributors and agents; it is not the proposed public-facing product landing page. Whether the product needs a separate landing or information page is still an open product decision.

## Project status

The team has agreed on the initial product direction, Android platform, and Filipino/English language support. A Flutter prototype is being built provisionally with local sample data; Flutter is not yet a confirmed production requirement. Backend, live map/routing services, and production release scope remain undecided.

## Start here

- [Project brief](docs/PROJECT_BRIEF.md) — current concept, assumptions, and questions to resolve.
- [Architecture](docs/ARCHITECTURE.md) — proposed framework-neutral, feature-first structure.
- [Clickable prototype scope](docs/PROTOTYPE_SCOPE.md) — proposed offline prototype flows, boundaries, and acceptance checklist.
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
| Optional mood check-in | Proposed; release scope and data handling need definition |
| Public landing/information page | Undecided; validate audience and launch needs |
| Framework and programming language | Undecided |
| Backend, storage, map, and routing providers | Undecided |

## Getting started

Requirements: Flutter SDK (Dart included) and an Android emulator or device.

```powershell
flutter pub get
flutter run
flutter test
flutter analyze
```

The prototype has no backend or live map integration. Its clearly labeled listings load from local JSON. See [prototype scope](docs/PROTOTYPE_SCOPE.md) for what is simulated and what remains out of scope. Production framework and service decisions remain open in the [project brief](docs/PROJECT_BRIEF.md).
