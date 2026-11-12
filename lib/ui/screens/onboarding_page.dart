import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../state/app_controller.dart';
import '../../ui/widgets/common.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _pageController = PageController();
  int _index = 0;

  static const _pages = [
    _PageData(
      emoji: '🤔',
      tint: Color(0xFFFFF0E0),
      titleKey: 'onb.1.title',
      bodyKey: 'onb.1.body',
      accent: [Color(0xFFFFD9B8), Color(0xFFF7B27A)],
    ),
    _PageData(
      emoji: '🍱',
      tint: Color(0xFFFFF6E6),
      titleKey: 'onb.2.title',
      bodyKey: 'onb.2.body',
      accent: [Color(0xFFFFE1B8), Color(0xFFF2A65A)],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(appControllerProvider).completeOnboarding();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final isLast = _index == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 12, top: 8),
                child: TextButton(
                  onPressed: _finish,
                  child: Text(t.t('common.skip')),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26),
                    child: Column(
                      children: [
                        const Spacer(flex: 2),
                        Container(
                          height: 260,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.pastel(page.tint),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          alignment: Alignment.center,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                right: 26,
                                bottom: 22,
                                child: Container(
                                  width: 54,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.55),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 30,
                                top: 26,
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Container(
                                width: 168,
                                height: 168,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: page.accent),
                                  borderRadius: BorderRadius.circular(44),
                                  boxShadow: [
                                    BoxShadow(
                                      color: page.accent.last
                                          .withValues(alpha: 0.32),
                                      blurRadius: 26,
                                      offset: const Offset(0, 14),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  page.emoji,
                                  style: const TextStyle(fontSize: 74),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 38),
                        Text(
                          t.t(page.titleKey),
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontSize: 26,
                                height: 1.3,
                              ),
                        ),
                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            t.t(page.bodyKey),
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.inkSoft,
                                  height: 1.65,
                                ),
                          ),
                        ),
                        const Spacer(flex: 3),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _pages.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _index ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _index ? AppColors.orange : AppColors.line,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: GradientButton(
                label: isLast ? t.t('onb.getStarted') : t.t('common.continue'),
                onPressed: () {
                  if (isLast) {
                    _finish();
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutCubic,
                    );
                  }
                },
              ),
            ),
            TextButton(
              onPressed: _finish,
              child: Text(
                t.t('onb.haveAccount'),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.inkSoft,
                    ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _PageData {
  const _PageData({
    required this.emoji,
    required this.tint,
    required this.titleKey,
    required this.bodyKey,
    required this.accent,
  });

  final String emoji;
  final Color tint;
  final String titleKey;
  final String bodyKey;
  final List<Color> accent;
}
