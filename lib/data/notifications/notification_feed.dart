import 'package:flutter/material.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';

/// One row in the notification inbox.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.emoji,
    required this.tint,
    required this.title,
    required this.body,
    required this.today,
    this.route,
  });

  final String id;
  final String emoji;
  final Color tint;
  final String title;
  final String body;
  final bool today;
  final String? route;
}

/// Builds the inbox from live app state. Home uses the same builder so the
/// bell badge and the "N unread" header always agree.
List<AppNotification> buildNotificationFeed({
  required AppLocalizations t,
  required bool reminderEnabled,
  required String reminderLabel,
  required int streak,
  required int checkInCount,
}) {
  return [
    if (reminderEnabled)
      AppNotification(
        id: 'reminder',
        emoji: '⏰',
        tint: AppColors.peachSoft,
        title: t.t('notif.reminderTitle'),
        body: '${t.t('notif.reminderBody')} · $reminderLabel',
        route: '/mood/checkin',
        today: true,
      ),
    if (streak >= 2)
      AppNotification(
        id: 'streak',
        emoji: '🔥',
        tint: const Color(0xFFFDE9EE),
        title: t.t('notif.streakTitle'),
        body: t.t('notif.streakBody', {'n': '$streak'}),
        route: '/history',
        today: true,
      ),
    AppNotification(
      id: 'tip',
      emoji: '🧘',
      tint: AppColors.violetSoft,
      title: t.t('notif.tipTitle'),
      body: t.t('notif.tipBody'),
      route: '/tips/breaths',
      today: true,
    ),
    if (checkInCount > 0)
      AppNotification(
        id: 'first',
        emoji: '📔',
        tint: const Color(0xFFE4F5EC),
        title: t.t('notifications.loggedTitle'),
        body: t.t('notifications.loggedBody'),
        route: '/history',
        today: false,
      ),
    AppNotification(
      id: 'welcome',
      emoji: '👋',
      tint: const Color(0xFFFFF3D6),
      title: t.t('notifications.welcomeTitle'),
      body: t.t('notifications.welcomeBody'),
      today: false,
    ),
  ];
}
