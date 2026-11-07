# Shared Listings Setup (Supabase)

This guide covers the optional shared listing source for the class-demo MVP. The app works without it: when no shared source is configured, it runs on the bundled `assets/data/sample_places.json` listings.

## Decision summary

- **Listings:** Supabase Free plan (`places` table) with the bundled JSON kept as the seed and offline fallback.
- **Photos:** an ordered gallery of up to 10 approved images per place. Supabase Storage URLs are primary; optional bundled APK assets cover offline use. One gallery image is the cover for place cards.
- **Edits:** authorized team members edit rows in the Supabase dashboard. There is no in-app admin screen.
- **Client access:** read-only. The app ships only the publishable (anon) key; row-level security allows `select` and nothing else.
- **Canonical copy:** the repository JSON/CSV stays the source of truth and is imported into Supabase one way. Do not edit both directions.
- **Mood check-ins:** never store mood or nickname data in this project. That is a separate privacy decision (Phase 4).

## 1. Create the project

1. Create a Supabase organization owned by the team's account, not a personal one, and a project for this app.
2. Keep the project on the **Free** plan. Do not enter billing details; the paid plan and image transformations are out of scope.
3. Copy the project URL and the **publishable (anon)** key from Project Settings → API. Never use the secret/service-role key in the app.

## 2. Create the table and read-only policy

Run this in the SQL editor. Column names are quoted so they keep the camelCase spelling the app expects from its JSON seed.

```sql
create table if not exists public.places (
  id text primary key,
  name text not null,
  category text not null,
  area text not null,
  address text,
  "descriptionEn" text not null,
  "descriptionTl" text not null,
  "priceMin" integer,
  "priceMax" integer,
  hours text,
  "hoursByDay" jsonb,
  amenities text[] not null default '{}',
  setting text not null,
  activities text[] not null default '{}',
  latitude double precision,
  longitude double precision,
  location_verified boolean not null default false,
  "mapX" double precision,
  "mapY" double precision,
  "photoUrl" text,
  "photoAsset" text
);

alter table public.places enable row level security;

-- The app is read-only. Dashboard edits use a privileged role and still work.
revoke all on table public.places from anon, authenticated;
grant select on table public.places to anon, authenticated;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'places'
      and policyname = 'Public read of listings'
  ) then
    create policy "Public read of listings"
      on public.places
      for select
      to anon, authenticated
      using (true);
  end if;
end $$;
```

No insert, update, or delete policy is created for `anon`, so the shipped key cannot change listings even if it is extracted from the APK.

### Category values

`category` is free text in the table, but the app groups and labels only the five agreed keys: `tambayan`, `coffee`, `park`, `eatery`, and `other`. Write those exact lowercase values in dashboard edits and CSV imports. Any other spelling, such as `Karinderya`, `Eatery`, or `cafe`, is still displayed verbatim so the mistake is visible, but it will not match a category filter. The list lives in `lib/features/places/place_categories.dart` and is independent of the rows currently stored, so every category stays selectable before listings exist for it.

### Price values

`priceMin` and `priceMax` are optional as a pair. Leave **both** blank when the team has no reliable estimate: the app shows "Price not listed" and excludes the listing while a budget filter is active. Never enter `0` to mean unknown — `0` means free. For an exact price, repeat the same value in both columns; the app displays it once instead of as a range.

The budget filter compares the lowest estimated spend (`priceMin`) with the selected limit. Whether it should use the highest (`priceMax`) instead is an open product question recorded in the project brief, so do not treat the current behavior as final.

### Operating hours values

Two fields describe hours, and they answer different questions.

`hours` is a free-text summary or note, such as `8:00 AM–8:00 PM` or `Closed on holidays`. When no weekly schedule exists, the detail view shows this line alone. When `"hoursByDay"` is present, the app renders the weekly list and shows this text beneath it as a note. It is optional and is never parsed to decide whether a place is open.

`"hoursByDay"` is the structured weekly schedule. It is the only field that powers the "Open now" badge and filter. Leave it `NULL` when the team has no reliable schedule; the app then shows nothing rather than guessing. Write the object keyed by three-letter weekday:

