# MoodMeal — 100% ට යන Step-by-Step Guide

> මේ file එකේ තියෙන්නේ **ඔයාගේ account එකක් අවශ්‍ය නිසා ඔයා කරන්න ඕන දේවල්** විතරයි.
> මගේ පැත්තෙන් කළ හැකි දේවල් (code, build, fix, verify) දැනටමත් අවසන්.

---

## 0. දැනට සූදානම් දේ (මගේ පැත්තෙන් අවසන්)

| Item | Status |
|---|---|
| `flutter analyze` | ✅ 0 issues |
| Automated tests | ✅ 23/23 pass |
| Web release build (Supabase සමඟ) | ✅ `build/web` |
| Netlify Drop සඳහා zip | ✅ `build/moodmeal-web.zip` (17 MB) |
| Android release APK | ✅ `build/app/outputs/flutter-apk/app-release.apk` (debug-signed) |
| Dark / Light / System theme | ✅ |
| Sinhala ↔ English | ✅ |
| Profile photo, notifications badge, favourites | ✅ |
| Console errors | ✅ 0 |

---

## 1. Google Login එක යාළුවන්ට වැඩ කරන්න සැලසුම් කරන්න

Google Cloud Console → **APIs & Services → OAuth consent screen**

### Option A — Testing mode (ඉක්මන්, publish ඕන නෑ)
1. **Audience** tab එකට යන්න
2. **Test users** → **+ ADD USERS**
3. යාළුවන්ගේ Gmail addresses එකින් එක එකතු කරන්න (max 100)
4. **SAVE**

> ⚠️ Test user ලැයිස්තුවේ නැති කෙනෙක් login කරන්න හැදුවොත් "Access blocked" එකක් එනවා.

### Option B — Publish (හැමෝටම, ස්ථිර)
1. **Audience** → **PUBLISH APP** → Confirm
2. Verification අවශ්‍ය වෙන්නේ sensitive scopes තියෙනවා නම් විතරයි. මේ app එකට ඕන වෙන්නේ `email`, `profile`, `openid` විතරයි — ඒ නිසා **verification ඕන නෑ**.
3. Status එක **In production** වෙනකම් ඉන්න (සාමාන්‍යයෙන් විනාඩි කිහිපයක්).

**Authorized redirect URI** (දැනටමත් තියෙන්න ඕන):
```
https://jsyusctedenikunyqfzk.supabase.co/auth/v1/callback
```

---

## 2. Email Confirmation — තීරණයක් ගන්න

Supabase Dashboard → **Authentication → Sign In / Providers → Email**

| තත්ත්වය | ප්‍රතිඵලය |
|---|---|
| **Confirm email = ON** (දැන්) | Sign up කළාට පස්සේ inbox එකේ link එක ඔබන්න ඕන. Link එක නැතිව login බෑ. |
| **Confirm email = OFF** | Sign up කළාම කෙලින්ම login වෙනවා. Testing වලට ලේසි. |

- **යාළුවන් test කරනවා නම් → OFF කරන්න** (spam folder, link expiry ප්‍රශ්න එන්නේ නෑ)
- **Real users එවනවා නම් → ON තියන්න** (fake emails block වෙනවා)

> OFF කරනවා නම්: toggle එක off කරලා **Save**.

---

## 3. Web App එක Deploy කරන්න (permanent link)

### 3.1 Netlify Drop (account එකක් නැතුව පවා පුළුවන්)
1. `C:\Users\user\MoodMealApp\build\moodmeal-web.zip` එක ගන්න
2. https://app.netlify.com/drop එකට යන්න
3. Zip එක **drag & drop** කරන්න
4. ලැබෙන link එක copy කරගන්න — උදා: `https://moodmeal-abc123.netlify.app`
5. (තමන්ගේ account එකට save කරන්න ඕන නම්) **Sign up → Claim site**

> App එක hash routing (`#/home`) use කරන නිසා redirect rules අවශ්‍ය නෑ.
> `moodmeal-web.zip` එකේ Supabase keys දැනටමත් build වෙලා තියෙනවා.

**ආයේ build කරන විට (code වෙනස් කළාට පස්සේ):**
```powershell
flutter build web --release --no-wasm-dry-run --dart-define-from-file=supabase.json
python tool\zip_web.py
```
`Compress-Archive` **use කරන්න එපා** — ඒක `\` separators දානවා (පහළ troubleshooting බලන්න). `tool\zip_web.py` එක entries ගණන සහ backslash 0 ද කියලා check කරලා කියනවා.

### 3.2 Supabase URL Configuration (අනිවාර්යයි)
Supabase Dashboard → **Authentication → URL Configuration**

- **Site URL:**
  ```
  https://moodmeal-abc123.netlify.app
  ```
- **Redirect URLs** එකතු කරන්න:
  ```
  https://moodmeal-abc123.netlify.app/**
  http://localhost:8080/**
  io.moodmeal.app://login-callback
  ```
- **Save**

> මේ step එක නොකළොත් Google login එකෙන් පස්සේ user `localhost` එකට හෝ error page එකකට යනවා.

**Link එක මට එවන්න** → මම deploy වුණු version එක browser එකෙන් check කරලා, login page + Google button + console errors verify කරන්නම්.

---

## 4. Android APK එක Install කරන්න

### යාළුවන්ට එවන්න පුළුවන් APK

| File | Size | කාටද |
|---|---|---|
| `app-arm64-v8a-release.apk` | 23.7 MB | **අලුත් phones 99%කට** (recommended) |
| `app-armeabi-v7a-release.apk` | 21.4 MB | පරණ 32-bit phones |
| `app-x86_64-release.apk` | 25.1 MB | Emulator / x86 tablets |
| `app-release.apk` | 61.3 MB | Universal — මොකක්ද තියෙන්නේ කියලා නොදන්නවා නම් මේක දෙන්න |

හැම එකක්ම තියෙන්නේ: `C:\Users\user\MoodMealApp\build\app\outputs\flutter-apk\`

> යාළුවෙක්ට "Install කරන්න බෑ" කිව්වොත් එයාගේ phone එක 32-bit වෙන්න පුළුවන් — ඒ වෙලාවට **armeabi-v7a** එක එවන්න.

### Install කරන විදිය
1. APK එක phone එකට යවන්න (WhatsApp "Message yourself", Google Drive, USB cable)
2. Phone එකේ **Settings → Apps → Special access → Install unknown apps** → Files/Chrome වලට allow
3. APK එක tap → **Install**
4. App name: **moodmeal**

> ⚠️ මේ APK එක **debug key එකෙන් sign කරලා** තියෙන්නේ — direct install/testing වලට හොඳයි.
> Play Store එකට දාන්න නම් release keystore එකක් හදලා sign කරන්න වෙනවා (ඕන නම් මම steps දෙන්නම්).

### APK එකේ Google login
- Deep link: `io.moodmeal.app://login-callback` (Supabase Redirect URLs වල තියෙන්න ඕන)
- Emulator එකේ test කරනවා නම් Play Services තියෙන image එකක් පාවිච්චි කරන්න

