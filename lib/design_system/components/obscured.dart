import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:tagarela/design_system/tokens/app_tokens.dart';

class Obscured extends StatelessWidget {
  const Obscured({super.key, required this.obscured, required this.child});

  final bool obscured;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AppMotion.reveal;
    return ExcludeSemantics(
      excluding: obscured,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: obscured ? 1 : 0),
        duration: duration,
        curve: AppMotion.standard,
        child: child,
        builder: (context, fog, child) => Opacity(
          opacity: 1 - fog * (1 - AppOpacity.obscured),
          child: ImageFiltered(
            enabled: fog > 0,
            imageFilter: ImageFilter.blur(
              sigmaX: AppBlur.obscured * fog,
              sigmaY: AppBlur.obscured * fog,
              tileMode: TileMode.decal,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
