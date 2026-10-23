import 'package:flutter/material.dart';

import 'package:tagarela/design_system/design_system.dart';

class SocialButtons extends StatelessWidget {
  const SocialButtons({
    super.key,
    required this.onGoogle,
    required this.onApple,
  });

  final VoidCallback? onGoogle;
  final VoidCallback? onApple;

  @override
  Widget build(BuildContext context) {
    final isIos = Theme.of(context).platform == TargetPlatform.iOS;

    return Column(
      spacing: AppSpacing.s4,
      children: [
        Row(
          spacing: AppSpacing.s3,
          children: [
            const Expanded(child: Divider()),
            Text(
              'ou',
              style: AppText.bodyMd.copyWith(color: context.colors.inkSoft),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        AppButton(
          label: 'Continuar com Google',
          onPressed: onGoogle,
          leading: Image.asset('assets/images/google.png', width: 20),
          variant: AppButtonVariant.outline,
          size: AppButtonSize.large,
          expand: true,
        ),
        if (isIos)
          AppButton(
            label: 'Continuar com a Apple',
            onPressed: onApple,
            leading: const Icon(AppIcons.apple, size: 20),
            variant: AppButtonVariant.contrast,
            size: AppButtonSize.large,
            expand: true,
          ),
      ],
    );
  }
}
