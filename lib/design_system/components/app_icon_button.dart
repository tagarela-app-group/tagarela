import 'package:flutter/material.dart';

import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_colors.dart';

enum AppIconButtonVariant { onHeader, ink, primary, ghost }

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.variant = AppIconButtonVariant.ghost,
    this.size = 44,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final AppIconButtonVariant variant;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (bg, fg) = switch (variant) {
      AppIconButtonVariant.onHeader => (c.headerChip, AppPalette.white),
      AppIconButtonVariant.ink => (AppPalette.ink, AppPalette.mango),
      AppIconButtonVariant.primary => (c.primary, c.onPrimary),
      AppIconButtonVariant.ghost => (Colors.transparent, c.inkSoft),
    };

    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon),
      iconSize: size * 0.5,
      style: IconButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        fixedSize: Size.square(size),
        minimumSize: Size.square(size),
        padding: EdgeInsets.zero,
        shape: const CircleBorder(),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
