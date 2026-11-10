# Project Brief

## Working concept

An Android application to help students find suitable tambayan places in Malinta, Valenzuela City, particularly near PLV Annex and CPAG. Students should be able to consider shop operating hours, budget, preferred environment, and (if included) emotional needs when choosing a place.

The concept and feature direction below reflect the team's October 29, 2026 meeting agreement. Implementation details may still change based on feasibility, testing, and applicable requirements. This document records the agreed direction; it is not a complete technical specification.

The team answered the initial scope questions on November 2, 2026. These answers define the current class-presentation/testing target below; unresolved implementation, privacy, and service details remain open.

## Goals and initial scope

- Help students discover places for studying, eating, relaxing, and socializing.
- Limit the initial coverage area to Malinta, particularly around PLV Annex and CPAG.
- Support Filipino (Tagalog) and English.
- Provide useful listing details, an in-app map, and filters so students can choose a suitable place. In-app travel-time estimates were removed from the lower-priced delivery scope; directions open in Google Maps.
- The team will provide the initial compiled listing set; the development team will manage and verify listing information as much as possible.
- Shop owners will not need app accounts, identification submissions, or in-app payments. The development team manages listings and updates.

## Agreed product direction

### Platform and language

- **Platform:** Android application.
- **Languages:** Filipino (Tagalog) and English.
- **School-mandated framework or programming language:** None.
- **Framework and minimum Android version:** No school requirement was identified. Flutter is the framework for the current class-demo MVP; the production framework and minimum Android version are not confirmed.

### First delivery and feature priority

- **Deliverable:** installable Android APK for class presentation and testing.
- **Google Play:** publication is not required.
- **Web preview (added November 4, 2026):** the same app is also built for the browser and published to GitHub Pages, so the client can review changes without reinstalling the APK. This is a review channel rather than an additional deliverable; the APK remains what is presented and tested. It is not a landing, marketing, or product-information page.
- **Separate public webpage:** not required for this delivery.
- **Presentation priority (highest first):** place listings and details; map; optional mood check-in; estimated travel time; Filipino/English language options; introductory guide. The original ranking is retained, but in-app travel-time estimates were removed from the lower-priced delivery scope.
- Filters remain part of the concept and MVP scope; the team did not rank them in this priority list.

### Navigation and visual direction

Confirmed November 5, 2026 as the current class-demo direction, based on the client's exported home-screen mockup:

- **Navigation:** the home screen is the hub. It offers three speech bubbles: Find a tambayan (the explore list), Mood check-in (an informational preview for now), and More, which opens the sidebar. There is no bottom navigation bar. Spoke screens use a top-right menu button to open the shared sidebar, where Home and bilingual language switching remain available. The Android/system Back action returns to the hub.
- **Map access:** the first bubble opens the searchable list, and the list keeps the map one tap away through its "View map" action.
- **Sidebar:** the home hamburger and More bubble open one sidebar with Home, Instructions, Vision & Mission, Privacy, Terms & Conditions, English/Filipino switching, and a subtle version note. Instructions reopens the intro guide. Vision/Mission, Privacy, and Terms remain explicitly labelled placeholders until reviewed client copy is supplied; no About dialog is shown.
- **Palette:** cream `#FBF8F4`, sky `#DFEDFB`, navy ink `#1F2A5C`, deep navy `#0B1F4B`, primary/interactive blue `#1F6FD1`, hero blue `#3490F5`, light bubble blue `#BBDDFF`, pale surface `#E9F2F9`, undersides `#8EC4FA` and `#C3D8E8`, and a gold accent `#E2A92B`. White text on `#1F6FD1` is used for normal-size primary controls; `#3490F5` is limited to large bold text or deep-navy text. Green and red are reserved for status.
- **Typography:** Fredoka for the brand and headings, Nunito for body and interface text. Both are bundled with their OFL licences.
- **Shapes and spacing:** flat speech-bubble and card shapes with a hard darker underside, 24–30 px corner radii, 24 px side margins (16 px below 360 px widths), an 8 px spacing grid, and touch targets of at least 48 dp. Shared breakpoints and sizing live in `lib/app/app_layout.dart`, so list pages cap content at 600 px on wide screens and large-text rows stack instead of overflowing. The home wordmark receives the largest header share; its emblem sits close to it, with a wider gap before the 48 dp hamburger utility. The curved sky scene, bubbles, and student figure sit slightly lower to give the header breathing room. Cards put their status pills at the top. Material icons are used only for interface utilities, not as decorative placeholders.
- **Branding status:** confirmed November 5, 2026: the displayed app name and supplied wordmark are "Kamus Tambay". The internal package/application ID and GitHub repository name remain unchanged. Final logo treatment is still open. Vision and mission copy will be supplied by the client and must not be invented.

