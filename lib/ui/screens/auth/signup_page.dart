import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../state/app_controller.dart';
import '../../widgets/common.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final error = await ref.read(appControllerProvider).signUp(
          _name.text,
          _email.text,
          _password.text,
        );
    if (!mounted) return;
    if (error == AppController.needsEmailConfirmation) {
      final t = context.l10n;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(t.t('auth.confirmEmailTitle')),
          content: Text(t.t('auth.confirmEmail')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(t.t('common.done')),
            ),
          ],
        ),
      );
      if (!mounted) return;
      context.go('/login');
      return;
    }
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _google() async {
    final controller = ref.read(appControllerProvider);
    if (!controller.isRemote) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.t('auth.googleNeedsBackend'))),
      );
      return;
    }
    final error = await controller.signInWithGoogle();
    if (!mounted) return;
    if (error == AppController.googleNotEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.t('auth.googleNotEnabled'))),
      );
      return;
    }
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.t('auth.googleError'))),
      );
      return;
    }
    if (controller.session == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.t('auth.googleRedirect'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final controller = ref.watch(appControllerProvider);
    final busy = controller.busy;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 8, 26, 26),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const BackHeader(title: ''),
                    const SizedBox(height: 6),
                    Text(
                      t.t('auth.createTitle'),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      t.t('auth.createSub'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.inkSoft,
                          ),
                    ),
                    const SizedBox(height: 26),
                    TextFormField(
                      controller: _name,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: t.t('auth.name'),
                        prefixIcon: Icon(Icons.person_outline_rounded,
                            size: 20, color: AppColors.muted),
                        enabled: !busy,
                      ),
                      validator: (value) => (value?.trim().isNotEmpty ?? false)
                          ? null
                          : t.t('auth.errName'),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: t.t('auth.email'),
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
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _password,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        hintText: t.t('auth.password'),
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
                    const SizedBox(height: 26),
                    GradientButton(
                      label: t.t('auth.signUp'),
                      busy: busy,
                      onPressed: busy ? null : _submit,
                    ),
                    const SizedBox(height: 14),
                    if (controller.isRemote) ...[
                      GoogleSignInButton(
                        key: const Key('signup-google'),
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
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          t.t('auth.haveAccount'),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: Text(t.t('auth.login')),
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