```json
{
  "mon": { "open": "08:00", "close": "20:00" },
  "tue": { "open": "08:00", "close": "20:00" },
  "fri": { "open": "08:00", "close": "21:00" },
  "sat": { "open": "09:00", "close": "17:00" },
  "sun": null
}
```

Three states must stay distinct:

- **missing key** — the day's hours are unknown; the app stays silent for that day;
- **`null`** — the place is **closed** that day;
- **an object** — that day's window.

Rules the app applies:

- Times are `HH:MM` on a 24-hour clock and are read as **Asia/Manila (UTC+8)**, not the viewer's device timezone. Philippines has no daylight saving time, so the fixed offset is exact.
- Opening time is inclusive, closing time exclusive, so a place that closes at `20:00` reads as closed at `20:00`.
- A window whose `close` is earlier than its `open` crosses midnight, such as `20:00`–`02:00`.
- An entry with an unreadable time is treated as unknown for that day, not as closed.
- Identical `open` and `close` values are treated as **unknown**, because "00:00–00:00" could mean 24 hours or a typo. Whether to support a 24-hour marker is an open question in the project brief. For a place open around the clock today, write `00:00`–`23:59`; that leaves a one-minute closed window at 23:59, which is exactly why a real 24-hour value is still being considered.

Reject typo'd weekday keys without blocking normal edits:

```sql
alter table public.places
  drop constraint if exists places_hours_by_day_shape;

alter table public.places
  add constraint places_hours_by_day_shape check (
    "hoursByDay" is null
    or (
      jsonb_typeof("hoursByDay") = 'object'
      and ("hoursByDay" - 'mon' - 'tue' - 'wed' - 'thu' - 'fri' - 'sat' - 'sun')
          = '{}'::jsonb
    )
  );
```

If the table already exists from an earlier setup, add the newer fields and
relax the columns that are now optional instead of recreating it:

```sql
alter table public.places add column if not exists latitude double precision;
alter table public.places add column if not exists longitude double precision;
alter table public.places add column if not exists address text;
alter table public.places
  add column if not exists location_verified boolean not null default false;
alter table public.places alter column "priceMin" drop not null;
alter table public.places alter column "priceMax" drop not null;
alter table public.places add column if not exists "hoursByDay" jsonb;
alter table public.places alter column hours drop not null;
alter table public.places alter column "mapX" drop not null;
alter table public.places alter column "mapY" drop not null;
alter table public.places add column if not exists "photoUrl" text;
alter table public.places add column if not exists "photoAsset" text;
```

## 3. Create the ordered photo gallery

Run this after the `places` table exists. The gallery permits at most 10 rows
per place and one optional marked cover. The app uses the marked cover first,
then the lowest `sortOrder` when a cover has not yet been chosen.

```sql
create table if not exists public.place_photos (
  id bigint generated always as identity primary key,
  place_id text not null references public.places(id) on delete cascade,
  "photoUrl" text not null,
  "photoAsset" text,
  "sortOrder" integer not null,
  "isCover" boolean not null default false,
  "captionEn" text,
  "captionTl" text,
  constraint place_photos_sort_order_nonnegative check ("sortOrder" >= 0),
  constraint place_photos_place_order_unique unique (place_id, "sortOrder")
);

create unique index if not exists place_photos_one_cover_per_place
  on public.place_photos (place_id)
  where "isCover";

create or replace function public.limit_place_photos()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if (
    select count(*)
    from public.place_photos
    where place_id = new.place_id
      and id is distinct from new.id
  ) >= 10 then
    raise exception 'A place can have at most 10 photos';
  end if;
  return new;
end;
$$;

drop trigger if exists place_photos_limit on public.place_photos;
create trigger place_photos_limit
  before insert or update of place_id on public.place_photos
  for each row execute function public.limit_place_photos();

alter table public.place_photos enable row level security;
revoke all on table public.place_photos from anon, authenticated;
grant select on table public.place_photos to anon, authenticated;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'place_photos'
      and policyname = 'Public read of place photos'
  ) then
    create policy "Public read of place photos"
      on public.place_photos
      for select
      to anon, authenticated
      using (true);
  end if;
end $$;
```

