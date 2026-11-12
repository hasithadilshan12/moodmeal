import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/mood_stats.dart';
import '../../../data/models/models.dart';
import '../../../data/models/mood_entry.dart';
import '../../../data/seed/catalog.dart';
import '../../../state/app_controller.dart';
import '../../widgets/common.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final controller = ref.watch(appControllerProvider);
    final entries = controller.moods;
    final week = controller.week;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.t('history.title'),
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 4),
                      Text(
                        t.t('insights.sub'),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                CircleIconButton(
                  icon: Icons.insights_rounded,
                  background: AppColors.peachSoft,
                  color: AppColors.orangeDeep,
                  onTap: () => context.push('/insights'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    value: '${controller.streak}',
                    label: t.t('history.streak'),
                    emoji: '🔥',
                    tint: const Color(0xFFFFF0E0),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatTile(
                    value: '${entries.length}',
                    label: t.t('history.checkins'),
                    emoji: '📔',
                    tint: const Color(0xFFEDE9FF),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatTile(
                    value: controller.topMood == null
                        ? '—'
                        : t.t(controller.topMood!.labelKey),
                    label: t.t('history.avgMood'),
                    emoji: controller.topMood?.emoji ?? '',
                    tint: const Color(0xFFE4F5EC),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            AppCard(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.t('history.week'),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 168,
                    child: _WeekChart(week: week),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: Text(
                    t.t('history.mealsTitle'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  t.t('history.mealsThisWeek'),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              t.t('history.mealsSub'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            if (controller.mealLogs.isEmpty)
              AppCard(
                shadow: false,
                border: Border.all(color: AppColors.line),
                child: Row(
                  children: [
                    const Text('🍳', style: TextStyle(fontSize: 26)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.t('history.mealsEmpty'),
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            t.t('history.mealsEmptySub'),
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              for (final log in controller.mealLogs.take(10))
                _MealLogRow(log: log),
            const SizedBox(height: 26),
            Text(
              t.t('history.timeline'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (entries.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: EmptyState(
                  emoji: '🌱',
                  title: t.t('history.empty'),
                  body: t.t('history.emptySub'),
                  actionLabel: t.t('mood.cta'),
                  onAction: () => context.push('/mood/checkin'),
                ),
              )
            else
              ..._buildTimeline(context, entries),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTimeline(BuildContext context, List<MoodEntry> entries) {
    final t = context.l10n;
    final widgets = <Widget>[];
    String? currentDay;
    for (final entry in entries) {
      final label = Dates.dayLabel(
        entry.createdAt,
        today: t.t('common.today'),
        yesterday: t.t('common.yesterday'),
      );
      if (label != currentDay) {
        currentDay = label;
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8, left: 4),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
            ),
          ),
        );
      }
      widgets.add(_TimelineEntry(entry: entry));
      widgets.add(const SizedBox(height: 8));
    }
    return widgets;
  }
}

class _WeekChart extends StatelessWidget {
  const _WeekChart({required this.week});

  final List<DayMood> week;

  static const _dayKeys = [
    'day.short.mon',
    'day.short.tue',
    'day.short.wed',
    'day.short.thu',
    'day.short.fri',
    'day.short.sat',
    'day.short.sun',
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return BarChart(
      BarChartData(
        maxY: 5,
        minY: 0,
        alignment: BarChartAlignment.spaceAround,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= week.length) {
                  return const SizedBox.shrink();
                }
                final key = _dayKeys[week[index].date.weekday - 1];
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    t.t(key),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.muted,
                          fontSize: 10,
                        ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < week.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: week[i].mood == null
                      ? 0.35
                      : week[i].intensity.toDouble(),
                  width: 20,
                  borderRadius: BorderRadius.circular(8),
                  color: week[i].mood == null
                      ? AppColors.line
                      : AppColors.moods[week[i].mood!.name]!.last
                          .withValues(alpha: 0.9),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 5,
                    color: AppColors.surfaceAlt,
                  ),
                ),
              ],
            ),
        ],
      ),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    required this.emoji,
    required this.tint,
  });

  final String value;
  final String label;
  final String emoji;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.pastel(tint),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          if (emoji.isNotEmpty) ...[
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 6),
          ],
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 9.5,
                ),
          ),
        ],
      ),
    );
  }
}

class _MealLogRow extends StatelessWidget {
  const _MealLogRow({required this.log});

  final MealLog log;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final meal = Catalog.mealById(log.mealId);
    final day = Dates.dayLabel(
      log.createdAt,
      today: t.t('common.today'),
      yesterday: t.t('common.yesterday'),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        padding: const EdgeInsets.all(10),
        shadow: false,
        border: Border.all(color: AppColors.line),
        onTap: () => context.push('/meal/${meal.id}'),
        child: Row(
          children: [
            MealImage(meal: meal, size: 46, radius: 12),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.localizedName(t.isSinhala),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$day · ${Dates.time(log.createdAt)}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({required this.entry});

  final MoodEntry entry;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return AppCard(
      padding: const EdgeInsets.all(14),
      shadow: false,
      border: Border.all(color: AppColors.line),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: MoodStats.distribution([entry]).isEmpty
                      ? AppColors.peachSoft
                      : AppColors.moods[entry.mood.name]!.first
                          .withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(entry.mood.emoji,
                    style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.t(entry.mood.labelKey),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      '${Dates.time(entry.createdAt)} · ${entry.intensity}/5',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (entry.note.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              entry.note,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.inkSoft,
                  ),
            ),
          ],
          if (entry.tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final tag in entry.tags)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '#${t.t('tag.$tag')}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontSize: 9.5,
                            color: AppColors.inkSoft,
                          ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
