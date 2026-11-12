import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/app_localizations.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../state/app_controller.dart';

class MoodMealApp extends ConsumerStatefulWidget {
  const MoodMealApp({super.key});

  @override
  ConsumerState<MoodMealApp> createState() => _MoodMealAppState();
}

class _MoodMealAppState extends ConsumerState<MoodMealApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    if (ref.read(appControllerProvider).themeMode == ThemeMode.system) {
      setState(() {});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(appControllerProvider).refreshSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeCode = ref.watch(localeProvider);
    final mode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    final systemDark =
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
    final dark =
        mode == ThemeMode.dark || (mode == ThemeMode.system && systemDark);

    // Neutral palette tokens are read directly by hundreds of widgets, so the
    // active brightness is published globally before the tree is rebuilt.
    AppColors.setDark(dark);

    // Keep the Android status/navigation bars in step with the in-app theme.
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: dark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: AppColors.cream,
        systemNavigationBarIconBrightness:
            dark ? Brightness.light : Brightness.dark,
      ),
    );

    return MaterialApp.router(
      title: 'MoodMeal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(Brightness.light),
      darkTheme: AppTheme.build(Brightness.dark),
      themeMode: mode,
      routerConfig: router,
      locale: Locale(localeCode),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        // Flutter's built-in material/widgets strings only ship in English.
        // Without the global delegates every dialog and bottom sheet throws in
        // Sinhala, which made the language picker impossible to reopen.
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final content = MediaQuery.withClampedTextScaling(
          minScaleFactor: 0.9,
          maxScaleFactor: 1.2,
          child: child ?? const SizedBox.shrink(),
        );

        // MoodMeal is designed phone-first. On tablets and desktop keep the
        // experience at a comfortable reading width instead of stretching
        // every card across the window.
        if (MediaQuery.sizeOf(context).width <= 560) return content;

        return ColoredBox(
          color: AppColors.peachSoft,
          child: Center(
            child: SizedBox(
              width: 520,
              height: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  border: Border.symmetric(
                    vertical: BorderSide.none,
                    horizontal: BorderSide(
                        color: AppColors.line.withValues(alpha: 0.6)),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.isDark
                          ? Colors.black.withValues(alpha: 0.5)
                          : AppColors.ink.withValues(alpha: 0.08),
                      blurRadius: 40,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRect(child: content),
              ),
            ),
          ),
        );
      },
    );
  }
}
