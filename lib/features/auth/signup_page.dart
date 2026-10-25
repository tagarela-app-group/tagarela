import 'package:flutter/material.dart';

import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/auth/auth_form.dart';
import 'package:tagarela/features/auth/widgets/auth_header.dart';
import 'package:tagarela/features/auth/widgets/social_buttons.dart';
import 'package:tagarela/l10n/l10n.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with AuthForm {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  Set<String> get fields => const {'name', 'email', 'password'};

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _signup() {
    final email = _email.text.trim();
    submit(
      () => auth.signup(_name.text.trim(), email, _password.text),
      (result) => onResult(result, email: email),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SheetPage(
      header: AuthHeader(
        title: context.l10n.createAccount,
        subtitle: context.l10n.signupSubtitle,
      ),
      gap: AppSpacing.s4,
      children: [
        AppTextField(
          label: context.l10n.name,
          hint: context.l10n.nameHint,
          icon: AppIcons.profile,
          controller: _name,
          errorText: errors['name'],
          textInputAction: TextInputAction.next,
        ),
        AppTextField(
          label: context.l10n.email,
          hint: context.l10n.emailHint,
          icon: AppIcons.mail,
          controller: _email,
          errorText: errors['email'],
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        AppTextField(
          label: context.l10n.password,
          hint: context.l10n.passwordCreateHint,
          icon: AppIcons.lock,
          controller: _password,
          helperText: context.l10n.passwordHelper,
          errorText: errors['password'],
          obscure: true,
          textInputAction: TextInputAction.done,
        ),
        AppButton(
          label: context.l10n.createAccount,
          onPressed: busy ? null : _signup,
          size: AppButtonSize.large,
          expand: true,
          loading: loading == AuthAction.submit,
        ),
        SocialButtons(
          loading: loading,
          onGoogle: busy
              ? null
              : () => submit(
                  auth.signInWithGoogle,
                  onResult,
                  failure: context.l10n.googleFailed,
                  button: AuthAction.google,
                ),
          onApple: busy
              ? null
              : () => submit(
                  auth.signInWithApple,
                  onResult,
                  failure: context.l10n.appleFailed,
                  button: AuthAction.apple,
                ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.l10n.haveAccount,
              style: AppText.bodyMd.copyWith(color: context.colors.inkSoft),
            ),
            AppButton(
              label: context.l10n.signIn,
              onPressed: () => Navigator.of(context).pop(),
              variant: AppButtonVariant.text,
              size: AppButtonSize.small,
            ),
          ],
        ),
      ],
    );
  }
}
