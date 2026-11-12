# MoodMeal — Figma Design Analysis

Source: <https://www.figma.com/design/fqmPjzwSQmbLjMxd6cRCwA/UX-design-Group-project>

The file is view-only for an anonymous viewer (no hotspot interaction, no export),
so this analysis combines the prototype walkthrough, the layer tree (31 frames on
`Page 1`) and the canvas at 50 %.

## 1. Frame inventory (as named in Figma)

| Group | Notes |
| --- | --- |
| Splash / Get Started | Logo, tagline "Choose with heart. Eat with calm.", single CTA |
| Onboarding 1 | "Your Emotions affect what you eat" + illustration, Skip, pager dots |
| Onboarding 2 | "Get meal suggestions that support your feelings", Continue |
| Login (Welcome Back) | Email + password, orange CTA, "Forgot Password?", "Sign UP" |
| Home | Greeting, mood CTA card, Today's Suggestion, Last Check In + Mindful Tip, 4-tab bottom nav |
| Mindful Eating Tips | Illustrated tip list (7 tips), back arrow, bottom nav |
| Food Preferences | Allergies, Health Conditions, Foods to avoid (chip grids) |
| Settings / Profile | Avatar, name, edit profile, reminder time toggle, preferences |
| post meal / choose | Post-meal flow, meal choice |
| post meal / choose open now | Restaurant suggestions with "open now" state |
| Mindful meal screen 2–5 | Meal detail / mindful eating step screens |
| Component 23–100 | Remaining app screens & component sheets (history, notifications, favourites, etc.) |

## 2. Visual language (extracted)

- **Primary**: `#F9751A` (also appears as gradient `#FF9A3C → #F0630C`)
- **Neutrals in file**: `#655656` (ink), `#BEB7B7` (muted)
- **Backgrounds**: cream `#FFF7F0`, peach tint `#FFE8D6`, white cards
- **Shapes**: 24–28 px card radius, pill buttons, soft layered shadows
- **Imagery**: rounded square "food tiles" with 3D/emoji style illustrations
- **Navigation**: persistent bottom bar — Home · History · Tips · Settings
- **Type**: geometric sans (Poppins-like), bold section titles, small muted captions
- **Density**: generous white space, single-column cards, small bottom nav labels

## 3. Feature map derived from the brief + frames

1. Mood check-in: emoji picker → intensity/energy → note & context tags
2. Mood-based meal recommendations (rule-based scoring of a curated catalog)
3. Meal detail: ingredients, nutrition, mindful-eating prompt, log meal, favourite
4. Nearby restaurants with distance / open-now / rating
5. History: mood timeline, streaks, weekly mood chart
6. Insights: mood ↔ food correlation, mood distribution
7. Mindful eating tips (7 illustrated tips from the design)
8. Food preferences & allergens (from the design's chip grids)
9. Favourites, notifications, reminders (time + days)
10. Profile/settings: edit profile, language (EN/SI), reminder management

## 4. Gaps closed in the implementation (not visible in the file)

- Empty / loading / error states, offline demo mode
- Real auth (Supabase) with a local demo fallback
- Accessibility: semantic labels, 48 dp targets, contrast-safe text
- Sinhala localisation, dynamic type, reduced motion friendly transitions
