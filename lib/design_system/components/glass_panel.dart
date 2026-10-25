import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';

class GlassPanel extends StatelessWidget {
  const GlassPanel({super.key, required this.child, this.maxWidth = 270});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final radius = BorderRadius.circular(AppRadius.lg);
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: c.cardShadow,
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: AppBlur.glass,
              sigmaY: AppBlur.glass,
            ),
            child: ColoredBox(
              color: c.glassPanel,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s4,
                  18,
                  AppSpacing.s4,
                  AppSpacing.s4,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
