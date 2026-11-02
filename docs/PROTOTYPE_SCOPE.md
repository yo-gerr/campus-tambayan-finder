# Clickable Prototype Scope

## Purpose and status

Define a reviewable Android prototype for an installable APK used in a class presentation and testing. The team does not require Google Play publication or a separate public webpage for this delivery.

The agreed product direction is an Android app for students near PLV Annex and CPAG in Malinta, with Filipino (Tagalog) and English support. Flutter is a **provisional prototype choice**, not a confirmed school or production requirement. If the team requires another framework, this prototype can still communicate screens and interactions, but its code may not be reusable.

This document records the current class-demo target, not a production release, selected service provider, or final client quote. Flutter remains provisional: the school has not required a particular framework or programming language.

## Delivery target and priorities

The requested deliverable is an installable Android APK for class presentation/testing; no Google Play release or public landing page is needed. The team ranked the presentation features in this order:

1. Place listings and details.
2. Map.
3. Optional mood check-in.
4. Estimated travel time.
5. Filipino and English language options.
6. Introductory guide.

## Recommended prototype boundary

- Flutter Android prototype, pending no school framework requirement, with local sample data until the team supplies the listing set.
- The target initial dataset is approximately 15–20 establishments. The team will provide a compiled list, available photos, and available information, including names, locations, descriptions, operating hours, and prices.
- No custom admin screen; authorized team members will make listing edits manually using a provider dashboard once the provider and access controls are decided.
- For the current prototype, keep using local sample data. Whether the class-demo APK must load a shared online listing set or may package the team-provided listings locally is still open; do not choose a backend/provider or configure billing without confirmation.
- No student accounts, API credentials, billing configuration, or real user data.
- No real-device location permission request.
- Use a simple locally drawn schematic map or placeholder map visual. Do not present it as a real or accurate map.
- Directions should open Google Maps rather than implement in-app navigation. Do not add a Maps SDK or Routes API, promise in-app ETA, or configure billing until the ETA presentation and service requirements are confirmed.
- Focus on browsing listings, viewing details, filtering, and demonstrating the agreed presentation priorities with clearly simulated behavior where required.

## Provisional visual direction

Use a calm, welcoming local-guide style that feels suitable for students without becoming childish or overly gamified. Treat this as a design hypothesis to review with the team, not as approved branding or a final production design.

- Use Android Material 3 patterns for familiar navigation, controls, and accessibility behavior.
- Start with a warm neutral background, deep teal/green primary actions, light sage secondary surfaces, and restrained terracotta accents. Example exploration colors: `#215B50`, `#F7F5EF`, `#E7EEE8`, and `#B4543A`. Check actual text/background contrast before use; these values are not finalized.
- Prefer Roboto or the platform default sans-serif for readable English and Tagalog labels. Check long translated strings and Android font scaling.
- Use clear place cards, recognizable icons with text labels, simple filter chips, and an obvious list/map switch. Keep prices and hours easy to scan.
- Use only approved images; otherwise use clearly labeled placeholders.
- Do not rely on color alone to convey category, status, price, or amenities.
- If dark mode is explored, ensure semantic colors and contrast work in both themes rather than simply inverting the palette.

Collect student/team feedback on clarity, tone, readability, and color before settling a visual identity.

## Features to prototype

### 1. First-use guide

- Show a short, dismissible introduction to browsing places, filtering, and viewing details.
- Provide a Help/Instructions action that opens the guide again.
- Do not block browsing if the user dismisses it.

### 2. Explore places

- Show sample places in a scrollable list or cards.
- Include category labels such as tambayan, coffee shop, park/open space, and affordable eatery.
- Show sample name, general area, indicative price range, and a few amenities.
- Include a simple way to switch the starting campus between PLV Annex and CPAG if it helps demonstrate the agreed travel-origin concept.
- Mark all sample records and values as demo content; do not imply that prices, hours, amenities, or listings are verified.

### 3. Filters

- Filter the local sample list by category.
- Demonstrate a simple budget range.
- Demonstrate a small selection of agreed amenities (Wi-Fi, air conditioning, electrical outlets) and setting/activity (indoor/outdoor; study/eat/relax/socialize).
- Include clear Apply, Reset, and empty-results states.
- Treat opening days/hours and estimated travel time as separate details. Do not invent a separate “available time” filter or a time-staying feature.

### 4. Place details

