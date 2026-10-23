import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/app/home_shell.dart';
import 'package:tagarela/design_system/design_system.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    void enter() {
      AppScope.of(context).loadAll();
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeShell()));
    }

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
        const AppTextField(
          label: 'E-mail',
          hint: 'voce@email.com',
          icon: AppIcons.mail,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const AppTextField(
              label: 'Senha',
              hint: 'Sua senha',
              icon: AppIcons.lock,
              obscure: true,
              textInputAction: TextInputAction.done,
            ),
            AppButton(
              label: 'Esqueci minha senha',
              onPressed: () {},
              variant: AppButtonVariant.text,
              size: AppButtonSize.small,
            ),
          ],
        ),
        AppButton(
          label: 'Entrar',
          onPressed: enter,
          size: AppButtonSize.large,
          expand: true,
        ),
        Row(
          spacing: AppSpacing.s3,
          children: [
            const Expanded(child: Divider()),
            Text('ou', style: AppText.bodyMd.copyWith(color: c.inkSoft)),
            const Expanded(child: Divider()),
          ],
        ),
        AppButton(
          label: 'Continuar com Google',
          onPressed: enter,
          leading: Image.asset('assets/images/google.png', width: 20),
          variant: AppButtonVariant.outline,
          size: AppButtonSize.large,
          expand: true,
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
              onPressed: () {},
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
