import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/dates.dart';
import '../../../data/models/models.dart';
import '../../../data/models/mood_entry.dart';
import '../../../data/notifications/notification_feed.dart';
import '../../../data/seed/catalog.dart';
import '../../../data/services/nearby_service.dart';
import '../../../state/app_controller.dart';
import '../../../state/nearby_controller.dart';
import '../../widgets/common.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final controller = ref.watch(appControllerProvider);
    final name = controller.profile?.name.split(' ').first ?? 'Friend';
    final today = controller.todayEntry;
    final mood = today?.mood ?? controller.lastEntry?.mood ?? Mood.calm;
    // Respect the profile's allergies and avoid list, but never crash or show a
    // blank card when those filters remove every meal.
    final preferred = Catalog.mealsForMood(
      mood,
      allergies: controller.profile?.allergies ?? const [],
      avoid: controller.profile?.avoid ?? const [],
    );
    final suggestion = preferred.isNotEmpty
        ? preferred.first
        : Catalog.mealsForMood(mood).first;
    final tip = Catalog.tips[(DateTime.now().day - 1) % Catalog.tips.length];
    final nearby = ref.watch(nearbyProvider);
    final readNotifs = ref.watch(readNotifsProvider);
    final feed = buildNotificationFeed(
      t: t,
      reminderEnabled: controller.profile?.reminderEnabled ?? true,
      reminderLabel: controller.profile?.reminderLabel ?? '8:00 AM',
      streak: controller.streak,
      checkInCount: controller.checkInCount,
    );
    final hasUnread = feed.any((item) => !readNotifs.contains(item.id));
    final hour = DateTime.now().hour;
    final greetingKey = hour < 12
        ? 'app.morning'
        : hour < 17
            ? 'app.afternoon'
            : 'app.evening';

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 130),
          children: [
            _Header(
              greeting: t.t(greetingKey),
              name: name,
              profile: controller.profile,
              showBadge: hasUnread,
            ),
            const SizedBox(height: 14),
            _SearchPill(onTap: () => context.push('/explore')),
            const SizedBox(height: 16),
            _MoodCard(
              mood: mood,
              hasCheckedIn: today != null,
              streak: controller.streak,
              onTap: () => context.push('/mood/checkin'),
            ),
            const SizedBox(height: 22),
            SectionHeader(
              title: t.t('home.todaySuggestion'),
              padding: EdgeInsets.zero,
              actionLabel: t.t('rec.all'),
              onAction: () => context.push('/mood/result'),
            ),
            _SuggestionCard(
              meal: suggestion,
              onTap: () => context.push('/meal/${suggestion.id}'),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _LastCheckInCard(
                    entry: controller.lastEntry,
                    onTap: () => context.go('/history'),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _TipCard(
                    tip: tip,
                    onTap: () => context.push('/tips/${tip.id}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            SectionHeader(
              title: t.t('home.quickActions'),
              padding: EdgeInsets.zero,
            ),
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    emoji: '💛',
                    label: t.t('home.favourites'),
                    tint: const Color(0xFFFDE9EE),
                    onTap: () => context.push('/favourites'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAction(
                    emoji: '📍',
                    label: t.t('home.nearby'),
                    tint: const Color(0xFFE4F5EC),
                    onTap: () => context.push('/restaurants'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAction(
                    emoji: '📊',
                    label: t.t('home.insights'),
                    tint: const Color(0xFFEDE9FF),
                    onTap: () => context.push('/insights'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            SectionHeader(
              title: t.t('rec.nearbyTitle'),
              padding: EdgeInsets.zero,
              actionLabel: t.t('common.seeAll'),
              onAction: () => context.push('/restaurants'),
            ),
            if (nearby.places.isEmpty)
              NearbyPromptCard(
                title: t.t('rec.nearbyTitle'),
                body: t.t('rest.sub'),
                actionLabel: t.t('common.seeAll'),
                onTap: () => context.push('/restaurants'),
              )
            else
              SizedBox(
                height: 150,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(right: 4),
                  itemCount: nearby.places.take(4).length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final place = nearby.places[index];
                    return _PlaceMiniCard(
                      place: place,
                      onTap: () => context.push('/restaurants'),
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
            _QuoteCard(mood: mood),
          ],
        ),
      ),
    );
  }
}

class _SearchPill extends StatelessWidget {
  const _SearchPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, size: 19, color: AppColors.muted),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  t.t('explore.hint'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.muted,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.greeting,
    required this.name,
    required this.profile,
    required this.showBadge,
  });

  final String greeting;
  final String name;
  final UserProfile? profile;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final avatar = profile;
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.push('/profile'),
          child: avatar == null
              ? Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFE0C2), Color(0xFFFFC79A)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text('🌤️', style: TextStyle(fontSize: 21)),
                )
              : ProfileAvatar(
                  profile: avatar,
                  size: 46,
                  borderWidth: 0,
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '$greeting, $name 👋',
                    maxLines: 1,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                t.t('home.moodQuestion'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        CircleIconButton(
          icon: Icons.favorite_border_rounded,
          background: AppColors.surface,
          onTap: () => context.push('/favourites'),
        ),
        const SizedBox(width: 8),
        CircleIconButton(
          icon: Icons.notifications_none_rounded,
          background: AppColors.surface,
          onTap: () => context.push('/notifications'),
          badge: showBadge,
        ),
      ],
    );
  }
}