- Open a detail view from a place card or map marker.
- Show sample address/area, categories, amenities, price estimate, hours, and photos or safe placeholders.
- Label uncertain or illustrative values as sample data.
- Show a last-reviewed placeholder only if clearly marked as demo content; do not imply a real verification process has occurred.

### 5. Map interaction

- Show a schematic map panel with sample pins corresponding to sample listings.
- Selecting a pin and selecting a place card should lead to the same place details.
- Show PLV Annex or CPAG as the selected origin if that interaction is included.
- The team prefers a Directions action that opens Google Maps. In the prototype, use an explicit preview/simulation or a Google Maps URL only when suitable sample coordinates are available; do not imply sample pins are real locations.
- The team ranked estimated travel time as a priority, but has not specified whether it should be shown inside the app or by Google Maps. Clarify this before implementing a live ETA integration. Do not call a routing API, request a key, or configure billing for the prototype.
- Clearly mark the map as illustrative and not for navigation.

### 6. Language selection

- Provide a visible English/Filipino toggle for the prototype's main interface and sample labels.
- Keep both languages aligned in meaning.
- Use placeholder translations only when reviewed by the owner/team; do not imply unreviewed translation is final copy.

### 7. Optional mood check-in

- The team wants an optional mood check-in and ranked it third for the class presentation.
- A nickname may be used, but the mood response must not be linked to a student profile; no student account/profile is requested for browsing.
- For the prototype, demonstrate the interaction with sample-only or transient state. Do not store actual mood responses or nicknames, add history/analytics, or imply research findings.
- Before any persistent mood collection, clarify whether nickname entry is optional and per check-in, consent and purpose, who can access responses, retention/deletion, and whether responses are intended for aggregate analysis. Do not present responses as diagnoses or causal evidence.

## Suggested review flow

1. Dismiss or revisit the short guide.
2. Choose PLV Annex or CPAG as a starting point, if included.
3. Browse sample places and apply one or more filters.
4. Open a place's details from the list or schematic map.
5. Try the Directions action and see a clear prototype-only response.
6. Switch the interface language.
7. Optionally submit a sample mood check-in and verify it is not linked to a profile or persisted.

## Explicitly out of scope for this prototype

- Firebase, Supabase, or any other backend, database, authentication, or cloud storage.
- Custom admin screen, provider-dashboard setup, and cross-device synchronization.
- Student or shop-owner accounts, persistent nicknames, ratings, comments, submissions, or reports.
- Persistent mood check-ins, mood history, analytics, or research use. A non-persistent optional sample-only check-in is described above.
- Live GPS, background location, or device permission prompts.
- In-app Google Maps/MapLibre/OpenStreetMap SDK or tile integration, geocoding, or live route/ETA services. External Google Maps directions may be opened as described above; do not imply sample coordinates are real.
- Production listing research, field visits, photography, verification, or permission-seeking unless separately agreed as project work.
- Public landing page, domain/hosting setup, Google Play publication, production security, or legal terms.

These are not rejected product ideas; they require confirmation and may materially affect cost, privacy, technical design, or maintenance.

## Prototype acceptance checklist

- An Android APK can be built, installed, and launched for class presentation/testing; Google Play publication is not required.
- The main browsing, filtering, and detail interactions can be demonstrated without a network connection.
- Selecting a filter changes the visible sample results and Reset restores them.
- A place can be opened from both the list and schematic map.
- The language control changes the prototype interface copy.
- The onboarding guide can be dismissed and opened again.
- The optional mood check-in is clearly optional and does not create a profile or persist mood/nickname data.
- Prototype-only map/directions behavior and sample listing data are clearly identified as illustrative.
- No real credentials, personal information, mood data, or location data are collected.

## Replaceable implementation seams

When implementation begins, keep sample places behind a small data-source/repository boundary and keep map actions behind a presentation/application boundary. This makes local sample data and simulated map actions easier to replace after the team confirms a backend or provider. Avoid building generalized frameworks or production abstractions just for the prototype.

## Decisions to confirm before production

Use the [project brief](PROJECT_BRIEF.md) and scope-question answers to track remaining decisions: deadline and acceptance criteria; listing template, photo permissions, translation source and verification; map provider; whether ETA is shown in-app or by Google Maps and which travel modes apply; mood nickname necessity and data handling; provider dashboard/access control; service/account ownership; and final app name/logo/assets.
