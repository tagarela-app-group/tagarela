import 'package:flutter/material.dart';

import 'package:tagarela/design_system/components/app_button.dart';
import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_typography.dart';

class TextLinkRow extends StatelessWidget {
  const TextLinkRow({
    super.key,
    required this.text,
    required this.link,
    required this.onPressed,
  });

  final String text;
  final String link;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: AppText.bodyMd.copyWith(color: context.colors.inkSoft),
        ),
        AppButton(
          label: link,
          onPressed: onPressed,
          variant: AppButtonVariant.text,
          size: AppButtonSize.small,
        ),
      ],
    );
  }
}