For an existing single cover photo, migrate it once into the gallery:

```sql
insert into public.place_photos (
  place_id, "photoUrl", "photoAsset", "sortOrder", "isCover"
)
select id, "photoUrl", "photoAsset", 0, true
from public.places
where "photoUrl" is not null
on conflict (place_id, "sortOrder") do nothing;
```

## 4. Enable realtime updates

The app listens for changes so two phones stay in sync. Run this once:

```sql
alter publication supabase_realtime add table public.places;
alter publication supabase_realtime add table public.place_photos;
```

If the table is already in the publication, the statement errors with "already member of publication"; that is safe to ignore.

## 5. Load the listings

Use the dashboard's CSV import or the SQL editor, keeping the column names exactly as defined above. Array columns (`amenities`, `activities`) need Postgres array values such as `{wifi,outlets}`, not a bare comma-separated list. Verify the first import in the Table Editor before relying on it.

Keep `assets/data/sample_places.json` as the bundled seed and offline fallback. Its `photos` array holds offline gallery entries; it is not a `places` column, so omit it from a `places` CSV import. Keep related `place_photos` rows in a separate CSV/export. The fictional sample listings contain illustrative coordinates solely to preview the local demo map; do not import those coordinates as actual listing locations. Replace them with verified coordinates, or leave both coordinate fields blank, before publishing real listings. When the team supplies new listings, update the repository records and import the matching `places` and `place_photos` data. Export both tables back before each APK build if anyone has edited them in the dashboard.

Listing ids also drive the in-app demo labels. The app treats any id beginning with `sample-` as fictional prototype data and shows the `DEMO LISTING` badge plus the sample-information note; other ids are presented as normal listings. Do not use that prefix for real listings. This is a temporary convention until an explicit demo/verification field is modeled.

For map pins, enter verified decimal-degree `latitude` and `longitude` values as a pair. Leave both blank until the place's position has been checked; the app omits places without a valid pair rather than plotting the old schematic `mapX`/`mapY` values. Those legacy columns are retained only for existing project data and are not used by the geographic map.

The `location_verified` flag must remain `false` unless the listing's actual location and coordinates have been checked. The app defaults missing flags to `false` and only enables Google Maps directions when this flag is `true` and the coordinate pair is valid. Existing rows get `false` from the migration; CSV imports that omit this field also use the default. Bundled sample rows use illustrative coordinates and must never be marked verified or imported as real destinations. In the repository JSON the matching field is `locationVerified`.

### Addresses

`address` is a single optional, untranslated text field. Keep `area` as the short neighborhood label used on cards and the subtitle; `address` appears only in the detail sheet when present. Publish an address only after checking it against the establishment's own listing or another authoritative source, and update or clear it if the shop moves. The fictional demo rows use obviously fake addresses ending in `(demo only)`; never replace them with a real address until the listing is approved, and never present an unverified address as confirmed. CSV imports can leave the field blank.

After adding the column, label the fictional demo rows so they match `assets/data/sample_places.json`:

```sql
update public.places as p
set address = v.address
from (values
  ('sample-study-corner', 'Blk 1 Lot 2, Demo Street, Malinta, Valenzuela City (demo only)'),
  ('sample-kape-stop', 'Blk 3 Lot 4, Sample Avenue, Malinta, Valenzuela City (demo only)'),
  ('sample-luntiang-pahingahan', 'Demo Park, Illustrative Road, Malinta, Valenzuela City (demo only)'),
  ('sample-budget-kainan', 'Blk 5 Lot 6, Prototype Lane, Malinta, Valenzuela City (demo only)')
) as v(id, address)
where p.id = v.id;
```

Replace these placeholders with verified addresses only when the team approves the real listing.

### Photos and galleries

The legacy optional `places` photo columns keep older bundled data compatible:

- `photoUrl` — public URL of the single legacy/cover photo.
- `photoAsset` — path to a single legacy bundled fallback.

New galleries are managed through `place_photos`. For each entry, use:

