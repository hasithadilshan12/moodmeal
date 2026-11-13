import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/mood_entry.dart';
import '../../../data/seed/catalog.dart';
import '../../../state/app_controller.dart';
import '../../widgets/common.dart';

class InsightsPage extends ConsumerWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final controller = ref.watch(appControllerProvider);
    final entries = controller.moods;
    final top = controller.topMood;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            BackHeader(
                title: t.t('insights.title'), subtitle: t.t('insights.sub')),
            Expanded(
              child: entries.isEmpty || top == null
                  ? EmptyState(
                      emoji: '📊',
                      title: t.t('history.empty'),
                      body: t.t('insights.noData'),
                      actionLabel: t.t('mood.cta'),
                      onAction: () => context.push('/mood/checkin'),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                      children: [
                        _ConnectionCard(entries: entries, top: top),
                        const SizedBox(height: 18),
                        _DistributionCard(entries: entries, top: top),
                        const SizedBox(height: 18),
                        _CheckInTimes(entries: entries),
                        const SizedBox(height: 22),
                        _MoodMeals(
                          top: top,
                          allergies: controller.profile?.allergies ?? const [],
                          avoid: controller.profile?.avoid ?? const [],
                        ),
                        const SizedBox(height: 18),
                        _ReflectionCard(
                          onTap: () => context.push('/mood/checkin'),
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

class _ConnectionCard extends StatelessWidget {
  const _ConnectionCard({required this.entries, required this.top});

  final List<MoodEntry> entries;
  final Mood top;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final colors = top.gradient;
    final total = entries.length;
    final light = entries
        .where(
            (e) => const [Mood.calm, Mood.happy, Mood.excited].contains(e.mood))
        .length;
    final lightPct = total == 0 ? 0 : (light / total * 100).round();
    final heavyPct = total == 0 ? 0 : 100 - lightPct;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.first.withValues(alpha: 0.34),
            colors.last.withValues(alpha: 0.16),
            AppColors.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.surface, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: colors.last.withValues(alpha: 0.16),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.75),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(top.emoji, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.t('insights.correlation').toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            letterSpacing: 1,
                            color: AppColors.inkSoft,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      t.t(top.labelKey),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  t.t('insights.entries', {'n': '$total'}),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.orangeDeep,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            t.t('insights.correlationBody'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.inkSoft,
                  height: 1.65,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SplitStat(
                  label: t.t('insights.lightDays'),
                  value: '$lightPct%',
                  color: AppColors.green,
                  emoji: '🌿',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SplitStat(
                  label: t.t('insights.heavyDays'),
                  value: '$heavyPct%',
                  color: AppColors.rose,
                  emoji: '🫂',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SplitStat extends StatelessWidget {
  const _SplitStat({
    required this.label,
    required this.value,
    required this.color,
    required this.emoji,
  });

  final String label;
  final String value;
  final Color color;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DistributionCard extends StatelessWidget {
  const _DistributionCard({required this.entries, required this.top});

  final List<MoodEntry> entries;
  final Mood top;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final counts = <Mood, int>{};
    for (final e in entries) {
      counts[e.mood] = (counts[e.mood] ?? 0) + 1;
    }
    final ordered = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.length;

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  t.t('insights.donut'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                t.t('insights.entries', {'n': '$total'}),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 138,
                height: 138,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 42,
                        startDegreeOffset: -90,
                        borderData: FlBorderData(show: false),
                        sections: [
                          for (final item in ordered)
                            PieChartSectionData(
                              value: item.value.toDouble(),
                              color: AppColors.moods[item.key.name]!.last,
                              radius: 21,
                              showTitle: false,
                            ),
                        ],
                      ),
                      duration: const Duration(milliseconds: 650),
                      curve: Curves.easeOutCubic,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(top.emoji, style: const TextStyle(fontSize: 22)),
                        const SizedBox(height: 2),
                        Text(
                          '${total == 0 ? 0 : (ordered.first.value / total * 100).round()}%',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.inkSoft,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    for (final item in ordered.take(4))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _LegendRow(
                          mood: item.key,
                          count: item.value,
                          total: total,
                        ),
                      ),
                    if (ordered.length > 4)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '+${ordered.length - 4}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.mood,
    required this.count,
    required this.total,
  });

  final Mood mood;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0 : (count / total * 100).round();
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: AppColors.moods[mood.name]!.last,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            context.t(mood.labelKey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
        Text(
          '$pct%',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
        ),
      ],
    );
  }
}

class _CheckInTimes extends StatelessWidget {
  const _CheckInTimes({required this.entries});

  final List<MoodEntry> entries;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final buckets = [
      _bucket(t.t('insights.morning'), '🌅', 5, 11),
      _bucket(t.t('insights.afternoon'), '☀️', 12, 16),
      _bucket(t.t('insights.evening'), '🌇', 17, 20),
      _bucket(t.t('insights.night'), '🌙', 21, 4),
    ];
    final maxCount = buckets.fold<int>(
      1,
      (value, b) => b.count > value ? b.count : value,
    );

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.t('insights.whenYouCheckIn'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          for (final bucket in buckets)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Text(bucket.emoji, style: const TextStyle(fontSize: 15)),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 66,
                    child: Text(
                      bucket.label,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 10,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.surfaceAlt,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: bucket.count / maxCount,
                            heightFactor: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: AppColors.orangeGradient,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 18,
                    child: Text(
                      '${bucket.count}',
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  _TimeBucket _bucket(String label, String emoji, int from, int to) {
    final count = entries.where((e) {
      final h = e.createdAt.hour;
      if (from <= to) return h >= from && h <= to;
      return h >= from || h <= to;
    }).length;
    return _TimeBucket(label: label, emoji: emoji, count: count);
  }
}

class _TimeBucket {
  const _TimeBucket({
    required this.label,
    required this.emoji,
    required this.count,
  });

  final String label;
  final String emoji;
  final int count;
}

class _MoodMeals extends StatelessWidget {
  const _MoodMeals({
    required this.top,
    this.allergies = const [],
    this.avoid = const [],
  });

  final Mood top;
  final List<String> allergies;
  final List<String> avoid;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final meals = Catalog.mealsForMood(
      top,
      allergies: allergies,
      avoid: avoid,
    ).take(2).toList();

    // Honest empty state: the profile filters may leave nothing to suggest.
    if (meals.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.t('insights.matchesMood'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        for (final meal in meals)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              padding: const EdgeInsets.all(12),
              onTap: () => context.push('/meal/${meal.id}'),
              child: Row(
                children: [
                  MealImage(
                    meal: meal,
                    size: 60,
                    radius: 16,
                  ),
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
                        const SizedBox(height: 4),
                        Text(
                          meal.localizedDescription(t.isSinhala),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.peachSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      t.t('mood.match', {'n': '${meal.matchScore(top)}'}),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontSize: 9.5,
                            color: AppColors.orangeDeep,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ReflectionCard extends StatelessWidget {
  const _ReflectionCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2F2118), Color(0xFF5A4032)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🕯️', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                t.t('insights.reflection'),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            t.t('insights.reflectionBody'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.82),
                  height: 1.65,
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 190,
            child: GradientButton(
              label: t.t('insights.logToday'),
              height: 44,
              icon: Icons.add_reaction_outlined,
              gradient: const LinearGradient(
                colors: [Color(0xFFFFA24C), AppColors.orange],
              ),
              onPressed: onTap,
            ),
          ),
        ],
      ),
    );
  }
}
