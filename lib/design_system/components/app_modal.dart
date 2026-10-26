import 'package:flutter/material.dart';

import 'package:tagarela/design_system/components/app_icon_button.dart';
import 'package:tagarela/design_system/components/icon_tile.dart';
import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_colors.dart';
import 'package:tagarela/design_system/tokens/app_icons.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';
import 'package:tagarela/design_system/tokens/app_typography.dart';
import 'package:tagarela/l10n/l10n.dart';

class AppModal extends StatelessWidget {
  const AppModal({
    super.key,
    this.icon,
    this.accent,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData? icon;
  final AppAccent? accent;
  final String title;
  final String subtitle;
  final Widget child;

  static Future<T?> show<T>(BuildContext context, WidgetBuilder builder) =>
      showModalBottomSheet<T>(
        context: context,
        builder: builder,
        isScrollControlled: true,
        useRootNavigator: true,
        backgroundColor: Colors.transparent,
        barrierColor: context.colors.scrim,
        elevation: 0,
      );

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final media = MediaQuery.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s5,
        AppSpacing.s2,
        AppSpacing.s5,
        AppSpacing.s5 + media.viewPadding.bottom + media.viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.s4,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: c.line,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
          Row(
            spacing: AppSpacing.s3,
            children: [
              if (icon != null) IconTile(icon: icon, accent: accent),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(title, style: AppText.titleMd),
                    ),
                    Text(
                      subtitle,
                      style: AppText.bodyMd.copyWith(color: c.inkSoft),
                    ),
                  ],
                ),
              ),
              AppIconButton(
                icon: AppIcons.close,
                tooltip: context.l10n.close,
                variant: AppIconButtonVariant.soft,
                onPressed: () => Navigator.maybePop(context),
              ),
            ],
          ),
          Flexible(child: SingleChildScrollView(child: child)),
        ],
      ),
    );
  }
}
