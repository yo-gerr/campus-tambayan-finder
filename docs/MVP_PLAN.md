# Flutter MVP Plan

## Purpose and status

This plan organizes the agreed class-presentation/testing deliverable into implementation phases and makes dependencies visible. The requested deliverable is an installable Android APK; Google Play publication and a separate public webpage are not required.

Flutter is the framework for this MVP because the team has no school-mandated framework and has chosen to proceed with the existing Flutter app. This does not decide whether Flutter, the backend, or any service provider will be used for a later production release.

The app already has a clickable Flutter baseline. This plan tracks the steps from that baseline to a reviewable MVP. Feature priority follows the team's ranking; implementation order also accounts for dependencies and unresolved decisions. Do not select paid services, persist mood responses, or present fictional data as real while decisions remain open.

## Delivery decisions and boundaries

- **Target:** Android APK for class presentation/testing; no Google Play release.
- **Feature priority:** place listings/details, map, optional mood check-in, estimated travel time, Filipino/English, introductory guide. In-app ETA is deferred from the current map phase; directions open in Google Maps.
- **Initial listings:** approximately 15–20. The team will provide a compiled list, names, locations, descriptions, hours, prices, and up to 10 approved ordered photos per place.
- **Listing edits:** authorized team members edit listing information manually in the Supabase dashboard; no custom in-app admin screen.
- **Listing source:** shared Supabase Free-plan table, with the bundled JSON listings kept as seed and offline fallback. See [Shared Listings Setup](SUPABASE_SETUP.md).
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

**Status: not started.** The shared-listing plumbing this phase feeds is built and verified (2026-11-03), but the table still holds the four fictional sample rows. No approved listings, photos, or data template exist yet.

- Receive the compiled list and available photos for approximately 15–20 establishments.
- Agree on a simple spreadsheet/data template and required fields, including up to 10 gallery photos per place, one marked cover photo, display order, public Storage URL, optional captions, and bundled fallback path when supplied.
- Confirm photo permissions, translation responsibility, and how the team expects information to be checked and updated.
- Replace fictional records with the team's approved information while preserving clear labels for any unknown or estimated values.
- Keep the repository JSON canonical and import it into the related Supabase `places` and `place_photos` tables one way; export dashboard edits from both tables back before an APK build.
- Confirm Supabase organization ownership and dashboard edit access. Keep the project on the Free plan unless a paid service is separately approved.

**Acceptance:** the agreed listings display accurate, supplied details; each supplied gallery has no more than 10 approved, ordered images and a correct cover; missing or estimated data is identified rather than invented; the app remains usable for browsing and shows the bundled copy with a clear notice when the shared source is unavailable.

### Phase 2 — Place discovery and details

**Priority: highest; prototype implementation exists and must be completed against approved data.**

- Refine list, search, filters, and details using the confirmed listing fields and content.
- Show each place's ordered gallery of up to 10 approved photos, with one cover for list cards; prefer the shared Storage copy and fall back to bundled assets. Anything missing keeps a neutral placeholder.
- Use a consistent, edge-to-edge crop for photos in the detail gallery and list cards. **Restored 2026-11-04** after emulator screenshots showed portrait images rendered too narrowly in the fixed-height detail area; the full-screen viewer remains available for seeing the complete photo.
- Show an accessible, static, theme-based skeleton while a network photo loads. **Implemented 2026-11-04.** Loading and error states remain distinct; failed network images keep the existing bundled-photo or neutral-placeholder fallback.
- Let users open a gallery photo in a full-screen pinch-to-zoom viewer that contains the complete portrait or landscape image. Separate the zoom view from the swipeable gallery to avoid gesture conflicts. **Implemented 2026-11-04.**
- The inline shop-detail gallery uses a 210 dp height for a larger photo preview while retaining edge-to-edge cropping; listing cards remain unchanged.
- Establish and document image-preparation guidance: preferred JPEG or WebP uploads, a recommended maximum long edge of 2048 px and roughly 2 MB per image, plus review/removal of unnecessary EXIF location metadata when practical. These are guidance, not automatic client-side validation.
- Preserve category, budget, amenity, setting, and activity filters unless the team reprioritizes them.
- Show operating days/hours and prices only from supplied or checked information, with suitable qualification for estimates.
- Confirm whether place browsing must work offline for the class demo.

