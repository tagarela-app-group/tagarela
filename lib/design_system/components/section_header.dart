import 'package:flutter/material.dart';

import 'package:tagarela/design_system/components/app_button.dart';
import 'package:tagarela/design_system/tokens/app_typography.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppText.titleMd)),
        if (actionLabel != null)
          AppButton(
            label: actionLabel!,
            onPressed: onAction,
            variant: AppButtonVariant.text,
            size: AppButtonSize.small,
          ),
      ],
    );
  }
}
