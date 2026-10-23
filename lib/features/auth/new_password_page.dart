import 'package:flutter/material.dart';

import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/auth/auth_form.dart';
import 'package:tagarela/features/auth/widgets/auth_header.dart';

class NewPasswordPage extends StatefulWidget {
  const NewPasswordPage({
    super.key,
    required this.code,
    required this.sessionToken,
  });

  final String code;
  final String sessionToken;

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> with AuthForm {
  final _password = TextEditingController();

  @override
  Set<String> get fields => const {'password'};

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SheetPage(
      header: const AuthHeader(title: 'Nova senha', subtitle: 'Última etapa.'),
      gap: AppSpacing.s4,
      children: [
        Text(
          'Crie uma senha nova pra sua conta. Depois de salvar, você já '
          'entra no app.',
          style: AppText.bodyLg.copyWith(color: context.colors.inkSoft),
        ),
        AppTextField(
          label: 'Nova senha',
          hint: 'Sua senha nova',
          icon: AppIcons.lock,
          controller: _password,
          helperText: 'Mínimo de 8 caracteres. Evite só números.',
          errorText: errors['password'],
          obscure: true,
          textInputAction: TextInputAction.done,
        ),
        AppButton(
          label: 'Salvar e entrar',
          onPressed: busy
              ? null
              : () => submit(
                  () => auth.resetPassword(
                    widget.code,
                    _password.text,
                    widget.sessionToken,
                  ),
                  onResult,
                ),
          size: AppButtonSize.large,
          expand: true,
        ),
      ],
    );
  }
}
