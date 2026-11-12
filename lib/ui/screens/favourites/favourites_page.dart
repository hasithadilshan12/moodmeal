import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/models.dart';
import '../../../data/seed/catalog.dart';
import '../../../state/app_controller.dart';
import '../../widgets/common.dart';
import '../shell/app_shell.dart';

class FavouritesPage extends ConsumerWidget {
  const FavouritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final controller = ref.watch(appControllerProvider);
    final meals = Catalog.meals
        .where((meal) => controller.favourites.contains(meal.id))
        .toList();
    final suggestions = Catalog.meals
        .where((meal) => !controller.favourites.contains(meal.id))
        .take(3)
        .toList();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            BackHeader(
              title: t.t('fav.title'),
              subtitle: t.t('fav.sub'),
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.roseSoft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  '💛 ${meals.length}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.rose,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
            Expanded(
              child: meals.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: EmptyState(
                        emoji: '🍽️',
                        title: t.t('fav.empty'),
                        body: t.t('fav.emptySub'),
                        actionLabel: t.t('fav.explore'),
                        onAction: () => context.push('/explore'),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                      children: [
                        Text(
                          t.t('fav.count', {'n': '${meals.length}'}),
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: AppColors.muted),
                        ),
                        const SizedBox(height: 10),
                        for (final meal in meals)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _FavouriteCard(meal: meal, removable: true),
                          ),
                        const SizedBox(height: 14),
                        Text(
                          t.t('fav.suggested'),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        for (final meal in suggestions)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _FavouriteCard(meal: meal, removable: false),
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

class _FavouriteCard extends ConsumerWidget {
  const _FavouriteCard({required this.meal, required this.removable});

  final Meal meal;
  final bool removable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;

    Future<void> toggle() async {
      final wasFavourite = ref.read(appControllerProvider).isFavourite(meal.id);
      final error =
          await ref.read(appControllerProvider).toggleFavourite(meal.id);
      if (!context.mounted) return;
      Toast.show(
        context,
        error ?? t.t(wasFavourite ? 'meal.removed' : 'meal.saved'),
      );
    }

    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: () => context.push('/meal/${meal.id}'),
      child: Row(
        children: [
          MealImage(
            meal: meal,
            size: 68,
            radius: 18,
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
                const SizedBox(height: 7),
                Row(
                  children: [
                    Icon(Icons.schedule_rounded,
                        size: 12, color: AppColors.muted),
                    const SizedBox(width: 4),
                    Text(
                      t.t('common.minValue', {'n': '${meal.minutes}'}),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.local_fire_department_rounded,
                        size: 12, color: AppColors.orange),
                    const SizedBox(width: 4),
                    Text(
                      t.t('common.kcalValue', {'n': '${meal.calories}'}),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            onPressed: toggle,
            tooltip: t.t(removable ? 'meal.removeFavourite' : 'meal.favourite'),
            icon: Icon(
              removable
                  ? Icons.favorite_rounded
                  : Icons.add_circle_outline_rounded,
              color: removable ? AppColors.rose : AppColors.orange,
            ),
          ),
        ],
      ),
    );
  }
}
