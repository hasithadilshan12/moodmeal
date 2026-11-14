import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moodmeal/core/l10n/app_localizations.dart';
import 'package:moodmeal/core/theme/app_theme.dart';
import 'package:moodmeal/data/services/location_service.dart';
import 'package:moodmeal/state/nearby_controller.dart';
import 'package:moodmeal/ui/screens/restaurants/restaurants_page.dart';

/// Location that stays pending until the test completes it, so the loading
/// state can be inspected (this is the state that used to be unreachable).
class _PendingLocation implements LocationService {
  final completer = Completer<GeoPoint?>();

  @override
  Future<GeoPoint?> current() => completer.future;

  @override
  Future<bool> openAppSettings() async => true;

  @override
  Future<bool> openLocationSettings() async => true;
}

Widget _app(NearbyController nearby) {
  return ProviderScope(
    overrides: [nearbyProvider.overrideWith((ref) => nearby)],
    child: MaterialApp(
      theme: AppTheme.light(),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const RestaurantsPage(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Use my location shows progress instead of doing nothing',
      (tester) async {
    final location = _PendingLocation();
    final nearby = NearbyController(location: location);

    await tester.pumpWidget(_app(nearby));
    await tester.pumpAndSettle();

    expect(find.text('Use my location'), findsOneWidget);

    await tester.tap(find.text('Use my location'));
    await tester.pump();

    // The regression: the start prompt ignored NearbyStage.locating because it
    // checked for an origin first, so the tap looked dead.
    expect(find.text('Finding your location…'), findsOneWidget);
    expect(find.text('Use my location'), findsNothing);

    location.completer.completeError(
      const LocationProblem(LocationProblemKind.disabled),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Location services are turned off on this device. Open '
          'settings to turn them on, or pick your city.'),
      findsOneWidget,
    );
    expect(find.text('Open settings'), findsWidgets);
  });
}
