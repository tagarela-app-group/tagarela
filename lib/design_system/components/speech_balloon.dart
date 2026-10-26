import 'package:flutter/material.dart';

import 'package:tagarela/design_system/tokens/app_tokens.dart';

class SpeechBalloon extends StatelessWidget {
  const SpeechBalloon({
    super.key,
    required this.child,
    required this.color,
    this.mirrored = false,
    this.radius = AppRadius.lg,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: AppSpacing.s3,
    ),
    this.ring,
    this.shadow,
  });

  final Widget child;
  final Color color;
  final bool mirrored;
  final double radius;
  final EdgeInsetsGeometry padding;
  final Color? ring;
  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.base,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.bubble(radius, mirrored: mirrored),
        border: Border.all(
          color: ring ?? Colors.transparent,
          width: 2,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        boxShadow: shadow,
      ),
      child: child,
    );
  }
}
