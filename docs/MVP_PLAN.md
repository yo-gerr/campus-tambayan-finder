# Flutter MVP Plan

## Purpose and status

This plan organizes the agreed class-presentation/testing deliverable into implementation phases and makes dependencies visible. The requested deliverable is an installable Android APK; Google Play publication and a separate public webpage are not required.

Flutter is the framework for this MVP because the team has no school-mandated framework and has chosen to proceed with the existing Flutter app. This does not decide whether Flutter, the backend, or any service provider will be used for a later production release.

The app already has a clickable Flutter baseline. This plan tracks the steps from that baseline to a reviewable MVP. Feature priority follows the team's ranking; implementation order also accounts for dependencies and unresolved decisions. Do not select paid services, persist mood responses, or present fictional data as real while decisions remain open.

## Delivery decisions and boundaries

- **Target:** Android APK for class presentation/testing; no Google Play release.
- **Feature priority:** place listings/details, map, optional mood check-in, Filipino/English, introductory guide. In-app ETA was removed from the lower-priced delivery scope; directions open in Google Maps.
- **Initial listings:** approximately 15–20. The team will provide a compiled list, names, locations, descriptions, hours, prices, and up to 10 approved ordered photos per place.
- **Listing edits:** authorized team members edit listing information manually in the Supabase dashboard; no custom in-app admin screen.
- **Listing source:** shared Supabase Free-plan table; the latest successful non-empty snapshot is cached on-device for offline browsing, with bundled JSON kept as the first-sync seed/fallback. Remote photos and map tiles are not included in this listing cache. See [Shared Listings Setup](SUPABASE_SETUP.md).
- **Directions:** open Google Maps rather than implementing in-app navigation.
- **ETA scope reduction:** live ETA, current-location routing, route caching, and routing-service integration were removed to lower the project price. They may be reconsidered as a separately approved future phase.
- **Services and costs:** prefer no-cost/no-card choices where feasible; explain any paid or card-dependent service and obtain approval before enabling it.
- **Mood privacy:** mood responses must not be linked to a user profile. Persistence and nickname behavior are undecided; do not persist mood or nickname data until clarified.
- **Web preview:** the same app is built for the browser and published to GitHub Pages so the client can review changes without reinstalling the APK. It rebuilds on every push to `master`, carries no marketing content, and is a review channel rather than an additional deliverable.
- **Not required:** public landing page and Google Play publication.

## Provisional visual direction

Retain the calm, welcoming student-oriented visual style as a design hypothesis for the class demo, not as approved final branding. The current direction follows the client's exported home-screen mockup (confirmed November 5, 2026) and replaces the earlier "Warm Campus" teal palette.

- Use Material 3 patterns without relying on a bottom navigation bar. The home screen is the hub: three speech bubbles lead to the explore list, the informational mood preview, and the sidebar. The More bubble, home hamburger, and top-right menu buttons on spoke screens open that sidebar. System Back returns to the hub.
- The "speech bubble" palette is the current working choice, still provisional rather than approved final branding. Tokens live in `lib/app/app_theme.dart`; screens must not declare their own color literals.
  - `background #FBF8F4`, `sky #DFEDFB`, `surface #E9F2F9`, `raised #FFFFFF`
  - `ink #1F2A5C`, `inkStrong #0B1F4B`, `mutedInk #5A6485`
  - `primary #1F6FD1`, `onPrimary #FFFFFF`, `brand #3490F5`, `onBrand #0B1F4B`
  - `bubble #BBDDFF` with `bubbleUnder #8EC4FA`, and `surfaceUnder #C3D8E8`
  - `accent #E2A92B`, `open #14594A`, `error #B3261E`
  - `demoContainer #FBEBC8` with `onDemoContainer #6A4B00`
