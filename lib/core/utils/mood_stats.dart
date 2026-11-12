import '../../data/models/mood_entry.dart';

class DayMood {
  const DayMood({required this.date, this.mood, this.intensity = 0});

  final DateTime date;
  final Mood? mood;
  final int intensity;
}

class MoodStats {
  MoodStats._();

  /// Consecutive days (ending today or yesterday) that contain a check-in.
  static int streak(List<MoodEntry> entries, {DateTime? now}) {
    if (entries.isEmpty) return 0;
    final today = _dateOnly(now ?? DateTime.now());
    final days = entries.map((e) => _dateOnly(e.createdAt)).toSet();
    var cursor = today;
    if (!days.contains(cursor)) {
      cursor = today.subtract(const Duration(days: 1));
      if (!days.contains(cursor)) return 0;
    }
    var count = 0;
    while (days.contains(cursor)) {
      count++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return count;
  }

  static Map<Mood, int> distribution(List<MoodEntry> entries) {
    final map = <Mood, int>{};
    for (final entry in entries) {
      map[entry.mood] = (map[entry.mood] ?? 0) + 1;
    }
    return map;
  }

  static Mood? topMood(List<MoodEntry> entries) {
    final dist = distribution(entries);
    if (dist.isEmpty) return null;
    final sorted = dist.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  /// Last seven calendar days, oldest first.
  static List<DayMood> week(List<MoodEntry> entries, {DateTime? now}) {
    final today = _dateOnly(now ?? DateTime.now());
    final result = <DayMood>[];
    for (var i = 6; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      final dayEntries = entries
          .where((e) => _dateOnly(e.createdAt) == day)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (dayEntries.isEmpty) {
        result.add(DayMood(date: day));
      } else {
        result.add(DayMood(
          date: day,
          mood: dayEntries.first.mood,
          intensity: dayEntries.first.intensity,
        ));
      }
    }
    return result;
  }

  static List<MoodEntry> forDay(List<MoodEntry> entries, DateTime day) {
    final target = _dateOnly(day);
    return entries.where((e) => _dateOnly(e.createdAt) == target).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static List<MoodEntry> lastNDays(List<MoodEntry> entries, int n,
      {DateTime? now}) {
    final today = _dateOnly(now ?? DateTime.now());
    final from = today.subtract(Duration(days: n - 1));
    return entries
        .where((e) => !_dateOnly(e.createdAt).isBefore(from))
        .toList();
  }
}
