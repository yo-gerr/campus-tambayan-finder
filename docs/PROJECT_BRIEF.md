# Project Brief

## Working concept

An Android application to help students find suitable tambayan places in Malinta, Valenzuela City, particularly near PLV Annex and CPAG. Students should be able to consider shop operating hours, budget, preferred environment, and (if included) emotional needs when choosing a place.

The concept and feature direction below reflect the team's October 29, 2026 meeting agreement. Implementation details may still change based on feasibility, testing, and applicable requirements. This document records the agreed direction; it is not a complete technical specification.

The team answered the initial scope questions on November 2, 2026. These answers define the current class-presentation/testing target below; unresolved implementation, privacy, and service details remain open.

## Goals and initial scope

- Help students discover places for studying, eating, relaxing, and socializing.
- Limit the initial coverage area to Malinta, particularly around PLV Annex and CPAG.
- Support Filipino (Tagalog) and English.
- Provide useful listing details, maps, estimated travel times, and filters so students can choose a suitable place.
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
- **Separate public webpage:** not required for this delivery.
- **Presentation priority (highest first):** place listings and details; map; optional mood check-in; estimated travel time; Filipino/English language options; introductory guide.
- Filters remain part of the concept and MVP scope; the team did not rank them in this priority list.

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

### Discovery and filters

The agreed direction includes filters for:

- Free Wi-Fi, air conditioning, and electrical outlets.
- Estimated capacity or spaciousness.
- Indoor or outdoor setting.
- Suitability for studying, eating, relaxing, or socializing.
- Price range or a user's preferred budget.

### Map, travel time, and location

- Show estimated travel times from PLV Annex or CPAG to selected places; estimates may vary by route and travel mode.
- Request device location permission only when needed for a location-based feature.
- Updated listings, maps, and location services may require an internet connection.

The map provider, routing provider, travel modes, and fallback behavior when location permission or connectivity is unavailable are undecided.

The team prefers opening directions in Google Maps rather than implementing in-app navigation. The presentation priority also includes estimated travel time to a place; confirm whether the estimate should appear in this app or be shown by Google Maps after opening directions. Do not assume a Google Maps SDK, Routes API, billing setup, or in-app ETA until this is settled. A map visible inside the app is still a stated priority, but its data/rendering provider and implementation approach remain undecided.

### Guidance and participation

- Provide a first-use introduction to the main features and keep instructions accessible in the app.
- Students primarily browse listings; no ratings or comments are requested.
- An optional mood check-in with a nickname is requested, but responses must not be linked to a user profile.
- Shop owners do not need app accounts, submit identification through the app, or make online payments; the development team manages initial listings and updates.

There will be no persistent student profile for the requested mood check-in. Clarify whether the nickname is optional and supplied per check-in, whether it is stored with the mood response, and whether responses are retained or only shown transiently. Until purpose, consent, storage, access, retention, and deletion are decided, do not persist mood/nickname records or use them for analysis. No ratings, comments, or other student-generated content are requested.

### Listing maintenance and service costs

- The team does not want a custom in-app admin screen. Authorized team members may manually edit listing information using an agreed data/provider dashboard; the provider and access controls are not yet selected.
- Confirmed November 2, 2026: the class-demo APK loads listings from a shared Supabase (Free plan) table, while the bundled JSON listings stay in the build as the seed and offline fallback. Resolved November 3, 2026: photos use a hybrid — public Supabase Storage supplies an ordered gallery of up to 10 approved images per place, with one cover photo; optional bundled copies are offline fallbacks, and a place with no usable photo shows a placeholder.
- Planned Phase 2 photo presentation work (not implemented): preserve full portrait and landscape images in the detail gallery, show an accessible loading skeleton, and offer full-screen pinch-to-zoom viewing. Card covers may remain cropped for a consistent list layout. Upload preparation guidance will recommend reasonably sized JPEG/WebP files and review of unnecessary EXIF location metadata; it does not make the app an image-moderation or metadata-removal service.
- The repository JSON/CSV is the canonical listing copy and is imported into Supabase one way. Dashboard edits must be exported back before an APK build so the bundled fallback and the shared table do not drift apart.
- The app reads shared listings with the publishable key only. Row-level security allows reads and no writes, so no student account or sign-in is introduced. Who owns the Supabase organization and who holds dashboard edit access remain open.
- The team accepts an approach that prefers no-cost/no-card services where feasible and requires advance disclosure and approval before enabling paid services or card-dependent billing.
- The framework is not dictated by the school. Flutter is selected for the current MVP; a later production framework is not decided.

