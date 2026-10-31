# Clickable Prototype Scope

## Purpose and status

Define a small, reviewable prototype that can be built while the team clarifies delivery, budget, framework requirements, and service choices. It is intended to make the core place-discovery experience tangible and collect feedback before committing to production architecture.

The agreed product direction is an Android app for students near PLV Annex and CPAG in Malinta, with Filipino (Tagalog) and English support. Flutter is a **provisional prototype choice**, not a confirmed school or production requirement. If the team requires another framework, this prototype can still communicate screens and interactions, but its code may not be reusable.

This document is a prototype plan, not approval of a final MVP, production release, provider, or client quote. Confirm the scope and budget with the team before treating it as a committed deliverable.

## Recommended prototype boundary

- Flutter Android prototype with local, clearly fictional/sample data.
- No backend, accounts, API credentials, billing configuration, or real user data.
- No real-device location permission request.
- Use a simple locally drawn schematic map or placeholder map visual. Do not present it as a real or accurate map.
- Focus on navigating, filtering, and viewing places; simulate actions that would later use external services.

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
- Do not implement “available time” filtering until the team clarifies whether it means travel duration or time available to stay.

### 4. Place details

- Open a detail view from a place card or map marker.
- Show sample address/area, categories, amenities, price estimate, hours, and photos or safe placeholders.
- Label uncertain or illustrative values as sample data.
- Show a last-reviewed placeholder only if clearly marked as demo content; do not imply a real verification process has occurred.

### 5. Map interaction

- Show a schematic map panel with sample pins corresponding to sample listings.
- Selecting a pin and selecting a place card should lead to the same place details.
- Show PLV Annex or CPAG as the selected origin if that interaction is included.
- A “Directions” action may show a prototype message or a nonfunctional preview. Do not call a live routing API, request a key, promise an ETA, or launch navigation unless that behavior is separately approved.
- Clearly mark the map as illustrative and not for navigation.

### 6. Language selection

- Provide a visible English/Filipino toggle for the prototype's main interface and sample labels.
- Keep both languages aligned in meaning.
- Use placeholder translations only when reviewed by the owner/team; do not imply unreviewed translation is final copy.

## Suggested review flow

1. Dismiss or revisit the short guide.
2. Choose PLV Annex or CPAG as a starting point, if included.
3. Browse sample places and apply one or more filters.
4. Open a place's details from the list or schematic map.
5. Try the Directions action and see a clear prototype-only response.
6. Switch the interface language.

## Explicitly out of scope for this prototype

- Firebase, Supabase, or any other backend, database, authentication, or cloud storage.
- Custom admin screen, provider-dashboard setup, and cross-device synchronization.
- Student or shop-owner accounts, persistent nicknames, ratings, comments, submissions, or reports.
- Mood check-ins, mood history, analytics, or research use.
- Live GPS, background location, or device permission prompts.
- Google Maps, MapLibre, OpenStreetMap tile-provider integration, geocoding, or live route/ETA services.
- Production listing research, field visits, photography, verification, or permission-seeking unless separately agreed as project work.
- Public landing page, domain/hosting setup, Play Store publication, production security, or legal terms.

These are not rejected product ideas; they require confirmation and may materially affect cost, privacy, technical design, or maintenance.

## Prototype acceptance checklist

- The main browsing, filtering, and detail interactions can be demonstrated without a network connection.
- Selecting a filter changes the visible sample results and Reset restores them.
- A place can be opened from both the list and schematic map.
- The language control changes the prototype interface copy.
- The onboarding guide can be dismissed and opened again.
- Prototype-only map/directions behavior and sample listing data are clearly identified as illustrative.
- No real credentials, personal information, mood data, or location data are collected.

## Replaceable implementation seams

When implementation begins, keep sample places behind a small data-source/repository boundary and keep map actions behind a presentation/application boundary. This makes local sample data and simulated map actions easier to replace after the team confirms a backend or provider. Avoid building generalized frameworks or production abstractions just for the prototype.

## Decisions to confirm before production

Use the [project brief](PROJECT_BRIEF.md) and the scope-question document with the team to resolve the target deliverable, deadline and must-haves, meaning of “available time,” direction/ETA behavior, listing count and data responsibility, update workflow, student participation and mood handling, service costs/account ownership, school framework requirements, app name/assets, and distribution.
