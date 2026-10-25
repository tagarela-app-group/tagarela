import 'package:flutter/material.dart';

import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_colors.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';
import 'package:tagarela/design_system/tokens/app_typography.dart';

class HeaderPill extends StatelessWidget {
  const HeaderPill({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.height = 44,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.s3),
  });

  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final double height;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final content = SizedBox(
      height: height,
      child: Padding(
        padding: padding,
        child: IconTheme.merge(
          data: const IconThemeData(color: AppPalette.white, size: 16),
          child: DefaultTextStyle.merge(
            style: AppText.pill.copyWith(color: AppPalette.white),
            child: Row(mainAxisSize: MainAxisSize.min, children: [child]),
          ),
        ),
      ),
    );
    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      excludeSemantics: semanticLabel != null,
      child: Material(
        color: context.colors.headerChip,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: onTap == null ? content : InkWell(onTap: onTap, child: content),
      ),
    );
  }
}
