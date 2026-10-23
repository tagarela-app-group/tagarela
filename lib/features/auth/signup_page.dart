import 'package:flutter/material.dart';

import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/auth/auth_form.dart';
import 'package:tagarela/features/auth/widgets/auth_header.dart';
import 'package:tagarela/features/auth/widgets/social_buttons.dart';

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
      header: const AuthHeader(
        title: 'Criar conta',
        subtitle: 'Seu vocabulário salvo em qualquer celular.',
      ),
      gap: AppSpacing.s4,
      children: [
        AppTextField(
          label: 'Nome',
          hint: 'Como quer ser chamado',
          icon: AppIcons.profile,
          controller: _name,
          errorText: errors['name'],
          textInputAction: TextInputAction.next,
        ),
        AppTextField(
          label: 'E-mail',
          hint: 'voce@email.com',
          icon: AppIcons.mail,
          controller: _email,
          errorText: errors['email'],
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        AppTextField(
          label: 'Senha',
          hint: 'Crie uma senha',
          icon: AppIcons.lock,
          controller: _password,
          helperText: 'Mínimo de 8 caracteres.',
          errorText: errors['password'],
          obscure: true,
          textInputAction: TextInputAction.done,
        ),
        AppButton(
          label: 'Criar conta',
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
                  failure: 'Não deu pra entrar com o Google. Tente de novo.',
                  button: AuthAction.google,
                ),
          onApple: busy
              ? null
              : () => submit(
                  auth.signInWithApple,
                  onResult,
                  failure: 'Não deu pra entrar com a Apple. Tente de novo.',
                  button: AuthAction.apple,
                ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Já tem conta?',
              style: AppText.bodyMd.copyWith(color: context.colors.inkSoft),
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
