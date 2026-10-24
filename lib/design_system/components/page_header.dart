import 'package:flutter/material.dart';

import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_colors.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';
import 'package:tagarela/design_system/tokens/app_typography.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.centered = false,
  }) : assert(!centered || trailing == null);

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;

  final bool centered;

  @override
  Widget build(BuildContext context) {
    final align = centered ? TextAlign.center : null;
    final texts = Column(
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: align,
          style: AppText.titleLg.copyWith(color: AppPalette.white),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            textAlign: align,
            style: AppText.bodyMd.copyWith(color: context.colors.onHeaderSoft),
          ),
      ],
    );
    if (centered) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.s3,
        children: [
          if (leading != null) Center(child: leading),
          texts,
        ],
      );
    }
    return Row(
      spacing: 14,
      children: [
        ?leading,
        Expanded(child: texts),
        ?trailing,
      ],
    );
  }
}
