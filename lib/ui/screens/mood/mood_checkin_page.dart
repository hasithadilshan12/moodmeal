import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/mood_entry.dart';
import '../../../data/seed/catalog.dart';
import '../../../state/app_controller.dart';
import '../../widgets/common.dart';
import '../shell/app_shell.dart';

class MoodCheckinPage extends ConsumerStatefulWidget {
  const MoodCheckinPage({super.key});

  @override
  ConsumerState<MoodCheckinPage> createState() => _MoodCheckinPageState();
}

class _MoodCheckinPageState extends ConsumerState<MoodCheckinPage> {
  Mood? _mood;
  int _intensity = 3;
  final Set<String> _tags = {};
  final _note = TextEditingController();

  @override
  void initState() {
    super.initState();
    _mood = ref.read(appControllerProvider).todayEntry?.mood;
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final mood = _mood;
    if (mood == null) {
      HapticFeedback.mediumImpact();
      Toast.show(context, '🙂');
      return;
    }
    final entry = MoodEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      mood: mood,
      intensity: _intensity,
      createdAt: DateTime.now(),
      note: _note.text.trim(),
      tags: _tags.toList(),
    );
    final error = await ref.read(appControllerProvider).saveMood(entry);
    if (!mounted) return;
    if (error != null) {
      Toast.show(context, error);
      return;
    }
    HapticFeedback.lightImpact();
    context.pushReplacement('/mood/result', extra: mood);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final busy = ref.watch(appControllerProvider).busy;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            BackHeader(
              title: t.t('mood.title'),
              subtitle: t.t('mood.question'),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                children: [
                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: t.isSinhala ? 0.78 : 0.86,
                    children: [
                      for (final mood in Mood.values)
                        _MoodTile(
                          mood: mood,
                          selected: _mood == mood,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _mood = mood);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  _SectionLabel(t.t('mood.intensity')),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.ink.withValues(alpha: 0.04),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 8,
                            activeTrackColor: (_mood ?? Mood.calm)
                                .color
                                .withValues(alpha: 0.8),
                            inactiveTrackColor: AppColors.line,
                            thumbColor: Colors.white,
                            overlayColor: (_mood ?? Mood.calm)
                                .color
                                .withValues(alpha: 0.12),
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 11,
                              elevation: 4,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 22,
                            ),
                          ),
                          child: Slider(
                            value: _intensity.toDouble(),
                            min: 1,
                            max: 5,
                            divisions: 4,
                            onChanged: (value) {
                              HapticFeedback.selectionClick();
                              setState(() => _intensity = value.round());
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(6, 0, 6, 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(t.t('mood.low'),
                                  style:
                                      Theme.of(context).textTheme.labelSmall),
                              Text(
                                '$_intensity/5',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      color: AppColors.orangeDeep,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              Text(t.t('mood.high'),
                                  style:
                                      Theme.of(context).textTheme.labelSmall),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel(t.t('mood.tags')),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final tag in Catalog.moodTags)
                        MoodPill(
                          emoji: Catalog.tagEmoji[tag] ?? '•',
                          label: t.t('tag.$tag'),
                          colors: [
                            AppColors.peach,
                            AppColors.orange,
                          ],
                          selected: _tags.contains(tag),
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              if (!_tags.remove(tag)) _tags.add(tag);
                            });
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel(t.t('mood.note')),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _note,
                    maxLines: 3,
                    maxLength: 160,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: t.t('mood.noteHint'),
                      counterStyle: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
              child: GradientButton(
                label: t.t('mood.cta'),
                icon: Icons.restaurant_menu_rounded,
                busy: busy,
                onPressed: _mood == null || busy ? null : _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodTile extends StatelessWidget {
  const _MoodTile({
    required this.mood,
    required this.selected,
    required this.onTap,
  });

  final Mood mood;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final colors = mood.gradient;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: [
                    colors.first.withValues(alpha: 0.55),
                    colors.last.withValues(alpha: 0.35),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: selected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? colors.last : AppColors.line,
            width: selected ? 1.8 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: colors.last.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [
                  BoxShadow(
                    color: AppColors.ink.withValues(alpha: 0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: selected ? 1.12 : 1,
              duration: const Duration(milliseconds: 180),
              child: Text(mood.emoji, style: const TextStyle(fontSize: 30)),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                t.t(mood.labelKey),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: t.isSinhala ? 10 : 10.5,
                      height: 1.15,
                      color: AppColors.ink,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppColors.ink,
          ),
    );
  }
}
