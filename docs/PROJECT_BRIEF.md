# Project Brief

## Working concept

An Android application to help students find suitable tambayan places in Malinta, Valenzuela City, particularly near PLV Annex and CPAG. Students should be able to consider available time, budget, preferred environment, and (if included) emotional needs when choosing a place.

The concept and feature direction below reflect the team's October 29, 2026 meeting agreement. Implementation details may still change based on feasibility, testing, and applicable requirements. This document records the agreed direction; it is not a complete technical specification.

## Goals and initial scope

- Help students discover places for studying, eating, relaxing, and socializing.
- Limit the initial coverage area to Malinta, particularly around PLV Annex and CPAG.
- Support Filipino (Tagalog) and English.
- Provide useful listing details, maps, estimated travel times, and filters so students can choose a suitable place.
- The development team will gather, manage, and verify initial listing information as much as possible.
- Shop owners will not need app accounts, identification submissions, or in-app payments. The development team manages listings and updates.

## Agreed product direction

### Platform and language

- **Platform:** Android application.
- **Languages:** Filipino (Tagalog) and English.
- **Framework, programming language, and minimum Android version:** Not selected.

### Places and listings

Initial categories include tambayan spots, coffee shops, open spaces and parks, karinderyas and affordable eateries, and other suitable study, eating, relaxation, and socializing locations.

Listings may include:

- Establishment name and address.
- Photographs.
- Amenities and environment.
- Estimated prices or price ranges when reliable information is available.
- Operating days and hours based on the latest information available.
- Other details relevant to students.

The development team is responsible for collecting and maintaining the initial listings and for verifying information as much as possible. Obtain appropriate permission for photographs or other materials when necessary. Listing freshness and how corrections are reported remain to be defined.

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

### Guidance and participation

- Provide a first-use introduction to the main features and keep instructions accessible in the app.
- Users may use nicknames instead of full names.
- Shop owners do not need app accounts, submit identification through the app, or make online payments; the development team manages initial listings and updates.

The concept does not yet specify whether nicknames require accounts, how users contribute content, or whether any user-generated content beyond optional mood check-ins is in scope.

### Optional mood check-in

The app may include an optional mood check-in after a user visits a listed place. The proposed responses are happy, relaxed, stressed, and sad. The team intends this to explore how environments and experiences may relate to student mood and well-being.

This feature is optional and its release scope is not confirmed. Before implementation, clarify whether mood responses are stored, linked to a nickname or visit, used only on-device or for aggregate research, who can access them, how long they are retained, and what consent and deletion controls are needed. Avoid presenting mood data as a psychological diagnosis or proven causal finding.

## Privacy, accuracy, and legal considerations

The team intends to establish terms and guidelines covering respectful use, listing accuracy, mood-related features, and reporting inaccurate information. The meeting notes identify the Philippine Data Privacy Act of 2012 (RA 10173) and Consumer Act of the Philippines (RA 7394) as laws to consider.

These are areas for further review, not a determination that a particular legal obligation applies or that the proposed design is compliant. Minimize personal and precise location data, explain permissions, and make useful discovery possible when location access is denied. Seek qualified guidance for legal requirements before launch, particularly if collecting or analyzing mood or location data.

Reassess these considerations whenever a feature change affects personal or precise location data, mood data, nicknames or other identifiers, listing accuracy, user reports, or consumer-facing price/service claims. Agents and developers must not treat this brief as legal advice or claim compliance; obtain qualified review for legal interpretations and final terms.

## Public landing/information page

Not decided. The contributor-facing repository README is not a product landing page. A separate static companion-page prototype may be considered to explain the app and demonstrate a future download button, but this does not confirm that the team wants a public page or that one should be hosted. Confirm its audience, content, distribution link, hosting, maintenance, and any domain costs before adding it to a committed release scope. See `docs/PROTOTYPE_SCOPE.md` for the optional prototype boundary.

## Decisions and open questions

| Topic | Current status |
|---|---|
| Initial product direction | Agreed Android campus-area place finder |
| Coverage | Agreed initial focus: Malinta near PLV Annex and CPAG |
| Languages | Agreed: Filipino (Tagalog) and English |
| Framework and programming language | Open |
| Minimum Android version and device support | Open |
| First release: class demo, installable test APK, or public production app | Open |
| Map renderer/data provider and routing provider | Open; these may be separate services |
| Travel modes and estimate presentation | Open |
| Meaning of "available time" in place selection | Open |
| Listing update cadence and correction/reporting process | Open |
| Listing count, photo source, and initial data collection responsibilities | Open |
| Admin editing workflow (provider console or custom tool) | Open |
| User accounts and nickname implementation | Open |
| Mood check-in | Optional proposal; data handling and release scope open |
| Public landing/information page | Open; validate need |
| Hosting, services, costs, and operational ownership | Open |
| Distribution channel and account ownership | Open |
| MVP prioritization and acceptance criteria | Open |

When the team confirms or changes a decision, update this brief and summarize the material change in `docs/AGENT_HANDOFF.md`.
