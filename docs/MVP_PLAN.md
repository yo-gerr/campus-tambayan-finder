# Flutter MVP Plan

## Purpose and status

This plan organizes the agreed class-presentation/testing deliverable into implementation phases and makes dependencies visible. The requested deliverable is an installable Android APK; Google Play publication and a separate public webpage are not required.

Flutter is the framework for this MVP because the team has no school-mandated framework and has chosen to proceed with the existing Flutter app. This does not decide whether Flutter, the backend, or any service provider will be used for a later production release.

The app already has a clickable Flutter baseline. This plan tracks the steps from that baseline to a reviewable MVP. Feature priority follows the team's ranking; implementation order also accounts for dependencies and unresolved decisions. Do not select paid services, persist mood responses, or present fictional data as real while decisions remain open.

## Delivery decisions and boundaries

- **Target:** Android APK for class presentation/testing; no Google Play release.
- **Feature priority:** place listings/details, map, optional mood check-in, estimated travel time, Filipino/English, introductory guide.
- **Initial listings:** approximately 15–20. The team will provide a compiled list, available photos, names, locations, descriptions, hours, and prices.
- **Listing edits:** authorized team members will edit listing information manually; no custom in-app admin screen.
- **Directions:** open Google Maps rather than implementing in-app navigation.
- **Services and costs:** prefer no-cost/no-card choices where feasible; explain any paid or card-dependent service and obtain approval before enabling it.
- **Mood privacy:** mood responses must not be linked to a user profile. Persistence and nickname behavior are undecided; do not persist mood or nickname data until clarified.
- **Not required:** public landing page and Google Play publication.

## Provisional visual direction

Retain the existing calm, welcoming student-oriented visual style as a design hypothesis for the class demo, not as approved final branding.

- Use Material 3 patterns, a warm neutral background, deep teal/green primary actions, light sage surfaces, and restrained terracotta accents.
- The prototype palette (`#215B50`, `#F7F5EF`, `#E7EEE8`, `#B4543A`) is provisional. Check text contrast and Android font scaling as screens are refined.
- Prefer Roboto or the Android default sans-serif. Keep translated labels readable and check longer Filipino strings.
- Use clear listing cards, recognizable icons with labels, understandable filters, and an obvious list/map switch. Do not rely on color alone to communicate status or category.
- Use only team-approved photos; otherwise retain clearly labeled placeholders.

## Phases

### Phase 0 — Flutter prototype baseline

**Status: implemented.**

- Android Flutter app shell and shared Material 3 theme.
- Fictional local JSON records, browsing/search, place details, category/budget/amenity/setting/activity filters.
- English/Filipino interface toggle, introductory guide, and schematic map.
- Sample data and map/directions behavior are labeled illustrative.
- Widget and sample-repository tests.

This is a working starting point, not the finished class-demo MVP. Do not treat its fictional locations, coordinates, prices, hours, amenities, or translations as approved content.

### Phase 1 — Confirm and load the team's place listings

**Priority: first. Depends on the team supplying approved content.**

- Receive the compiled list and available photos for approximately 15–20 establishments.
- Agree on a simple spreadsheet/data template and required fields.
- Confirm photo permissions, translation responsibility, and how the team expects information to be checked and updated.
- Replace fictional records with the team's approved information while preserving clear labels for any unknown or estimated values.
- Decide whether the class-demo APK can bundle the listing data locally or must show shared updates from an online source. If shared updates are required, pause provider integration until service cost, access, and account ownership are approved.

**Acceptance:** the agreed listings display accurate, supplied details; missing or estimated data is identified rather than invented; the app remains usable for browsing.

### Phase 2 — Place discovery and details

**Priority: highest; prototype implementation exists and must be completed against approved data.**

- Refine list, search, filters, and details using the confirmed listing fields and content.
- Preserve category, budget, amenity, setting, and activity filters unless the team reprioritizes them.
- Show operating days/hours and prices only from supplied or checked information, with suitable qualification for estimates.
- Confirm whether place browsing must work offline for the class demo.

**Acceptance:** a reviewer can browse the agreed places, find one with available search/filters, and inspect its approved details without confusing sample content with real listings.