### Places and listings

Initial categories include tambayan spots, coffee shops, open spaces and parks, karinderyas and affordable eateries, and other suitable study, eating, relaxation, and socializing locations.

Listings may include:

- Establishment name and address.
- Photographs.
- Amenities and environment.
- Estimated prices or price ranges when reliable information is available.
- Operating days and hours based on the latest information available.
- Other details relevant to students.

The team will provide the compiled initial listing information and available photos. The development team will maintain the in-app listings and verify information as much as feasible. Obtain appropriate permission for photographs or other materials when necessary. Listing freshness and how corrections are reported remain to be defined.

For the first version, the team expects to provide a compiled list of approximately 15–20 establishments, with available photos and information. The requested listing details include establishment names, locations, descriptions, operating hours, and prices. The exact data template, translation source, photo permissions, and completeness/verification expectations still need agreement.

- Confirmed November 4, 2026: each listing may store one optional address as plain text. The detail view shows it only when present; the short neighborhood label stays on cards. Addresses are published only after verification, and fictional demo rows use clearly labeled placeholder addresses.
- Confirmed November 4, 2026: the price is optional as a pair. A listing without a reliable `priceMin`/`priceMax` range shows a localized "not listed" label instead of an implied free price, and it is hidden while a budget filter is active. `0` always means free and must never stand in for an unknown price.
- Confirmed November 4, 2026: hours are stored two ways. `hoursByDay` holds a structured weekly schedule covering opening/closing times and which days a place is open or closed, and the detail view renders it as a per-day list. `hours` remains an optional free-text summary or exception note. The app derives an "open now"/"closed now" state from the structured field only, evaluated in Asia/Manila time, and offers an "Open now" filter. A listing without structured hours shows no indicator and is excluded while that filter is active. Equal opening/closing times, and whether closed places should stay on the map, remain follow-up questions in the table below.

### Discovery and filters

The agreed direction includes filters for:

- Free Wi-Fi, air conditioning, and electrical outlets.
- Estimated capacity or spaciousness.
- Indoor or outdoor setting.
- Suitability for studying, eating, relaxing, or socializing.
- Price range or a user's preferred budget.

Confirmed November 4, 2026: the budget filter is a preset chip row (₱50, ₱100, ₱150, ₱200, ₱300, ₱500) plus "Any budget", matching the other filter groups. "Any budget" applies no limit at all; it is not a maximum preset. The filter currently compares a listing's lowest estimated spend against the selected limit. Whether it should use the highest estimated spend instead is an open follow-up question.

### Map, travel time, and location

- Confirmed November 4, 2026: use the MapLibre Flutter renderer with the OpenFreeMap public tile/style service and OpenStreetMap-derived data for the class-demo map. The map foundation uses OpenFreeMap's Positron style. Fixed PLV Annex and CPAG anchors keep the basemap visible when no place coordinates are available; place pins require valid coordinate pairs.
- OpenFreeMap currently advertises no registration, API key, fee, or map-view limit. Using the service is subject to its terms, which currently require an integrator to be at least 18 and legally able to accept them, or to have authority to bind the represented organization. Before live use, confirm the integrator is eligible. The public service has no warranty or SLA, may be discontinued, and requires internet access; recheck current terms, availability, and attribution before presentation. Do not treat the OpenStreetMap Foundation's public tile servers as an unrestricted app tile API.
- The current Positron style is a light, neutral baseline. A custom warm, student-centered style remains a visual improvement to evaluate; OpenFreeMap's guide says a customized style JSON must be hosted, so check whether an app-bundled style is supported before choosing separate hosting. Preserve required attribution.
- The owner supplied fixed coordinates for the PLV Annex and CPAG anchors; visually confirm that each pin matches its intended location before presenting them as verified. Obtain and check coordinates for approved places before showing their markers or launching directions. Place latitude/longitude fields are optional decimal-degree pairs; do not use old prototype normalized coordinates as geographic locations.
- The bundled fictional sample listings use illustrative coordinates only to preview local map behavior. They are not verified locations and must be replaced with verified coordinates or left blank before importing or using listings as real destinations.
- Confirmed November 4, 2026: directions should open in Google Maps; no in-app ETA is included in the current Phase 3 scope. Google Maps URLs do not require a Google Maps API key. Any later in-app ETA requires a separate product and service decision.
- Directions are enabled only when a listing has a valid coordinate pair explicitly marked as verified. Missing verification defaults to false; sample locations remain ineligible, with a clear explanation shown instead of opening a route.
- Request device location permission only when needed for a location-based feature.
- No device-location permission is needed for fixed campus/place markers or Google Maps directions to verified destinations. Add location access only if a later approved feature needs the user's current position.
- Live maps and directions may require an internet connection. Provide clear unavailable states; do not show fabricated coordinates or travel estimates.

