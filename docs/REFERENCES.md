# Product and Implementation References

Curated external references for product discovery and implementation research. These are inspiration and research leads, not approved requirements or code to copy. Apply useful ideas only after checking fit with the confirmed project scope and applicable licenses.

## How to use this list

For each reference, record:

- Project name and canonical URL.
- What is relevant to this project and a concrete pattern or user flow worth studying.
- License and attribution requirements when source code or assets are involved. Verify the current license at the source before reuse; a public repository is not automatically open source.
- Date checked and any limitations (for example, stale project, different audience, or platform-specific assumptions).

Prefer linking to the original source rather than copying source code, assets, screenshots, or substantial text into this repository. If reuse is proposed, review the exact license and compatibility first, identify attribution obligations, and get owner approval before adding third-party code or assets.

## References to investigate

### Official platform and service documentation

These are official service references researched on 2026-10-30 to compare likely implementation options. Pricing and product terms can change; recheck them when choosing providers and before launch.

#### Google Maps Platform pricing
- Source: https://developers.google.com/maps/billing-and-pricing/pricing
- Relevant ideas: Separate map display, routing, places, and geocoding into their own usage-based services when estimating cost.
- Adaptation notes: The current global pricing list shows the native Maps SDK for Android with an unlimited no-cost usage cap, while Routes Essentials has a 10,000-event monthly free usage cap and then usage-based USD pricing. This does not make every Google Maps service free.
- Caveats: Verify the exact SKU, account billing configuration, region, API enablement, quotas, and current terms. Budget alerts are not the same as a hard spending cap.

#### Google Routes API billing and usage
- Source: https://developers.google.com/maps/documentation/routes/usage-and-billing
- Relevant ideas: Route estimates are a distinct API from displaying a map; request features determine the billed SKU.
- Adaptation notes: For a low-cost MVP, consider opening directions in a navigation app rather than calculating and displaying routes inside the app, if that satisfies the requirement.
- Caveats: Routes calls are usage-based; advanced options can use higher-priced SKUs. Verify current rates and quota behavior.

#### OpenStreetMap data and tile usage
- Source: https://www.openstreetmap.org/copyright and https://operations.osmfoundation.org/policies/tiles/
- Relevant ideas: OSM data can be used under the ODbL with attribution, but map data and the public tile service are different things.
- Adaptation notes: An OSM-based Android map still needs a renderer/library and a tile source. Use a suitable provider or hosting plan for an app rather than assuming the community tile servers are a free production map API.
- Caveats: The public tile service is best-effort, has no SLA, imposes caching/attribution/identification requirements, and may block unsuitable usage. Check ODbL obligations for data use.

#### MapLibre Flutter
- Source: https://pub.dev/packages/maplibre_gl and https://github.com/maplibre/flutter-maplibre-gl
- License: The package includes a BSD-style license; review its full license and bundled notices before distribution (checked 2026-11-04).
- Relevant ideas: MapLibre is an open-source renderer, not map data or a tile-hosting service. Its Flutter plugin supports Android, custom vector-map styles, markers, and other map layers.
- Adaptation notes: A MapLibre style can be customized to use a warm, calm palette and emphasize useful campus features. Pair it with a separately selected style/tile source; do not make MapLibre itself responsible for listing coordinates or route estimates.
- Caveats: The current pub.dev page requires Flutter 3.44+, Dart 3.12+, JDK 21, and Android 7.0/API 24+. Confirm the demo devices meet the Android minimum. A map still needs network access unless offline tiles are deliberately prepared.

#### OpenFreeMap public instance
- Source: https://openfreemap.org/, https://openfreemap.org/quick_start/, and https://openfreemap.org/tos/
- Relevant ideas: OpenFreeMap serves OSM-derived vector tiles and MapLibre-compatible styles. Its site currently says the public instance has no registration, API key, view limit, or fee; the map styles can be customized.
- Adaptation notes: It is a candidate tile/style source for a small, internet-connected class demo using MapLibre. Its current terms allow commercial use and limit offline downloads to 3,000 tiles or 50 MB per download, at most four parallel requests, with a unique identifying User-Agent. Its quick start says a customized style JSON must be hosted by the app developer; verify whether the Flutter plugin can instead load an app-bundled style before introducing a separate hosting service.
- Caveats: The service is donation-supported, supplied as-is with no warranty or SLA, and may be discontinued without notice. Its terms (last updated 2026-10-14) require an integrator to be at least 18 and legally able to accept them, or to have authority to bind the represented organization. The service may use Cloudflare as a CDN. Recheck terms and availability before integration and presentation.

