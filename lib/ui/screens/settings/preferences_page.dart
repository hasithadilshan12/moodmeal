import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/models.dart';
import '../../../data/seed/catalog.dart';
import '../../../state/app_controller.dart';
import '../../widgets/common.dart';
import '../shell/app_shell.dart';

class PreferencesPage extends ConsumerStatefulWidget {
  const PreferencesPage({super.key});

  @override
  ConsumerState<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends ConsumerState<PreferencesPage> {
  static const _allergyEmoji = {
    'dairy': '🥛',
    'nuts': '🥜',
    'eggs': '🥚',
    'seafood': '🦐',
    'gluten': '🌾',
    'soy': '🫘',
  };

  static const _conditionEmoji = {
    'highBp': '🩺',
    'gastritis': '🔥',
    'cholesterol': '🫀',
    'vegan': '🌱',
    'kidney': '🫘',
    'diabetes': '🩸',
  };

  static const _avoidEmoji = {
    'spicy': '🌶️',
    'fried': '🍟',
    'oily': '🫗',
    'sugary': '🍬',
    'caffeine': '☕',
    'redMeat': '🥩',
  };

  late Set<String> _allergies;
  late Set<String> _conditions;
  late Set<String> _avoid;
  final _other = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(appControllerProvider).profile;
    _allergies = {...?profile?.allergies};
    _conditions = {...?profile?.conditions};
    _avoid = {...?profile?.avoid};
  }

  @override
  void dispose() {
    _other.dispose();
    super.dispose();
  }

  Set<String> get _customAllergies =>
      _allergies.where((key) => !Catalog.allergyKeys.contains(key)).toSet();

  void _toggle(Set<String> target, String key) {
    HapticFeedback.selectionClick();
    setState(() {
      if (!target.remove(key)) target.add(key);
    });
  }

  void _addOther() {
    final value = _other.text.trim();
    if (value.isEmpty) return;
    setState(() {
      _allergies.add(value);
      _other.clear();
    });
    FocusScope.of(context).unfocus();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final controller = ref.read(appControllerProvider);
    final current = controller.profile ??
        UserProfile(
          name: controller.session?.name ?? '',
          email: controller.session?.email ?? '',
        );
    final error = await controller.updateProfile(
      current.copyWith(
        allergies: _allergies.toList(),
        conditions: _conditions.toList(),
        avoid: _avoid.toList(),
      ),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    HapticFeedback.lightImpact();
    Toast.show(context, error ?? context.l10n.t('prefs.saved'));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            BackHeader(
              title: t.t('prefs.title'),
              subtitle: t.t('prefs.sub'),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                children: [
                  _ChipSection(
                    title: t.t('prefs.allergies'),
                    subtitle: t.t('prefs.allergiesSub'),
                    emoji: '🚫',
                    items: [
                      for (final key in Catalog.allergyKeys)
                        ChipItem(
                          key: key,
                          emoji: _allergyEmoji[key] ?? '•',
                          label: t.t('allergy.$key'),
                        ),
                    ],
                    selected: _allergies,
                    onToggle: (key) => _toggle(_allergies, key),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _other,
                          textInputAction: TextInputAction.done,
                          textCapitalization: TextCapitalization.sentences,
                          onSubmitted: (_) => _addOther(),
                          decoration: InputDecoration(
                            hintText: t.t('prefs.other'),
                            isDense: true,
                            prefixIcon: Icon(
                              Icons.add_circle_outline_rounded,
                              size: 19,
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 52,
                        height: 52,
                        child: FilledButton(
                          onPressed: _addOther,
                          style: FilledButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(52, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Icon(Icons.add_rounded, size: 22),
                        ),
                      ),
                    ],
                  ),
                  if (_customAllergies.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final key in _customAllergies)
                          InputChip(
                            label: Text(key),
                            onDeleted: () =>
                                setState(() => _allergies.remove(key)),
                            backgroundColor: AppColors.peachSoft,
                            side: const BorderSide(color: AppColors.orange),
                            deleteIconColor: AppColors.orangeDeep,
                            labelStyle: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: AppColors.ink),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 26),
                  _ChipSection(
                    title: t.t('prefs.conditions'),
                    subtitle: t.t('prefs.conditionsSub'),
                    emoji: '🩺',
                    items: [
                      for (final key in Catalog.conditionKeys)
                        ChipItem(
                          key: key,
                          emoji: _conditionEmoji[key] ?? '•',
                          label: t.t('cond.$key'),
                        ),
                    ],
                    selected: _conditions,
                    onToggle: (key) => _toggle(_conditions, key),
                  ),
                  const SizedBox(height: 26),
                  _ChipSection(
                    title: t.t('prefs.avoid'),
                    subtitle: t.t('prefs.avoidSub'),
                    emoji: '🙅',
                    items: [
                      for (final key in Catalog.avoidKeys)
                        ChipItem(
                          key: key,
                          emoji: _avoidEmoji[key] ?? '•',
                          label: t.t('avoid.$key'),
                        ),
                    ],
                    selected: _avoid,
                    onToggle: (key) => _toggle(_avoid, key),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            t.t('prefs.avoidSub'),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.inkSoft,
                                      height: 1.55,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: GradientButton(
                label: t.t('common.save'),
                icon: Icons.check_rounded,
                busy: _saving,
                onPressed: _saving ? null : _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipSection extends StatelessWidget {
  const _ChipSection({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.items,
    required this.selected,
    required this.onToggle,
  });

  final String title;
  final String subtitle;
  final String emoji;
  final List<ChipItem> items;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (selected.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.peachSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${selected.length}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.orangeDeep,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 3),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 12),
        ChipGrid(
          items: items,
          selected: selected,
          onToggle: onToggle,
        ),
      ],
    );
  }
}
