import 'package:flutter/material.dart';

import 'package:tagarela/design_system/design_system.dart';

typedef CardAction = (String label, VoidCallback? onPressed);

class CaptureActions extends StatelessWidget {
  const CaptureActions({super.key, this.secondary, this.primary});

  final CardAction? secondary;
  final CardAction? primary;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: AppSpacing.s2,
      children: [
        if (secondary case (final label, final onPressed))
          Expanded(
            child: AppButton(
              label: label,
              onPressed: onPressed,
              variant: AppButtonVariant.outline,
              size: AppButtonSize.small,
              expand: true,
            ),
          ),
        if (primary case (final label, final onPressed))
          Expanded(
            child: AppButton(
              label: label,
              onPressed: onPressed,
              size: AppButtonSize.small,
              expand: true,
            ),
          ),
      ],
    );
  }
}
