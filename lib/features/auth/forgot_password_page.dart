import 'package:flutter/material.dart';

import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/auth/logic/auth_form.dart';
import 'package:tagarela/features/auth/widgets/auth_header.dart';
import 'package:tagarela/features/auth/widgets/email_field.dart';
import 'package:tagarela/l10n/l10n.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key, this.email = ''});

  final String email;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> with AuthForm {
  late final _email = TextEditingController(text: widget.email);

  @override
  Set<String> get fields => const {'email'};

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _send() {
    final email = _email.text.trim();
    submit(
      () => auth.requestPasswordReset(email),
      (result) => onResult(result, email: email),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return AppPage(
      header: AuthHeader(
        title: context.l10n.forgotTitle,
        subtitle: context.l10n.forgotSubtitle,
      ),
      gap: AppSpacing.s4,
      children: [
        Text(
          context.l10n.forgotBody,
          style: AppText.bodyLg.copyWith(color: c.inkSoft),
        ),
        EmailField(
          controller: _email,
          errorText: errors['email'],
          textInputAction: TextInputAction.done,
        ),
        AppButton(
          label: context.l10n.sendCode,
          onPressed: busy ? null : _send,
          loading: busy,
          size: AppButtonSize.large,
          expand: true,
        ),
        TextLinkRow(
          text: context.l10n.rememberedPassword,
          link: context.l10n.signIn,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
