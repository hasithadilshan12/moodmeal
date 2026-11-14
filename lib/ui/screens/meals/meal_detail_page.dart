import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/models.dart';
import '../../../data/seed/catalog.dart';
import '../../../data/seed/media.dart';
import '../../../data/seed/recipes.dart';
import '../../../state/app_controller.dart';
import '../../../state/nearby_controller.dart';
import '../../widgets/common.dart';
import '../shell/app_shell.dart';

class MealDetailPage extends ConsumerStatefulWidget {
  const MealDetailPage({super.key, required this.mealId});

  final String mealId;

  @override
  ConsumerState<MealDetailPage> createState() => _MealDetailPageState();
}

class _MealDetailPageState extends ConsumerState<MealDetailPage> {
  final Set<int> _checked = {};

  Meal get meal => Catalog.mealById(widget.mealId);
  Recipe get recipe => RecipeBook.of(widget.mealId);
  MealMedia get media => MediaBook.of(widget.mealId);

  Future<void> _openUrl(String url) async {
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!mounted || ok) return;
    Toast.show(context, context.l10n.t('common.cannotOpen'));
  }

  void _findNearby() {
    HapticFeedback.selectionClick();
    context.push('/restaurants?meal=${meal.id}');
  }

  String get _dishSearchUrl {
    final nearby = ref.read(nearbyProvider);
    final term = Uri.encodeComponent(media.searchTerm);
    if (nearby.lat != null && nearby.lng != null) {
      return 'https://www.google.com/maps/search/$term/@${nearby.lat},${nearby.lng},15z';
    }
    return 'https://www.google.com/maps/search/?api=1&query=$term';
  }

  Future<void> _logMeal() async {
    HapticFeedback.mediumImpact();
    final error = await ref.read(appControllerProvider).logMeal(meal.id);
    if (!mounted) return;
    Toast.show(context, error ?? context.l10n.t('meal.logged'));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final isSi = t.isSinhala;
    final controller = ref.watch(appControllerProvider);
    final favourite = controller.isFavourite(meal.id);
    final loggedToday = controller.loggedToday(meal.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 330,
            pinned: true,
            backgroundColor: meal.colors.first,
            surfaceTintColor: Colors.transparent,
            leadingWidth: 64,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Center(
                child: CircleIconButton(
                  icon: Icons.arrow_back_rounded,
                  // The translucent circle stays light in both themes, so the
                  // glyph must stay dark rather than following AppColors.ink.
                  color: const Color(0xFF2F2118),
                  onTap: () => Navigator.of(context).maybePop(),
                  background: Colors.white.withValues(alpha: 0.92),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: CircleIconButton(
                    icon: favourite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: favourite ? AppColors.rose : const Color(0xFF2F2118),
                    background: Colors.white.withValues(alpha: 0.92),
                    onTap: () async {
                      HapticFeedback.selectionClick();
                      final error = await ref
                          .read(appControllerProvider)
                          .toggleFavourite(meal.id);
                      if (!context.mounted) return;
                      Toast.show(
                        context,
                        error ?? t.t(favourite ? 'meal.removed' : 'meal.saved'),
                      );
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    media.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => DecoratedBox(
                      decoration: BoxDecoration(gradient: meal.gradient),
                      child: Center(
                        child: Text(meal.emoji,
                            style: const TextStyle(fontSize: 120)),
                      ),
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x33000000),
                          Color(0x00000000),
                          Color(0x66000000),
                        ],
                        stops: [0, 0.55, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    // Sinhala titles have taller ascenders and descenders, so
                    // they sit a little higher to keep clear of the sheet.
                    bottom: isSi ? 60 : 52,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            meal.localizedName(isSi),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              // Sinhala glyphs need more room above and below.
                              height: isSi ? 1.4 : 1.25,
                              shadows: const [
                                Shadow(blurRadius: 12, color: Colors.black38),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (meal.isVegetarian)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '🌱 ${t.t('rec.veg')}',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: AppColors.green),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              transform: Matrix4.translationValues(0, -24, 0),
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.localizedDescription(isSi),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.inkSoft,
                          height: isSi ? 1.8 : 1.6,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Meta(
                        icon: Icons.schedule_rounded,
                        value: t.t('common.minValue', {'n': '${meal.minutes}'}),
                      ),
                      _Meta(
                        icon: Icons.people_alt_outlined,
                        value: t.t('meal.serves', {'n': '${recipe.servings}'}),
                      ),
                      _Meta(
                        icon: Icons.local_fire_department_rounded,
                        value:
                            t.t('common.kcalValue', {'n': '${meal.calories}'}),
                      ),
                      _Meta(
                        icon: Icons.restaurant_rounded,
                        value: t.t(meal.cuisine),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _WatchCard(
                    video: media.video,
                    onTap: () => _openUrl(media.video.watchUrl),
                  ),
                  const SizedBox(height: 22),
                  _MindfulMoment(text: meal.localizedPrompt(isSi)),
                  const SizedBox(height: 22),
                  Text(
                    t.t('meal.why'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    meal.localizedWhy(isSi),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.inkSoft,
                          height: 1.65,
                        ),
                  ),
                  const SizedBox(height: 26),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          t.t('meal.ingredients'),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Text(
                        t.t('meal.tickOff'),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _IngredientList(
                    recipe: recipe,
                    isSi: isSi,
                    checked: _checked,
                    onToggle: (index) => setState(() {
                      if (!_checked.remove(index)) _checked.add(index);
                      HapticFeedback.selectionClick();
                    }),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    t.t('meal.method'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  for (var i = 0; i < recipe.steps.length; i++)
                    _StepRow(
                      number: i + 1,
                      text: recipe.steps[i].localized(isSi),
                      isLast: i == recipe.steps.length - 1,
                    ),
                  if (recipe.localizedTip(isSi) != null) ...[
                    const SizedBox(height: 18),
                    _TipCard(text: recipe.localizedTip(isSi)!),
                  ],
                  const SizedBox(height: 26),
                  _NearbyCard(
                    meal: meal,
                    onFind: _findNearby,
                    onOrder: () => _openUrl(_dishSearchUrl),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    t.t('meal.nutrition'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _Nutrition(
                        label: t.t('meal.protein'),
                        value: '${meal.protein}g',
                        color: AppColors.green,
                      ),
                      const SizedBox(width: 10),
                      _Nutrition(
                        label: t.t('meal.carbs'),
                        value: '${meal.carbs}g',
                        color: AppColors.amber,
                      ),
                      const SizedBox(width: 10),
                      _Nutrition(
                        label: t.t('meal.fat'),
                        value: '${meal.fat}g',
                        color: AppColors.rose,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton.icon(
                      onPressed: () => context.push('/credits'),
                      icon: Icon(Icons.photo_camera_back_outlined,
                          size: 15, color: AppColors.muted),
                      label: Text(
                        t.t('meal.photoCredit'),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
        decoration: BoxDecoration(
          color: AppColors.cream.withValues(alpha: 0.97),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: GradientButton(
            label: loggedToday ? t.t('meal.loggedToday') : t.t('meal.log'),
            icon: loggedToday
                ? Icons.check_circle_rounded
                : Icons.check_circle_outline_rounded,
            onPressed: _logMeal,
          ),
        ),
      ),
    );
  }
}

class _WatchCard extends StatelessWidget {
  const _WatchCard({required this.video, required this.onTap});

  final MealVideo video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.line),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      video.thumbnail,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => ColoredBox(
                        color: AppColors.surfaceAlt,
                        child: const Center(
                          child: Icon(Icons.play_circle_fill_rounded,
                              size: 54, color: AppColors.orange),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.94),
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 16),
                      ],
                    ),
                    child: const Icon(Icons.play_arrow_rounded,
                        size: 34, color: AppColors.orangeDeep),
                  ),
                  if (video.sinhala)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          t.t('meal.videoSi'),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.smart_display_outlined,
                            size: 14, color: AppColors.muted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${t.t('meal.watch')} · ${video.channel}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IngredientList extends StatelessWidget {
  const _IngredientList({
    required this.recipe,
    required this.isSi,
    required this.checked,
    required this.onToggle,
  });

  final Recipe recipe;
  final bool isSi;
  final Set<int> checked;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          for (var i = 0; i < recipe.ingredients.length; i++) ...[
            InkWell(
              onTap: () => onToggle(i),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: checked.contains(i)
                            ? AppColors.green
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: checked.contains(i)
                              ? AppColors.green
                              : AppColors.line,
                          width: 1.5,
                        ),
                      ),
                      child: checked.contains(i)
                          ? const Icon(Icons.check_rounded,
                              size: 15, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        recipe.ingredients[i].localizedName(isSi),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              decoration: checked.contains(i)
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: checked.contains(i)
                                  ? AppColors.muted
                                  : AppColors.ink,
                            ),
                      ),
                    ),
                    Text(
                      recipe.ingredients[i].quantity,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.orangeDeep,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            if (i != recipe.ingredients.length - 1)
              Divider(height: 1, indent: 48, color: AppColors.line),
          ],
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.number,
    required this.text,
    required this.isLast,
  });

  final int number;
  final String text;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.peachSoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$number',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.orangeDeep,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: AppColors.line,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.55,
                      color: AppColors.inkSoft,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.greenSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.t('meal.cookTip'),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.green,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  text,
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

class _NearbyCard extends StatelessWidget {
  const _NearbyCard({
    required this.meal,
    required this.onFind,
    required this.onOrder,
  });

  final Meal meal;
  final VoidCallback onFind;
  final VoidCallback onOrder;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.isDark
              ? [AppColors.surface, AppColors.surfaceAlt]
              : const [Color(0xFFFFEBD9), Color(0xFFFFF7F0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.isDark ? AppColors.line : Colors.white,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📍', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  t.t('meal.nearbyTitle'),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            t.t('meal.nearbySub'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.inkSoft,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 12),
          // Sinhala labels ("අසල සොයන්න" / "සිතියමේ සොයන්න") are wider than
          // English, so side-by-side buttons wrapped into two cramped lines on
          // a phone. Stack them whenever there is not enough room for one line.
          LayoutBuilder(
            builder: (context, constraints) {
              final find = FilledButton.icon(
                onPressed: onFind,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  minimumSize: const Size(0, 44),
                  textStyle: Theme.of(context).textTheme.labelMedium,
                ),
                icon: const Icon(Icons.near_me_outlined, size: 17),
                label: Text(
                  t.t('meal.findNearby'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
              final order = OutlinedButton.icon(
                onPressed: onOrder,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  textStyle: Theme.of(context).textTheme.labelMedium,
                ),
                icon: const Icon(Icons.delivery_dining_outlined, size: 18),
                label: Text(
                  t.t('meal.orderDish'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
              if (constraints.maxWidth < 340) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [find, const SizedBox(height: 8), order],
                );
              }
              return Row(
                children: [
                  Expanded(child: find),
                  const SizedBox(width: 8),
                  Expanded(child: order),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MindfulMoment extends StatelessWidget {
  const _MindfulMoment({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.isDark
              ? [AppColors.surface, AppColors.surfaceAlt]
              : const [Color(0xFFFFEBD9), Color(0xFFFFF7F0)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.isDark ? AppColors.line : Colors.white,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🧘', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.t('meal.mindful'),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.orangeDeep,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.inkSoft,
                        height: 1.55,
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

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.orange),
          const SizedBox(width: 5),
          Text(value, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _Nutrition extends StatelessWidget {
  const _Nutrition({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 2),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
