import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/mood_stats.dart';
import '../data/models/models.dart';
import '../data/models/mood_entry.dart';
import '../data/repositories/repository.dart';
import '../data/services/store.dart';

final repositoryProvider = Provider<AppRepository>((ref) {
  return Backend.isConfigured ? SupabaseRepository() : LocalRepository();
});

final appControllerProvider = ChangeNotifierProvider<AppController>((ref) {
  final controller = AppController(ref.watch(repositoryProvider));
  controller.bootstrap();
  return controller;
});

class AppController extends ChangeNotifier {
  AppController(this._repository);

  final AppRepository _repository;

  bool booting = true;
  bool busy = false;
  bool onboarded = false;
  AppSession? session;
  UserProfile? profile;
  List<MoodEntry> moods = const [];
  Set<String> favourites = {};
  List<MealLog> mealLogs = const [];
  String localeCode = 'en';
  ThemeMode themeMode = ThemeMode.system;
  String? error;

  bool get isSignedIn => session != null;
  bool get isDemo => session?.isDemo ?? !_repository.isRemote;
  bool get isRemote => _repository.isRemote;

  List<MoodEntry> get recentMoods => moods;

  MoodEntry? get lastEntry => moods.isEmpty ? null : moods.first;

  MoodEntry? get todayEntry {
    final now = DateTime.now();
    for (final entry in moods) {
      if (MoodStats.sameDay(entry.createdAt, now)) return entry;
    }
    return null;
  }

  int get streak => MoodStats.streak(moods);

  Mood? get topMood => MoodStats.topMood(moods);

  List<DayMood> get week => MoodStats.week(moods);

  int get checkInCount => moods.length;

  Future<void> bootstrap() async {
    final started = DateTime.now();
    try {
      onboarded = Store.onboarded;
      localeCode = Store.locale;
      themeMode = themeModeFromName(Store.themeMode);
      session = await _repository.restoreSession();
      if (session != null) {
        profile = await _repository.loadProfile(session!);
        moods = await _repository.loadMoods();
        favourites = await _repository.loadFavourites();
        mealLogs = await _repository.loadMealLogs();
      }
    } catch (e) {
      error = e.toString();
    } finally {
      // Keep the splash on screen long enough to feel intentional rather than
      // flickering on fast devices.
      final elapsed = DateTime.now().difference(started).inMilliseconds;
      if (elapsed < 900) {
        await Future<void>.delayed(Duration(milliseconds: 900 - elapsed));
      }
      booting = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserData() async {
    if (session == null) return;
    profile = await _repository.loadProfile(session!);
    moods = await _repository.loadMoods();
    favourites = await _repository.loadFavourites();
    mealLogs = await _repository.loadMealLogs();
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    onboarded = true;
    await Store.setOnboarded(true);
    notifyListeners();
  }

  /// Sentinel returned when Supabase requires the user to confirm their email
  /// before a session exists. The sign-up/sign-in screens translate it.
  static const needsEmailConfirmation = 'email-confirmation-required';

  /// Sentinel returned when the Supabase project has not enabled Google yet.
  static const googleNotEnabled = 'google-provider-not-enabled';

  Future<String?> signIn(String email, String password) async {
    return _auth(() async {
      session = await _repository.signIn(email.trim(), password);
      await _loadUserData();
    });
  }

  Future<String?> signUp(String name, String email, String password) async {
    return _auth(() async {
      session = await _repository.signUp(name.trim(), email.trim(), password);
      await _loadUserData();
    });
  }

  /// Like [_run], but maps "email not confirmed" failures to a friendly code
  /// instead of dumping the raw Supabase message into a snackbar.
  Future<String?> _auth(Future<void> Function() action) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      await action();
      return null;
    } on EmailConfirmationRequired {
      return needsEmailConfirmation;
    } catch (e) {
      final text = e.toString().toLowerCase();
      if (text.contains('not confirmed') || text.contains('confirm your')) {
        return needsEmailConfirmation;
      }
      error = e.toString();
      return error;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<String?> continueAsDemo() async {
    return _run(() async {
      session = await _repository.continueAsDemo();
      onboarded = true;
      await Store.setOnboarded(true);
      await _loadUserData();
    });
  }

  Future<void> signOut() async {
    await _repository.signOut();
    session = null;
    profile = null;
    moods = const [];
    favourites = {};
    mealLogs = const [];
    notifyListeners();
  }

  Future<String?> saveMood(MoodEntry entry) async {
    return _run(() async {
      await _repository.saveMood(entry);
      moods = [entry, ...moods];
      notifyListeners();
    });
  }

  Future<String?> toggleFavourite(String mealId) async {
    return _run(() async {
      final next = Set<String>.from(favourites);
      if (!next.remove(mealId)) next.add(mealId);
      favourites = next;
      await _repository.saveFavourites(next);
      notifyListeners();
    });
  }

  bool isFavourite(String mealId) => favourites.contains(mealId);

  /// Persists a cooked/eaten meal so the history screen can show a real log.
  Future<String?> logMeal(String mealId) async {
    return _run(() async {
      final log = MealLog(
        id: 'meal-${DateTime.now().microsecondsSinceEpoch}',
        mealId: mealId,
        createdAt: DateTime.now(),
      );
      await _repository.saveMealLog(log);
      mealLogs = [log, ...mealLogs];
      notifyListeners();
    });
  }

  bool loggedToday(String mealId) {
    final now = DateTime.now();
    return mealLogs.any(
      (log) => log.mealId == mealId && MoodStats.sameDay(log.createdAt, now),
    );
  }

  int get mealsLogged => mealLogs.length;

  int get mealsLoggedThisWeek {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 6));
    return mealLogs.where((log) => !log.createdAt.isBefore(start)).length;
  }

