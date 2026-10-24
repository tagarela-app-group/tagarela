import 'package:flutter/material.dart';

import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_colors.dart';

class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    this.icon,
    this.glyph,
    this.accent,
    this.size = 44,
  }) : assert(icon != null || glyph != null);

  final IconData? icon;
  final Widget? glyph;
  final AppAccent? accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (soft, fg) = switch (accent) {
      final accent? => (c.accent(accent).soft, c.accent(accent).fg),
      null => (c.surfaceAlt, c.inkSoft),
    };
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: soft,
        borderRadius: BorderRadius.circular(size / 3),
      ),
      alignment: Alignment.center,
      child: IconTheme(
        data: IconThemeData(size: size / 2, color: fg),
        child: glyph ?? Icon(icon, size: size / 2, color: fg),
      ),
    );
  }
}
