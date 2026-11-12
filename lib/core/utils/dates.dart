class Dates {
  Dates._();

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String time(DateTime value) {
    final h = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final m = value.minute.toString().padLeft(2, '0');
    final suffix = value.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $suffix';
  }

  static String dayLabel(DateTime value,
      {required String today, required String yesterday}) {
    final now = DateTime.now();
    final date = DateTime(value.year, value.month, value.day);
    final todayDate = DateTime(now.year, now.month, now.day);
    final diff = todayDate.difference(date).inDays;
    if (diff == 0) return today;
    if (diff == 1) return yesterday;
    return '${value.day} ${_months[value.month - 1]}';
  }

  static String longDay(DateTime value) =>
      '${value.day} ${_months[value.month - 1]} ${value.year}';

  static String monthShort(int month) => _months[(month - 1).clamp(0, 11)];

  static String relative(DateTime value,
      {required String today, required String yesterday, required String now}) {
    final diff = DateTime.now().difference(value);
    if (diff.inMinutes < 1) return now;
    if (diff.inMinutes < 60) return '${diff.inMinutes} min';
    if (diff.inHours < 24 && DateTime.now().day == value.day) {
      return time(value);
    }
    return dayLabel(value, today: today, yesterday: yesterday);
  }
}
