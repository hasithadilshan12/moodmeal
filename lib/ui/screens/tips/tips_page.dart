import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/models.dart';
import '../../../data/seed/catalog.dart';
import '../../../state/app_controller.dart';
import '../../widgets/common.dart';

class TipsPage extends ConsumerWidget {
  const TipsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final practised = ref.watch(practisedProvider);
    const tips = Catalog.tips;
    final featured = tips[(DateTime.now().day - 1) % tips.length];
    final done = tips.where((tip) => practised.contains(tip.id)).length;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            PageHeader(
              title: t.t('tips.title'),
              subtitle: t.t('tips.sub'),
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.peachSoft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  '🌿 $done/${tips.length}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.orangeDeep,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 130),
                children: [
                  _FeaturedTip(
                    tip: featured,
                    practised: practised.contains(featured.id),
                    onTap: () => context.push('/tips/${featured.id}'),
                  ),
                  const SizedBox(height: 16),
                  _ProgressCard(done: done, total: tips.length),
                  const SizedBox(height: 22),
                  Text(
                    t.t('tips.all'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  for (final tip in tips)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _TipTile(
                        tip: tip,
                        practised: practised.contains(tip.id),
                        onTap: () => context.push('/tips/${tip.id}'),
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

class _FeaturedTip extends StatelessWidget {
  const _FeaturedTip({
    required this.tip,
    required this.practised,
    required this.onTap,
  });

  final Tip tip;
  final bool practised;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.isDark
                ? [
                    Color.alphaBlend(
                        Colors.black.withValues(alpha: 0.55), tip.tint),
                    AppColors.surface,
                  ]
                : [
                    tip.tint,
                    Color.lerp(tip.tint, Colors.white, 0.65)!,
                    Colors.white,
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppColors.isDark ? AppColors.line : Colors.white,
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.06),
              blurRadius: 26,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  t.t('tips.featured').toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 1,
                        color: AppColors.inkSoft,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                if (practised)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            size: 13, color: AppColors.green),
                        const SizedBox(width: 4),
                        Text(
                          t.t('tips.practised'),
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontSize: 9.5,
                                    color: AppColors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  alignment: Alignment.center,
                  child: Text(tip.emoji, style: const TextStyle(fontSize: 34)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tip.localizedTitle(t.isSinhala),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        tip.localizedBody(t.isSinhala),
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
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.timer_outlined, size: 15, color: AppColors.inkSoft),
                const SizedBox(width: 5),
                Text(
                  t.t('tips.minutes', {'n': '${tip.minutes}'}),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const Spacer(),
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.arrow_forward_rounded,
                      size: 18, color: AppColors.orangeDeep),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final ratio = total == 0 ? 0.0 : done / total;

    return AppCard(
      padding: const EdgeInsets.all(16),
      shadow: false,
      border: Border.all(color: AppColors.line),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.greenSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Text('🌱', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        t.t('tips.progress', {'n': '$done', 'total': '$total'}),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    Text(
                      '${(ratio * 100).round()}%',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.green,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: ratio),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => LinearProgressIndicator(
                      value: value,
                      minHeight: 8,
                      backgroundColor: AppColors.line,
                      valueColor: const AlwaysStoppedAnimation(AppColors.green),
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
}

class _TipTile extends StatelessWidget {
  const _TipTile({
    required this.tip,
    required this.practised,
    required this.onTap,
  });

  final Tip tip;
  final bool practised;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Row(
        children: [
          EmojiTile(
            emoji: tip.emoji,
            colors: [
              tip.tint,
              Color.lerp(tip.tint, AppColors.orange, 0.22)!,
            ],
            size: 56,
            radius: 16,
            fontSize: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.localizedTitle(t.isSinhala),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 3),
                Text(
                  tip.localizedBody(t.isSinhala),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (practised)
            const Icon(Icons.check_circle_rounded,
                size: 20, color: AppColors.green)
          else
            Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.muted),
        ],
      ),
    );
  }
}
