# MoodMeal 🍲

**Choose with heart. Eat with calm.**

MoodMeal is a mood-aware mindful eating companion. Check in with how you feel,
get meals and nearby places that support that feeling, and notice your patterns
over time — without scores, streaks-as-pressure, or guilt.

Built with Flutter for Android, Windows and the web. English and සිංහල.

---

## What is inside

| Area | Highlights |
| --- | --- |
| **Mood check-in** | 8 moods, intensity slider, influence tags, optional note |
| **Recommendations** | Curated meals matched to mood, match scores, allergens and filters |
| **Meal detail** | Real photograph, full bilingual recipe (quantities, tick-off ingredients, steps, cook's tip), verified YouTube walkthrough, nutrition, mindful prompt, one-tap meal logging |
| **Nearby** | Real restaurants and cafés from OpenStreetMap around your GPS position or a chosen city, with directions, call, website and ordering links |
| **History** | Streak, weekly bar chart, day-grouped check-in timeline, logged meals |
| **Insights** | Mood distribution donut, lighter/heavier days, time-of-day pattern, meal pairings |
| **Mindful tips** | 6 short practices, step-by-step detail, "practised" tracking |
| **Favourites** | Saved meals plus gentle suggestions |
| **Profile & settings** | Photo upload or emoji avatar, name/email editing, food preferences and allergies, reminder schedule, light/dark/system appearance, language, photo/video credits, sign out |
| **Accounts** | Email/password (local or Supabase) and Google sign-in when Supabase is configured |
| **Notifications** | In-app gentle nudges, unread state, mark-all-read, back navigation |
| **Polish** | Empty/loading/error states, warm light + dark themes, adaptive text scaling, haptics, keyboard-safe forms |

The catalogue, recipes and photographs work **offline**. The two optional
online features are the YouTube walkthrough (opens in the YouTube app/browser)
and the nearby-restaurant search (OpenStreetMap). Data is stored per account, so
signing in with a different email never reveals another person's check-ins. The
shared demo account starts with a week of example check-ins; accounts you create
start with a clean history and friendly empty states.

---

## Real food content

| Content | Source | Notes |
| --- | --- | --- |
| **Photographs** | Wikimedia Commons | 17 real dish photos, bundled in `assets/images/food/`. Licences and authors in [`assets/images/food/CREDITS.md`](assets/images/food/CREDITS.md) and the in-app **Settings → Photo & video credits** page. |
| **Recipes** | Hand-written for this app | Bilingual ingredients, quantities, ordered steps and a cook's tip per dish (`lib/data/seed/recipes.dart`). |
| **Videos** | YouTube | One verified walkthrough per dish, checked against YouTube's oEmbed endpoint. Two are narrated in Sinhala (dhal, kottu) and are labelled in the UI. |
| **Restaurants** | OpenStreetMap (Photon + Overpass) | Live lookup within 2.5 km of the user's GPS position or one of six Sri Lankan city anchors. Photon answers in seconds and several food keywords are merged and de-duplicated, so dense city centres show enough places; Overpass adds richer tags as a fallback. No API key. Directions and ordering open Google Maps; phone/website links come from OSM tags. |

Nothing is simulated on those screens: if the network is unavailable, the app
shows a real error state with a retry button and a manual city fallback.

---

## Run it

Requires Flutter 3.27 or newer (built and tested with 3.47.9 stable).

```bash
flutter pub get
flutter run -d windows      # or: flutter run -d chrome / android device
```

No backend or keys are needed. Data is persisted with `shared_preferences` on
the device. The nearby screen asks for location permission the first time; you
can decline and choose a city instead.

> Building for web? Browsers only allow geolocation on `https://` and
> `http://localhost`, which the development server already satisfies.

### Demo account

Pick **Continue in demo mode** on the login screen. You can also create a local
account — in demo mode the credentials never leave the device.

### Tests

```bash
flutter test
flutter analyze
```

---

## Optional: Supabase cloud sync

The app can store the profile, check-ins and favourites in Supabase while the
meal catalogue stays local.

1. Create a project at [supabase.com](https://supabase.com).
2. Open the SQL editor and run [`supabase/schema.sql`](supabase/schema.sql). Existing projects only need the `alter table ... add column if not exists photo` line near the top.
3. Enable **Email** auth (Authentication → **Sign In / Providers**).
4. Optional Google sign-in: open Authentication → **Sign In / Providers** → **Google**, enable it, add your Google OAuth client id/secret, and allow these redirect URLs in Authentication → URL Configuration:
   - Web: your site URL (for local development `http://localhost:8080`)
   - Android: `io.moodmeal.app://login-callback`
5. Put your project credentials in `supabase.json` (already git-ignored). Copy
   [`supabase.example.json`](supabase.example.json) and fill in your own values:

```json
{
  "SUPABASE_URL": "https://YOUR-PROJECT.supabase.co",
  "SUPABASE_ANON_KEY": "sb_publishable_..."
}
```

Then use the helper scripts, which pass the file through
`--dart-define-from-file`:

```powershell
.\tool\run_web.ps1                 # Chrome
.\tool\run_web.ps1 -Device windows # Windows desktop
.\tool\build_web.ps1               # release web bundle
.\tool\build_apk.ps1               # release Android APK
```

Equivalently, pass the defines directly:

```bash
flutter run -d windows --dart-define-from-file=supabase.json
```

If **Confirm sign up** is enabled in Supabase, a new account must open the
confirmation email before logging in; the app explains this with a localized
dialog. To skip the email step during development, open
**Authentication → Emails → Confirm sign up** and turn it off.

If the defines are absent, MoodMeal automatically falls back to the local
repository. The schema enables row-level security so each user can only read
and write their own rows. The **Continue with Google** button shows an honest
explanation instead of pretending to sign in when Supabase is not configured.

Profile photos are compressed to at most 512 px and stored as base64 in
`profiles.photo` (and in the local profile JSON). No storage bucket is required.

---

## Share a build

The repo already contains the deploy helper outputs:

| Artefact | Path |
| --- | --- |
| Web bundle (Supabase enabled) | `build/web` |
| Web bundle zipped for Netlify Drop | `build/moodmeal-web.zip` |
| Universal Android APK | `build/app/outputs/flutter-apk/app-release.apk` |
| Per-ABI APKs | `build/app/outputs/flutter-apk/app-*-release.apk` |

Deploying to a public URL needs two Supabase changes: add the site origin to
Authentication → URL Configuration (Site URL **and** `https://your-site/**`), and
make sure every Google test user is listed under Google Cloud → Audience → Test
users (or publish the app). Because the web build uses hash routing, Netlify
needs no redirect rules. Step-by-step instructions are in
[`LAUNCH_GUIDE.md`](LAUNCH_GUIDE.md).

On Android, `supabase_flutter` (`detectSessionInUri` is on by default) catches
the `io.moodmeal.app://login-callback` deep link and exchanges it for a session,
so no extra deep-link package is required.

---

## Project structure

```
lib/
  app.dart                 MaterialApp.router, locale, theme, localisation delegates
  main.dart                WidgetsFlutterBinding, SharedPreferences, Supabase
  core/
    l10n/                  English + Sinhala string table (no codegen)
    router/                go_router routes and auth redirects
    theme/                 colour tokens, typography, shadows
    utils/                 dates, streak/distribution/week helpers
  data/
    models/                Meal, Recipe, MealVideo, MealLog,
                           Tip, UserProfile, MoodEntry
    seed/catalog.dart      17 meals, tips and friendly demo content
    seed/recipes.dart      bilingual ingredients, steps and cook's tips
    seed/media.dart        dish photo path, verified video id, search term
    repositories/          LocalRepository + SupabaseRepository
    services/              SharedPreferences keys, Photon/Overpass lookup,
                           geolocation
  state/                   AppController, NearbyController, locale, practised tips
  ui/
    screens/               auth, home, mood, meals, restaurants, credits,
                           history, insights, tips, favourites, profile,
                           settings, notifications, shell
    widgets/               cards, buttons, headers, chips, MealImage
assets/images/food/        17 dish photographs + credits.json + CREDITS.md
supabase/schema.sql        tables, indexes, RLS, signup trigger
test/                      mood statistics + Sinhala/English switch regression
docs/figma-analysis.md     design audit and gap analysis
```

### Architecture notes

- **State** — `flutter_riverpod` with `ChangeNotifier` controllers.
- **Routing** — `go_router` with a `StatefulShellRoute` for the four tabs and
  root-level pushes for detail screens. Auth and onboarding redirects are
  driven by controller state.
- **Persistence** — one `AppRepository` interface, two implementations.
- **Local accounts** — profile, moods, favourites and read notifications are
  namespaced by email; only the demo identity is pre-seeded.
- **Localisation** — a single table in `app_localizations.dart` (index 0
  English, index 1 Sinhala). Missing keys fall back to the key itself, which
  makes incremental translation safe. The app registers Flutter's
  `GlobalMaterialLocalizations` / `GlobalWidgetsLocalizations` delegates rather
  than the English-only defaults; without them dialogs and bottom sheets throw
  in Sinhala, which previously trapped the UI in Sinhala.
- **Design system** — warm cream surfaces, `#F9751A` accent, 24–28 px radii,
  pill CTAs, bundled Poppins and Noto Sans Sinhala. Dishes use real photographs
  with the emoji tile kept as a fallback for missing assets.

---

## Screens

`/splash` → `/onboarding` → `/login` → four-tab shell:

- **Home** — greeting, mood card, today's suggestion, last check-in, tip,
  quick actions, nearby restaurants, reflection.
- **History** — stats, week chart, timeline.
- **Tips** — featured practice, progress, all practices.
- **Settings** — profile, personalisation, language, reminders, credits, support.

Root-level screens: mood check-in/result, meal detail, restaurants, credits,
insights, favourites, tip detail, profile/edit, preferences, reminders,
notifications.

---

## Notes and limitations

- Reminders are scheduled in-app; wiring `flutter_local_notifications` would
  make them system notifications.
- Nearby data comes from OpenStreetMap. Photon is the primary source because it
  answers quickly; if it has no listings for the area, Overpass is tried as a
  fallback (the public instance is rate-limited and can be slow at peak times).
  Results are cached in memory for ten minutes, and the last result for an area
  is saved on the device so the screen still works offline. The UI offers retry
  and a manual city fallback. Ordering and delivery links open Google Maps/search
  because no restaurant ordering API is free and keyless.
- YouTube recipes open in the YouTube app or a new browser tab. Videos are not
  downloaded or embedded, so creators keep their views and attribution.
- Supabase mirrors the profile, check-ins, favourites and meal logs. Recipes,
  photographs and videos are versioned with the app.
- Meal logging is real (`meal_logs` locally, `public.meal_logs` when Supabase is
  configured) and appears in History.
