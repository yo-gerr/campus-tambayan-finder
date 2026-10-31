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

#### Nominatim public geocoding policy
- Source: https://operations.osmfoundation.org/policies/nominatim/
- Relevant ideas: Address lookup/geocoding is a separate capability from displaying OSM tiles or calculating routes.
- Adaptation notes: Avoid relying on the public Nominatim server for bulk collection of the initial venue list; collect and verify listing coordinates through an appropriate workflow/provider.
- Caveats: Public Nominatim has a maximum of one request per second, disallows autocomplete and systematic/bulk querying, and may withdraw access.

#### Firebase pricing plans
- Source: https://firebase.google.com/docs/projects/billing/firebase-pricing-plans and https://firebase.google.com/pricing
- Relevant ideas: Firebase offers a no-cost Spark plan and a pay-as-you-go Blaze plan; Firestore has no-cost quotas, while some products/features require billing.
- Adaptation notes: Could support shared, read-oriented place listings for a modest demo. A custom admin interface is still a separate implementation task; provider-console editing is a possible simpler alternative.
- Caveats: Check quotas and whether each selected feature requires Blaze. Cloud Functions and usage beyond free quotas can incur charges. Use security rules and client-owned billing.

#### Supabase pricing
- Source: https://supabase.com/pricing
- Relevant ideas: Managed Postgres, authentication, and storage can be used as separate backend capabilities.
- Adaptation notes: Could suit structured place records and relationships if the team prefers SQL.
- Caveats: The current free tier has usage limits and pauses projects after a week of inactivity; Pro currently starts at USD 25/month. Recheck pricing and terms before selection.

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