### Guidance and participation

- Provide an in-app guide to the main features. The current build opens a concise three-page visual onboarding flow on first launch, with Skip/Back/Next controls, and keeps a detailed section-navigable guide reopenable from the sidebar → Instructions.
- Students primarily browse listings; no ratings or comments are requested.
- An optional mood check-in with a nickname is requested, but responses must not be linked to a user profile.
- Shop owners do not need app accounts, submit identification through the app, or make online payments; the development team manages initial listings and updates.

There will be no persistent student profile for the requested mood check-in. Clarify whether the nickname is optional and supplied per check-in, whether it is stored with the mood response, and whether responses are retained or only shown transiently. Until purpose, consent, storage, access, retention, and deletion are decided, do not persist mood/nickname records or use them for analysis. No ratings, comments, or other student-generated content are requested.

The current build includes a UI-only mood workflow preview: consent explanation, four mood choices, optional nickname field, review, and a final not-submitted state. It uses no database, network request, GPS, account, or persistent mood storage.

### Listing maintenance and service costs

- The team does not want a custom in-app admin screen. Authorized team members may manually edit listing information using an agreed data/provider dashboard; the provider and access controls are not yet selected.
- Confirmed November 2, 2026: the class-demo APK loads listings from a shared Supabase (Free plan) table. Confirmed November 5, 2026: the app saves the latest successful non-empty listing snapshot on-device for offline browsing after a first sync; before that sync, bundled JSON is the seed/fallback. This cache holds listing data and photo references, not downloaded image files or map tiles. Resolved November 3, 2026: photos use a hybrid — public Supabase Storage supplies an ordered gallery of up to 10 approved images per place, with one cover photo; optional bundled copies are offline fallbacks, and a place with no usable photo shows a placeholder.
- Phase 2 photo presentation: an accessible, static, theme-based loading skeleton for network photos and a separate full-screen pinch-to-zoom viewer were implemented November 4, 2026. Detail-gallery and card photos use a consistent crop; the full-screen viewer contains the complete portrait or landscape image. Upload preparation guidance recommends reasonably sized JPEG/WebP files and review of unnecessary EXIF location metadata; it does not make the app an image-moderation or metadata-removal service.
- The repository JSON/CSV is the canonical listing copy and is imported into Supabase one way. Dashboard edits must be exported back before an APK build so the bundled fallback and the shared table do not drift apart.
- The app reads shared listings with the publishable key only. Row-level security allows reads and no writes, so no student account or sign-in is introduced. Who owns the Supabase organization and who holds dashboard edit access remain open.
- The team accepts an approach that prefers no-cost/no-card services where feasible and requires advance disclosure and approval before enabling paid services or card-dependent billing.
- The framework is not dictated by the school. Flutter is selected for the current MVP; a later production framework is not decided.

### Optional mood check-in

The app may include an optional mood check-in after a user visits a listed place. The proposed responses are happy, relaxed, stressed, and sad. The team intends this to explore how environments and experiences may relate to student mood and well-being.

This feature is optional and ranked third for the class presentation. Confirmed November 5, 2026: the intended direction is anonymous aggregate analysis, with a response associated with the selected place but not with a student account or persistent profile. A nickname may be entered optionally per check-in, but the app must explain that a nickname can still identify someone; do not make it required by default. The retention period remains undecided and blocks real collection until the client and qualified reviewer approve it.

Terms and Privacy content may explain the broader rules, but they do not replace a separate, clear consent step immediately before the first mood submission. The consent flow must state the purpose, data fields, place linkage, optional nickname, access, retention, deletion/withdrawal process, and that results are aggregate indicators rather than psychological diagnoses or proof that a place caused a mood. Do not request device location or create a student account for this feature.

## Privacy, accuracy, and legal considerations

