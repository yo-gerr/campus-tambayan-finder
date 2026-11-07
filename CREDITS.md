# Credits and Third-Party Notices

Kamus Tambay is a class-demo Flutter app for Android. This file lists the
third-party data, services, software, fonts, and artwork the app uses, and the
attribution each one requires. It mirrors the in-app **Credits** screen
(sidebar → Credits) and is the public reference for this repository.

> This is an attribution and engineering inventory, not legal advice. Licence
> terms can change. Recheck each source before distribution. Questions about
> ODbL share-alike, the repository licence, or asset ownership should go to a
> qualified professional.

## Where attribution appears

- **Map:** an always-visible chip reads
  `© OpenStreetMap contributors · OpenFreeMap · OpenMapTiles`. Each name opens
  its own project page, so the ODbL and OpenMapTiles link requirements are both
  met on the map itself.
- **Credits screen:** the full inventory below, with links to the original
  projects and policies.
- **Licence page:** `Sidebar → Credits → Open source licenses` lists the Flutter
  package licences plus the bundled Fredoka and Nunito OFL texts.
- **Repository:** this file.

## Summary

| Work | Used for | Licence or terms | Attribution shown |
| --- | --- | --- | --- |
| OpenStreetMap contributors | Map and route data | ODbL 1.0 | `© OpenStreetMap contributors` + copyright link |
| OpenFreeMap (Hyperknot Software Kft.) | Vector tiles and the Positron style | Free public service; no SLA | `OpenFreeMap` + project link |
| OpenMapTiles | Tile schema and cartography | CC BY 4.0 (design); BSD-3-Clause (code) | `© OpenMapTiles` + project link |
| Natural Earth | Shaded-relief raster (`ne2_shaded`) | Public domain | Courtesy credit |
| MapLibre GL Native / `maplibre_gl` | Map renderer | BSD-style | Flutter licence page |
| Flutter and Dart | App framework and runtime | BSD-3-Clause | Flutter licence page |
| Material Icons | Interface icons | Apache-2.0 | Flutter licence page |
| Supabase / `supabase_flutter` | Shared listings | MIT (SDK); PostgreSQL licence (service) | Flutter licence page |
| `url_launcher`, `shared_preferences` | Flutter utilities | BSD-3-Clause | Flutter licence page |
| `cupertino_icons` | Icon font dependency | MIT | Flutter licence page |
| Fredoka | Heading typeface | SIL Open Font License 1.1 | Bundled OFL text + licence page |
| Nunito | Body typeface | SIL Open Font License 1.1 | Bundled OFL text + licence page |
| `flutter_native_splash` | Build-time splash generation | MIT | This file |
| Google Maps | External directions hand-off | Google Maps terms apply when opened | This file |

## Map data and rendering

### OpenStreetMap contributors

- Source: <https://www.openstreetmap.org/copyright>
- Licence: Open Data Commons Open Database License (ODbL) 1.0.
- Use: the map's vector tiles are derived from OpenStreetMap data.
- Required attribution: `© OpenStreetMap contributors`, with a link to the
  copyright page. The map chip provides it.
- Map corrections: <https://www.openstreetmap.org/fixthemap>. The Credits screen
  links to this page so viewers can report errors.
- Caveat: ODbL share-alike obligations for a derived database are an owner
  review item. This project does not claim that its cache or exports are
  compliant.

### OpenFreeMap

- Source: <https://openfreemap.org/> and <https://openfreemap.org/tos/>
- Terms: free public service, provided as-is with no warranty or SLA. The
  service may be discontinued without notice; it may use Cloudflare as a CDN.
- Attribution: OpenFreeMap's quick-start page shows
  `OpenFreeMap © OpenMapTiles Data from OpenStreetMap`.
- Use: `https://tiles.openfreemap.org/styles/positron` supplies the vector tiles,
  glyphs, sprites, and the Positron style. The style includes a Natural Earth
  shaded-relief raster source.
- Offline limits: at most 3,000 tiles or 50 MB per download, at most four
  parallel requests, and a unique identifying User-Agent. This app does not
  offer offline map downloads.
- Caveat: the style JSON has no `attribution` metadata, so the MapLibre info
  button alone would show nothing. The app therefore shows the map chip.

### OpenMapTiles

- Source: <https://www.openmaptiles.org/> and
  <https://github.com/openmaptiles/openmaptiles/blob/master/LICENSE.md>
- Licence: the code is BSD-3-Clause; the cartography and visual design are
  CC BY 4.0.