- Fredoka (600/700) sets the brand and headings; Nunito (400–800) sets body and interface text. Both font families and their OFL licences are bundled, so the interface does not fetch fonts at runtime.
- Cards and bubbles are flat shapes with a hard darker underside, not shadows or gradients. Speech-bubble outlines are painted from vectors so they stay crisp at any width; the student figure and wordmark are image assets.
- Use 24 px side margins, tightened to 16 px below 360 px widths, an 8 px spacing grid, touch targets of at least 48 dp, and 24–30 px card radii. Sizes derive from screen width so the hub holds together on small phones. Shared breakpoints, margins, readable content width, sheet sizing, and the large-text threshold live in `lib/app/app_layout.dart`; list pages cap content at 600 px with a centered gutter on wide screens, and rows that would overflow at large text stack instead. On the home header, give the wordmark the largest share, keep its emblem close, and leave the hamburger a distinct 48 dp utility target; position the sky scene and hub actions slightly lower for breathing room.
- Primary controls use `primary #1F6FD1` with white text, which clears 4.5:1. The lighter `brand #3490F5` is reserved for large bold text or for deep-navy text, because white on it does not clear AA at normal sizes. Status badges use green for open and neutral grey/navy for closed; red is reserved for genuine errors. Demo markers keep their own warm container.
- Text contrast is checked in `test/widget_test.dart`. Keep every normal-size text/background pair at or above 4.5:1.
- Keep translated labels readable and check longer Filipino strings at narrow widths. Use Material icons only for interface utilities, with labels or tooltips where the meaning is not obvious.
- Use clear listing cards, recognizable icons with labels, understandable filters, and an obvious list/map switch. Do not rely on color alone to communicate status or category.
- Use only team-approved photos; otherwise retain clearly labeled placeholders.

## Phases

### Phase 0 — Flutter prototype baseline

**Status: implemented.**

- Android Flutter app shell and shared Material 3 theme.
- Native Android launch splash using the provisional app-bar emblem and warm app background; revisit the artwork if the team approves final branding.
- Fictional local JSON records, browsing, place details, and filters for category, budget, amenities, setting, activity, and open-now. Search matches name, area, and the localized category label.
- The five agreed categories come from one static catalog, so all remain selectable before any listing uses them.
- Optional price ranges: a missing pair shows a "not listed" label and is excluded while a budget limit is active. The budget control is a preset chip row with a genuine "Any budget" state.
- Structured per-day hours: the weekly list, the open/closed badge on cards and in details, and the "Open now" filter all read `hoursByDay`; free-text `hours` is a note only.
- English/Filipino interface toggle in the sidebar, launch guide reopenable from Sidebar → Instructions, and a MapLibre/OpenFreeMap map with campus anchors, place pins, and a card carousel.
- Home hub with three speech-bubble destinations and no bottom navigation; spoke screens use the shared top-right menu to open a sidebar holding Home, Instructions, Vision & Mission, Privacy, Terms & Conditions, language switching, and a version note. System Back returns to the hub. Vision/Mission, Privacy, and Terms are labelled placeholders pending reviewed client copy; the mood bubble opens an informational preview that stores nothing.
- Speech-bubble palette, Fredoka/Nunito typography, and flat card shapes applied across the app. The displayed app name and supplied wordmark are confirmed as Kumus Tambay; final logo treatment remains open.
- Shared Supabase listings with realtime updates, the latest non-empty snapshot cached for offline browsing, bundled JSON as the first-sync seed/fallback, and clear demo labelling for `sample-` rows.
- GitHub Pages web preview rebuilt on every push to `master`.
- Shared responsive layout utility for width bands, page margins, readable content width, sidebar sizing, sheet height, and large-text stacking; tested across 320–600 px widths at 1.0–2.0 text scale.
- Widget, domain, repository, and map tests (114 at the time of writing).

This is a working starting point, not the finished class-demo MVP. Do not treat its fictional locations, coordinates, prices, hours, amenities, or translations as approved content.

### Phase 1 — Confirm and load the team's place listings

**Priority: first. Depends on the team supplying approved content.**

**Status: not started.** The shared-listing plumbing this phase feeds is built and verified (2026-11-03), including the optional price pair, nullable `hours`, and structured `hoursByDay`, but the table still holds the four fictional sample rows. A plain-language draft intake sheet is available for team review; the final template, approved listings, and photos are still pending.