---

## 5. QA Checklist — ඔයා test කරන්න ඕන දේවල්

| # | Test | බලාපොරොත්තු ප්‍රතිඵලය |
|---|---|---|
| 1 | Splash → Onboarding → Skip | Login page එකට යනවා |
| 2 | Sign up (email/password) | Confirm ON නම් dialog එකක්; OFF නම් කෙලින්ම Home |
| 3 | Login (email/password) | Home එකට යනවා |
| 4 | **Continue with Google** | Google account chooser → sign in → Home |
| 5 | Mood check-in → Find my meals | Result page එක, filter chips වැඩ කරනවා |
| 6 | Meal → Log this meal | "Meal logged" → History එකේ පේනවා |
| 7 | Meal → Heart icon | Favourites එකේ පේනවා, count එක වැඩි වෙනවා |
| 8 | Favourites → heart remove | Count එක අඩු වෙනවා |
| 9 | Settings → Appearance → Dark/Light/System | මුළු app එකම මාරු වෙනවා, restart කළාට පස්සේත් ඉතුරු |
| 10 | Settings → App Language → සිංහල | හැම screen එකේම Sinhala, English වලට ආයේ මාරු කරන්න පුළුවන් |
| 11 | Profile → Add photo → Save | Home එකේ avatar එකේ පේනවා |
| 12 | Home bell → Mark all read | Badge එක clear වෙනවා, reload කළාට පස්සේත් clear |
| 13 | Home → Nearby restaurants | Location allow කරලා restaurants ලැයිස්තුව (network ඕන) |
| 14 | Logout → Login | Data ඉතුරු වෙලා තියෙනවා |

---

## 6. දැනට දන්නා සීමා (bugs නෙවෙයි)

| සීමාව | හේතුව |
|---|---|
| Web URL bar එක in-app page වලට යද්දී update වෙන්නේ නෑ | go_router push behaviour. Back button හරියට වැඩ කරනවා. |
| Nearby සමහර වෙලාවට slow/fail | Photon/Overpass public services. Retry + error state තියෙනවා. |
| APK debug-signed | Play Store සඳහා release keystore ඕන. |
| Email confirm ON නම් link එක ඕන | Supabase setting එකෙන් off කරන්න පුළුවන්. |

---

## 7. Troubleshooting: deploy කළාට පස්සේ icons □ □ □ වගේ පේනවා නම්

හේතුව: zip එක Windows `Compress-Archive` එකෙන් හදලා නම්, ඒක ඇතුළේ folder separators `\` විදියට තියෙනවා. Netlify ඒවා extract කරද්දී `assets\fonts\...` කියන නමින් හදනවා → browser එකට `assets/fonts/...` 404 → **icons සහ fonts load වෙන්නේ නෑ**.

මේ repo එකේ තියෙන `build/moodmeal-web.zip` එක **හරි** (forward slash, 77 entries). පරණ එක deploy කරලා නම් අලුත් එකෙන් ආයේ deploy කරන්න:

1. Netlify → site එක → **Deploys** tab
2. පහළ තියෙන **"Need to update your site? Drag and drop your site folder here"** කොටුවට අලුත් zip එක drag කරන්න
3. URL එක **වෙනස් වෙන්නේ නෑ**
4. Browser එකේ **Ctrl + Shift + R** (hard refresh)

Check කරන්න:
```
https://ඔයාගේ-site.netlify.app/assets/fonts/MaterialIcons-Regular.otf   → 200
https://ඔයාගේ-site.netlify.app/assets/FontManifest.json                → 200
```

---

## 8. මට එවන්න ඕන දේ

1. **Netlify link එක** (deploy කළාට පස්සේ) — මම verify කරන්නම්
2. Error එකක් ආවොත් **screenshot එකක්** + ඒ වෙලාවේ URL එක
3. Google login එකේ ප්‍රශ්නයක් නම් — Google page එකේ පේන error message එක

ඔයා link එක එව්ව ගමන් මම:
- Public URL එකේ login page, Google button, console errors check කරනවා
- Supabase redirect config එක හරිද කියලා test කරනවා
- ප්‍රශ්නයක් තිබ්බොත් code fix කරලා ආයේ build කරනවා
