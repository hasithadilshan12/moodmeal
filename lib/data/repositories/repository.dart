import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/models.dart';
import '../models/mood_entry.dart';
import '../seed/catalog.dart';
import '../services/store.dart';

class AppSession {
  const AppSession(
      {required this.email, required this.name, this.isDemo = false});

  final String email;
  final String name;
  final bool isDemo;
}

/// Thrown when Supabase is set up to require email confirmation. The account
/// exists, but there is no session until the user opens the confirmation link,
/// so the UI must explain that instead of showing a raw RLS error.
class EmailConfirmationRequired implements Exception {
  const EmailConfirmationRequired();
}

/// Thrown before an OAuth redirect when the Supabase project has not enabled
/// the Google provider yet. Without this guard the web app would navigate away
/// from itself and land on a raw JSON error page.
class GoogleProviderDisabled implements Exception {
  const GoogleProviderDisabled();
}

/// Builds an [AppSession] from a Supabase user. Shared with the controller so
/// an OAuth callback that arrives after the login screen can adopt the session.
AppSession sessionFromSupabaseUser(User user) {
  final name = (user.userMetadata?['name'] as String?) ??
      (user.userMetadata?['full_name'] as String?) ??
      user.email?.split('@').first ??
      'Friend';
  return AppSession(email: user.email ?? '', name: name);
}

abstract class AppRepository {
  bool get isRemote;

  Future<AppSession?> restoreSession();
  Future<AppSession> signIn(String email, String password);
  Future<AppSession> signUp(String name, String email, String password);
  Future<AppSession?> signInWithGoogle();
  Future<AppSession> continueAsDemo();
  Future<void> signOut();

  Future<UserProfile> loadProfile(AppSession session);
  Future<void> saveProfile(UserProfile profile);

  Future<List<MoodEntry>> loadMoods();
  Future<void> saveMood(MoodEntry entry);

  Future<Set<String>> loadFavourites();
  Future<void> saveFavourites(Set<String> ids);

  Future<List<MealLog>> loadMealLogs();
  Future<void> saveMealLog(MealLog log);
}

/// Offline-first implementation. Seeds a friendly week of sample check-ins so
/// charts and insights are useful on first launch.
class LocalRepository implements AppRepository {
  LocalRepository();

  @override
  bool get isRemote => false;

  @override
  Future<AppSession?> restoreSession() async {
    final email = Store.sessionEmail;
    if (email == null) return null;
    await Store.claimLegacyData(email);
    final profile = await _readProfile(email);
    return AppSession(
      email: email,
      name: profile.name,
      isDemo: email.toLowerCase() == Store.demoEmail,
    );
  }

  @override
  Future<AppSession> signIn(String email, String password) async {
    await Store.setSessionEmail(email);
    return AppSession(email: email, name: (await _readProfile(email)).name);
  }

  @override
  Future<AppSession> signUp(String name, String email, String password) async {
    await Store.setSessionEmail(email);
    await saveProfile(UserProfile(name: name, email: email));
    return AppSession(email: email, name: name);
  }

  @override
  Future<AppSession?> signInWithGoogle() async {
    throw const AuthException(
      'Connect MoodMeal to Supabase to enable Google sign-in.',
    );
  }

  @override
  Future<AppSession> continueAsDemo() async {
    const email = Store.demoEmail;
    await Store.setSessionEmail(email);
    await Store.claimLegacyData(email);
    if (Store.profileJsonFor(email) == null) {
      await saveProfile(
        const UserProfile(name: 'Cameron Wilson', email: email),
      );
    }
    return const AppSession(email: email, name: 'Cameron Wilson', isDemo: true);
  }

  @override
  Future<void> signOut() => Store.setSessionEmail(null);

  @override
  Future<UserProfile> loadProfile(AppSession session) async {
    await _seedIfNeeded(session.email);
    final profile = await _readProfile(session.email);
    return profile;
  }

  Future<UserProfile> _readProfile(String email) async {
    await Store.claimLegacyData(email);
    final raw = Store.profileJsonFor(email);
    if (raw == null) {
      return UserProfile(name: email.split('@').first, email: email);
    }
    try {
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return UserProfile(name: email.split('@').first, email: email);
    }
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    await Store.setProfileJsonFor(
      jsonEncode(profile.toJson()),
      email: profile.email,
    );
  }

  String get _currentEmail => (Store.sessionEmail ?? '').toLowerCase();

