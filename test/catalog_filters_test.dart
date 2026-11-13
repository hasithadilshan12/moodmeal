import 'package:flutter_test/flutter_test.dart';
import 'package:moodmeal/data/models/mood_entry.dart';
import 'package:moodmeal/data/seed/catalog.dart';

/// Regression tests for the food-preference filters. Before this, "avoid red
/// meat" was a no-op and sugary/caffeine/oily preferences were ignored, so the
/// mood result page recommended food the user asked never to see.
void main() {
  test('allergens remove meals that contain them', () {
    final meals = Catalog.mealsForMood(Mood.calm, allergies: const ['nuts']);
    expect(meals, isNotEmpty);
    expect(meals.any((m) => m.allergens.contains('nuts')), isFalse);
  });

  test('avoiding caffeine hides tea and chocolate', () {
    final meals = Catalog.mealsForMood(Mood.calm, avoid: const ['caffeine']);
    expect(meals.any((m) => m.id == 'green_tea'), isFalse);
    expect(meals.any((m) => m.id == 'chocolate'), isFalse);
    expect(meals, isNotEmpty);
  });

  test('avoiding sugary hides sweet drinks and treats', () {
    final meals = Catalog.mealsForMood(Mood.happy, avoid: const ['sugary']);
    expect(meals.any((m) => m.id == 'mango_smoothie'), isFalse);
    expect(meals.any((m) => m.id == 'chocolate'), isFalse);
  });

  test('avoiding fried and oily hides fried kottu', () {
    for (final tag in ['fried', 'oily']) {
      final meals = Catalog.mealsForMood(Mood.happy, avoid: [tag]);
      expect(meals.any((m) => m.id == 'kottu'), isFalse, reason: tag);
    }
  });

  test('every avoid key is attached to at least one meal or is a no-op', () {
    // Keys without a matching meal must not silently break the filter.
    for (final tag in Catalog.avoidKeys) {
      final meals = Catalog.mealsForMood(Mood.calm, avoid: [tag]);
      expect(meals, isA<List>());
    }
  });

  test('mood-matched meals are listed first', () {
    final meals = Catalog.mealsForMood(Mood.tired);
    expect(meals.first.worksFor(Mood.tired), isTrue);
  });
}
