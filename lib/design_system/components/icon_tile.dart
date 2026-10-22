import 'package:flutter/material.dart';

import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_colors.dart';

/// Ícone sobre quadrado tingido. Grupos, origem de captura, atalhos.
class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.icon,
    required this.accent,
    this.size = 44,
  });

  final IconData icon;
  final AppAccent accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors.accent(accent);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.soft,
        borderRadius: BorderRadius.circular(size / 3),
      ),
      child: Icon(icon, size: size / 2, color: colors.fg),
    );
  }
}
