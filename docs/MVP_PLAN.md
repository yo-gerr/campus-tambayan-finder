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
- **Listing source:** shared Supabase Free-plan table; the latest successful non-empty snapshot is cached on-device for offline browsing, with bundled JSON kept as the first-sync seed/fallback. Remote photos and map tiles are not included in this listing cache. See [Shared Listings Setup](SUPABASE_SETUP.md).
- **Directions:** open Google Maps rather than implementing in-app navigation.
- **Services and costs:** prefer no-cost/no-card choices where feasible; explain any paid or card-dependent service and obtain approval before enabling it.
- **Mood privacy:** mood responses must not be linked to a user profile. Persistence and nickname behavior are undecided; do not persist mood or nickname data until clarified.
- **Web preview:** the same app is built for the browser and published to GitHub Pages so the client can review changes without reinstalling the APK. It rebuilds on every push to `master`, carries no marketing content, and is a review channel rather than an additional deliverable.
- **Not required:** public landing page and Google Play publication.

## Provisional visual direction

Retain the calm, welcoming student-oriented visual style as a design hypothesis for the class demo, not as approved final branding. The current direction follows the client's exported home-screen mockup (confirmed November 5, 2026) and replaces the earlier "Warm Campus" teal palette.

- Use Material 3 patterns without relying on a bottom navigation bar. The home screen is the hub: three speech bubbles lead to the explore list, the informational mood preview, and the sidebar. The More bubble and home hamburger open that sidebar. Every other screen carries a visible Home control, and system Back returns to the hub.
- The "speech bubble" palette is the current working choice, still provisional rather than approved final branding. Tokens live in `lib/app/app_theme.dart`; screens must not declare their own color literals.
  - `background #FBF8F4`, `sky #DFEDFB`, `surface #E9F2F9`, `raised #FFFFFF`
  - `ink #1F2A5C`, `inkStrong #0B1F4B`, `mutedInk #5A6485`
  - `primary #1F6FD1`, `onPrimary #FFFFFF`, `brand #3490F5`, `onBrand #0B1F4B`
  - `bubble #BBDDFF` with `bubbleUnder #8EC4FA`, and `surfaceUnder #C3D8E8`
  - `accent #E2A92B`, `open #14594A`, `error #B3261E`
  - `demoContainer #FBEBC8` with `onDemoContainer #6A4B00`
- Fredoka (600/700) sets the brand and headings; Nunito (400–800) sets body and interface text. Both font families and their OFL licences are bundled, so the interface does not fetch fonts at runtime.
- Cards and bubbles are flat shapes with a hard darker underside, not shadows or gradients. Speech-bubble outlines are painted from vectors so they stay crisp at any width; the student figure and wordmark are image assets.
- Use 24 px side margins, an 8 px spacing grid, touch targets of at least 48 dp, and 24–30 px card radii. Sizes derive from screen width so the hub holds together on small phones. On the home header, give the wordmark the largest share, keep its emblem close, and leave the hamburger a distinct 48 dp utility target; position the sky scene and hub actions slightly lower for breathing room.
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
- Home hub with three speech-bubble destinations and no bottom navigation; every spoke screen has a Home control, and system Back returns to the hub. The More bubble and home hamburger open a sidebar holding Home, Instructions, Vision & Mission, Privacy, Terms & Conditions, language switching, and a version note. Vision/Mission, Privacy, and Terms are labelled placeholders pending reviewed client copy; the mood bubble opens an informational preview that stores nothing.
- Speech-bubble palette, Fredoka/Nunito typography, and flat card shapes applied across the app. The displayed app name and supplied wordmark are confirmed as Kamus Tambay; final logo treatment remains open.
- Shared Supabase listings with realtime updates, the latest non-empty snapshot cached for offline browsing, bundled JSON as the first-sync seed/fallback, and clear demo labelling for `sample-` rows.
- GitHub Pages web preview rebuilt on every push to `master`.
- Widget, domain, repository, and map tests (79 at the time of writing).

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
- The Map tab uses a full-body map layout with a floating Home control at the top-left, a compact horizontally scrollable carousel overlay 30 dp above the bottom for places with valid coordinates, and an internet/coordinate note at the top-right. The carousel uses equal left/right insets and sits above the map attribution control; it uses the same place cards and opens place details. Unlocated places are not shown in it. Its height accommodates card content without overflow. The searchable place list remains on Explore, and tapping a map marker/label also opens place details.
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

**Status: not started for data collection.** The home mood bubble now opens an informational preview that explains the plan and states that nothing is saved; it asks for no mood, nickname, or profile. Real collection remains blocked on the decisions below.

- Confirm whether a nickname is required or optional and entered per check-in.
- Confirm purpose, consent wording, whether a response is retained, who can access it, retention/deletion, and whether any aggregate analysis is intended.
- Never link mood responses to a persistent user profile. Do not add account/profile tracking for this feature.
- Until storage decisions and appropriate review are complete, limit implementation to an optional, non-persistent interaction with no actual response history or analytics.
- Do not represent mood selections as diagnoses or evidence that a place caused a particular mood.

**Acceptance:** the check-in is optional, follows the team's confirmed privacy behavior, and does not create profile linkage or unsupported psychological claims.

### Phase 5 — Estimated travel time

