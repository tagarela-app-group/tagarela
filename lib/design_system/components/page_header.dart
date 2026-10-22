import 'package:flutter/material.dart';

import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_colors.dart';
import 'package:tagarela/design_system/tokens/app_typography.dart';

/// Título + subtítulo para o header do `SheetPage`.
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 14,
      children: [
        ?leading,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppText.titleLg.copyWith(color: AppPalette.white),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: AppText.bodyMd.copyWith(
                    color: context.colors.onHeaderSoft,
                  ),
                ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}