### Phase 3 — Real map and Google Maps directions

**Priority: second. Depends on approved place coordinates and a map-data approach.**

- Decide how the in-app map will be rendered and sourced, including any attribution, terms, network needs, or cost.
- Obtain and check coordinates for approved places and the PLV Annex/CPAG origins.
- Replace the schematic map only after real, approved coordinates and a suitable map approach are available.
- Open directions in Google Maps using the selected place's real coordinates or verified address; handle missing Google Maps/app availability with a clear fallback.
- Keep any unverified or placeholder map visibly marked and never use prototype coordinates to launch real navigation.

**Acceptance:** map markers correspond to the agreed listings and campus origins; selecting a place opens the intended Google Maps destination, or clearly explains why directions are unavailable.

### Phase 4 — Optional mood check-in

**Priority: third, but privacy decisions are a prerequisite to real collection.**

- Confirm whether a nickname is required or optional and entered per check-in.
- Confirm purpose, consent wording, whether a response is retained, who can access it, retention/deletion, and whether any aggregate analysis is intended.
- Never link mood responses to a persistent user profile. Do not add account/profile tracking for this feature.
- Until storage decisions and appropriate review are complete, limit implementation to an optional, non-persistent interaction with no actual response history or analytics.
- Do not represent mood selections as diagnoses or evidence that a place caused a particular mood.

**Acceptance:** the check-in is optional, follows the team's confirmed privacy behavior, and does not create profile linkage or unsupported psychological claims.

### Phase 5 — Estimated travel time

**Priority: fourth. Blocked on a product/service decision.**

- Confirm whether the travel estimate should be displayed inside this app or left to Google Maps.
- Confirm travel mode(s), origin behavior, acceptable estimate wording, and whether a live routing service is permitted.
- If an in-app ETA requires a paid or card-dependent service, disclose the cost and obtain approval before enabling it.
- Until resolved, show no fabricated ETA; a clearly labeled non-live example may be used only for presentation if the team approves.

**Acceptance:** any displayed estimate has a defined source, origin, mode, limitations, and clear non-guaranteed wording; otherwise the app does not claim to provide an ETA.

### Phase 6 — Filipino/English and introductory guide

**Priority: fifth and sixth. Existing controls need content review.**

- Review translations of app UI and supplied place information with the team or its chosen translator.
- Ensure language changes cover navigation, filters, errors, empty states, details, directions messaging, and mood UI if included.
- Review the onboarding guide against the final class-demo feature set and keep it dismissible/reopenable.

**Acceptance:** both languages communicate the same approved meaning across in-scope screens; the guide accurately describes implemented behavior.

### Phase 7 — APK verification and handoff

**Depends on all features selected for the presentation and on receiving final content.**

- Confirm target Android version/device expectations and whether a debug or signed release APK is required for installation/testing.
- Test install, launch, core presentation flows, no-network behavior if required, and the final APK on an Android emulator or device.
- Build the agreed APK artifact and provide installation instructions. Google Play publication remains out of scope.
- Record known limitations, provider attribution, and any network/service requirements for the presentation.

**Acceptance:** the APK installs and launches on the agreed test device(s); priority flows work; limitations and setup are communicated; no unapproved credentials or billing are included.

## Decisions and inputs still needed

- The team's listing spreadsheet/data template and final 15–20 entries.
- Photo permissions, translation responsibility, data verification expectations, and update process.
- Local bundled listings versus shared online data for the class-demo APK.
- In-app map source/renderer and attribution requirements.
- Confirmed coordinates and whether Google Maps is installed/available on presentation devices.
- Whether ETA appears in-app or only in Google Maps, travel modes, and approved source/cost.
- Mood nickname necessity, consent, storage, access, retention, deletion, and purpose.
- Final app name/logo/assets, presentation deadline, target Android/device, and APK signing expectations.

Update this plan as decisions are confirmed. Keep the [project brief](PROJECT_BRIEF.md) as the source of truth for agreed requirements and unresolved product decisions; record meaningful implementation progress in the [agent handoff](AGENT_HANDOFF.md).