- Receive the compiled list and available photos for approximately 15–20 establishments.
- Agree on a simple, non-technical spreadsheet for place details and a way to receive multiple photos per place. The development team will organize and map the submission into app records, select a cover photo, and handle photo storage.
- Confirm photo permissions, translation responsibility, and how the team expects information to be checked and updated.
- Replace fictional records with the team's approved information while preserving clear labels for any unknown or estimated values.
- Keep the repository JSON canonical and import it into the related Supabase `places` and `place_photos` tables one way; export dashboard edits from both tables back before an APK build.
- Confirm Supabase organization ownership and dashboard edit access. Keep the project on the Free plan unless a paid service is separately approved.

**Acceptance:** the agreed listings display accurate, supplied details; each supplied gallery has no more than 10 approved, ordered images and a correct cover; missing or estimated data is identified rather than invented; the app remains usable for browsing and shows the bundled copy with a clear notice when the shared source is unavailable.

### Phase 2 — Place discovery and details

**Priority: highest; prototype implementation exists and must be completed against approved data.**

**Status: core implemented against the four fictional sample rows; awaiting approved listings.**

- Refine list, search, filters, and details using the confirmed listing fields and content. **Search and filters are implemented:** search is a substring match on name, area, and localized category label, and filters cover category, budget, amenities, setting, activity, and open-now.
- Show each place's ordered gallery of up to 10 approved photos, with one cover for list cards; prefer the shared Storage copy and fall back to bundled assets. Anything missing keeps a neutral placeholder.
- Use a consistent, edge-to-edge crop for photos in the detail gallery and list cards. **Restored 2026-11-04** after emulator screenshots showed portrait images rendered too narrowly in the fixed-height detail area; the full-screen viewer remains available for seeing the complete photo.
- Show an accessible, static, theme-based skeleton while a network photo loads. **Implemented 2026-11-04.** Loading and error states remain distinct; failed network images keep the existing bundled-photo or neutral-placeholder fallback.
- Let users open a gallery photo in a full-screen pinch-to-zoom viewer that contains the complete portrait or landscape image. Separate the zoom view from the swipeable gallery to avoid gesture conflicts. **Implemented 2026-11-04.**
- The inline shop-detail gallery uses a 210 dp height for a larger photo preview while retaining edge-to-edge cropping; listing cards remain unchanged.
- Establish and document image-preparation guidance: preferred JPEG or WebP uploads, a recommended maximum long edge of 2048 px and roughly 2 MB per image, plus review/removal of unnecessary EXIF location metadata when practical. These are guidance, not automatic client-side validation.
- Preserve category, budget, amenity, setting, and activity filters unless the team reprioritizes them.
- Show operating days/hours and prices only from supplied or checked information, with suitable qualification for estimates. **Implemented:** a missing price shows "Price not listed" and is excluded under a budget limit; `hoursByDay` drives the weekly list and the open/closed state, and a listing without it shows no indicator.
- Confirm whether place browsing must work offline for the class demo. **Resolved November 5, 2026:** cache the latest successful non-empty shared listing snapshot on-device. Use bundled JSON before the first successful sync; remote photo files and map tiles are not included.

**Acceptance:** a reviewer can browse the agreed places, find one with available search/filters, and inspect its approved details without confusing sample content with real listings.

### Phase 3 — Real map and Google Maps directions

**Priority: second. Status: implemented for the class demo; approved place coordinates and verified flags are still missing.**