- Required attribution: visible `© OpenMapTiles` with a link to
  <https://www.openmaptiles.org/>. The map chip provides it.
- Note: the OpenMapTiles licence states that the schema was initially modelled
  after CARTO's Positron basemap with permission from CartoDB Inc.

### Natural Earth

- Source: <https://www.naturalearthdata.com/>
- Licence: public domain. No permission is needed; credit is courtesy only.
- Use: the `ne2_shaded` raster source in the Positron style.

### MapLibre GL Native and `maplibre_gl`

- Source: <https://maplibre.org/> and
  <https://github.com/maplibre/flutter-maplibre-gl>
- Licence: BSD-style. The full text is included in the Flutter-generated
  `NOTICES` file and shown on the in-app licence page.
- Use: Android map rendering, camera control, markers, and the attribution
  control.

## Deferred ETA

Live ETA and routing-service integration were removed from the lower-priced
delivery scope. Any future routing provider, cache, attribution, and legal
review will require a separately approved phase.

## Platform and libraries

### Flutter and Dart

- Source: <https://flutter.dev/> and <https://dart.dev/>
- Licence: BSD-3-Clause. The licence text is included in the Flutter-generated
  `NOTICES` file and shown on the in-app licence page.

### Material Icons

- Source: <https://fonts.google.com/icons>
- Licence: Apache-2.0. Included with Flutter's Material icon font and shown on
  the in-app licence page.

### Supabase and `supabase_flutter`

- Source: <https://supabase.com/> and
  <https://pub.dev/packages/supabase_flutter>
- Licence: the Flutter SDK is MIT. The hosted service runs PostgreSQL and
  related components under their own licences.
- Use: read-only shared listings and the shared route cache on the Supabase
  Free plan. The publishable key ships in the app by design; row-level security
  is the security boundary.

### Other Dart packages

`url_launcher`, `shared_preferences`, and `http` are BSD-3-Clause.
`cupertino_icons` is MIT. `flutter_native_splash` is MIT, and `flutter_lints`
is BSD-3-Clause; both are build-time only. All runtime package licences are
collected into the generated `NOTICES` file and shown on the in-app licence
page.

## Fonts

### Fredoka

- Copyright 2016 The Fredoka Project Authors
  (<https://github.com/hafontia/Fredoka-One>).
- Licence: SIL Open Font License 1.1.
- The full licence text is bundled at `assets/fonts/OFL-fredoka.txt` and
  registered with Flutter's licence registry at startup.

### Nunito

- Copyright 2014 The Nunito Project Authors
  (<https://github.com/googlefonts/nunito>).
- Licence: SIL Open Font License 1.1.
- The full licence text is bundled at `assets/fonts/OFL-nunito.txt` and
  registered with Flutter's licence registry at startup.

## External links

### Google Maps

- Source: <https://www.google.com/maps>
- Use: the Directions button hands a verified destination to Google Maps. The
  app embeds no Google map, uses no Google Maps API key, and receives no Google
  content or data.
- Terms: Google Maps terms apply to the external app or website that opens. This
  repository does not redistribute Google map data.

## Content and brand assets

- The bundled listings (`assets/data/sample_places.json` and the demo rows in
  Supabase) are fictional class-demo samples. Names, prices, hours, photos, and
  coordinates are illustrative, not real business data.
- The brand images (`assets/brand/wordmark.png`, `student_male.png`,
  `splash.png`, `splash_android12.png`) are provisional client-supplied
  artwork. Ownership and permission to redistribute them publicly are not yet
  confirmed. Do not treat them as licensed project assets.

## Repository licence

This repository has **no `LICENSE` file**. No open-source licence is granted
for the project's own source code, documentation, or artwork. Choosing a
licence (or keeping the repository unlicensed) is an owner decision. Third-party
components remain under their own licences listed above.

## Open review items

- Choose a repository licence, or record that the repository stays unlicensed.
- Confirm ownership and redistribution permission for the brand images.
- Review ODbL obligations for the shared route cache with a qualified
  professional.
- Audit native/Gradle transitive dependencies (for example AndroidX, Kotlin,
  MapLibre Native, OkHttp) before a public release. Flutter's `NOTICES` covers
  Dart packages, not every native artifact.
- Record the final in-app ETA product decision. The live path remains deferred
  and opt-in.

## Maintenance

Update this file and the in-app Credits screen whenever a provider, dependency,
font, asset, or external link changes. Recheck the linked terms on each release
and when a Free-plan provider changes its policy.

Sources checked 2026-11-07. Terms and versions can change.