#### Google Maps URLs
- Source: https://developers.google.com/maps/documentation/urls/get-started
- Relevant ideas: A universal directions URL can open the Google Maps app or browser without a Google Maps API key.
- Adaptation notes: This matches the team's preference to hand off navigation to Google Maps. Use a verified destination coordinate/address; this does not provide an in-app ETA.
- Caveats: URL directions require valid destination data and an internet connection; provide a clear fallback if the URL cannot be opened.

#### Nominatim public geocoding policy
- Source: https://operations.osmfoundation.org/policies/nominatim/
- Relevant ideas: Address lookup/geocoding is a separate capability from displaying OSM tiles or calculating routes.
- Adaptation notes: Avoid relying on the public Nominatim server for bulk collection of the initial venue list; collect and verify listing coordinates through an appropriate workflow/provider.
- Caveats: Public Nominatim has a maximum of one request per second, disallows autocomplete and systematic/bulk querying, and may withdraw access.

#### Firebase pricing plans
- Source: https://firebase.google.com/docs/projects/billing/firebase-pricing-plans and https://firebase.google.com/pricing (checked 2026-11-02)
- Relevant ideas: Firebase offers a no-cost Spark plan and a pay-as-you-go Blaze plan; Firestore has no-cost quotas, while some products/features require billing.
- Adaptation notes: Could support shared, read-oriented place listings for a modest demo. A custom admin interface is still a separate implementation task; provider-console editing is a possible simpler alternative.
- Caveats: Cloud Storage has no Spark quota (Blaze only), so hosting photos there requires a card. Linking a Cloud Billing account, or enabling Google Maps APIs in the same project, automatically upgrades the project to Blaze. Firestore Spark quotas are 1 GiB stored, 10 GiB/month egress, 20K writes/day, and 50K reads/day, and the product stops when a quota is exceeded. Use security rules and client-owned billing.

#### Supabase pricing and free-plan limits
- Source: https://supabase.com/pricing (checked 2026-11-02)
- Relevant ideas: Managed Postgres, row-level security, Realtime Postgres Changes, and file storage are separate capabilities. The Free plan includes 500 MB database, 1 GB file storage, 5 GB egress, unlimited API requests, 200 realtime connections, and 2 active projects, with no payment method.
- Adaptation notes: Selected for class-demo shared listings: read-only access through row-level security, no student accounts, and bundled JSON as seed and offline fallback. The table editor and CSV import fit the team's spreadsheet template. Setup and demo runbook are in `docs/SUPABASE_SETUP.md`.
- Caveats: Free projects pause after one week of inactivity and must be restored manually, which is a demo-day risk; there are no automatic backups; the paid plan from USD 25/month is not approved. The publishable key ships in the app by design, so row-level security must allow reads only. Recheck terms before launch.

#### Supabase row-level security and Realtime
- Source: https://supabase.com/docs/guides/database/postgres/row-level-security and https://supabase.com/docs/guides/realtime/postgres-changes (checked 2026-11-02)
- Relevant ideas: Policies decide what the publishable key may read or write; Realtime Postgres Changes streams row updates, and a table must be added to the realtime publication.
- Adaptation notes: Use a `select`-only policy for `anon` so the shipped key cannot modify listings, and enable realtime for the `places` table for the two-phone demo.
- Caveats: Policies are the security boundary, not key secrecy. Realtime requires the table in the publication and counts toward the plan's concurrent-connection and message limits.

#### Google Play Console registration
- Source: https://support.google.com/googleplay/android-developer/answer/6112435
- Relevant ideas: Publishing to Google Play has a separate account setup and distribution cost from application development.
- Adaptation notes: Direct APK handoff for a class demo avoids making Play Store publication part of the initial deliverable.
- Caveats: Google's current guidance lists a USD 25 one-time registration fee and identity verification; personal accounts may also have testing requirements. Confirm who owns the publishing account and pays.

### Entry template

```text
### Project name
- Source: URL
- License: Name or "not verified" (checked YYYY-MM-DD)
- Relevant ideas: Specific flow, capability, or design pattern to study
- Adaptation notes: How it might fit this project's requirements; what should differ
- Caveats: Maintenance, audience, platform, data, accessibility, or licensing concerns
```

## Evaluation reminders

- Compare the reference to confirmed users, campus context, and requirements; do not assume a common feature is needed here.
- Learn from behavior and architecture rather than copying a whole application or its design.
- Verify that a project is maintained enough to be useful and that its data and map choices fit the intended region.
- Treat provider branding, map data, and third-party APIs as separate licensing and terms-of-use questions.