- The app integrates MapLibre with OpenFreeMap's public Positron style and OSM-derived data. The fixed PLV Annex and CPAG anchors keep the basemap visible; the initial view uses zoom 16 centered on the midpoint between their owner-supplied coordinates. Their markers and labels are distinct from place pins. Bundled fictional listings have illustrative coordinates for local map previews so the carousel can be exercised without Supabase; these are not real locations and must be replaced with verified coordinates or omitted before use for live listings or directions.
- The Map tab uses a full-body map layout with a top-right menu button, a compact horizontally scrollable carousel overlay 15 dp above the bottom for places with valid coordinates, and an internet/coordinate note at the top-left. The carousel uses equal left/right insets and sits above the map attribution control; it uses the same place cards and opens place details. Unlocated places are not shown in it. Its height accommodates card content without overflow. The searchable place list remains on Explore, and tapping a map marker/label also opens place details.
- OpenFreeMap currently has no registration, API key, or fee, but its public instance has no warranty/SLA and may be discontinued. Confirm the integrator meets the current terms (age 18+ and legally able to accept them, or authorized to bind the represented organization) and recheck availability/terms before live use. Include required attribution. Map tiles require internet.
- The Positron style is a light neutral baseline. Evaluate a warm app-themed style without obscuring map information or attribution. OpenFreeMap's quick start says custom style JSON must be hosted; verify whether an app-bundled style works before introducing separate hosting. Do not add a paid/card-dependent host without approval.
- Add verified decimal-degree `latitude` and `longitude` pairs to approved live place data. The app ignores missing, incomplete, non-numeric, or out-of-range coordinates; legacy schematic `mapX`/`mapY` values are no longer used. Never treat the bundled illustrative sample coordinates as real destinations. Update existing Supabase tables with the nullable coordinate columns and relax legacy schematic fields using the setup guide.
- Visually confirm the owner-supplied PLV Annex and CPAG anchor coordinates against their intended locations. Obtain and check coordinates for approved places before adding their map pins.
- Open Google Maps directions with an external URL only when the listing's `location_verified` flag is true and its coordinates form a valid pair. The flag defaults to false for existing rows; do not mark bundled illustrative coordinates as verified. Explain unverified or missing locations, and report when the external map/browser cannot be opened.
- Do not add an in-app ETA in this phase. The owner selected Google Maps for directions; any future in-app ETA needs a separate decision about source, mode, origin, limitations, and cost.
- Keep the MVP free of a Google Maps SDK, API key, and billing account; Google Maps URLs can open directions without an API key.
- Keep any unverified or placeholder map visibly marked and never use prototype coordinates to launch real navigation.
- Map pins carry no open/closed state yet: a closed place keeps an ordinary pin. Whether to hide it or mark it as closed is an open client question recorded in the brief.

**Acceptance:** the styled map always shows the PLV Annex and CPAG anchors with required attribution; place pins use valid coordinates, with explicitly illustrative coordinates limited to fictional demo listings. Real listings use verified locations. Selecting a mapped live place opens the intended Google Maps destination only when `location_verified` is true, or clearly explains why directions are unavailable. No unapproved in-app ETA is shown.

### Phase 4 — Optional mood check-in

**Priority: third, but privacy decisions are a prerequisite to real collection.**

**Status: UI prototype only; no data collection.** The home mood bubble now opens a local interactive preview of the planned consent, mood selection, optional nickname, review, and confirmation flow. Every step states that nothing is submitted or saved. The approved direction is anonymous aggregate analysis linked to the selected place, with an optional per-check-in nickname. Retention and qualified privacy/legal review remain blockers.

- Define the consent text and require a separate explicit opt-in immediately before the first submission; the Terms and Privacy pages are supporting explanations, not the sole consent mechanism.
- Confirm the retention period, who can access the aggregate data, how a participant can withdraw or request deletion where applicable, and whether a nickname is stored or discarded after display.
- Never link mood responses to a persistent user profile. Do not add account/profile tracking for this feature.
- Do not request device location or infer that the user visited a place; the user must voluntarily identify the selected place/check-in context.
- Until storage decisions and appropriate review are complete, limit implementation to the informational preview with no actual response history or analytics.
- Do not represent mood selections as diagnoses, psychological assessments, or evidence that a place caused a particular mood.
- The current UI preview uses no database, network request, account, GPS, or persistent mood storage. It must not be presented as a working collection system.

**Proposed consent-first workflow (pending retention and review):**

1. The user opens a place detail and chooses **Share how you feel**; the feature remains optional.
2. The app shows a plain-language explanation and links to the full Terms and Privacy pages.
3. Before the first submission, a separate consent screen explains the purpose, selected-place linkage, mood choices, optional nickname, retention, access, deletion/withdrawal process, and aggregate-only reporting. The user can accept or decline.
4. The user selects Happy, Relaxed, Stressed, or Sad. The app must not describe the result as a diagnosis.
5. The user may enter an optional nickname. The UI warns that a nickname is not necessarily anonymous and can be omitted.
6. A review step shows exactly what will be submitted, including the selected place and nickname if entered. The user confirms or cancels.
7. The app submits only after consent and confirmation. It does not send device coordinates, account identifiers, or background location.
8. The app shows a confirmation and provides the approved withdrawal/deletion route. Aggregate views are shown only under the approved access and minimum-group rules.