The team intends to establish terms and guidelines covering respectful use, listing accuracy, mood-related features, and reporting inaccurate information. The meeting notes identify the Philippine Data Privacy Act of 2012 (RA 10173) and Consumer Act of the Philippines (RA 7394) as laws to consider.

These are areas for further review, not a determination that a particular legal obligation applies or that the proposed design is compliant. Minimize personal and precise location data, explain permissions, and make useful discovery possible when location access is denied. Seek qualified guidance for legal requirements before launch, particularly if collecting or analyzing mood or location data.

Reassess these considerations whenever a feature change affects personal or precise location data, mood data, nicknames or other identifiers, listing accuracy, user reports, or consumer-facing price/service claims. Agents and developers must not treat this brief as legal advice or claim compliance; obtain qualified review for legal interpretations and final terms.

The approved web preview makes the app reachable at a public URL, and GitHub Pages cannot be password-protected. Anything the app can read is therefore publicly retrievable, including listing details, gallery photos, and any coordinates, including ones marked verified. A search-engine opt-out reduces discoverability but is not access control. Keep the preview limited to fictional or team-approved demo data, and revisit this before real Malinta listings with precise pins are loaded. The Supabase publishable key is exposed by design in the web build, so row-level security on every exposed table must stay read-only.

## Public landing/information page

The team confirmed that no separate webpage is needed for the class-presentation/testing APK. The contributor-facing repository README is not a product landing page. Do not build or host a companion page for the current delivery unless the team later requests it.

The approved GitHub Pages web preview is not this kind of page. It serves a build of the app itself, carries no marketing or product-information content, and exists only so the client can review changes without reinstalling an APK.

## Decisions and open questions

