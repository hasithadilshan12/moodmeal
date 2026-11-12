import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() => build(Brightness.light);

  static ThemeData dark() => build(Brightness.dark);

  static ThemeData build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.orange,
      onPrimary: Colors.white,
      primaryContainer: AppColors.peach,
      onPrimaryContainer: AppColors.ink,
      secondary: AppColors.orangeDeep,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.peachSoft,
      onSecondaryContainer: AppColors.ink,
      tertiary: AppColors.green,
      onTertiary: Colors.white,
      error: AppColors.rose,
      onError: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      onSurfaceVariant: AppColors.inkSoft,
      outline: AppColors.line,
      outlineVariant: AppColors.line,
      shadow: dark ? const Color(0x66000000) : const Color(0x1A2F2118),
      scrim: const Color(0x662F2118),
      inverseSurface: AppColors.ink,
      onInverseSurface: dark ? const Color(0xFF16120F) : Colors.white,
      inversePrimary: AppColors.orangeLight,
      surfaceTint: Colors.transparent,
    );

    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    final textTheme = _textTheme(base.textTheme);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.cream,
      textTheme: textTheme,
      colorScheme: scheme,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: AppColors.ink, size: 22),
        systemOverlayStyle:
            dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.line,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceAlt,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
        labelStyle: textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.orange, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.rose),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.rose, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.orange,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          textStyle: textTheme.titleMedium,
          shape: const StadiumBorder(),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          minimumSize: const Size.fromHeight(54),
          side: BorderSide(color: AppColors.line, width: 1.4),
          textStyle: textTheme.titleMedium,
          shape: const StadiumBorder(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.orangeDeep,
          textStyle: textTheme.labelLarge,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.peach,
        side: BorderSide(color: AppColors.line),
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: const StadiumBorder(),
        showCheckmark: false,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.cream,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: dark ? const Color(0xFFE9DFD6) : AppColors.ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: dark ? const Color(0xFF241C17) : Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base) {
    final t = base.apply(
      fontFamily: 'Poppins',
      fontFamilyFallback: const ['NotoSansSinhala'],
      bodyColor: AppColors.ink,
    );
    return t.copyWith(
      displaySmall: t.displaySmall
          ?.copyWith(fontSize: 34, height: 1.15, fontWeight: FontWeight.w700),
      headlineMedium: t.headlineMedium
          ?.copyWith(fontSize: 28, height: 1.2, fontWeight: FontWeight.w700),
      headlineSmall: t.headlineSmall
          ?.copyWith(fontSize: 24, height: 1.25, fontWeight: FontWeight.w700),
      titleLarge: t.titleLarge
          ?.copyWith(fontSize: 20, height: 1.3, fontWeight: FontWeight.w600),
      titleMedium: t.titleMedium
          ?.copyWith(fontSize: 16, height: 1.3, fontWeight: FontWeight.w600),
      titleSmall: t.titleSmall
          ?.copyWith(fontSize: 14, height: 1.3, fontWeight: FontWeight.w600),
      bodyLarge: t.bodyLarge?.copyWith(fontSize: 15, height: 1.55),
      bodyMedium: t.bodyMedium?.copyWith(fontSize: 13.5, height: 1.5),
      bodySmall: t.bodySmall
          ?.copyWith(fontSize: 12, height: 1.45, color: AppColors.inkSoft),
      labelLarge:
          t.labelLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
      labelMedium:
          t.labelMedium?.copyWith(fontSize: 12.5, fontWeight: FontWeight.w500),
      labelSmall: t.labelSmall?.copyWith(
          fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.2),
    );
  }
}

/// Shared elevation / radius helpers so cards feel consistent across screens.
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get card => [
        BoxShadow(
          color: AppColors.isDark
              ? Colors.black.withValues(alpha: 0.38)
              : AppColors.ink.withValues(alpha: 0.05),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get floating => [
        BoxShadow(
          color: AppColors.orange.withValues(alpha: 0.32),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ];
}
