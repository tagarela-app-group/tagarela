import 'package:flutter/material.dart';

import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/auth/auth_form.dart';
import 'package:tagarela/features/auth/forgot_password_page.dart';
import 'package:tagarela/features/auth/signup_page.dart';
import 'package:tagarela/features/auth/widgets/social_buttons.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with AuthForm {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  Set<String> get fields => const {'email', 'password'};

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _login() {
    final email = _email.text.trim();
    submit(
      () => auth.login(email, _password.text),
      (result) => onResult(result, email: email),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return SheetPage(
      header: const _LoginHeader(),
      gap: AppSpacing.s4,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Entrar', style: AppText.titleLg),
            Text(
              'Que bom te ver de novo.',
              style: AppText.bodyLg.copyWith(color: c.inkSoft),
            ),
          ],
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            AppTextField(
              label: 'Senha',
              hint: 'Sua senha',
              icon: AppIcons.lock,
              controller: _password,
              errorText: errors['password'],
              obscure: true,
              textInputAction: TextInputAction.done,
            ),
            AppButton(
              label: 'Esqueci minha senha',
              onPressed: () =>
                  push(ForgotPasswordPage(email: _email.text.trim())),
              variant: AppButtonVariant.text,
              size: AppButtonSize.small,
            ),
          ],
        ),
        AppButton(
          label: 'Entrar',
          onPressed: busy ? null : _login,
          size: AppButtonSize.large,
          expand: true,
        ),
        SocialButtons(
          onGoogle: busy
              ? null
              : () => submit(
                  auth.signInWithGoogle,
                  onResult,
                  failure: 'Não deu pra entrar com o Google. Tente de novo.',
                ),
          onApple: busy
              ? null
              : () => submit(
                  auth.signInWithApple,
                  onResult,
                  failure: 'Não deu pra entrar com a Apple. Tente de novo.',
                ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Novo por aqui?',
              style: AppText.bodyMd.copyWith(color: c.inkSoft),
            ),
            AppButton(
              label: 'Criar conta',
              onPressed: () => push(const SignupPage()),
              variant: AppButtonVariant.text,
              size: AppButtonSize.small,
            ),
          ],
        ),
      ],
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const SizedBox(width: double.infinity),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.s6),
            const AppBubble(
              size: 64,
              child: Text('t', style: TextStyle(fontSize: 38)),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              'tagarela',
              style: AppText.statLg.copyWith(color: AppPalette.white),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 230,
              child: Text(
                'Inglês de verdade, tirado das conversas do seu dia.',
                style: AppText.bodyLg.copyWith(
                  color: context.colors.onHeaderSoft,
                ),
              ),
            ),
          ],
        ),
        const Positioned(
          top: 0,
          right: 4,
          child: _TalkChip("what's up?", turns: 0.011),
        ),
        const Positioned(
          top: 48,
          right: 84,
          child: _TalkChip('break the ice', turns: -0.017, filled: true),
        ),
        const Positioned(
          bottom: 20,
          right: 8,
          child: _TalkChip('cheers!', turns: -0.008),
        ),
      ],
    );
  }
}

class _TalkChip extends StatelessWidget {
  const _TalkChip(this.text, {required this.turns, this.filled = false});

  final String text;
  final double turns;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: RotationTransition(
        turns: AlwaysStoppedAnimation(turns),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: filled ? AppPalette.mango : context.colors.headerChip,
            borderRadius: AppRadius.bubble(16),
          ),
          child: Text(
            text,
            style: AppText.label.copyWith(
              fontSize: 14,
              color: filled ? AppPalette.ink : AppPalette.white,
            ),
          ),
        ),
      ),
    );
  }
}
