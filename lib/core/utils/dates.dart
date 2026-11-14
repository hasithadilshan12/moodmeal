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
    final local = value.toLocal();
    final h = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final m = local.minute.toString().padLeft(2, '0');
    final suffix = local.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $suffix';
  }

  static String dayLabel(DateTime value,
      {required String today, required String yesterday}) {
    final now = DateTime.now().toLocal();
    final local = value.toLocal();
    final date = DateTime(local.year, local.month, local.day);
    final todayDate = DateTime(now.year, now.month, now.day);
    final diff = todayDate.difference(date).inDays;
    if (diff == 0) return today;
    if (diff == 1) return yesterday;
    return '${local.day} ${_months[local.month - 1]}';
  }

  static String longDay(DateTime value) {
    final local = value.toLocal();
    return '${local.day} ${_months[local.month - 1]} ${local.year}';
  }

  static String monthShort(int month) => _months[(month - 1).clamp(0, 11)];

  static String relative(DateTime value,
      {required String today, required String yesterday, required String now}) {
    final local = value.toLocal();
    final current = DateTime.now().toLocal();
    final diff = current.difference(local);
    if (diff.inMinutes < 1) return now;
    if (diff.inMinutes < 60) return '${diff.inMinutes} min';
    if (diff.inHours < 24 && current.day == local.day) {
      return time(local);
    }
    return dayLabel(local, today: today, yesterday: yesterday);
  }
}
