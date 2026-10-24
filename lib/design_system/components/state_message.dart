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
    this.icon,
    this.glyph,
    required this.title,
    required this.message,
    this.accent = AppAccent.violet,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  }) : assert(icon != null || glyph != null);

  final IconData? icon;
  final Widget? glyph;
  final String title;
  final String message;
  final AppAccent accent;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.s3,
        children: [
          IconTile(icon: icon, glyph: glyph, accent: accent, size: 64),
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
              leading: actionIcon == null ? null : Icon(actionIcon),
              variant: AppButtonVariant.tonal,
            ),
        ],
      ),
    );
  }
}
