# Kumus Tambay — Client User Guide & Feature Walkthrough

Welcome to **Kumus Tambay** (Campus Tambayan Finder)! This guide provides a non-technical overview of all the app's features, how students use it to discover study and tambayan spots near **PLV Annex** and **CPAG**, and instructions on capturing screenshots for your client presentation.

---

## 1. Home Screen Hub & Navigation

The **Home Screen** is the central hub of the application. It uses a clean, friendly campus design with three main speech-bubble buttons:

* 🔍 **Find a tambayan:** Opens the complete place list and search dashboard.
* 😊 **Mood check-in:** Opens the voluntary, 4-step anonymous mood feedback wizard.
* ≡ **More (Top-Right Menu Button):** Opens the side menu drawer from any screen.

The home screen displays the Kumus Tambay wordmark, logo badge, mascot artwork, and cream/sky campus theme.

> 📷 **Screenshot Opportunity #1: Home Screen Hub**
> * **What to capture:** Open the app to the main Home screen showing the wordmark, student mascot, and 3 speech bubbles (**Find a tambayan**, **Mood check-in**, **More**).
> * **Save image as:** `docs/screenshots/01_home_screen.png`
>
> ![Screenshot 1: Home Screen Hub](screenshots/01_home_screen.png)

---

## 2. Finding & Sorting Tambayan Places

The **Explore Dashboard** allows students to discover local study spots, cafes, eateries, and parks in Malinta:

* 🔎 **Quick Search:** Type place names, neighborhoods, or categories in the search bar.
* 📍 **Campus Distance Sorting:** Tap **PLV Annex** or **CPAG** at the top ("Starting near") to automatically sort places by distance to that campus building!
* 🔄 **Pull-to-Refresh:** Swipe down at the top of the list to instantly fetch the latest place listings from Supabase and update offline storage.
* 🌐 **Offline Browsing:** If offline, the app automatically loads the saved snapshot so browsing never stops.

> 📷 **Screenshot Opportunity #2: Explore Place List & Campus Sorting**
> * **What to capture:** Tap **Find a tambayan** on Home. Capture the place list with the "Starting near PLV Annex / CPAG" selector at the top.
> * **Save image as:** `docs/screenshots/02_explore_list.png`
>
> ![Screenshot 2: Explore Place List](screenshots/02_explore_list.png)

---

## 3. Smart Filters & Live Operating Hours

Students can customize their search using preset filter chips:

* 💰 **Budget Chips:** Select preset spending limits (₱50, ₱100, ₱150, ₱200, ₱300, ₱500) or "Any budget".
* 🕒 **Open Now Filter:** Shows only places currently open, evaluated live in **Asia/Manila time** (fixed UTC+8).
* ⚡ **Amenities:** Filter by Free Wi-Fi, Aircon, Power Outlets, or Roomy capacity.
* 🌳 **Setting & Activities:** Filter by Indoor/Outdoor setting or intended activity (Study, Eat, Relax, Socialize).

> 📷 **Screenshot Opportunity #3: Filter Options Sheet**
> * **What to capture:** Tap the **Filters** button on the Explore screen. Capture the filter modal showing preset budget chips, amenities, and "Open now" toggle.
> * **Save image as:** `docs/screenshots/03_filters_sheet.png`
>
> ![Screenshot 3: Filter Options Sheet](screenshots/03_filters_sheet.png)

---

## 4. Place Details & Photo Gallery

Tapping any place card opens a complete detail sheet:

* 🖼️ **Swipeable Photo Gallery:** Swipe through photos or tap to open in a full-screen pinch-to-zoom viewer.
* 📅 **Per-Day Weekly Schedule:** View full operating hours from Monday to Sunday.
* 🏷️ **Facts & Badges:** Live **Bukas ngayon** (Open now) or **Sarado ngayon** (Closed now) status badges, estimated spend, address, and amenities.
* 🗺️ **Google Maps Directions:** Tap **Directions** to open turn-by-turn navigation directly in the Google Maps app for verified locations.

