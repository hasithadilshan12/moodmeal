import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/dates.dart';
import '../../../data/models/models.dart';
import '../../../state/app_controller.dart';
import '../../widgets/common.dart';
import '../shell/app_shell.dart';

class RemindersPage extends ConsumerStatefulWidget {
  const RemindersPage({super.key});

  @override
  ConsumerState<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends ConsumerState<RemindersPage> {
  static const _dayKeys = [
    'day.short.mon',
    'day.short.tue',
    'day.short.wed',
    'day.short.thu',
    'day.short.fri',
    'day.short.sat',
    'day.short.sun',
  ];

  late bool _enabled;
  late int _hour;
  late int _minute;
  late Set<int> _days;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(appControllerProvider).profile;
    _enabled = profile?.reminderEnabled ?? true;
    _hour = profile?.reminderHour ?? 8;
    _minute = profile?.reminderMinute ?? 0;
    _days = {
      ...(profile?.reminderDays ?? const [1, 2, 3, 4, 5, 6, 7])
    };
  }

  String _formatTime(int hour, int minute) {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = minute.toString().padLeft(2, '0');
    final suffix = hour < 12 ? 'AM' : 'PM';
    return '$h:$m $suffix';
  }

  String? _nextLabel() {
    if (!_enabled || _days.isEmpty) return null;
    final now = DateTime.now();
    for (var i = 0; i < 8; i++) {
      final day = now.add(Duration(days: i));
      if (!_days.contains(day.weekday)) continue;
      final candidate = DateTime(day.year, day.month, day.day, _hour, _minute);
      if (candidate.isAfter(now)) return Dates.time(candidate);
    }
    return null;
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      useRootNavigator: true,
      initialTime: TimeOfDay(hour: _hour, minute: _minute),
      helpText: context.l10n.t('settings.reminderTime'),
    );
    if (picked == null) return;
    HapticFeedback.selectionClick();
    setState(() {
      _hour = picked.hour;
      _minute = picked.minute;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final controller = ref.read(appControllerProvider);
    final current = controller.profile ??
        UserProfile(
          name: controller.session?.name ?? '',
          email: controller.session?.email ?? '',
        );
    final error = await controller.updateProfile(
      current.copyWith(
        reminderEnabled: _enabled,
        reminderHour: _hour,
        reminderMinute: _minute,
        reminderDays: _days.toList()..sort(),
      ),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    HapticFeedback.lightImpact();
    Toast.show(context, error ?? context.l10n.t('reminders.saved'));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final next = _nextLabel();
    final timeLabel = _formatTime(_hour, _minute);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            BackHeader(
              title: t.t('reminders.title'),
              subtitle: t.t('reminders.sub'),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppColors.isDark
                            ? [AppColors.surface, AppColors.surfaceAlt]
                            : _enabled
                                ? const [Color(0xFFFFEBDD), Colors.white]
                                : const [Color(0xFFF4EFEA), Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: AppColors.isDark ? AppColors.line : Colors.white,
                        width: 1.4,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: _enabled
                                ? AppColors.peach
                                : AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _enabled ? '⏰' : '🌙',
                            style: const TextStyle(fontSize: 27),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _enabled ? timeLabel : t.t('reminders.off'),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                next != null
                                    ? t.t('reminders.next', {'time': next})
                                    : t.t('reminders.offSub'),
                                maxLines: 2,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: _enabled,
                          activeThumbColor: AppColors.orange,
                          activeTrackColor: AppColors.peach,
                          onChanged: (value) {
                            HapticFeedback.selectionClick();
                            setState(() => _enabled = value);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (_enabled) ...[
                    AppCard(
                      onTap: _pickTime,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.peachSoft,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.schedule_rounded,
                                size: 20, color: AppColors.orangeDeep),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              t.t('settings.reminderTime'),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          Text(
                            timeLabel,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: AppColors.orangeDeep),
                          ),
                          Icon(Icons.chevron_right_rounded,
                              size: 20, color: AppColors.muted),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            t.t('reminders.days'),
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(
                            () => _days = {1, 2, 3, 4, 5, 6, 7},
                          ),
                          child: Text(t.t('reminders.daily')),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      t.t('reminders.daysSub'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        for (var day = 1; day <= 7; day++) ...[
                          if (day > 1) const SizedBox(width: 6),
                          Expanded(
                            child: _DayPill(
                              label: t.t(_dayKeys[day - 1]),
                              selected: _days.contains(day),
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  if (!_days.remove(day)) _days.add(day);
                                });
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('🔔', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              t.t('reminders.permission'),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.inkSoft,
                                    height: 1.55,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else
                    EmptyState(
                      emoji: '🌙',
                      title: t.t('reminders.off'),
                      body: t.t('reminders.offSub'),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: GradientButton(
                label: t.t('common.save'),
                icon: Icons.check_rounded,
                busy: _saving,
                onPressed: _saving ? null : _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayPill extends StatelessWidget {
  const _DayPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 46,
        decoration: BoxDecoration(
          color: selected ? AppColors.orange : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.orange : AppColors.line,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: selected ? Colors.white : AppColors.inkSoft,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
        ),
      ),
    );
  }
}
