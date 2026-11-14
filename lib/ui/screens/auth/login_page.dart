import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../state/app_controller.dart';
import '../../widgets/common.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController(text: '');
  final _password = TextEditingController(text: '');
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final controller = ref.read(appControllerProvider);
    final error = await controller.signIn(_email.text, _password.text);
    if (!mounted) return;
    if (error == AppController.needsEmailConfirmation) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(context.l10n.t('auth.confirmEmailTitle')),
          content: Text(context.l10n.t('auth.confirmEmail')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(context.l10n.t('common.done')),
            ),
          ],
        ),
      );
      return;
    }
    if (error != null) {
      _showError(error);
    }
  }

  Future<void> _google() async {
    final controller = ref.read(appControllerProvider);
    if (!controller.isRemote) {
      _showError(context.l10n.t('auth.googleNeedsBackend'));
      return;
    }
    final error = await controller.signInWithGoogle();
    if (!mounted) return;
    if (error == AppController.googleNotEnabled) {
      _showError(context.l10n.t('auth.googleNotEnabled'));
      return;
    }
    if (error != null) {
      _showError(context.l10n.t('auth.googleError'));
      return;
    }
    if (controller.session == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.t('auth.googleRedirect'))),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final controller = ref.watch(appControllerProvider);
    final busy = controller.busy;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(26, 12, 26, 26),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    const Center(child: AppLogo(size: 82)),
                    const SizedBox(height: 18),
                    Center(
                      child: Text(
                        t.t('app.name'),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              letterSpacing: -0.2,
                            ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      t.t('auth.welcomeBack'),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      t.t('auth.loginSub'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.inkSoft,
                          ),
                    ),
                    const SizedBox(height: 26),
                    _FieldLabel(t.t('auth.email')),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      decoration: InputDecoration(
                        hintText: 'you@example.com',
                        prefixIcon: Icon(Icons.mail_outline_rounded,
                            size: 20, color: AppColors.muted),
                        enabled: !busy,
                      ),
                      validator: (value) {
                        final v = value?.trim() ?? '';
                        final ok =
                            RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);
                        return ok ? null : t.t('auth.errEmail');
                      },
                    ),
                    const SizedBox(height: 16),
                    _FieldLabel(t.t('auth.password')),
                    TextFormField(
                      controller: _password,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        prefixIcon: Icon(Icons.lock_outline_rounded,
                            size: 20, color: AppColors.muted),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                            color: AppColors.muted,
                          ),
                        ),
                        enabled: !busy,
                      ),
                      validator: (value) {
                        final v = value ?? '';
                        return v.length >= 6 ? null : t.t('auth.errPassword');
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(t.t('auth.forgotToast'))),
                          );
                        },
                        child: Text(t.t('auth.forgot')),
                      ),
                    ),
                    const SizedBox(height: 4),
                    GradientButton(
                      label: t.t('auth.login'),
                      busy: busy,
                      onPressed: busy ? null : _submit,
                    ),
                    const SizedBox(height: 14),
                    if (controller.isRemote) ...[
                      GoogleSignInButton(
                        key: const Key('login-google'),
                        label: t.t('auth.google'),
                        busy: busy,
                        onPressed: _google,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t.t('auth.googleHint'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          t.t('auth.noAccount'),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        TextButton(
                          onPressed: () => context.go('/signup'),
                          child: Text(t.t('auth.signUp')),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.inkSoft,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
