import 'package:flutter/material.dart';

import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/auth/logic/auth_form.dart';
import 'package:tagarela/l10n/l10n.dart';

class SocialButtons extends StatelessWidget {
  const SocialButtons({
    super.key,
    required this.onGoogle,
    required this.onApple,
    this.loading,
  });

  final VoidCallback? onGoogle;
  final VoidCallback? onApple;
  final AuthAction? loading;

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
              context.l10n.or,
              style: AppText.bodyMd.copyWith(color: context.colors.inkSoft),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        AppButton(
          label: context.l10n.continueWithGoogle,
          onPressed: onGoogle,
          leading: Image.asset('assets/images/google.png', width: 20),
          variant: AppButtonVariant.outline,
          size: AppButtonSize.large,
          expand: true,
          loading: loading == AuthAction.google,
        ),
        if (isIos)
          AppButton(
            label: context.l10n.continueWithApple,
            onPressed: onApple,
            leading: const Icon(AppIcons.apple, size: AppIconSize.lg),
            variant: AppButtonVariant.contrast,
            size: AppButtonSize.large,
            expand: true,
            loading: loading == AuthAction.apple,
          ),
      ],
    );
  }
}
