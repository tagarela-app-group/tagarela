import 'package:flutter/material.dart';

import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.color,
    this.padding = const EdgeInsets.all(AppSpacing.s4),
    this.radius = AppRadius.lg,
    this.muted = false,
    this.selected = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final double radius;

  final bool muted;

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final borderRadius = BorderRadius.circular(radius);
    final content = Padding(padding: padding, child: child);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: color == null && !muted && !selected ? c.cardShadow : null,
      ),
      child: Material(
        color: muted ? Colors.transparent : color ?? c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: selected
              ? BorderSide(color: c.primary, width: 2)
              : muted
              ? BorderSide(color: c.line, width: 1.5)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: onTap == null && onLongPress == null
            ? content
            : InkWell(onTap: onTap, onLongPress: onLongPress, child: content),
      ),
    );
  }
}