**Acceptance:** the check-in is optional, follows the team's confirmed privacy behavior, and does not create profile linkage or unsupported psychological claims.

### Phase 5 — Estimated travel time

**Priority: fourth. Removed from the lower-priced delivery scope.**

The earlier ETA prototype and opt-in OSRM/cache validation path were removed to lower the project price and reduce service, privacy, and maintenance requirements. The current delivery opens Google Maps for directions to verified destinations instead. This phase remains documented as a possible separately approved future feature.

Open questions:

- If ETA returns in a later phase, confirm travel modes, origin behavior, provider terms, caching, and acceptable estimate wording.

**Acceptance:** any displayed estimate has a defined source, origin, mode, limitations, and clear non-guaranteed wording; otherwise the app does not claim to provide an ETA.

### Phase 6 — Filipino/English and introductory guide

**Priority: fifth and sixth. Existing controls need content review.**

**Status: bilingual UI, a three-page visual first-launch onboarding flow, and a section-navigable Instructions guide are implemented; translation and content review are pending.**

- Review translations of app UI and supplied place information with the team or its chosen translator.
- Ensure language changes cover navigation, filters, errors, empty states, details, directions messaging, and mood UI if included. **Implemented:** all UI copy has English and Filipino entries behind one in-app toggle. The selection is held in memory and resets to English on relaunch.
- Review the onboarding guide against the final class-demo feature set and keep it dismissible/reopenable. **Implemented:** a three-page visual guide opens on first launch and can be skipped, while the detailed guide with section navigation reopens from the sidebar → Instructions.

**Acceptance:** both languages communicate the same approved meaning across in-scope screens; the guide accurately describes implemented behavior.

### Phase 7 — APK verification and handoff

**Depends on all features selected for the presentation and on receiving final content.**

**Status: not started; depends on approved content and the final feature set.**

- Confirm target Android version/device expectations and whether a debug or signed release APK is required for installation/testing.
- Test install, launch, core presentation flows, no-network behavior if required, and the final APK on an Android emulator or device.
- Build the agreed APK artifact and provide installation instructions. Google Play publication remains out of scope.
- Record known limitations, provider attribution, and any network/service requirements for the presentation.

**Acceptance:** the APK installs and launches on the agreed test device(s); priority flows work; limitations and setup are communicated; no unapproved credentials or billing are included.

## Decisions and inputs still needed

- The team's listing spreadsheet/data template and final 15–20 entries.
- Capacity filter: whether the single "Roomy" amenity is sufficient, or a numeric/bucketed capacity estimate and filter is required.
- Budget matching: whether a listing qualifies on its lowest estimated spend (current) or highest estimated spend.
- Wi-Fi meaning: confirm the `wifi` amenity means free access only.
- Introductory guide: whether it should appear only on first launch, or at every launch as it does now.
- Closed places on the map: whether a closed place is hidden or kept visible but marked, and whether it is left out of results by default.
- 24-hour places: whether an around-the-clock schedule needs its own value.
- Photo permissions, translation responsibility, data verification expectations, and update process.
- Supabase organization ownership, dashboard edit access, and who exports the table back to the repository before each build.
- Confirmed coordinates and whether Google Maps is installed/available on presentation devices.
- Whether to approve an in-app ETA and select an appropriate routing service.
- ETA origin, travel modes, estimate wording, caching, and location-permission behavior if an in-app ETA is later approved.
- Mood nickname necessity, consent, storage, access, retention, deletion, and purpose.
- Final app name/logo/assets, presentation deadline, target Android/device, and APK signing expectations.

Update this plan as decisions are confirmed. Keep the [project brief](PROJECT_BRIEF.md) as the source of truth for agreed requirements and unresolved product decisions; record meaningful implementation progress in the [agent handoff](AGENT_HANDOFF.md).
