import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// True when the app was compiled with Supabase credentials:
/// `flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
/// Without them everything still works — data is stored on the device.
class Backend {
  Backend._();

  static const url = String.fromEnvironment('SUPABASE_URL');
  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  static Future<void> init() async {
    if (!isConfigured) return;
    await Supabase.initialize(url: url, publishableKey: anonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}

class Store {
  Store._();

  /// The shared demo identity gets sample data; real local accounts start
  /// empty so their charts and history reflect only their own check-ins.
  static const demoEmail = 'cameron@demo.moodmeal';

  static const _kOnboarded = 'mm.onboarded';
  static const _kSession = 'mm.session.email';
  static const _kProfile = 'mm.profile';
  static const _kMoods = 'mm.moods';
  static const _kFavourites = 'mm.favourites';
  static const _kPractised = 'mm.practised';
  static const _kReadNotifs = 'mm.notifications.read';
  static const _kMealLogs = 'mm.meal.logs';
  static const _kLocale = 'mm.locale';
  static const _kThemeMode = 'mm.theme.mode';
  static const _kSeedVersion = 'mm.seed';

  /// Local data is namespaced by account so signing out and signing in with a
  /// different email never exposes another person's moods or favourites.
  static String _key(String base, String? email) =>
      email == null || email.isEmpty ? base : '$base.${email.toLowerCase()}';

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final email = sessionEmail;
    if (email != null) await claimLegacyData(email);
  }

  static SharedPreferences get prefs => _prefs;

  static bool get onboarded => _prefs.getBool(_kOnboarded) ?? false;
  static Future<void> setOnboarded(bool value) =>
      _prefs.setBool(_kOnboarded, value);

  static String? get sessionEmail => _prefs.getString(_kSession);
  static Future<void> setSessionEmail(String? email) async {
    if (email == null) {
      await _prefs.remove(_kSession);
    } else {
      await _prefs.setString(_kSession, email);
    }
  }

  static String? profileJsonFor(String email) =>
      _prefs.getString(_key(_kProfile, email));

  static Future<void> setProfileJsonFor(String? value,
      {required String email}) async {
    final key = _key(_kProfile, email);
    if (value == null) {
      await _prefs.remove(key);
    } else {
      await _prefs.setString(key, value);
    }
  }

  static String? moodsJsonFor(String email) =>
      _prefs.getString(_key(_kMoods, email));

  static Future<void> setMoodsJsonFor(String? value,
      {required String email}) async {
    final key = _key(_kMoods, email);
    if (value == null) {
      await _prefs.remove(key);
    } else {
      await _prefs.setString(key, value);
    }
  }

  static String? favouritesJsonFor(String email) =>
      _prefs.getString(_key(_kFavourites, email));

  static Future<void> setFavouritesJsonFor(String value,
          {required String email}) =>
      _prefs.setString(_key(_kFavourites, email), value);

  static List<String> practisedFor(String email) =>
      _prefs.getStringList(_key(_kPractised, email)) ?? const [];
  static Future<void> setPractisedFor(String email, List<String> ids) =>
      _prefs.setStringList(_key(_kPractised, email), ids);

  static List<String> readNotifsFor(String email) =>
      _prefs.getStringList(_key(_kReadNotifs, email)) ?? const [];
  static Future<void> setReadNotifsFor(String email, List<String> ids) =>
      _prefs.setStringList(_key(_kReadNotifs, email), ids);

  static String? mealLogsJsonFor(String email) =>
      _prefs.getString(_key(_kMealLogs, email));
  static Future<void> setMealLogsJsonFor(String email, String value) =>
      _prefs.setString(_key(_kMealLogs, email), value);

  static String get locale => _prefs.getString(_kLocale) ?? 'en';
  static Future<void> setLocale(String code) =>
      _prefs.setString(_kLocale, code);

  /// One of `light`, `dark` or `system`.
  static String get themeMode => _prefs.getString(_kThemeMode) ?? 'system';
  static Future<void> setThemeMode(String mode) =>
      _prefs.setString(_kThemeMode, mode);

  static int seedVersionFor(String email) =>
      _prefs.getInt(_key(_kSeedVersion, email)) ?? 0;
  static Future<void> setSeedVersionFor(String email, int value) =>
      _prefs.setInt(_key(_kSeedVersion, email), value);

  /// Moves data written by older builds (single global keys) into the signed-in
  /// account's namespace. Safe to call on every launch: each key is moved at
  /// most once and the legacy key is removed afterwards.
  static Future<void> claimLegacyData(String email) async {
    await _claimString(_kProfile, email);
    await _claimString(_kMoods, email);
    await _claimString(_kFavourites, email);
    await _claimStringList(_kPractised, email);
    await _claimStringList(_kReadNotifs, email);

    final legacySeed = _prefs.getInt(_kSeedVersion);
    if (legacySeed != null) {
      final seedKey = _key(_kSeedVersion, email);
      if (!_prefs.containsKey(seedKey)) {
        await _prefs.setInt(seedKey, legacySeed);
      }
      await _prefs.remove(_kSeedVersion);
    }
  }

  static Future<void> _claimString(String base, String email) async {
    final legacy = _prefs.getString(base);
    if (legacy == null) return;
    final scoped = _key(base, email);
    if (!_prefs.containsKey(scoped)) {
      await _prefs.setString(scoped, legacy);
    }
    await _prefs.remove(base);
  }

  static Future<void> _claimStringList(String base, String email) async {
    final legacy = _prefs.getStringList(base);
    if (legacy == null) return;
    final scoped = _key(base, email);
    if (!_prefs.containsKey(scoped)) {
      await _prefs.setStringList(scoped, legacy);
    }
    await _prefs.remove(base);
  }
}