class _MoodCard extends StatelessWidget {
  const _MoodCard({
    required this.mood,
    required this.hasCheckedIn,
    required this.streak,
    required this.onTap,
  });

  final Mood mood;
  final bool hasCheckedIn;
  final int streak;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final colors = moodGradient(mood);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colors.first.withValues(alpha: 0.30),
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
              color: colors.last.withValues(alpha: 0.18),
              blurRadius: 30,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  hasCheckedIn
                      ? t.t('home.lastCheckIn').toUpperCase()
                      : t.t('home.moodCheckIn').toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 1.2,
                        color: AppColors.inkSoft,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                if (streak > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '🔥 ${t.t('home.streak', {'n': '$streak'})}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.orangeDeep,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasCheckedIn
                            ? '${t.t('home.chooseMood')} · ${mood.emoji}'
                            : t.t('home.chooseMood'),
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontSize: 22),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        hasCheckedIn
                            ? t.t('home.moodQuestion')
                            : t.t('home.chooseNow'),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: 150,
                        child: GradientButton(
                          label: hasCheckedIn
                              ? t.t('home.choose')
                              : t.t('home.choose'),
                          height: 44,
                          icon: Icons.add_reaction_outlined,
                          onPressed: onTap,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.last.withValues(alpha: 0.25),
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(mood.emoji, style: const TextStyle(fontSize: 44)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.meal, required this.onTap});

  final Meal meal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final isSi = t.isSinhala;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          MealImage(meal: meal, size: 76, radius: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.localizedName(isSi),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  meal.localizedDescription(isSi),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule_rounded,
                        size: 13, color: AppColors.muted),
                    const SizedBox(width: 4),
                    Text(
                      t.t('common.minValue', {'n': '${meal.minutes}'}),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.local_fire_department_rounded,
                        size: 13, color: AppColors.orange),
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

class _LastCheckInCard extends StatelessWidget {
  const _LastCheckInCard({required this.entry, required this.onTap});

  final dynamic entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final mood = entry?.mood as Mood?;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.t('home.lastCheckIn').toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 0.8,
                  color: AppColors.muted,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            mood?.emoji ?? '🫥',
            style: const TextStyle(fontSize: 26),
          ),
          const SizedBox(height: 6),
          Text(
            mood == null ? t.t('home.noCheckIn') : t.t(mood.labelKey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 2),
          Text(
            entry == null
                ? t.t('home.chooseNow')
                : Dates.dayLabel(
                    entry.createdAt as DateTime,
                    today: t.t('common.today'),
                    yesterday: t.t('common.yesterday'),
                  ),
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.tip, required this.onTap});

  final Tip tip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.t('home.mindfulTip').toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 0.8,
                  color: AppColors.muted,
                ),
          ),
          const SizedBox(height: 10),
          Text(tip.emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(height: 6),
          Text(
            tip.localizedTitle(t.isSinhala),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 2),
          Text(
            t.t('common.minValue', {'n': '${tip.minutes}'}),
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.emoji,
    required this.label,
    required this.tint,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.pastel(tint),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceMiniCard extends StatelessWidget {
  const _PlaceMiniCard({required this.place, required this.onTap});

  final NearbyPlace place;
  final VoidCallback onTap;

  IconData get _icon => switch (place.category) {
        'cafe' => Icons.local_cafe_rounded,
        'fast_food' => Icons.fastfood_rounded,
        _ => Icons.restaurant_rounded,
      };

  String _categoryLabel(AppLocalizations t) {
    final key = 'rest.cat.${place.category}';
    final label = t.t(key);
    return label == key ? t.t('rest.cat.restaurant') : label;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 172,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.peachSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(_icon, size: 19, color: AppColors.orangeDeep),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.greenSoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${place.distanceKm < 1 ? (place.distanceKm * 1000).round() : place.distanceKm.toStringAsFixed(1)}'
                    '${place.distanceKm < 1 ? ' m' : ' ${t.t('common.km')}'}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 9,
                          color: AppColors.green,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              place.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 2),
            Text(
              _categoryLabel(t),
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.near_me_outlined,
                    size: 13, color: AppColors.orange),
                const SizedBox(width: 4),
                Text(
                  t.t('common.seeAll'),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.orangeDeep,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.mood});

  final Mood mood;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.isDark
            ? LinearGradient(
                colors: [AppColors.peachSoft, AppColors.surface],
              )
            : const LinearGradient(
                colors: [Color(0xFFFFEFE2), Color(0xFFFFF8F2)],
              ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surface),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.8),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(mood.emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              t.t('insights.correlationBody'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.inkSoft,
                    height: 1.55,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
