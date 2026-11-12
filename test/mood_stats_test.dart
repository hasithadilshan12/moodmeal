import 'package:flutter_test/flutter_test.dart';
import 'package:moodmeal/core/utils/mood_stats.dart';
import 'package:moodmeal/data/models/mood_entry.dart';

MoodEntry entry(DateTime at, {Mood mood = Mood.calm, int intensity = 3}) {
  return MoodEntry(
    id: at.microsecondsSinceEpoch.toString(),
    mood: mood,
    intensity: intensity,
    createdAt: at,
  );
}

void main() {
  final now = DateTime(2026, 11, 4, 12);

  group('MoodStats.streak', () {
    test('is zero without entries', () {
      expect(MoodStats.streak(const [], now: now), 0);
    });

    test('counts consecutive days ending today', () {
      final entries = [
        entry(now),
        entry(now.subtract(const Duration(days: 1))),
        entry(now.subtract(const Duration(days: 2))),
      ];
      expect(MoodStats.streak(entries, now: now), 3);
    });

    test('keeps a streak alive if today is not logged yet', () {
      final entries = [
        entry(now.subtract(const Duration(days: 1))),
        entry(now.subtract(const Duration(days: 2))),
      ];
      expect(MoodStats.streak(entries, now: now), 2);
    });

    test('breaks on a missing day', () {
      final entries = [
        entry(now),
        entry(now.subtract(const Duration(days: 2))),
      ];
      expect(MoodStats.streak(entries, now: now), 1);
    });

    test('counts each calendar day only once', () {
      final entries = [
        entry(now),
        entry(now.subtract(const Duration(hours: 3))),
        entry(now.subtract(const Duration(days: 1))),
      ];
      expect(MoodStats.streak(entries, now: now), 2);
    });
  });

  group('MoodStats.distribution', () {
    test('counts moods', () {
      final entries = [
        entry(now, mood: Mood.calm),
        entry(now, mood: Mood.calm),
        entry(now, mood: Mood.stressed),
      ];
      expect(
        MoodStats.distribution(entries),
        {Mood.calm: 2, Mood.stressed: 1},
      );
    });

    test('topMood returns the most frequent mood', () {
      final entries = [
        entry(now, mood: Mood.tired),
        entry(now, mood: Mood.happy),
        entry(now, mood: Mood.happy),
      ];
      expect(MoodStats.topMood(entries), Mood.happy);
      expect(MoodStats.topMood(const []), isNull);
    });
  });

  group('MoodStats.week', () {
    test('returns seven days oldest first', () {
      final week = MoodStats.week([entry(now, mood: Mood.happy)], now: now);
      expect(week, hasLength(7));
      expect(week.first.date, DateTime(2026, 10, 29));
      expect(week.last.date, DateTime(2026, 11, 4));
      expect(week.last.mood, Mood.happy);
    });

    test('uses the latest entry per day', () {
      final entries = [
        entry(now.subtract(const Duration(hours: 6)), mood: Mood.tired),
        entry(now, mood: Mood.excited, intensity: 5),
      ];
      final week = MoodStats.week(entries, now: now);
      expect(week.last.mood, Mood.excited);
      expect(week.last.intensity, 5);
    });

    test('fills empty days with null moods', () {
      final week = MoodStats.week(const [], now: now);
      expect(week.every((day) => day.mood == null), isTrue);
    });
  });

  test('lastNDays includes the boundary day', () {
    final entries = [
      entry(now),
      entry(now.subtract(const Duration(days: 3))),
      entry(now.subtract(const Duration(days: 4))),
    ];
    expect(MoodStats.lastNDays(entries, 4, now: now), hasLength(2));
  });
}
