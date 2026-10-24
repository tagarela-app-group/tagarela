import 'package:flutter/material.dart';

import 'package:tagarela/design_system/components/app_tab_bar.dart';
import 'package:tagarela/design_system/components/arc_menu.dart';
import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_colors.dart';
import 'package:tagarela/design_system/tokens/app_icons.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';
import 'package:tagarela/design_system/tokens/app_typography.dart';

abstract final class AppToast {
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
    bool aboveTabBar = false,
  }) {
    final c = context.colors;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          persist: false,
          margin: EdgeInsets.fromLTRB(
            AppSpacing.s4,
            0,
            AppSpacing.s4,
            (aboveTabBar ? AppTabBar.height + ArcMenu.overhang : 0) +
                AppSpacing.s4,
          ),
          content: Row(
            spacing: AppSpacing.s3,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: c.mastered,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  AppIcons.check,
                  size: 18,
                  color: AppPalette.white,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppText.button),
                    Text(
                      message,
                      style: AppText.label.copyWith(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          action: SnackBarAction(label: actionLabel, onPressed: onAction),
        ),
      );
  }
}