### Optional mood check-in

The app may include an optional mood check-in after a user visits a listed place. The proposed responses are happy, relaxed, stressed, and sad. The team intends this to explore how environments and experiences may relate to student mood and well-being.

This feature is optional and ranked third for the class presentation. Before implementation, clarify whether mood responses are stored, how nickname entry works, whether responses are used only on-device or for aggregate research, who can access them, how long they are retained, and what consent and deletion controls are needed. Responses must not be linked to a user profile. Avoid presenting mood data as a psychological diagnosis or proven causal finding.

## Privacy, accuracy, and legal considerations

The team intends to establish terms and guidelines covering respectful use, listing accuracy, mood-related features, and reporting inaccurate information. The meeting notes identify the Philippine Data Privacy Act of 2012 (RA 10173) and Consumer Act of the Philippines (RA 7394) as laws to consider.

These are areas for further review, not a determination that a particular legal obligation applies or that the proposed design is compliant. Minimize personal and precise location data, explain permissions, and make useful discovery possible when location access is denied. Seek qualified guidance for legal requirements before launch, particularly if collecting or analyzing mood or location data.

Reassess these considerations whenever a feature change affects personal or precise location data, mood data, nicknames or other identifiers, listing accuracy, user reports, or consumer-facing price/service claims. Agents and developers must not treat this brief as legal advice or claim compliance; obtain qualified review for legal interpretations and final terms.

## Public landing/information page

The team confirmed that no separate webpage is needed for the class-presentation/testing APK. The contributor-facing repository README is not a product landing page. Do not build or host a companion page for the current delivery unless the team later requests it.

## Decisions and open questions

| Topic | Current status |
|---|---|
| Initial product direction | Agreed Android campus-area place finder |
| Coverage | Agreed initial focus: Malinta near PLV Annex and CPAG |
| Languages | Agreed: Filipino (Tagalog) and English |
| School framework requirement | None identified |
| Current class-demo MVP framework | Flutter |
| Production framework and minimum Android version | Open |
| Current delivery | Confirmed installable APK for class presentation and testing; Google Play publication not required |
| Feature priority | Confirmed ranking: listings/details, map, mood, estimated travel time, bilingual text, introductory guide |
| Map renderer/data provider and routing provider | Open; directions should open Google Maps |
| Estimated travel time display, travel modes, and estimate source | Open; clarify whether shown in-app or by Google Maps |
| Meaning of "available time" | Confirmed to mean shop operating hours; estimated travel time to the place is a separate desired detail |
| Listing update cadence and correction/reporting process | Open |
| Initial listing set | Approximately 15–20; team will provide a compiled list, up to 10 approved ordered photos per place, and available information, including names, locations, descriptions, hours, and prices |
| Photo permissions, data template, translation source, and verification criteria | Open |
| Admin editing workflow | No custom in-app admin screen; authorized team members will edit listing information manually in the Supabase dashboard; who holds access is open |
| Listing delivery/storage | Confirmed November 2, 2026: shared Supabase Free-plan `places` and `place_photos` tables, with bundled local JSON as seed and offline fallback |
| Listing photos (class demo) | Confirmed November 3, 2026: hybrid ordered gallery of up to 10 approved images per place; Storage URLs preferred, optional bundled copies as offline fallback, and a placeholder when no usable photo exists |
| Phase 2 photo presentation | Planned, not implemented: full-image portrait/landscape gallery display, accessible loading skeleton, and full-screen pinch-to-zoom viewer; card covers remain cropped |
| Student accounts, ratings, comments | No student profile or ratings/comments requested for browsing |
| Mood check-in | Optional and prioritized for class presentation; nickname may be used, but response must not be linked to a user profile. Persistence, nickname necessity, consent, retention, and access are open |
| Public landing/information page | Not needed for current class-demo deliverable |
| Hosting, services, costs, and operational ownership | Confirmed: Supabase Free plan for shared listings (no card, no paid add-ons). Paid plans and other services remain unapproved. Ownership of the Supabase organization is open |
| Distribution channel for APK handoff and account ownership | APK for presentation/testing; exact file handoff/account ownership open; Google Play not required |
| MVP prioritization and acceptance criteria | Feature ranking agreed; detailed acceptance criteria and deadline still open |

Implementation phases and per-phase acceptance criteria are tracked in `docs/MVP_PLAN.md`. When the team confirms or changes a product decision, update this brief and summarize the material change in `docs/AGENT_HANDOFF.md`.
