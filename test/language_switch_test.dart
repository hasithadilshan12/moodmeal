import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moodmeal/core/l10n/app_localizations.dart';
import 'package:moodmeal/core/theme/app_theme.dart';
import 'package:moodmeal/data/services/store.dart';
import 'package:moodmeal/ui/screens/settings/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Regression test for the "cannot switch back to English" bug: while the app
/// was in Sinhala, opening the language sheet threw because Material strings
/// were only registered for English.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('language sheet opens in Sinhala and switches back to English',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'flutter.mm.onboarded': true,
      'flutter.mm.session.email': 'cameron@demo.moodmeal',
      'flutter.mm.locale': 'si',
    });
    await Store.init();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('si'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const SettingsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    final row = find.text('යෙදුම් භාෂාව');
    expect(row, findsOneWidget);
    await tester.ensureVisible(row);
    await tester.pumpAndSettle();
    await tester.tap(row);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('language-en')), findsOneWidget);
    await tester.tap(find.byKey(const Key('language-en')));
    await tester.pumpAndSettle();

    expect(Store.locale, 'en');
  });
}