- `place_id` — the matching `places.id`.
- `photoUrl` — public URL of the Storage object (required).
- `sortOrder` — unique display order starting at `0`.
- `isCover` — `true` for exactly one card cover photo.
- `photoAsset`, `captionEn`, and `captionTl` — optional; asset paths are APK-only backups, and captions appear under the gallery photo. Use approved bilingual copy; the app falls back to the other language when one translation is missing.

Use the existing bucket **`places-photos`** (or create it once through **Storage → New bucket** if it is absent) and enable the public bucket option. Public read is what lets the shipped publishable key fetch images; do not add insert, update, or delete policies for `anon`. The Free plan includes 1 GB and needs no card.

Organize files by place id, for example `sample-kape-stop/cover.jpg` and `sample-kape-stop/interior.jpg`. Copy each public URL — it looks like `https://YOUR-PROJECT.supabase.co/storage/v1/object/public/places-photos/sample-kape-stop/cover.jpg` — into a `place_photos.photoUrl` row.

Example gallery insert:

```sql
insert into public.place_photos (
  place_id, "photoUrl", "sortOrder", "isCover"
) values
  ('sample-kape-stop',
   'https://YOUR-PROJECT.supabase.co/storage/v1/object/public/places-photos/sample-kape-stop/cover.jpg',
   0, true),
  ('sample-kape-stop',
   'https://YOUR-PROJECT.supabase.co/storage/v1/object/public/places-photos/sample-kape-stop/interior.jpg',
   1, false);
```

A place with no usable photo shows a neutral placeholder, which is expected until the team supplies approved images. The detail sheet becomes swipeable when a place has two or more gallery entries; the list card always uses the cover. Bundled copies go under `assets/photos/` and are referenced as `assets/photos/sample-kape-stop/cover.jpg`; add `assets/photos/` to `pubspec.yaml` when the first image arrives. Do not upload or bundle photos without permission, including photos with identifiable people whose use has not been cleared.

### Image preparation and presentation behavior

Mixed portrait and landscape photos are supported as uploaded. Prepare images before upload to keep the gallery responsive on student devices and within the Free-plan storage allowance:

- Prefer JPEG or WebP; retain enough quality for a phone screen rather than uploading camera originals.
- Recommended maximum: 2048 px on the longest edge and roughly 2 MB per file. The app decodes images at display size, but the full uploaded file is still downloaded on first view, so oversized files slow down slow connections and consume the Free-plan transfer allowance.
- Use a meaningful filename and the place-id folder structure above.
- Review whether an image contains people, copyrighted material, or unnecessary EXIF location metadata before publishing. Supabase Storage and the current app do not automatically remove metadata or verify photo permissions.

The app implements three presentation behaviors: the detail gallery renders the full image for mixed orientations, an accessible skeleton covers a network photo while it loads, and a separate full-screen pinch-to-zoom viewer shows the complete photo. List-card cover images remain cropped to keep cards visually consistent.

## 6. Run the app against the shared source

Pass the URL and publishable key at build time so no key is committed:

```powershell
flutter run --dart-define=SUPABASE_URL=https://YOUR-PROJECT.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
```

```powershell
flutter build apk --debug --dart-define=SUPABASE_URL=https://YOUR-PROJECT.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
```

Omit both defines to build a bundled-listings-only APK.

The publishable key is compiled into the APK, which is expected. Row-level security, not key secrecy, protects the data. Do not put the key in a committed file.

### Checking which copy is on screen

The app shows a localized notice when it falls back to saved or bundled listings. The saved copy contains listing data and photo URLs/references, not downloaded remote images or map tiles. During a rehearsal, read the device log to distinguish live listings from fallback:

```powershell
adb logcat -s flutter:V | Select-String 'Shared listings'
```

| Log line | Meaning |
|---|---|
| `Shared listings loaded: N places` | First shared read succeeded. |
| `Shared listings updated: N places` | A realtime change arrived. Several rows inserted at once appear as several lines. |
| `Shared listings table is empty; keeping the local copy` | The connection works but the table has no rows; cached data is kept when available, otherwise bundled data remains. |
| `Shared listings unavailable; keeping local copy` | The shared source failed; the app is keeping saved listings when available, otherwise bundled data. |

## 7. Free plan limits (verified 2026-11-02)