> 📷 **Screenshot Opportunity #4: Place Detail Sheet & Photo Gallery**
> * **What to capture:** Tap on a place card (e.g., *Sample Kape Stop*). Capture the open detail sheet showing place photos, operating hours, and the Google Maps Directions button.
> * **Save image as:** `docs/screenshots/04_place_details.png`
>
> ![Screenshot 4: Place Detail Sheet](screenshots/04_place_details.png)

---

## 5. Interactive Campus Map

The **Map** offers visual location discovery:

* 📍 **Campus Anchors:** Clear, fixed reference pins for **PLV Annex** and **CPAG**.
* 🏪 **Place Markers & Closed Styling:** Open places render active blue markers; closed places render in muted slate grey (`#5A6485`) with outlines.
* 🎴 **Bottom Card Carousel:** Swipe through place cards at the bottom of the map. Tapping a card or pin opens shop details.

> 📷 **Screenshot Opportunity #5: Interactive Map & Place Carousel**
> * **What to capture:** Tap **View map** on the Explore list. Capture the map screen showing PLV Annex / CPAG pins, place markers, and the bottom place carousel.
> * **Save image as:** `docs/screenshots/05_map_view.png`
>
> ![Screenshot 5: Interactive Map View](screenshots/05_map_view.png)

---

## 6. Anonymous Mood Check-in

Students can voluntarily share how their visit went:

* 1️⃣ **Select Place:** Choose the establishment visited.
* 2️⃣ **Choose Mood:** Select 1 of 4 mood icons (😊 Happy, 😌 Relaxed, 😰 Stressed, 😢 Sad).
* 3️⃣ **Privacy Disclosure & Optional Nickname:** Clear consent disclosure explaining 100% anonymous storage, no GPS tracking, and an optional nickname field with a privacy warning tip.
* 4️⃣ **Submit Check-in:** Inserts response into Supabase `public.mood_check_ins` with automated 90-day retention and offline queueing.

> 📷 **Screenshot Opportunity #6: Mood Check-in Step**
> * **What to capture:** Tap **Mood check-in** from Home or the menu. Capture Step 2 or 3 showing the mood icons and privacy tip.
> * **Save image as:** `docs/screenshots/06_mood_checkin.png`
>
> ![Screenshot 6: Mood Check-in Step](screenshots/06_mood_checkin.png)

---

## 7. Bilingual Experience (Tagalog / English) & Sidebar Menu

* 🇵🇭 / 🇬🇧 **Bilingual Support:** Switch between **English** and **Filipino (Tagalog)** anytime from the sidebar drawer.
* ☰ **Universal Access:** Tapping the menu button at the top-right of any screen opens the sidebar to access Home, Instructions, Vision & Mission, Privacy, Terms & Conditions, and Language settings.

> 📷 **Screenshot Opportunity #7: Sidebar Menu & Language Switcher**
> * **What to capture:** Tap the top-right menu button to open the sidebar drawer showing navigation destinations and the language toggle.
> * **Save image as:** `docs/screenshots/07_sidebar_menu.png`
>
> ![Screenshot 7: Sidebar Drawer Menu](screenshots/07_sidebar_menu.png)

---

## Summary of Screenshots to Capture for Presentation

| # | Screen Name | Action to Capture | Recommended Filename |
| :--- | :--- | :--- | :--- |
| **1** | Home Hub | Main screen with speech bubbles & logo | `01_home_screen.png` |
| **2** | Explore List | Place list with "Starting near PLV Annex / CPAG" | `02_explore_list.png` |
| **3** | Filters Sheet | Filter modal with budget chips & "Open now" toggle | `03_filters_sheet.png` |
| **4** | Place Details | Detail sheet showing photos & Google Maps button | `04_place_details.png` |
| **5** | Interactive Map | MapLibre map with campus pins & bottom carousel | `05_map_view.png` |
| **6** | Mood Check-in | 4-step check-in wizard with mood icons | `06_mood_checkin.png` |
| **7** | Sidebar Menu | Side drawer with language toggle | `07_sidebar_menu.png` |
