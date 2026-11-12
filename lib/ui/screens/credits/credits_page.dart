import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/models.dart';
import '../../../data/seed/catalog.dart';
import '../../../data/seed/media.dart';
import '../../widgets/common.dart';
import '../shell/app_shell.dart';

/// Lists the real origin of every bundled photograph and recipe video.
/// Required by the CC licences used for the Wikimedia Commons imagery.
class CreditsPage extends StatefulWidget {
  const CreditsPage({super.key});

  @override
  State<CreditsPage> createState() => _CreditsPageState();
}

class _CreditsPageState extends State<CreditsPage> {
  List<_Credit>? _credits;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final raw =
          await rootBundle.loadString('assets/images/food/credits.json');
      final list = (jsonDecode(raw) as List)
          .map((e) => _Credit.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
      if (!mounted) return;
      setState(() => _credits = list);
    } catch (_) {
      if (!mounted) return;
      setState(() => _failed = true);
    }
  }

  Future<void> _open(String? url) async {
    if (url == null || url.isEmpty) return;
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!mounted || ok) return;
    Toast.show(context, context.l10n.t('common.cannotOpen'));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final isSi = t.isSinhala;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            BackHeader(
                title: t.t('credits.title'), subtitle: t.t('credits.sub')),
            Expanded(
              child: _credits == null && !_failed
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                      children: [
                        if (_credits != null)
                          for (final credit in _credits!)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _CreditCard(
                                credit: credit,
                                isSi: isSi,
                                onOpen: () => _open(credit.source),
                              ),
                            ),
                        const SizedBox(height: 18),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                          child: Text(
                            t.t('credits.videosTitle'),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                          child: Text(
                            t.t('credits.videosSub'),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        for (final meal in Catalog.meals)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _VideoRow(
                              mealId: meal.id,
                              onOpen: () =>
                                  _open(MediaBook.of(meal.id).video.watchUrl),
                            ),
                          ),
                        const SizedBox(height: 18),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                          child: Text(
                            t.t('credits.mapTitle'),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                          child: Text(
                            t.t('credits.mapBody'),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        AppCard(
                          onTap: () =>
                              _open('https://www.openstreetmap.org/copyright'),
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              const Icon(Icons.map_outlined,
                                  size: 20, color: AppColors.orange),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  t.t('credits.mapSource'),
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ),
                              Icon(Icons.open_in_new_rounded,
                                  size: 16, color: AppColors.muted),
                            ],
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

class _Credit {
  const _Credit({
    required this.id,
    required this.file,
    required this.title,
    required this.author,
    required this.license,
    required this.licenseUrl,
    required this.source,
  });

  final String id;
  final String file;
  final String title;
  final String author;
  final String license;
  final String licenseUrl;
  final String source;

  factory _Credit.fromJson(Map<String, dynamic> json) => _Credit(
        id: json['id'] as String? ?? '',
        file: json['file'] as String? ?? '',
        title: json['title'] as String? ?? '',
        author: json['author'] as String? ?? '',
        license: json['license'] as String? ?? '',
        licenseUrl: json['licenseUrl'] as String? ?? '',
        source: json['source'] as String? ?? '',
      );
}

class _CreditCard extends StatelessWidget {
  const _CreditCard({
    required this.credit,
    required this.isSi,
    required this.onOpen,
  });

  final _Credit credit;
  final bool isSi;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    Meal? meal;
    for (final m in Catalog.meals) {
      if (m.id == credit.id) {
        meal = m;
        break;
      }
    }
    final name = meal?.localizedName(isSi) ?? credit.id;

    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (meal != null)
            MealImage(meal: meal, size: 58, radius: 14)
          else
            const SizedBox(width: 58),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 3),
                Text(
                  credit.author.isEmpty
                      ? t.t('credits.unknown')
                      : t.t('credits.by', {'author': credit.author}),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.inkSoft,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${t.t('credits.license')}: ${credit.license}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: onOpen,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.open_in_new_rounded,
                            size: 13, color: AppColors.orange),
                        const SizedBox(width: 4),
                        Text(
                          t.t('credits.source'),
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.orangeDeep,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
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

class _VideoRow extends StatelessWidget {
  const _VideoRow({required this.mealId, required this.onOpen});

  final String mealId;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final isSi = t.isSinhala;
    final meal = Catalog.mealById(mealId);
    final video = MediaBook.of(mealId).video;

    return AppCard(
      onTap: onOpen,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          MealImage(meal: meal, size: 52, radius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  '${video.channel} · ${meal.localizedName(isSi)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.open_in_new_rounded, size: 16, color: AppColors.muted),
        ],
      ),
    );
  }
}
