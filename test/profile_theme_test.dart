import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moodmeal/core/theme/app_colors.dart';
import 'package:moodmeal/data/models/models.dart';
import 'package:moodmeal/state/app_controller.dart';

void main() {
  test('profile photo survives a JSON round trip', () {
    const profile = UserProfile(
      name: 'Nimal',
      email: 'nimal@example.com',
      avatar: '🌱',
      photo: 'aGVsbG8=',
    );

    final restored = UserProfile.fromJson(profile.toJson());
    expect(restored.photo, 'aGVsbG8=');
    expect(restored.hasPhoto, isTrue);
    expect(restored.avatar, '🌱');

    final cleared = restored.copyWith(photo: '');
    expect(cleared.hasPhoto, isFalse);
    expect(cleared.name, 'Nimal');
  });

  test('theme mode names round trip', () {
    for (final mode in ThemeMode.values) {
      final name = AppController.themeModeName(mode);
      expect(AppController.themeModeFromName(name), mode);
    }
    expect(AppController.themeModeFromName('nonsense'), ThemeMode.system);
  });

  test('dark palette flips neutral tokens', () {
    AppColors.setDark(false);
    final lightCream = AppColors.cream;
    final lightInk = AppColors.ink;
    expect(AppColors.isDark, isFalse);

    AppColors.setDark(true);
    expect(AppColors.isDark, isTrue);
    expect(AppColors.cream, isNot(lightCream));
    expect(AppColors.ink, isNot(lightInk));
    expect(AppColors.ink.computeLuminance(),
        greaterThan(AppColors.cream.computeLuminance()));

    AppColors.setDark(false);
  });
}
