import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/notifications/notification_feed.dart';
import '../../../state/app_controller.dart';
import '../../widgets/common.dart';
import '../shell/app_shell.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  Future<void> _markAll(List<AppNotification> items) async {
    HapticFeedback.lightImpact();
    await ref.read(readNotifsProvider).markAll(items.map((item) => item.id));
    if (!mounted) return;
    Toast.show(context, context.l10n.t('notifications.allRead'));
  }

  Future<void> _open(AppNotification item) async {
    await ref.read(readNotifsProvider).mark(item.id);
    if (!mounted) return;
    if (item.route != null) context.push(item.route!);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final controller = ref.watch(appControllerProvider);
    final readNotifs = ref.watch(readNotifsProvider);
    final profile = controller.profile;
    final reminderOn = profile?.reminderEnabled ?? true;

    final all = buildNotificationFeed(
      t: t,
      reminderEnabled: reminderOn,
      reminderLabel: profile?.reminderLabel ?? '8:00 AM',
      streak: controller.streak,
      checkInCount: controller.checkInCount,
    );
    final today = all.where((item) => item.today).toList();
    final earlier = all.where((item) => !item.today).toList();
    final unread = all.where((item) => !readNotifs.contains(item.id)).length;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            BackHeader(
              title: t.t('notifications.title'),
              subtitle: unread > 0
                  ? t.t('notifications.unread', {'n': '$unread'})
                  : t.t('notifications.empty'),
            ),
            Expanded(
              child: all.isEmpty
                  ? EmptyState(
                      emoji: '🌤️',
                      title: t.t('notifications.empty'),
                      body: t.t('notifications.emptySub'),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                      children: [
                        if (unread > 0)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () => _markAll(all),
                              icon:
                                  const Icon(Icons.done_all_rounded, size: 16),
                              label: Text(t.t('notifications.markAll')),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                textStyle:
                                    Theme.of(context).textTheme.labelSmall,
                              ),
                            ),
                          ),
                        _SectionLabel(
                          label: t.t('notifications.today'),
                          count: today.length,
                        ),
                        for (final item in today)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _NotificationCard(
                              item: item,
                              unread: !readNotifs.contains(item.id),
                              onTap: () => _open(item),
                            ),
                          ),
                        const SizedBox(height: 14),
                        _SectionLabel(
                          label: t.t('notifications.earlier'),
                          count: earlier.length,
                        ),
                        for (final item in earlier)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _NotificationCard(
                              item: item,
                              unread: !readNotifs.contains(item.id),
                              onTap: () => _open(item),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 0.9,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.muted,
                  fontSize: 9.5,
                ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.item,
    required this.unread,
    required this.onTap,
  });

  final AppNotification item;
  final bool unread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      color: unread ? AppColors.surface : AppColors.surfaceAlt,
      border: unread ? Border.all(color: AppColors.peach, width: 1.2) : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.pastel(item.tint),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(item.emoji, style: const TextStyle(fontSize: 21)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: unread ? FontWeight.w600 : FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.body,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.inkSoft,
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              if (unread)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
              const SizedBox(height: 4),
              Icon(Icons.chevron_right_rounded,
                  size: 18, color: AppColors.muted),
            ],
          ),
        ],
      ),
    );
  }
}