**Client presentation priority: fourth. Proposed implementation order: after real listings and verified map coordinates, and before mood check-in if the owner/team approves this in-app feature.**

**Status: research complete; no ETA is implemented or approved for display. OSRM's public FOSSGIS demo is a candidate for a low-volume, non-commercial class demo only.**

- **Research result (checked 2026-11-05):** the current OSRM/FOSSGIS public demo exposes car, bicycle, and foot profiles. Its public API examples do not require a sign-up, API key, or payment card. The service is best-effort, has no uptime/latency/data-update guarantee, allows at most one request per second, logs route requests, and is documented for reasonable non-commercial use. Because this is a commission, ask the operator whether this use qualifies before making app requests; do not assume that “class demo” makes it eligible. This is not a production or commercial-service commitment. See [OSRM public routing server](REFERENCES.md#osrm-public-routing-server).
- **Recommended first version (proposal, pending owner/team approval):** show an optional estimate in a place's detail view for a verified destination only. Let the student choose a fixed origin—PLV Annex or CPAG—and one available mode (walking, cycling, or driving). Keep the existing Google Maps directions action as the navigation handoff. Use the OSRM-reported duration and distance, clearly labeled as an approximate route estimate with no live traffic and no guarantee of actual travel time.
- Request a route only after the student opens a place and chooses an origin/mode; never request routes for every card or refresh automatically. Allow one outstanding request at a time, enforce the public service's one-request-per-second limit, and reuse results in memory during the session where practical.
- Do not add a sign-up, API key, payment card, paid plan, billing project, or self-hosted server for this proposal. If the public service later requires any of these, stop and request a new decision rather than silently switching providers or enabling billing. Public access can still be changed or withdrawn by its operator.
- Identify the app with an appropriate User-Agent; show required OpenStreetMap and OSRM attribution; do not disguise the app or send bulk route requests. The routing provider logs requests, so disclose network use. A failed, unavailable, or unreachable route service should show a clear unavailable state while leaving the Google Maps directions action available.
- Use only verified live destination coordinates. Never request an ETA for the fictional bundled sample coordinates. Check real walking/cycling/driving routes in Malinta against the map and Google Maps before presentation; OSM route coverage and profile speeds can be incomplete or differ from actual conditions.
- **Origins and location privacy:** begin with the fixed campus origins only; this does not need device-location permission. A “use my current location” origin is not part of this proposal. If later requested, ask for foreground permission only after an explicit action, send a one-time coordinate to the routing server, do not store or track it, disclose that the provider logs requests, and provide campus-origin alternatives. Obtain a separate product/privacy decision before adding it.
- OSRM's supported public demo profiles cover car, bicycle, and foot, not public-transit timetables or live traffic. Valhalla is a possible open-source alternative, but its public demo's app-API access, no-sign-up/no-card terms, and usage allowance were not verified; self-hosting would add hosting and operations costs. Do not switch to it without rechecking those constraints.
- Until the in-app ETA behavior and public-server limitations are accepted by the owner/team, continue showing no ETA. Do not use fabricated or fixed-time examples.

**Dependencies:** Phase 1 real listing data and verified destinations, visually checked campus anchors, confirmation that in-app estimates are still wanted, and the routing-service operator's confirmation that this commissioned use is allowed under its non-commercial policy. Keep mood check-in blocked separately on its unresolved privacy decisions.

**Acceptance:** the student can request one estimate for a verified place from either fixed campus anchor in a supported mode; the UI states that the result is approximate, not live-traffic-aware, and may differ from actual travel; OSM/OSRM attribution is visible; rate and request constraints are observed; network failure gives no fabricated result; Google Maps directions remain available. No account, API key, payment card, billing setup, or paid service is introduced.

### Phase 6 — Filipino/English and introductory guide

**Priority: fifth and sixth. Existing controls need content review.**

**Status: bilingual UI and the guide are implemented; translation and content review are pending.**

- Review translations of app UI and supplied place information with the team or its chosen translator.
- Ensure language changes cover navigation, filters, errors, empty states, details, directions messaging, and mood UI if included. **Implemented:** all UI copy has English and Filipino entries behind one in-app toggle. The selection is held in memory and resets to English on relaunch.
- Review the onboarding guide against the final class-demo feature set and keep it dismissible/reopenable. **Implemented:** the guide opens at launch and reopens from More → How to use. Whether it should appear only on first launch is an open client question recorded in the brief.

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
- Whether to approve an in-app ETA using the proposed OSRM/FOSSGIS public class-demo service, and acceptance of its non-commercial, best-effort, logged-request, and rate-limit constraints.
- Ask the OSRM/FOSSGIS service operator whether this commissioned class-demo app is eligible under the public server's non-commercial-use policy before integrating or sending requests.
- ETA origin and modes: the proposal uses fixed PLV Annex/CPAG origins and walking, cycling, or driving; current-location origin is excluded unless separately approved.
- Mood nickname necessity, consent, storage, access, retention, deletion, and purpose.
- Final app name/logo/assets, presentation deadline, target Android/device, and APK signing expectations.

Update this plan as decisions are confirmed. Keep the [project brief](PROJECT_BRIEF.md) as the source of truth for agreed requirements and unresolved product decisions; record meaningful implementation progress in the [agent handoff](AGENT_HANDOFF.md).
