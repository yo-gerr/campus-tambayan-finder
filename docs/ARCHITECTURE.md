# Proposed Architecture

## Scope

The agreed target is an Android application, initially serving students near PLV Annex and CPAG in Malinta, Valenzuela City, with Filipino (Tagalog) and English language support. A Flutter app now implements a local-data clickable prototype; Flutter is provisional for this prototype only. Production framework, minimum Android version, backend, map provider, and routing provider remain undecided. The feature-first structure below is a conceptual guide, not a requirement to mirror every suggested layer.

## Guiding boundaries

- **Feature-first organization:** group code by user capability so related behavior can evolve together.
- **Domain before framework:** represent core concepts and rules without depending on UI widgets, platform APIs, network clients, or a particular database.
- **Explicit adapters:** keep external systems (maps, geolocation, persistence, APIs) behind interfaces owned by the application/domain boundary.
- **Thin presentation:** Android screens should render state and translate user actions into application operations; avoid putting business rules in UI components.
- **Shared visual theme:** once UI implementation begins, define shared semantic colors, typography, spacing, and component styles in the selected framework's app-level theme. Screens should consume theme values instead of duplicating hard-coded styling. Keep theme implementation framework-specific; Flutter is only a provisional prototype choice.
- **Share only stable code:** share domain, validation, and use-case logic when useful. Keep platform-specific presentation and integrations in their platform layer rather than forcing artificial cross-platform abstractions.
- **Start small:** do not create empty packages, layers, or services just to match a diagram.

## Feature areas in the agreed direction

These are capabilities in the agreed product direction. Their detailed behavior and MVP priority still need definition:

- **Place discovery:** browse and filter student-friendly places by category, budget, amenities, environment, capacity, and intended activity. Search behavior remains to be specified.
- **Place details:** show verified-as-possible listing information such as address, photos, amenities, estimated prices, and operating hours.
- **Map and travel estimates:** show nearby places and estimated travel time from PLV Annex or CPAG; route modes, provider, and accuracy caveats need definition.
- **Listing operations:** the development team gathers and maintains initial listing data. Shop owners do not need app accounts or in-app payments under the agreed concept.
- **Bilingual experience and guidance:** support Filipino and English and provide first-use and in-app instructions.
- **Location-aware behavior:** request device location only when needed and provide a useful experience if permission is denied.
- **Optional mood check-in:** a proposed post-visit feature. Keep it separate from core discovery; do not assume storage, account linkage, analytics, or research use until explicitly specified.
- **Public product information:** a separate landing page is not part of the agreed app scope. An optional static companion prototype may be explored separately; confirm before adding it as a deliverable or publishing it.

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
    mood-check-in/     # Only if approved and privacy requirements are defined
  platform/
    android/           # Android-specific APIs, permissions, and composition
tests/
  ...                  # Mirror the chosen stack's test conventions
landing-page/           # Optional standalone static information page; not app code
```

If a landing page is approved, keep its static source separate from Android app code and configure the chosen host to publish that directory. Prefer `landing-page/` over Flutter's reserved `web/` directory. A download button should link to an approved, separately published release artifact; do not store APK binaries in the source tree. Hosting, release signing, and distribution remain separate decisions.

### Current Flutter prototype layout

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

This layout is an implementation detail for the prototype, not a commitment to production architecture. Replace the sample repository or schematic map only after scope and provider decisions are confirmed.

In smaller projects, combine layers where the framework makes separate files clearer than separate packages. Keep dependencies directed inward: presentation and adapters may depend on application/domain contracts; domain rules should not depend on presentation or vendor SDKs.

## Android and cross-platform considerations

The Android target is agreed, but framework and language are not. Keep Android permission handling, lifecycle behavior, navigation, map SDKs, connectivity behavior, and deployment details in the Android platform layer. Avoid introducing cross-platform abstractions unless a confirmed need emerges.

Request location access only when needed, explain why it is requested, and provide useful discovery from the known PLV Annex/CPAG anchors when permission is denied. Avoid collecting or retaining precise location unless a confirmed requirement justifies it.

Mood check-ins and precise location can reveal sensitive information about a person. Keep mood functionality optional and isolated; before implementing it, define consent, purpose, data linkage, storage, access, retention, deletion, and whether any aggregate analysis is intended. Do not frame correlations as diagnoses or causal conclusions.

Listing photos, map data, and route estimates may have separate permission, attribution, licensing, or provider terms. Verify the applicable terms and obtain appropriate permissions before publication.

## Revisit when

Update this document when the selected Android stack or a confirmed requirement changes module boundaries, dependencies, data flow, privacy assumptions, or other architectural decisions. Keep the structure proportionate to the actual implementation.
