import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/models.dart';
import '../../../data/models/mood_entry.dart';
import '../../../data/seed/catalog.dart';
import '../../../state/app_controller.dart';
import '../../widgets/common.dart';
import '../shell/app_shell.dart';

class MoodResultPage extends ConsumerStatefulWidget {
  const MoodResultPage({super.key, this.mood});

  final Mood? mood;

  @override
  ConsumerState<MoodResultPage> createState() => _MoodResultPageState();
}

class _MoodResultPageState extends ConsumerState<MoodResultPage> {
  final Set<String> _filters = {};

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final controller = ref.watch(appControllerProvider);
    final mood = widget.mood ?? controller.todayEntry?.mood ?? Mood.calm;
    final profile = controller.profile;
    final meals = Catalog.mealsForMood(
      mood,
      filters: _filters,
      allergies: profile?.allergies ?? const [],
      avoid: profile?.avoid ?? const [],
    );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            BackHeader(
              title: t.t('mood.resultTitle',
                  {'mood': t.t(mood.labelKey).toLowerCase()}),
              trailing: CircleIconButton(
                icon: Icons.tune_rounded,
                background: AppColors.peachSoft,
                color: AppColors.orangeDeep,
                onTap: () => context.push('/preferences'),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                children: [
                  _MoodBanner(mood: mood, subtitle: t.t('mood.resultSub')),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _FilterChip(
                          label: t.t('rec.all'),
                          selected: _filters.isEmpty,
                          onTap: () => setState(() => _filters.clear()),
                        ),
                        _FilterChip(
                          label: t.t('rec.veg'),
                          selected: _filters.contains('veg'),
                          onTap: () => setState(() {
                            _filters.contains('veg')
                                ? _filters.remove('veg')
                                : _filters.add('veg');
                          }),
                        ),
                        _FilterChip(
                          label: t.t('rec.quick'),
                          selected: _filters.contains('quick'),
                          onTap: () => setState(() {
                            _filters.contains('quick')
                                ? _filters.remove('quick')
                                : _filters.add('quick');
                          }),
                        ),
                        _FilterChip(
                          label: t.t('rec.protein'),
                          selected: _filters.contains('protein'),
                          onTap: () => setState(() {
                            _filters.contains('protein')
                                ? _filters.remove('protein')
                                : _filters.add('protein');
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (meals.isEmpty)
                    EmptyState(
                      emoji: '🍽️',
                      title: t.t('rec.empty'),
                      body: t.t('rec.emptySub'),
                    )
                  else
                    for (final meal in meals)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _MealCard(
                          meal: meal,
                          score: meal.matchScore(mood),
                          favourite: controller.isFavourite(meal.id),
                          onFavourite: () async {
                            final error = await ref
                                .read(appControllerProvider)
                                .toggleFavourite(meal.id);
                            if (!context.mounted) return;
                            Toast.show(
                              context,
                              error ??
                                  t.t(controller.isFavourite(meal.id)
                                      ? 'meal.removed'
                                      : 'meal.saved'),
                            );
                          },
                          onTap: () => context.push('/meal/${meal.id}'),
                        ),
                      ),
                  const SizedBox(height: 6),
                  NearbyPromptCard(
                    title: t.t('rec.nearbyTitle'),
                    body: t.t('rest.sub'),
                    actionLabel: t.t('common.seeAll'),
                    onTap: () => context.push('/restaurants'),
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

class _MoodBanner extends StatelessWidget {
  const _MoodBanner({required this.mood, required this.subtitle});

  final Mood mood;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = mood.gradient;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.first.withValues(alpha: 0.35),
            colors.last.withValues(alpha: 0.10),
            AppColors.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(mood.emoji, style: const TextStyle(fontSize: 30)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.inkSoft,
                        height: 1.5,
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.orange : AppColors.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: selected ? AppColors.orange : AppColors.line,
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: selected ? Colors.white : AppColors.inkSoft,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
          ),
        ),
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({
    required this.meal,
    required this.score,
    required this.favourite,
    required this.onFavourite,
    required this.onTap,
  });

  final Meal meal;
  final int score;
  final bool favourite;
  final VoidCallback onFavourite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final isSi = t.isSinhala;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MealImage(
                meal: meal,
                size: 72,
                radius: 20,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            meal.localizedName(isSi),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        GestureDetector(
                          onTap: onFavourite,
                          child: Icon(
                            favourite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 20,
                            color: favourite ? AppColors.rose : AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      meal.localizedDescription(isSi),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.greenSoft,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            t.t('mood.match', {'n': '$score'}),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: AppColors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.schedule_rounded,
                            size: 12, color: AppColors.muted),
                        const SizedBox(width: 3),
                        Text(
                          t.t('common.minValue', {'n': '${meal.minutes}'}),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.local_fire_department_rounded,
                            size: 12, color: AppColors.orange),
                        const SizedBox(width: 3),
                        Text(
                          t.t('common.kcalValue', {'n': '${meal.calories}'}),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              meal.localizedWhy(isSi),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.inkSoft,
                    height: 1.45,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
