import 'package:flutter/material.dart';

import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/auth/auth_form.dart';
import 'package:tagarela/features/auth/widgets/auth_header.dart';

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

    return SheetPage(
      header: const AuthHeader(
        title: 'Esqueceu a senha?',
        subtitle: 'Acontece. A gente te ajuda.',
      ),
      gap: AppSpacing.s4,
      children: [
        Text(
          'Digite o e-mail da sua conta. Enviamos um código pra você criar '
          'uma senha nova.',
          style: AppText.bodyLg.copyWith(color: c.inkSoft),
        ),
        AppTextField(
          label: 'E-mail',
          hint: 'voce@email.com',
          icon: AppIcons.mail,
          controller: _email,
          errorText: errors['email'],
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
        ),
        AppButton(
          label: 'Enviar código',
          onPressed: busy ? null : _send,
          loading: busy,
          size: AppButtonSize.large,
          expand: true,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Lembrou a senha?',
              style: AppText.bodyMd.copyWith(color: c.inkSoft),
            ),
            AppButton(
              label: 'Entrar',
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
