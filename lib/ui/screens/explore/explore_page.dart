import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/models.dart';
import '../../../data/models/mood_entry.dart';
import '../../../data/seed/catalog.dart';
import '../../widgets/common.dart';

/// A plain search over the local catalogue: dish names, descriptions,
/// ingredients, cuisines and moods, in whichever language the app is showing.
class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _setQuery(String value) {
    setState(() => _query = value);
  }

  void _clear() {
    _searchController.clear();
    _setQuery('');
  }

  void _pickMood(Mood mood, AppLocalizations t) {
    HapticFeedback.selectionClick();
    final label = t.t(mood.labelKey);
    _searchController.text = label;
    _searchController.selection = TextSelection.collapsed(offset: label.length);
    _setQuery(label);
  }

  List<Meal> _results(AppLocalizations t) {
    final raw = _query.trim();
    if (raw.isEmpty) return Catalog.meals;
    final query = raw.toLowerCase();

    bool hit(String? value) =>
        value != null && value.toLowerCase().contains(query);

    return Catalog.meals.where((meal) {
      if (hit(meal.name) || hit(meal.nameSi)) return true;
      if (hit(meal.description) || hit(meal.descriptionSi)) return true;
      if (hit(t.t(meal.cuisine))) return true;
      if (meal.ingredients.any((item) => item.toLowerCase().contains(query))) {
        return true;
      }
      if (meal.ingredientsSi.any((item) => item.contains(raw))) return true;
      return meal.moods.any((mood) => hit(t.t(mood.labelKey)));
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final results = _results(t);
    final searching = _query.trim().isNotEmpty;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            BackHeader(
                title: t.t('explore.title'), subtitle: t.t('explore.sub')),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 10),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onChanged: _setQuery,
                decoration: InputDecoration(
                  hintText: t.t('explore.hint'),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: searching
                      ? IconButton(
                          tooltip: t.t('explore.clear'),
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: _clear,
                        )
                      : null,
                ),
              ),
            ),
            Expanded(
              child: results.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.only(top: 30),
                      children: [
                        EmptyState(
                          emoji: '🔍',
                          title: t.t('explore.empty'),
                          body: t.t('explore.emptySub'),
                          actionLabel: t.t('explore.clear'),
                          onAction: _clear,
                        ),
                      ],
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                      children: [
                        if (!searching) ...[
                          Text(
                            t.t('explore.moodPrompt'),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: AppColors.muted),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final mood in Mood.values)
                                ActionChip(
                                  label: Text(
                                    '${mood.emoji} ${t.t(mood.labelKey)}',
                                    style:
                                        Theme.of(context).textTheme.labelSmall,
                                  ),
                                  backgroundColor: AppColors.surface,
                                  side: BorderSide(color: AppColors.line),
                                  onPressed: () => _pickMood(mood, t),
                                ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Text(
                            t.t('explore.all'),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 10),
                        ] else ...[
                          Text(
                            t.t(
                              results.length == 1
                                  ? 'explore.resultOne'
                                  : 'explore.results',
                              {'n': '${results.length}'},
                            ),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: AppColors.muted),
                          ),
                          const SizedBox(height: 10),
                        ],
                        for (final meal in results)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _MealRow(meal: meal),
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

class _MealRow extends StatelessWidget {
  const _MealRow({required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;

    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: () => context.push('/meal/${meal.id}'),
      child: Row(
        children: [
          MealImage(meal: meal, size: 64, radius: 18),
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
          Icon(Icons.chevron_right_rounded, color: AppColors.muted),
        ],
      ),
    );
  }
}
