import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moodmeal/core/l10n/app_localizations.dart';
import 'package:moodmeal/core/theme/app_theme.dart';
import 'package:moodmeal/data/models/models.dart';
import 'package:moodmeal/data/models/mood_entry.dart';
import 'package:moodmeal/data/repositories/repository.dart';
import 'package:moodmeal/data/services/store.dart';
import 'package:moodmeal/state/app_controller.dart';
import 'package:moodmeal/ui/screens/auth/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A cloud build in tests: remote for auth, but never touches the network.
class _FakeCloudRepository implements AppRepository {
  @override
  bool get isRemote => true;

  @override
  Future<AppSession?> restoreSession() async => null;

  @override
  Future<AppSession> signIn(String email, String password) async =>
      AppSession(email: email, name: 'Test');

  @override
  Future<AppSession> signUp(String name, String email, String password) async =>
      AppSession(email: email, name: name);

  @override
  Future<AppSession?> signInWithGoogle() async => null;

  @override
  Future<void> signOut() async {}

  @override
  Future<UserProfile> loadProfile(AppSession session) async =>
      UserProfile(name: session.name, email: session.email);

  @override
  Future<void> saveProfile(UserProfile profile) async {}

  @override
  Future<List<MoodEntry>> loadMoods() async => const [];

  @override
  Future<void> saveMood(MoodEntry entry) async {}

  @override
  Future<Set<String>> loadFavourites() async => {};

  @override
  Future<void> saveFavourites(Set<String> ids) async {}

  @override
  Future<List<MealLog>> loadMealLogs() async => const [];

  @override
  Future<void> saveMealLog(MealLog log) async {}
}

Widget _app(AppController controller) {
  return ProviderScope(
    overrides: [
      appControllerProvider.overrideWith((ref) => controller),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const LoginPage(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await Store.init();
  });

  testWidgets('demo mode is gone from cloud builds', (tester) async {
    final controller = AppController(_FakeCloudRepository());
    await tester.pumpWidget(_app(controller));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login-demo')), findsNothing);
    expect(find.text('Continue in demo mode'), findsNothing);
    expect(find.byKey(const Key('login-google')), findsOneWidget);
  });

  testWidgets('an offline build hides the Google button and demo mode',
      (tester) async {
    final controller = AppController(LocalRepository());
    await tester.pumpWidget(_app(controller));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login-google')), findsNothing);
    expect(find.byKey(const Key('login-demo')), findsNothing);
  });

  test('the auth redirect target is never localhost', () {
    expect(authRedirectUrl, isNotEmpty);
    expect(authRedirectUrl.contains('localhost'), isFalse);
  });

  test('signing out clears the local session', () async {
    final repo = LocalRepository();
    await repo.signUp('Nimal', 'nimal@example.com', 'secret123');

    final controller = AppController(repo);
    await controller.bootstrap();
    expect(controller.isSignedIn, isTrue);

    await controller.signOut();
    expect(controller.isSignedIn, isFalse);
    expect(controller.profile, isNull);
    expect(controller.moods, isEmpty);
  });
}
