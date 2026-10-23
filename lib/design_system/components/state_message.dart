import 'package:flutter/material.dart';

import 'package:tagarela/design_system/components/app_button.dart';
import 'package:tagarela/design_system/components/icon_tile.dart';
import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_colors.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';
import 'package:tagarela/design_system/tokens/app_typography.dart';

class StateMessage extends StatelessWidget {
  const StateMessage({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.accent = AppAccent.violet,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final AppAccent accent;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s10),
      child: Column(
        spacing: AppSpacing.s3,
        children: [
          IconTile(icon: icon, accent: accent, size: 64),
          Text(title, textAlign: TextAlign.center, style: AppText.titleMd),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppText.bodyMd.copyWith(color: context.colors.inkSoft),
          ),
          if (actionLabel != null)
            AppButton(
              label: actionLabel!,
              onPressed: onAction,
              variant: AppButtonVariant.tonal,
            ),
        ],
      ),
    );
  }
}