  @override
  Future<List<MoodEntry>> loadMoods() async {
    final email = _currentEmail;
    await _seedIfNeeded(email);
    final raw = Store.moodsJsonFor(email);
    if (raw == null) return const [];
    final list = (jsonDecode(raw) as List)
        .map((e) => MoodEntry.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<void> saveMood(MoodEntry entry) async {
    final existing = await loadMoods();
    final updated = [entry, ...existing];
    await Store.setMoodsJsonFor(
      jsonEncode(updated.map((e) => e.toJson()).toList()),
      email: _currentEmail,
    );
  }

  @override
  Future<Set<String>> loadFavourites() async {
    final email = _currentEmail;
    await Store.claimLegacyData(email);
    final raw = Store.favouritesJsonFor(email);
    if (raw == null) {
      return email == Store.demoEmail ? {'oatmeal', 'green_tea'} : <String>{};
    }
    return (jsonDecode(raw) as List).cast<String>().toSet();
  }

  @override
  Future<void> saveFavourites(Set<String> ids) async {
    await Store.setFavouritesJsonFor(
      jsonEncode(ids.toList()),
      email: _currentEmail,
    );
  }

  @override
  Future<List<MealLog>> loadMealLogs() async {
    final raw = Store.mealLogsJsonFor(_currentEmail);
    if (raw == null) return const [];
    try {
      final list = (jsonDecode(raw) as List)
          .map((e) => MealLog.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> saveMealLog(MealLog log) async {
    final existing = await loadMealLogs();
    final updated = [log, ...existing].take(500).toList();
    await Store.setMealLogsJsonFor(
      _currentEmail,
      jsonEncode(updated.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> _seedIfNeeded(String email) async {
    if (email.toLowerCase() != Store.demoEmail) return;
    if (Store.seedVersionFor(email) >= 1) return;
    if (Store.moodsJsonFor(email) == null) {
      final now = DateTime.now();
      final sample = <MoodEntry>[
        MoodEntry(
          id: 'seed-1',
          mood: Mood.tired,
          intensity: 3,
          createdAt: now.subtract(const Duration(days: 6, hours: 2)),
          tags: const ['work'],
          note: 'Long day, skipped lunch.',
        ),
        MoodEntry(
          id: 'seed-2',
          mood: Mood.stressed,
          intensity: 4,
          createdAt: now.subtract(const Duration(days: 5, hours: 1)),
          tags: const ['work', 'sleep'],
        ),
        MoodEntry(
          id: 'seed-3',
          mood: Mood.calm,
          intensity: 4,
          createdAt: now.subtract(const Duration(days: 4)),
          tags: const ['family'],
          note: 'Slow morning with tea.',
        ),
        MoodEntry(
          id: 'seed-4',
          mood: Mood.happy,
          intensity: 5,
          createdAt: now.subtract(const Duration(days: 3)),
          tags: const ['social'],
        ),
        MoodEntry(
          id: 'seed-5',
          mood: Mood.bored,
          intensity: 2,
          createdAt: now.subtract(const Duration(days: 2)),
          tags: const ['weather'],
        ),
        MoodEntry(
          id: 'seed-6',
          mood: Mood.calm,
          intensity: 3,
          createdAt: now.subtract(const Duration(days: 1)),
          tags: const ['sleep'],
        ),
      ];
      await Store.setMoodsJsonFor(
        jsonEncode(sample.map((e) => e.toJson()).toList()),
        email: email,
      );
    }
    await Store.setSeedVersionFor(email, 1);
  }
}

/// Supabase-backed implementation. Schema lives in `supabase/schema.sql`.
class SupabaseRepository implements AppRepository {
  SupabaseRepository();

  SupabaseClient get _client => Supabase.instance.client;

  @override
  bool get isRemote => true;

  AppSession _sessionFrom(User user) => sessionFromSupabaseUser(user);

  @override
  Future<AppSession?> restoreSession() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _sessionFrom(user);
  }

  @override
  Future<AppSession> signIn(String email, String password) async {
    final res = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = res.user;
    if (user == null) throw const AuthException('Unable to sign in');
    return _sessionFrom(user);
  }

  @override
  Future<AppSession> signUp(String name, String email, String password) async {
    final res = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
    final user = res.user;
    if (user == null) throw const AuthException('Unable to sign up');
    if (res.session == null) {
      // Confirmation is enabled in the Supabase project. The `handle_new_user`
      // trigger already created the profile row, and RLS would reject an
      // unauthenticated upsert here, so stop and ask the user to confirm.
      throw const EmailConfirmationRequired();
    }
    await _client.from('profiles').upsert({
      'id': user.id,
      'name': name,
      'email': email,
    });
    return AppSession(email: email, name: name);
  }

  @override
  Future<AppSession> continueAsDemo() async {
    // Remote builds never fabricate users; the caller shows the sign-in screen.
    throw const AuthException('Demo mode is available offline only.');
  }

  @override
  Future<AppSession?> signInWithGoogle() async {
    // On web `signInWithOAuth` replaces the current page with the Supabase
    // authorize URL. If the provider is disabled that URL returns raw JSON and
    // the user loses the app, so ask the public settings endpoint first and
    // fail with a localized message instead.
    try {
      final response = await http.get(
        Uri.parse('${Backend.url}/auth/v1/settings'),
        headers: {'apikey': Backend.anonKey},
      ).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final external = data['external'] as Map<String, dynamic>?;
        if (external != null && external['google'] == false) {
          throw const GoogleProviderDisabled();
        }
      }
    } on GoogleProviderDisabled {
      rethrow;
    } catch (_) {
      // Settings are best-effort; let the normal OAuth flow try if unreachable.
    }

    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb ? Uri.base.origin : 'io.moodmeal.app://login-callback',
      authScreenLaunchMode:
          kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
    );
    // Web reloads on the redirect and mobile resumes the app; the session is
    // picked up by restoreSession either way.
    final user = _client.auth.currentUser;
    return user == null ? null : _sessionFrom(user);
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  @override
  Future<UserProfile> loadProfile(AppSession session) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return UserProfile(name: session.name, email: session.email);
    }
    final row =
        await _client.from('profiles').select().eq('id', user.id).maybeSingle();
    if (row == null) {
      final profile = UserProfile(name: session.name, email: session.email);
      await _client.from('profiles').insert({
        'id': user.id,
        'name': profile.name,
        'email': profile.email,
        'avatar': profile.avatar,
        'photo': profile.photo,
        'allergies': profile.allergies,
        'conditions': profile.conditions,
        'avoid': profile.avoid,
        'language': profile.language,
        'reminder_enabled': profile.reminderEnabled,
        'reminder_hour': profile.reminderHour,
        'reminder_minute': profile.reminderMinute,
        'reminder_days': profile.reminderDays,
      });
      return profile;
    }
    return UserProfile.fromJson(row);
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    await _client.from('profiles').upsert({
      'id': user.id,
      'name': profile.name,
      'email': profile.email,
      'avatar': profile.avatar,
      'photo': profile.photo,
      'allergies': profile.allergies,
      'conditions': profile.conditions,
      'avoid': profile.avoid,
      'language': profile.language,
      'reminder_enabled': profile.reminderEnabled,
      'reminder_hour': profile.reminderHour,
      'reminder_minute': profile.reminderMinute,
      'reminder_days': profile.reminderDays,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<List<MoodEntry>> loadMoods() async {
    final user = _client.auth.currentUser;
    if (user == null) return const [];
    final rows = await _client
        .from('mood_entries')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .limit(200);
    return rows
        .map((row) => MoodEntry(
              id: row['id'].toString(),
              mood: Mood.values.firstWhere(
                (m) => m.name == row['mood'],
                orElse: () => Mood.calm,
              ),
              intensity: (row['intensity'] as num?)?.toInt() ?? 3,
              createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
              note: row['note'] as String? ?? '',
              tags: (row['tags'] as List?)?.cast<String>() ?? const [],
            ))
        .toList();
  }

  @override
  Future<void> saveMood(MoodEntry entry) async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    await _client.from('mood_entries').insert({
      'user_id': user.id,
      'mood': entry.mood.name,
      'intensity': entry.intensity,
      'note': entry.note,
      'tags': entry.tags,
      'created_at': entry.createdAt.toUtc().toIso8601String(),
    });
  }

  @override
  Future<Set<String>> loadFavourites() async {
    final user = _client.auth.currentUser;
    if (user == null) return {};
    final rows = await _client
        .from('favourites')
        .select('meal_id')
        .eq('user_id', user.id);
    return rows.map((r) => r['meal_id'] as String).toSet();
  }

  @override
  Future<void> saveFavourites(Set<String> ids) async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    final existing = await loadFavourites();
    final toAdd = ids.difference(existing);
    final toRemove = existing.difference(ids);
    if (toAdd.isNotEmpty) {
      await _client.from('favourites').insert([
        for (final id in toAdd) {'user_id': user.id, 'meal_id': id},
      ]);
    }
    for (final id in toRemove) {
      await _client
          .from('favourites')
          .delete()
          .eq('user_id', user.id)
          .eq('meal_id', id);
    }
  }

  @override
  Future<List<MealLog>> loadMealLogs() async {
    final user = _client.auth.currentUser;
    if (user == null) return const [];
    final rows = await _client
        .from('meal_logs')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .limit(200);
    return rows
        .map((row) => MealLog(
              id: row['id'].toString(),
              mealId: row['meal_id'] as String,
              createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
            ))
        .toList();
  }

  @override
  Future<void> saveMealLog(MealLog log) async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    await _client.from('meal_logs').insert({
      'user_id': user.id,
      'meal_id': log.mealId,
      'created_at': log.createdAt.toUtc().toIso8601String(),
    });
  }
}

/// Keeps the catalogue close to the UI layer.
class Meals {
  Meals._();
  static List<Meal> all() => Catalog.meals;
}