| Limit | Free plan |
|---|---|
| Database | 500 MB |
| File storage | 1 GB |
| Egress / cached egress | 5 GB / 5 GB each |
| API requests | Unlimited |
| Realtime | 200 concurrent connections, 2M messages/month |
| Active projects | 2 |
| Backups | Not included |
| Inactivity | **Projects pause after 1 week of inactivity** |

The pausing rule is the main operational risk. The paid plan (from USD 25/month) removes it but is not approved and is not needed for this demo.

## 8. Demo runbook

1. **48 hours before:** open the Supabase dashboard and confirm the project is not paused. A paused project must be restored manually, and the app would otherwise fall back to the bundled copy.
2. **Before the demo:** confirm the table has the agreed listings and the app shows them without the offline notice. Rehearse on the venue's network, not only at home.
3. **Fallback check:** enable airplane mode and confirm the bundled list still appears with the "showing the bundled copy" notice. Turn the network back on and reopen the app.
4. **10 minutes before:** launch the app on both phones and freeze listing edits.
5. **During the demo:** change one field (for example, `hours`) for a place in the Table Editor. Both phones should update within a few seconds.
6. **If the venue network fails:** the app keeps working on the bundled copy and says so. Present that as the designed offline behavior rather than an error.

## Known limitations

- Live updates require connectivity. Once disconnected, the last live listings stay on screen; nothing is cached across app restarts beyond the bundled copy.
- No automatic backups on the Free plan. The repository JSON and periodic exports are the backup.
- The app does not retry a failed shared connection automatically; reopen the app to reconnect. A fresh launch always starts from the bundled copy.
- Photo galleries require a `place_photos` Realtime publication and usable network access; the bundled JSON only contains whatever approved asset fallbacks are included at build time.

## 9. Route Caching Proposal (Phase 5 Optional ETA)

This section is a proposal for a future product decision; the SQL has not been applied. The current in-app ETA prototype makes no routing-service or backend calls, so nothing here is required for the class demo.

If the team later approves live in-app travel estimates (Phase 5), run this SQL script in the Supabase SQL Editor to create the `route_cache` table and read-only policy.

```sql
drop table if exists public.route_cache cascade;

create table if not exists public.route_cache (
  cache_key text primary key,
  dest_place_id text references public.places(id) on delete set null,
  origin_lat double precision not null,
  origin_lng double precision not null,
  dest_lat double precision not null,
  dest_lng double precision not null,
  profile text not null default 'driving',
  distance_meters double precision not null,
  duration_seconds double precision not null,
  geometry_geojson jsonb not null,
  created_at timestamptz not null default now(),
  expires_at timestamptz not null default (now() + interval '90 days')
);

create index if not exists idx_route_cache_place on public.route_cache (dest_place_id);

-- Table for tracking OSRM API calls and cache hit/miss analytics
create table if not exists public.osrm_usage_logs (
  id bigint generated always as identity primary key,
  cache_key text not null,
  request_type text not null,
  response_code integer,
  created_at timestamptz not null default now()
);

alter table public.route_cache enable row level security;
revoke all on table public.route_cache from anon, authenticated;
grant select, insert, update on table public.route_cache to anon, authenticated;

alter table public.osrm_usage_logs enable row level security;
revoke all on table public.osrm_usage_logs from anon, authenticated;
grant insert, select on table public.osrm_usage_logs to anon, authenticated;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'route_cache'
      and policyname = 'Public read of route cache'
  ) then
    create policy "Public read of route cache"
      on public.route_cache
      for select
      to anon, authenticated
      using (true);
  end if;
end $$;
```

### Pre-Warming Campus Routes

To aim for presentation-day cache hits without live calls to OSRM:

1. Insert pre-calculated routes for the two campus anchors used by the app (**PLV Annex**: `14.6959, 120.9677` and **CPAG**: `14.6942, 120.9698`) to all verified place coordinates.
2. Format `cache_key` using 4-decimal-degree rounded coordinates, for example: `route:14.6959,120.9677:14.6964,120.9674:driving`.
3. The proposed client would query `route_cache` using `select` with the publishable key. When a match exists, it would render the distance, duration, and GeoJSON polyline over MapLibre instantly.
