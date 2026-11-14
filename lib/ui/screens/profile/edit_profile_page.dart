import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/models.dart';
import '../../../state/app_controller.dart';
import '../../widgets/common.dart';
import '../shell/app_shell.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  static const _avatars = ['🌤️', '🌱', '🍋', '🌊', '🍓', '🌙', '🧘', '🥑'];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late String _avatar;
  late String _photo;
  bool _saving = false;
  bool _picking = false;

  @override
  void initState() {
    super.initState();
    final controller = ref.read(appControllerProvider);
    final profile = controller.profile;
    _name = TextEditingController(
      text: profile?.name ?? controller.session?.name ?? '',
    );
    _email = TextEditingController(
      text: profile?.email ?? controller.session?.email ?? '',
    );
    _avatar = profile?.avatar ?? '🌤️';
    _photo = profile?.photo ?? '';
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    setState(() => _picking = true);
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (bytes.length > 2 * 1024 * 1024) {
        if (mounted) Toast.show(context, context.l10n.t('profile.photoTooBig'));
        return;
      }
      final encoded = base64Encode(bytes);
      if (mounted) setState(() => _photo = encoded);
    } catch (_) {
      if (mounted) Toast.show(context, context.l10n.t('profile.photoError'));
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    final controller = ref.read(appControllerProvider);
    final current = controller.profile ??
        UserProfile(
          name: controller.session?.name ?? '',
          email: controller.session?.email ?? '',
        );
    final next = current.copyWith(
      name: _name.text.trim(),
      // Never take the editable field as the identity key.
      email: controller.session?.email ?? current.email,
      avatar: _avatar,
      photo: _photo,
    );
    final error = await controller.updateProfile(next);
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      Toast.show(context, error);
      return;
    }
    HapticFeedback.lightImpact();
    // A deep link can open this page without anything underneath it, in which
    // case pop() would throw instead of taking the user back to their profile.
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/profile');
    }
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
              title: t.t('profile.edit'),
              subtitle: t.t('profile.detailsSub'),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppColors.isDark
                              ? [AppColors.surface, AppColors.surfaceAlt]
                              : const [Color(0xFFFFEBDD), Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color:
                              AppColors.isDark ? AppColors.line : Colors.white,
                          width: 1.4,
                        ),
                      ),
                      child: Column(
                        children: [
                          ProfileAvatar(
                            profile: UserProfile(
                              name: _name.text,
                              email: _email.text,
                              avatar: _avatar,
                              photo: _photo,
                            ),
                            size: 88,
                            borderWidth: 3,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            alignment: WrapAlignment.center,
                            children: [
                              OutlinedButton.icon(
                                key: const Key('profile-photo-pick'),
                                onPressed:
                                    _picking || _saving ? null : _pickPhoto,
                                icon: _picking
                                    ? const SizedBox(
                                        width: 15,
                                        height: 15,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : const Icon(Icons.add_a_photo_outlined,
                                        size: 16),
                                label: Text(
                                  _photo.isEmpty
                                      ? t.t('profile.addPhoto')
                                      : t.t('profile.changePhoto'),
                                ),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 40),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  textStyle:
                                      Theme.of(context).textTheme.labelMedium,
                                ),
                              ),
                              if (_photo.isNotEmpty)
                                TextButton.icon(
                                  key: const Key('profile-photo-remove'),
                                  onPressed: _saving
                                      ? null
                                      : () {
                                          HapticFeedback.selectionClick();
                                          setState(() => _photo = '');
                                        },
                                  icon: const Icon(Icons.delete_outline_rounded,
                                      size: 16),
                                  label: Text(t.t('profile.removePhoto')),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.rose,
                                    minimumSize: const Size(0, 40),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _photo.isEmpty
                                ? t.t('profile.avatar')
                                : t.t('profile.photoHint'),
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: AppColors.muted),
                          ),
                          if (_photo.isEmpty) ...[
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              alignment: WrapAlignment.center,
                              children: [
                                for (final avatar in _avatars)
                                  GestureDetector(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(() => _avatar = avatar);
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 160),
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        color: _avatar == avatar
                                            ? AppColors.peach
                                            : AppColors.surface,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: _avatar == avatar
                                              ? AppColors.orange
                                              : AppColors.line,
                                          width: _avatar == avatar ? 1.8 : 1,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        avatar,
                                        style: const TextStyle(fontSize: 21),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _FieldLabel(t.t('profile.editName')),
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      enabled: !_saving,
                      decoration: InputDecoration(
                        hintText: 'Cameron Wilson',
                        prefixIcon: Icon(Icons.person_outline_rounded,
                            size: 20, color: AppColors.muted),
                      ),
                      validator: (value) {
                        final v = value?.trim() ?? '';
                        return v.isEmpty ? t.t('auth.errName') : null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _FieldLabel(t.t('profile.editEmail')),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      // The email is the account key in Supabase and in the
                      // on-device store. Editing it here only desynced the
                      // profile from the sign-in identity, so it is read-only.
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'you@example.com',
                        helperText: t.t('profile.emailLocked'),
                        prefixIcon: Icon(Icons.mail_outline_rounded,
                            size: 20, color: AppColors.muted),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lock_outline_rounded,
                            size: 15, color: AppColors.muted),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            t.t('settings.data'),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: AppColors.muted),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: GradientButton(
                label: t.t('common.save'),
                busy: _saving,
                icon: Icons.check_rounded,
                onPressed: _saving ? null : _save,
              ),
            ),
          ],
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
