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
import '../shell/app_shell.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final controller = ref.watch(appControllerProvider);
    final profile = controller.profile ??
        UserProfile(
          name: controller.session?.name ?? 'Friend',
          email: controller.session?.email ?? '',
        );
    final themeLabel = controller.themeMode == ThemeMode.dark
        ? t.t('settings.themeDark')
        : controller.themeMode == ThemeMode.light
            ? t.t('settings.themeLight')
            : t.t('settings.themeSystem');
    final themeIcon = controller.themeMode == ThemeMode.dark
        ? Icons.dark_mode_outlined
        : controller.themeMode == ThemeMode.light
            ? Icons.wb_sunny_outlined
            : Icons.brightness_auto_outlined;

    Future<void> setReminder(bool value) async {
      HapticFeedback.selectionClick();
      final error = await ref
          .read(appControllerProvider)
          .updateProfile(profile.copyWith(reminderEnabled: value));
      if (!context.mounted) return;
      Toast.show(context, error ?? t.t('settings.saved'));
    }

    Future<void> signOut() async {
      HapticFeedback.mediumImpact();
      final confirmed = await showDialog<bool>(
        context: context,
        useRootNavigator: true,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          title: Text(
            t.t('auth.signOutConfirm'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: Text(
            t.t('profile.signOutSub'),
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
              child: Text(t.t('auth.signOut')),
            ),
          ],
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
            PageHeader(
              title: t.t('settings.title'),
              subtitle: t.t('app.tagline'),
              trailing: GestureDetector(
                onTap: () => context.push('/profile'),
                child: ProfileAvatar(profile: profile, size: 48),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 130),
                children: [
                  AppCard(
                    padding: const EdgeInsets.all(14),
                    onTap: () => context.push('/profile'),
                    child: Row(
                      children: [
                        ProfileAvatar(profile: profile, size: 52),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                profile.email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.peachSoft,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            t.t('profile.title'),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: AppColors.orangeDeep,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  SettingsGroup(
                    title: t.t('settings.general'),
                    children: [
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
                    title: t.t('settings.personalise'),
                    children: [
                      SettingsTile(
                        icon: Icons.language_rounded,
                        title: t.t('settings.language'),
                        subtitle: t.t('settings.languageSub'),
                        trailing: _Pill(
                          label: profile.language == 'si'
                              ? t.t('settings.sinhala')
                              : t.t('settings.english'),
                        ),
                        onTap: () => _pickLanguage(context, ref, profile),
                      ),
                      SettingsTile(
                        icon: themeIcon,
                        title: t.t('settings.theme'),
                        subtitle: t.t('settings.themeSub'),
                        iconColor: AppColors.amber,
                        iconBackground: AppColors.peachSoft,
                        trailing: _Pill(label: themeLabel),
                        onTap: () =>
                            _pickTheme(context, ref, controller.themeMode),
                        showChevron: false,
                      ),
                      SettingsTile(
                        icon: Icons.notifications_active_outlined,
                        title: t.t('settings.reminderOn'),
                        subtitle: t.t('settings.reminderSub'),
                        iconColor: AppColors.orangeDeep,
                        iconBackground: AppColors.peachSoft,
                        trailing: Switch.adaptive(
                          value: profile.reminderEnabled,
                          activeThumbColor: AppColors.orange,
                          activeTrackColor: AppColors.peach,
                          onChanged: setReminder,
                        ),
                        onTap: () => setReminder(!profile.reminderEnabled),
                        showChevron: false,
                      ),
                    ],
                  ),
                  SettingsGroup(
                    title: t.t('settings.support'),
                    children: [
                      SettingsTile(
                        icon: Icons.photo_library_outlined,
                        title: t.t('settings.credits'),
                        subtitle: t.t('settings.creditsSub'),
                        iconColor: AppColors.violet,
                        iconBackground: AppColors.violetSoft,
                        onTap: () => context.push('/credits'),
                      ),
                      SettingsTile(
                        icon: Icons.info_outline_rounded,
                        title: t.t('settings.about'),
                        subtitle: t.t('profile.version'),
                        iconColor: AppColors.inkSoft,
                        iconBackground: AppColors.surfaceAlt,
                        onTap: () => _showAbout(context),
                      ),
                      SettingsTile(
                        icon: Icons.shield_outlined,
                        title: t.t('profile.about'),
                        subtitle: t.t('settings.data'),
                        iconColor: AppColors.green,
                        iconBackground: AppColors.greenSoft,
                        showChevron: false,
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
                t.t('settings.language'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                t.t('settings.languageSub'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 14),
              _LanguageOption(
                key: const Key('language-en'),
                label: t.t('settings.english'),
                emoji: '🇬🇧',
                selected: profile.language == 'en',
                onTap: () => Navigator.of(context).pop('en'),
              ),
              const SizedBox(height: 10),
              _LanguageOption(
                key: const Key('language-si'),
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

  Future<void> _pickTheme(
    BuildContext context,
    WidgetRef ref,
    ThemeMode current,
  ) async {
    final t = context.l10n;
    final selected = await showModalBottomSheet<ThemeMode>(
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
                t.t('settings.theme'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                t.t('settings.themeSub'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 14),
              _ThemeOption(
                key: const Key('theme-light'),
                label: t.t('settings.themeLight'),
                icon: Icons.wb_sunny_outlined,
                selected: current == ThemeMode.light,
                onTap: () => Navigator.of(context).pop(ThemeMode.light),
              ),
              const SizedBox(height: 10),
              _ThemeOption(
                key: const Key('theme-dark'),
                label: t.t('settings.themeDark'),
                icon: Icons.dark_mode_outlined,
                selected: current == ThemeMode.dark,
                onTap: () => Navigator.of(context).pop(ThemeMode.dark),
              ),
              const SizedBox(height: 10),
              _ThemeOption(
                key: const Key('theme-system'),
                label: t.t('settings.themeSystem'),
                icon: Icons.brightness_auto_outlined,
                selected: current == ThemeMode.system,
                onTap: () => Navigator.of(context).pop(ThemeMode.system),
              ),
            ],
          ),
        ),
      ),
    );
    if (selected == null || selected == current) return;
    HapticFeedback.selectionClick();
    await ref.read(appControllerProvider).setThemeMode(selected);
    if (!context.mounted) return;
    Toast.show(context, t.t('settings.themeSaved'));
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

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

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
    super.key,
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

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
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
            Icon(icon, size: 21, color: AppColors.orangeDeep),
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