**Acceptance:** a reviewer can browse the agreed places, find one with available search/filters, and inspect its approved details without confusing sample content with real listings.

### Phase 3 — Real map and Google Maps directions

**Priority: second. Map foundation implemented November 4, 2026; live map display and directions depend on eligible service use and approved coordinates.**

- The app integrates MapLibre with OpenFreeMap's public Positron style and OSM-derived data. The fixed PLV Annex and CPAG anchors keep the basemap visible even when no place has coordinates; the initial view uses zoom 16 centered on the midpoint between their owner-supplied coordinates. Their markers and labels are distinct from place pins. Only places with complete, valid coordinates are plotted, so no sample locations are fabricated.
- The Map tab uses a full-body map layout between the app bar and bottom navigation, with a compact horizontally scrollable carousel overlay 30 dp above the bottom for places with valid coordinates and a floating internet/coordinate note at the top-right. The carousel uses equal left/right insets and sits above the map attribution control; it uses the same place cards and opens place details. Unlocated places are not shown in it. Its height accommodates card content without overflow. The searchable place list remains on Explore, and tapping a map marker/label also opens place details.
- OpenFreeMap currently has no registration, API key, or fee, but its public instance has no warranty/SLA and may be discontinued. Confirm the integrator meets the current terms (age 18+ and legally able to accept them, or authorized to bind the represented organization) and recheck availability/terms before live use. Include required attribution. Map tiles require internet.
- The Positron style is a light neutral baseline. Evaluate a warm app-themed style without obscuring map information or attribution. OpenFreeMap's quick start says custom style JSON must be hosted; verify whether an app-bundled style works before introducing separate hosting. Do not add a paid/card-dependent host without approval.
- Add verified decimal-degree `latitude` and `longitude` pairs to approved place data. The app ignores missing, incomplete, non-numeric, or out-of-range coordinates; legacy schematic `mapX`/`mapY` values are no longer used. Update existing Supabase tables with the nullable coordinate columns and relax legacy schematic fields using the setup guide.
- Visually confirm the owner-supplied PLV Annex and CPAG anchor coordinates against their intended locations. Obtain and check coordinates for approved places before adding their map pins.
- Open directions in Google Maps using the selected place's real coordinates or verified address; handle missing Google Maps/app availability with a clear fallback.
- Do not add an in-app ETA in this phase. The owner selected Google Maps for directions; any future in-app ETA needs a separate decision about source, mode, origin, limitations, and cost.
- Keep the MVP free of a Google Maps SDK, API key, and billing account; Google Maps URLs can open directions without an API key.
- Keep any unverified or placeholder map visibly marked and never use prototype coordinates to launch real navigation.

**Acceptance:** the styled map always shows the PLV Annex and CPAG anchors with required attribution, including before place coordinates are available; places without valid coordinates are not plotted. Selecting a mapped place opens the intended Google Maps destination, or clearly explains why directions are unavailable. No unapproved in-app ETA is shown.

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
- Supabase organization ownership, dashboard edit access, and who exports the table back to the repository before each build.
- In-app map source/renderer and attribution requirements.
- Confirmed coordinates and whether Google Maps is installed/available on presentation devices.
- Whether ETA appears in-app or only in Google Maps, travel modes, and approved source/cost.
- Mood nickname necessity, consent, storage, access, retention, deletion, and purpose.
- Final app name/logo/assets, presentation deadline, target Android/device, and APK signing expectations.

Update this plan as decisions are confirmed. Keep the [project brief](PROJECT_BRIEF.md) as the source of truth for agreed requirements and unresolved product decisions; record meaningful implementation progress in the [agent handoff](AGENT_HANDOFF.md).
