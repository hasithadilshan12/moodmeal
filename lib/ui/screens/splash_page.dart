import 'package:flutter/material.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../ui/widgets/common.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.isDark
                ? [AppColors.cream, AppColors.surfaceAlt]
                : const [Color(0xFFFFF3E6), Color(0xFFFFE3CC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value.clamp(0, 1),
                    child: Transform.translate(
                      offset: Offset(0, 24 * (1 - value)),
                      child: Transform.scale(
                        scale: 0.85 + 0.15 * value,
                        child: child,
                      ),
                    ),
                  );
                },
                child: const AppLogo(size: 118),
              ),
              const SizedBox(height: 26),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 1100),
                curve: Curves.easeOut,
                builder: (context, value, child) => Opacity(
                  opacity: value.clamp(0, 1),
                  child: child,
                ),
                child: Column(
                  children: [
                    Text(
                      t.t('app.name'),
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontSize: 34,
                                letterSpacing: -0.6,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t.t('app.tagline'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.inkSoft,
                          ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 4),
              SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation(
                    AppColors.orange.withValues(alpha: 0.8),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                '🍃  ${t.t('app.tagline')}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.muted,
                    ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
