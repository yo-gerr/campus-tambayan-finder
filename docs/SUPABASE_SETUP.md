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
  "descriptionEn" text not null,
  "descriptionTl" text not null,
  "priceMin" integer not null,
  "priceMax" integer not null,
  hours text not null,
  amenities text[] not null default '{}',
  setting text not null,
  activities text[] not null default '{}',
  latitude double precision,
  longitude double precision,
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

If the table already exists from an earlier setup, add the new nullable fields
and relax the old schematic-coordinate columns instead of recreating it:

```sql
alter table public.places add column if not exists latitude double precision;
alter table public.places add column if not exists longitude double precision;
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

For map pins, enter verified decimal-degree `latitude` and `longitude` values as a pair. Leave both blank until the place's position has been checked; the app omits places without a valid pair rather than plotting the old schematic `mapX`/`mapY` values. Those legacy columns are retained only for existing project data and are not used by the geographic map.

### Photos and galleries

The legacy optional `places` photo columns keep older bundled data compatible:

- `photoUrl` — public URL of the single legacy/cover photo.
- `photoAsset` — path to a single legacy bundled fallback.

New galleries are managed through `place_photos`. For each entry, use:

- `place_id` — the matching `places.id`.
- `photoUrl` — public URL of the Storage object (required).
- `sortOrder` — unique display order starting at `0`.
- `isCover` — `true` for exactly one card cover photo.
- `photoAsset`, `captionEn`, and `captionTl` — optional; asset paths are APK-only backups, and captions are reserved for approved bilingual copy.

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

### Image preparation and planned Phase 2 presentation

Mixed portrait and landscape photos are supported as uploaded. Prepare images before upload to keep the gallery responsive on student devices and within the Free-plan storage allowance:

- Prefer JPEG or WebP; retain enough quality for a phone screen rather than uploading camera originals.
- Recommended maximum: 2048 px on the longest edge and roughly 2 MB per file.
- Use a meaningful filename and the place-id folder structure above.
- Review whether an image contains people, copyrighted material, or unnecessary EXIF location metadata before publishing. Supabase Storage and the current app do not automatically remove metadata or verify photo permissions.

Phase 2 plans, but does not yet implement, three presentation improvements: uncropped full-image rendering in the detail gallery for mixed orientations, an accessible shimmer/skeleton while a network image loads, and a full-screen pinch-to-zoom viewer. List-card cover images may remain cropped to keep cards visually consistent.

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

The interface shows the bundled-copy notice only when the shared source fails, so a populated table and the bundled fallback can look identical. During a rehearsal, read the device log instead:

```powershell
adb logcat -s flutter:V | Select-String 'Shared listings'
```

| Log line | Meaning |
|---|---|
| `Shared listings loaded: N places` | First shared read succeeded. |
| `Shared listings updated: N places` | A realtime change arrived. Several rows inserted at once appear as several lines. |
| `Shared listings table is empty; keeping the bundled copy` | The connection works but the table has no rows. |
| `Shared listings unavailable, using bundled copy` | The shared source failed; the notice is showing. |

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
