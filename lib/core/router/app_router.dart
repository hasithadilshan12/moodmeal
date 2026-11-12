import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/mood_entry.dart';
import '../../state/app_controller.dart';
import '../../ui/screens/auth/login_page.dart';
import '../../ui/screens/auth/signup_page.dart';
import '../../ui/screens/credits/credits_page.dart';
import '../../ui/screens/explore/explore_page.dart';
import '../../ui/screens/favourites/favourites_page.dart';
import '../../ui/screens/history/history_page.dart';
import '../../ui/screens/history/insights_page.dart';
import '../../ui/screens/home/home_page.dart';
import '../../ui/screens/meals/meal_detail_page.dart';
import '../../ui/screens/mood/mood_checkin_page.dart';
import '../../ui/screens/mood/mood_result_page.dart';
import '../../ui/screens/notifications/notifications_page.dart';
import '../../ui/screens/onboarding_page.dart';
import '../../ui/screens/profile/edit_profile_page.dart';
import '../../ui/screens/profile/profile_page.dart';
import '../../ui/screens/restaurants/restaurants_page.dart';
import '../../ui/screens/settings/preferences_page.dart';
import '../../ui/screens/settings/reminders_page.dart';
import '../../ui/screens/settings/settings_page.dart';
import '../../ui/screens/shell/app_shell.dart';
import '../../ui/screens/splash_page.dart';
import '../../ui/screens/tips/tip_detail_page.dart';
import '../../ui/screens/tips/tips_page.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final routerProvider = Provider<GoRouter>((ref) {
  final controller = ref.read(appControllerProvider);

  final router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/splash',
    refreshListenable: controller,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      if (controller.booting) return loc == '/splash' ? null : '/splash';

      final onAuthPage = loc == '/login' || loc == '/signup';
      if (!controller.onboarded) {
        return loc == '/onboarding' ? null : '/onboarding';
      }
      if (!controller.isSignedIn) {
        return onAuthPage ? null : '/login';
      }
      if (loc == '/splash' || loc == '/onboarding' || onAuthPage) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingPage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupPage()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (_, __) => const HomePage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/history', builder: (_, __) => const HistoryPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/tips', builder: (_, __) => const TipsPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/settings', builder: (_, __) => const SettingsPage()),
          ]),
        ],
      ),
      GoRoute(
        path: '/mood/checkin',
        parentNavigatorKey: _rootKey,
        builder: (_, __) => const MoodCheckinPage(),
      ),
      GoRoute(
        path: '/mood/result',
        parentNavigatorKey: _rootKey,
        builder: (context, state) {
          final mood = state.extra is Mood ? state.extra as Mood : null;
          return MoodResultPage(mood: mood);
        },
      ),
      GoRoute(
        path: '/meal/:id',
        parentNavigatorKey: _rootKey,
        builder: (_, state) =>
            MealDetailPage(mealId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/restaurants',
        parentNavigatorKey: _rootKey,
        builder: (_, state) => RestaurantsPage(
          mealId: state.uri.queryParameters['meal'],
        ),
      ),
      GoRoute(
        path: '/credits',
        parentNavigatorKey: _rootKey,
        builder: (_, __) => const CreditsPage(),
      ),
      GoRoute(
        path: '/insights',
        parentNavigatorKey: _rootKey,
        builder: (_, __) => const InsightsPage(),
      ),
      GoRoute(
        path: '/favourites',
        parentNavigatorKey: _rootKey,
        builder: (_, __) => const FavouritesPage(),
      ),
      GoRoute(
        path: '/explore',
        parentNavigatorKey: _rootKey,
        builder: (_, __) => const ExplorePage(),
      ),
      GoRoute(
        path: '/tips/:id',
        parentNavigatorKey: _rootKey,
        builder: (_, state) =>
            TipDetailPage(tipId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/profile',
        parentNavigatorKey: _rootKey,
        builder: (_, __) => const ProfilePage(),
      ),
      GoRoute(
        path: '/profile/edit',
        parentNavigatorKey: _rootKey,
        builder: (_, __) => const EditProfilePage(),
      ),
      GoRoute(
        path: '/preferences',
        parentNavigatorKey: _rootKey,
        builder: (_, __) => const PreferencesPage(),
      ),
      GoRoute(
        path: '/reminders',
        parentNavigatorKey: _rootKey,
        builder: (_, __) => const RemindersPage(),
      ),
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: _rootKey,
        builder: (_, __) => const NotificationsPage(),
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