  Future<String?> updateProfile(UserProfile next) async {
    return _run(() async {
      profile = next;
      await _repository.saveProfile(next);
      notifyListeners();
    });
  }

  Future<void> setLanguage(String code) async {
    localeCode = code;
    await Store.setLocale(code);
    final current = profile;
    if (current != null) {
      profile = current.copyWith(language: code);
      await _repository.saveProfile(profile!);
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    await Store.setThemeMode(themeModeName(mode));
    notifyListeners();
  }

  static ThemeMode themeModeFromName(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String themeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  /// Signs in with Google through Supabase. Returns `null` when a browser
  /// redirect was opened: the session arrives on the next launch (web) or via
  /// [refreshSession] when the app resumes (mobile).
  Future<String?> signInWithGoogle() async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      final next = await _repository.signInWithGoogle();
      if (next != null) {
        session = next;
        await _loadUserData();
      }
      return null;
    } on GoogleProviderDisabled {
      return googleNotEnabled;
    } catch (e) {
      error = e.toString();
      return error;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  /// Picks up an OAuth session that completed while the app was backgrounded.
  Future<void> refreshSession() async {
    if (session != null) return;
    try {
      final restored = await _repository.restoreSession();
      if (restored == null) return;
      session = restored;
      await _loadUserData();
    } catch (_) {
      // Silent: the normal sign-in path surfaces actionable errors.
    }
  }

  void clearError() {
    error = null;
    notifyListeners();
  }

  Future<String?> _run(Future<void> Function() action) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      await action();
      return null;
    } catch (e) {
      error = e.toString();
      return error;
    } finally {
      busy = false;
      notifyListeners();
    }
  }
}

final localeProvider = Provider<String>((ref) {
  return ref.watch(appControllerProvider).localeCode;
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(appControllerProvider).themeMode;
});

/// Tracks which mindful tips the user has marked as practised. Kept separate
/// from [AppController] so a tip toggle rebuilds only the tip surfaces.
class PractisedStore extends ChangeNotifier {
  PractisedStore(this._email) {
    ids = Store.practisedFor(_email).toSet();
  }

  final String _email;

  Set<String> ids = {};

  bool contains(String id) => ids.contains(id);

  Future<void> toggle(String id) async {
    final next = Set<String>.from(ids);
    if (!next.remove(id)) next.add(id);
    ids = next;
    notifyListeners();
    await Store.setPractisedFor(_email, next.toList());
  }
}

final practisedProvider = ChangeNotifierProvider<PractisedStore>((ref) {
  final email =
      ref.watch(appControllerProvider.select((c) => c.session?.email ?? ''));
  return PractisedStore(email);
});

/// Tracks which notification rows the user has read. Shared so the Home bell
/// badge clears as soon as the inbox is marked read.
class ReadNotifsStore extends ChangeNotifier {
  ReadNotifsStore(this._email) {
    ids = Store.readNotifsFor(_email).toSet();
  }

  final String _email;

  Set<String> ids = {};

  bool contains(String id) => ids.contains(id);

  Future<void> markAll(Iterable<String> all) async {
    final next = {...ids, ...all};
    ids = next;
    notifyListeners();
    await Store.setReadNotifsFor(_email, next.toList());
  }

  Future<void> mark(String id) async {
    if (!ids.add(id)) return;
    ids = {...ids};
    notifyListeners();
    await Store.setReadNotifsFor(_email, ids.toList());
  }
}

final readNotifsProvider = ChangeNotifierProvider<ReadNotifsStore>((ref) {
  final email =
      ref.watch(appControllerProvider.select((c) => c.session?.email ?? ''));
  return ReadNotifsStore(email);
});
