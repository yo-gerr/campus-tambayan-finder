# Proposed Architecture

## Scope

The agreed target is an Android application, initially serving students near PLV Annex and CPAG in Malinta, Valenzuela City, with Filipino (Tagalog) and English language support. The current delivery target is an installable APK for class presentation/testing; Google Play publication and a separate public webpage are not required. Flutter is the framework for the current class-demo MVP, although it is not school-mandated. Production framework, minimum Android version, backend, and map renderer remain undecided.

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
- **Map and travel estimates:** map is a high-priority presentation feature. The team prefers opening directions in Google Maps; the in-app map renderer, travel modes, and whether ETA is displayed in-app or by Google Maps remain open.
- **Listing operations:** the team plans to provide approximately 15–20 initial entries with available photos and details. Authorized team members will edit listing information manually; a custom in-app admin screen is not wanted. Whether class-demo listings are bundled locally or loaded from a shared source, and the data/provider dashboard and access controls, remain undecided.
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
  app/                  # App shell, shared theme, and bilingual UI copy
  features/
    places/             # Place model, local JSON repository, browse/filter/detail UI
    map/                # Non-geographic illustrative map UI
    onboarding/         # Intro guide
assets/data/
  sample_places.json    # Fictional prototype fixtures only
test/
  widget_test.dart      # Main interaction smoke tests
```

This layout is an implementation detail for the current MVP, not a commitment to production architecture. Replace the sample repository or schematic map only after scope and provider decisions are confirmed.

In smaller projects, combine layers where the framework makes separate files clearer than separate packages. Keep dependencies directed inward: presentation and adapters may depend on application/domain contracts; domain rules should not depend on presentation or vendor SDKs.

## Android and cross-platform considerations

The Android target is agreed, but framework and language are not. Keep Android permission handling, lifecycle behavior, navigation, map SDKs, connectivity behavior, and deployment details in the Android platform layer. Avoid introducing cross-platform abstractions unless a confirmed need emerges.

Request location access only when needed, explain why it is requested, and provide useful discovery from the known PLV Annex/CPAG anchors when permission is denied. Avoid collecting or retaining precise location unless a confirmed requirement justifies it.

Mood check-ins and precise location can reveal sensitive information about a person. Keep mood functionality optional and isolated; before implementing it, define consent, purpose, data linkage, storage, access, retention, deletion, and whether any aggregate analysis is intended. Do not frame correlations as diagnoses or causal conclusions.

Listing photos, map data, and route estimates may have separate permission, attribution, licensing, or provider terms. Verify the applicable terms and obtain appropriate permissions before publication.

## Revisit when

Update this document when the selected Android stack or a confirmed requirement changes module boundaries, dependencies, data flow, privacy assumptions, or other architectural decisions. Keep the structure proportionate to the actual implementation.