| Topic | Current status |
|---|---|
| Initial product direction | Agreed Android campus-area place finder |
| Coverage | Agreed initial focus: Malinta near PLV Annex and CPAG |
| Languages | Agreed: Filipino (Tagalog) and English |
| Place categories | Confirmed: five categories — tambayan, coffee shop, open space/park, karinderya/affordable eatery, and other place. The catalog is static, so every category stays selectable before listings exist for it |
| School framework requirement | None identified |
| Current class-demo MVP framework | Flutter |
| Production framework and minimum Android version | Open |
| Current delivery | Confirmed installable APK for class presentation and testing; Google Play publication not required |
| Android launcher icon | Temporary icon uses the existing blue-and-gold app mark; replace it when the team supplies the official logo/icon |
| Feature priority | Confirmed ranking: listings/details, map, mood, estimated travel time, bilingual text, introductory guide; in-app ETA removed from the lower-priced delivery scope |
| Navigation | Confirmed November 8, 2026: home hub with three speech bubbles; More, the home hamburger, and top-right spoke-screen menu buttons open one sidebar; no bottom navigation bar; system Back returns to the hub |
| Visual direction | Confirmed November 5, 2026 as the provisional class-demo direction: cream/sky/navy/blue palette, Fredoka headings with Nunito body text, flat speech-bubble shapes with hard undersides, 24 px margins (16 px on compact widths), 8 px grid, and 48 dp targets |
| Product name and wordmark | Confirmed November 5, 2026: displayed app name and supplied wordmark are "Kamus Tambay". Keep the internal package/application ID and GitHub repository name unchanged; final logo treatment remains open |
| Sidebar content | Confirmed November 8, 2026: Home, Instructions, Vision & Mission, Privacy, Terms & Conditions, language switching, and a version note |
| Campus distance sorting | Confirmed November 10, 2026: selecting "Starting near PLV Annex" or "CPAG" sorts Explore place listings by straight-line Haversine distance to the active campus anchor |
| Pull-to-refresh | Confirmed November 9, 2026: swiping down on the Explore place list triggers a live re-fetch from Supabase and updates the local on-device cache |
| Mood check-in | Confirmed November 9, 2026: implemented Option 1 (4-step wizard UI, Supabase `public.mood_check_ins` table with 90-day retention and RLS policies, explicit privacy consent notice with nickname tip, and offline queueing) |
| Map renderer/data provider | Confirmed November 4, 2026: MapLibre Flutter with OpenFreeMap public tiles/styles and OSM-derived data, subject to eligible representative accepting terms and current service review |
| Directions and in-app travel-time estimates | Confirmed November 4, 2026: open directions in Google Maps. In-app ETA, current-location routing, OSRM integration, and route caching were removed from the lower-priced delivery scope. A future ETA phase would require a separate product/service decision and review of provider terms, privacy, and maintenance |
| Meaning of "available time" | Confirmed to mean shop operating hours; estimated travel time to the place is a separate desired detail |
| Listing update cadence and correction/reporting process | Open |
| Initial listing set | Approximately 15–20; team will provide a compiled list, up to 10 approved ordered photos per place, and available information, including names, locations, descriptions, hours, and prices |
| Capacity estimate versus spaciousness | Open — follow-up with client: the app currently stores one boolean `capacity` amenity ("Roomy"/"Maluwag"), which covers spaciousness but not an estimated seat count or size bucket. Confirm whether a numeric or bucketed capacity estimate and filter is required |
| Budget control | Confirmed November 4, 2026: preset chips (₱50, ₱100, ₱150, ₱200, ₱300, ₱500) plus "Any budget", which applies no limit at all |
| Budget comparison basis | Open — follow-up with client: the app matches a budget against the lowest estimated spend (`priceMin`), so a listing priced ₱80–₱250 appears under a ₱100 limit. Confirm whether the highest estimated spend (`priceMax`) should be used instead |
| Wi-Fi amenity meaning | Open — follow-up with client: the app labels the `wifi` amenity "Free Wi-Fi" / "Libreng Wi-Fi". Confirm that paid Wi-Fi must be excluded from that value, or whether paid access needs its own value |
| Introductory guide display | Open — follow-up with client: the app opens the short guide every time it starts, and Sidebar → Instructions reopens it. Should it appear only on first launch, or is showing it at launch each time acceptable? |
| Structured operating days | Confirmed November 4, 2026: `hoursByDay` stores per-day opening and closing times, with a null day meaning closed and a missing day meaning unknown. The detail view lists the week and the app derives an "open now" state in Manila time. The concept document requires the days a place is open or closed, so this is a requirement rather than an inference |
| Closed places on the map | Open — follow-up with client: the map shows every listing, including places that are closed right now. Should a closed place's pin be hidden, or kept visible but marked as closed? Should closed places also be left out of the place list by default, or only when the "Open now" filter is on? |
| 24-hour places | Open — follow-up with client: the app has no value for a place that stays open around the clock, so identical opening and closing times are read as unknown instead of 24 hours. Should a 24-hour place get its own value, or is an around-the-clock schedule not needed for these listings? |
| Photo permissions, data template, translation source, and verification criteria | Open |
| Admin editing workflow | No custom in-app admin screen; authorized team members will edit listing information manually in the Supabase dashboard; who holds access is open |
| Listing delivery/storage | Confirmed November 2, 2026: shared Supabase Free-plan `places` and `place_photos` tables; confirmed November 5, 2026: latest successful non-empty listings snapshot is saved on-device for offline browsing, with bundled local JSON as first-sync seed/fallback |
| Listing photos (class demo) | Confirmed November 3, 2026: hybrid ordered gallery of up to 10 approved images per place; Storage URLs preferred, optional bundled copies as offline fallback, and a placeholder when no usable photo exists |
| Phase 2 photo presentation | Implemented November 4, 2026: full-image detail gallery for mixed orientations, accessible loading skeleton for network photos, and a separate full-screen pinch-to-zoom viewer; card covers remain cropped |
| Student accounts, ratings, comments | No student profile or ratings/comments requested for browsing |
| Mood check-in | Optional and prioritized for class presentation; nickname may be used, but response must not be linked to a user profile. Persistence, nickname necessity, consent, retention, and access are open |
| Public landing/information page | Not needed for current class-demo deliverable |
| Web preview (client review) | Confirmed November 4, 2026: separate browser build of the same app published to GitHub Pages, rebuilt on every push to `master`. Review channel only; the APK remains the deliverable. Public URL, no password; limited to fictional or approved demo data |
| Hosting, services, costs, and operational ownership | Confirmed: Supabase Free plan for shared listings (no card, no paid add-ons). Paid plans and other services remain unapproved. Ownership of the Supabase organization is open |
| Distribution channel for APK handoff and account ownership | APK for presentation/testing; exact file handoff/account ownership open; Google Play not required |
| MVP prioritization and acceptance criteria | Feature ranking agreed; detailed acceptance criteria and deadline still open |

Implementation phases and per-phase acceptance criteria are tracked in `docs/MVP_PLAN.md`. When the team confirms or changes a product decision, update this brief and summarize the material change in `docs/AGENT_HANDOFF.md`.
