# Shared Listings Setup (Supabase)

This guide covers the optional shared listing source for the class-demo MVP. The app works without it: when no shared source is configured, it runs on the bundled `assets/data/sample_places.json` listings.

## Decision summary

- **Listings:** Supabase Free plan (`places` table) with the bundled JSON kept as the seed and offline fallback.
- **Photos:** bundled with the app for the demo. Supabase Storage is available on the Free plan if the team later wants to replace photos without rebuilding, but photos are not required to come from the network.
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
  "mapX" double precision not null,
  "mapY" double precision not null,
  "photoUrl" text,
  "photoAsset" text
);

alter table public.places enable row level security;

-- The app is read-only. Dashboard edits use a privileged role and still work.
revoke all on table public.places from anon, authenticated;
grant select on table public.places to anon, authenticated;

create policy "Public read of listings"
  on public.places
  for select
  to anon, authenticated
  using (true);
```

No insert, update, or delete policy is created for `anon`, so the shipped key cannot change listings even if it is extracted from the APK.

If the table already exists from an earlier setup, add the photo columns instead of recreating it:

```sql
alter table public.places add column if not exists "photoUrl" text;
alter table public.places add column if not exists "photoAsset" text;
```

## 3. Enable realtime updates

The app listens for changes so two phones stay in sync. Run this once:

```sql
alter publication supabase_realtime add table public.places;
```

If the table is already in the publication, the statement errors with "already member of publication"; that is safe to ignore.

## 4. Load the listings

Use the dashboard's CSV import or the SQL editor, keeping the column names exactly as defined above. Array columns (`amenities`, `activities`) need Postgres array values such as `{wifi,outlets}`, not a bare comma-separated list. Verify the first import in the Table Editor before relying on it.

Keep `assets/data/sample_places.json` as the canonical copy. When the team supplies new listings, update the repository copy and the bundled asset together, then re-import. Export the table back to JSON before each APK build if anyone has edited it in the dashboard.

### Photos

Two optional columns and one Storage bucket cover place photos:

- `photoUrl` — public URL of the current photo. The app tries it first, so a photo can be replaced in the dashboard without rebuilding the APK.
- `photoAsset` — path to a copy bundled in the APK, used when `photoUrl` is missing or fails to load (offline, weak signal, deleted file).

Create the bucket once: **Storage → New bucket**, name `place-photos`, and enable the public bucket option. Public read is what lets the shipped publishable key fetch images; do not add insert, update, or delete policies for `anon`. The Free plan includes 1 GB and needs no card.

Upload each file named after the place id, for example `sample-kape-stop.jpg`, then copy its public URL — it looks like `https://YOUR-PROJECT.supabase.co/storage/v1/object/public/place-photos/sample-kape-stop.jpg` — and paste it into the row's `photoUrl`.

A row with no photo shows a neutral placeholder, which is the expected state until the team supplies approved images. Bundled copies go under `assets/photos/` and are referenced as `assets/photos/sample-kape-stop.jpg`; add `assets/photos/` to `pubspec.yaml` when the first image arrives. Do not bundle a photo the team has not cleared for use.

## 5. Run the app against the shared source

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

## 6. Free plan limits (verified 2026-11-02)

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

## 7. Demo runbook

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
- Photos are not part of the shared table yet.
