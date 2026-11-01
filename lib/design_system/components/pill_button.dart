import 'package:flutter/material.dart';

import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';
import 'package:tagarela/design_system/tokens/app_typography.dart';

class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      container: true,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: SizedBox(
          height: AppBubbleSize.touch,
          child: Center(
            child: Container(
              height: AppBubbleSize.sm,
              padding: const EdgeInsets.only(
                left: AppSpacing.s25,
                right: AppSpacing.s3,
              ),
              decoration: BoxDecoration(
                color: c.primarySoft,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: AppSpacing.s15,
                children: [
                  Icon(icon, size: AppIconSize.sm, color: c.primaryText),
                  Text(
                    label,
                    style: AppText.pill.copyWith(color: c.primaryText),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
