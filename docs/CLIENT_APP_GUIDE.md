# Kamus Tambay

## Client guide: what the application can do

This guide describes the application as it currently works in the class-demo
build. It focuses on what a student can do, what information the app shows,
and what the app does not yet guarantee.

## 1. Home screen

The home screen is the starting point of the app. It has three main choices:

- **Find a tambayan** opens the place list.
- **Mood check-in** opens the optional mood and visit check-in flow.
- **More** opens the side menu.

The home screen also provides access to the menu button and uses the Kamus
Tambay branding and supplied visual design.

## 2. Finding places

The place list is the main discovery feature. Students can:

- Browse the available tambayan places.
- Search by place name, neighborhood or area, and category.
- Choose whether they are starting near **PLV Annex** or **CPAG**.
- See places with valid map coordinates first, based on their distance from
  the selected campus starting point.
- Pull down to refresh the list when shared listing data is available.
- Open the map from the place list.
- Tap a place card to see its complete details.

The list displays a notice when it is using sample information or an offline
copy, so students can distinguish the demo data source from a recently
downloaded shared listing set.

## 3. Filters

The filter panel lets students narrow the list by:

- Place category, such as tambayan, coffee shop, park or open space, and
  affordable food.
- Maximum estimated budget.
- Whether the place is open now.
- Amenities such as Wi-Fi, air-conditioning, power outlets, or roomier
  capacity.
- Indoor or outdoor setting.
- Intended activity, including studying, eating, relaxing, or socializing.

Filters can be combined, applied, reset, or cleared. A counter shows how many
filters are active.

### Filter limitations

- The budget filter uses the stored estimated price range. It is not a live
  price check.
- A place without a reliable price range is not treated as free and is hidden
  when a budget limit is applied.
- “Open now” depends on the stored weekly schedule and Asia/Manila time.
- Places without structured hours cannot be confirmed as open and are excluded
  from the “Open now” results.
- Search is a simple text match. It is not a map-radius search, typo-tolerant
  search, or recommendation engine.
- Distance ordering is straight-line distance from the selected campus anchor,
  not walking distance or travel time.

## 4. Place details

Opening a place shows:

- Place name, category, and area.
- A demo or verification status where applicable.
- Photos or a no-photo placeholder.
- Photo captions and a full-screen photo viewer when photos are available.
- What the place is good for.
- Amenities.
- Estimated price or price range.
- Indoor or outdoor setting.
- Open or closed status when structured hours are available.
- The weekly opening-hours schedule.
- Address when one is available.
- Description and other supplied listing information.

Students can copy a displayed address and use the directions button when the
listing has a verified location.

### Place detail limitations

- Listing accuracy depends on the information supplied and maintained by the
  project team.
- Prices, hours, amenities, photos, and addresses may become outdated.
- The app does not allow shop owners to edit their own listings.
- The app does not process reservations, payments, orders, or in-app
  messaging.
- Directions open in Google Maps outside the app. The app does not calculate
  routes, walking time, traffic, or live travel estimates.
- Directions are unavailable when the location is not verified or coordinates
  are missing.

## 5. Map

The map displays:

- Fixed reference points for PLV Annex and CPAG.
- Place markers when a listing has valid coordinates.
- Place names beside markers.
- A horizontal place-card carousel for mapped places.
- A notice explaining that the map needs internet access and that places
  without valid coordinates are not shown.
- A map attribution control and provider information for the map data and
  style.

Students can tap a map marker or place card to open the same place details
shown from the list.

### Map limitations

- The app does not request or track the student’s GPS location.
- The campus points are fixed reference points, not the student’s live
  location.
- Places without valid coordinates cannot appear as map markers.
- The map requires an internet connection to load its online map style and
  tiles.
- The map is a discovery map, not a navigation or route-planning service.

## 6. Mood check-in

Mood check-in is an optional flow separate from browsing places. A student
can:

1. Read the purpose and privacy information.
2. Review and accept the check-in consent notice.
3. Select **where they went** from the available tambayan places.
4. Choose how they felt:
   - Happy
   - Relaxed
   - Stressed
   - Sad
5. Add an optional nickname.
6. Review the selected place, mood, and nickname.
7. Submit the anonymous check-in.
8. Start another check-in or return home.

The check-in does not use GPS and does not require an account or student
profile. The nickname is optional, but the app warns that a unique nickname
could still identify someone.

When the shared service is configured, the check-in is sent to the mood
check-in database. If submission cannot reach the service, the app places the
check-in in an offline retry queue and can retry it later.

### Mood check-in limitations

- A student can select only from places currently supplied to the app.
- The check-in records the selected place and mood; it does not prove that the
  student visited the place.
- The app does not diagnose mental health or provide counselling.
- The nickname is not a secure identity system and should not be treated as
  anonymous if it identifies the student.
- The check-in requires the project’s approved database setup and privacy
  decisions before it should be treated as a production service.
- Aggregate mood summaries are supported by the data layer, but the current
  student-facing flow is primarily for submitting a check-in.

## 7. Shared listings and offline behavior

The application can use two listing sources:

- A shared online listing service for the team’s maintained data.
- Bundled sample listings included with the app.

The app uses the bundled listings when shared service configuration is absent
or unavailable. After a successful non-empty shared download, it can retain a
local copy for offline browsing. The app does not silently replace a useful
saved listing set with an empty response.

### Data and connectivity limitations

- The online listing service must be configured separately for shared data to
  work.
- Offline mode cannot provide new online map tiles, current external
  directions, or newly updated listings.
- The app does not include an administrator screen. Authorized team members
  maintain listings through the configured backend.
- The bundled and demo information should not be presented as verified
  business information until the team supplies and reviews the final dataset.

## 8. Language support

The interface supports:

- English
- Filipino (Tagalog)

Students can switch languages from the side menu. The selected language is
used by the app interface, filters, place detail labels, mood flow, notices,
and guide screens.

### Language limitation

The language switch covers the app’s supplied interface and bilingual listing
fields. It cannot translate newly entered backend content automatically.

## 9. Onboarding and instructions

The first-launch visual guide introduces:

1. Finding nearby tambayan places.
2. Using filters.
3. Reviewing a place and opening directions.

The guide can be skipped. The detailed Instructions screen can be reopened
from the side menu and explains the main discovery, filtering, details, map,
and information behaviors.

## 10. Side menu and information pages

The side menu provides:

- Home
- Instructions
- Vision & Mission
- Privacy
- Terms & Conditions
- English/Filipino language switching
- App version information

Vision & Mission, Privacy, and Terms & Conditions are clearly marked
informational or draft content until the client supplies and approves final
copy.

## 11. Privacy and account limitations

The current application:

- Does not require registration or login.
- Does not create student accounts or profiles.
- Does not request live GPS location.
- Does not provide in-app payments.
- Does not provide an owner/admin account screen.
- Treats the mood check-in as optional.

The mood check-in and listing backend still require the project team to confirm
retention, access, deletion, consent wording, and operational responsibilities
before production use. This document describes application behavior; it is
not a legal or privacy compliance assessment.

## 12. Current class-demo scope

The application is suitable for demonstrating:

- Student place discovery near PLV Annex and CPAG.
- Search and practical place filters.
- Place details and photo viewing.
- A campus-reference map.
- External Google Maps directions for verified listings.
- Bilingual navigation and instructions.
- Optional anonymous mood check-ins with place selection.
- Online listing synchronization with local fallback behavior.

It is not yet a complete production marketplace, navigation service, business
management system, or verified source of current commercial information.
