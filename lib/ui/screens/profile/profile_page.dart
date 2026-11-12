import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/models.dart';
import '../../../state/app_controller.dart';
import '../../widgets/common.dart';
import '../../widgets/settings_tiles.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final controller = ref.watch(appControllerProvider);
    final profile = controller.profile ??
        UserProfile(
          name: controller.session?.name ?? 'Friend',
          email: controller.session?.email ?? '',
        );
    final favouriteCount = controller.favourites.length;

    Future<void> signOut() async {
      HapticFeedback.mediumImpact();
      final confirmed = await showDialog<bool>(
        context: context,
        useRootNavigator: true,
        builder: (context) => _ConfirmDialog(
          title: t.t('auth.signOutConfirm'),
          body: t.t('profile.signOutSub'),
          confirmLabel: t.t('auth.signOut'),
        ),
      );
      if (confirmed != true) return;
      await controller.signOut();
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            BackHeader(
              title: t.t('profile.title'),
              trailing: CircleIconButton(
                icon: Icons.notifications_none_rounded,
                onTap: () => context.push('/notifications'),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 40),
                children: [
                  _ProfileHero(
                    profile: profile,
                    isDemo: controller.isDemo,
                    onEdit: () => context.push('/profile/edit'),
                    onAvatar: () => context.push('/profile/edit'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _Stat(
                          value: '${controller.checkInCount}',
                          label: t.t('profile.checkins'),
                          emoji: '📔',
                          tint: const Color(0xFFFFF0E0),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _Stat(
                          value: '${controller.streak}',
                          label: t.t('profile.streak'),
                          emoji: '🔥',
                          tint: const Color(0xFFFDE9EE),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _Stat(
                          value: '$favouriteCount',
                          label: t.t('profile.saved'),
                          emoji: '💛',
                          tint: const Color(0xFFE4F5EC),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SettingsGroup(
                    title: t.t('profile.accountSection'),
                    children: [
                      SettingsTile(
                        icon: Icons.person_outline_rounded,
                        title: t.t('profile.edit'),
                        subtitle: t.t('profile.detailsSub'),
                        onTap: () => context.push('/profile/edit'),
                      ),
                      SettingsTile(
                        icon: Icons.restaurant_menu_rounded,
                        title: t.t('profile.preferences'),
                        subtitle: t.t('prefs.sub'),
                        iconColor: AppColors.green,
                        iconBackground: AppColors.greenSoft,
                        onTap: () => context.push('/preferences'),
                      ),
                      SettingsTile(
                        icon: Icons.alarm_rounded,
                        title: t.t('profile.reminders'),
                        subtitle: profile.reminderEnabled
                            ? t.t('settings.onAt',
                                {'time': profile.reminderLabel})
                            : t.t('settings.off'),
                        iconColor: AppColors.violet,
                        iconBackground: AppColors.violetSoft,
                        onTap: () => context.push('/reminders'),
                      ),
                      SettingsTile(
                        icon: Icons.notifications_none_rounded,
                        title: t.t('profile.notifications'),
                        subtitle: t.t('settings.notificationsSub'),
                        iconColor: AppColors.amber,
                        iconBackground: AppColors.amberSoft,
                        onTap: () => context.push('/notifications'),
                      ),
                    ],
                  ),
                  SettingsGroup(
                    title: t.t('profile.appSection'),
                    children: [
                      SettingsTile(
                        icon: Icons.language_rounded,
                        title: t.t('profile.language'),
                        subtitle: profile.language == 'si'
                            ? t.t('settings.sinhala')
                            : t.t('settings.english'),
                        iconColor: AppColors.orangeDeep,
                        iconBackground: AppColors.peachSoft,
                        trailing: _LanguagePill(
                          label: profile.language == 'si'
                              ? t.t('settings.sinhala')
                              : t.t('settings.english'),
                        ),
                        onTap: () => _pickLanguage(context, ref, profile),
                      ),
                      SettingsTile(
                        icon: Icons.info_outline_rounded,
                        title: t.t('profile.about'),
                        subtitle: t.t('profile.version'),
                        iconColor: AppColors.inkSoft,
                        iconBackground: AppColors.surfaceAlt,
                        onTap: () => _showAbout(context),
                      ),
                    ],
                  ),
                  SettingsGroup(
                    padding: EdgeInsets.zero,
                    children: [
                      SettingsTile(
                        icon: Icons.logout_rounded,
                        title: t.t('auth.signOut'),
                        subtitle: t.t('profile.signOutSub'),
                        destructive: true,
                        showChevron: false,
                        onTap: signOut,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'MoodMeal · ${t.t('profile.version')}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.muted,
                          ),
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

  Future<void> _pickLanguage(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
  ) async {
    final t = context.l10n;
    final selected = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.t('profile.language'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                t.t('settings.languageSub'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 14),
              _LanguageOption(
                label: t.t('settings.english'),
                emoji: '🇬🇧',
                selected: profile.language == 'en',
                onTap: () => Navigator.of(context).pop('en'),
              ),
              const SizedBox(height: 10),
              _LanguageOption(
                label: t.t('settings.sinhala'),
                emoji: '🇱🇰',
                selected: profile.language == 'si',
                onTap: () => Navigator.of(context).pop('si'),
              ),
            ],
          ),
        ),
      ),
    );
    if (selected == null) return;
    await ref.read(appControllerProvider).setLanguage(selected);
  }

  void _showAbout(BuildContext context) {
    final t = context.l10n;
    showDialog<void>(
      context: context,
      useRootNavigator: true,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
        ),
        title: Row(
          children: [
            const AppLogo(size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                t.t('profile.about'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
        content: Text(
          t.t('profile.aboutBody'),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.inkSoft,
                height: 1.6,
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t.t('common.done')),
          ),
        ],
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.profile,
    required this.isDemo,
    required this.onEdit,
    required this.onAvatar,
  });

  final UserProfile profile;
  final bool isDemo;
  final VoidCallback onEdit;
  final VoidCallback onAvatar;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.isDark
              ? [AppColors.surface, AppColors.surfaceAlt]
              : const [
                  Color(0xFFFFEBDD),
                  Color(0xFFFFF8F2),
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
            color: AppColors.orange.withValues(alpha: 0.08),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onAvatar,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.orange.withValues(alpha: 0.18),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ProfileAvatar(
                    profile: profile,
                    size: 92,
                    borderWidth: 3,
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: 2,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.orange,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.edit_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            profile.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 2),
          Text(
            profile.email,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (isDemo) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.line),
              ),
              child: Text(
                '✨ ${t.t('profile.demo')}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 9.5,
                      color: AppColors.orangeDeep,
                    ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: 168,
            child: OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: Text(t.t('profile.edit')),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 42),
                backgroundColor: AppColors.surface.withValues(alpha: 0.7),
                side: BorderSide(color: AppColors.line, width: 1.2),
                textStyle: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
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
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.pastel(tint),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 5),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 9.5,
                ),
          ),
        ],
      ),
    );
  }
}

class _LanguagePill extends StatelessWidget {
  const _LanguagePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.peachSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.orangeDeep,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.peachSoft : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.orange : AppColors.line,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: selected ? AppColors.orangeDeep : AppColors.ink,
                    ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  size: 20, color: AppColors.orange),
          ],
        ),
      ),
    );
  }
}

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.title,
    required this.body,
    required this.confirmLabel,
  });

  final String title;
  final String body;
  final String confirmLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      title: Text(title, style: Theme.of(context).textTheme.titleLarge),
      content: Text(
        body,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.inkSoft,
            ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(t.t('common.cancel')),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.rose,
            minimumSize: const Size(0, 44),
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
