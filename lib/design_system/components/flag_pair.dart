import 'package:flutter/material.dart';

import 'package:tagarela/design_system/components/flag_badge.dart';
import 'package:tagarela/design_system/theme.dart';

class FlagPair extends StatelessWidget {
  const FlagPair({
    super.key,
    required this.back,
    required this.front,
    this.size = 48,
  });

  final String back;
  final String front;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 7 / 6,
      height: size,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: FlagBadge(country: back, size: size * 0.625),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: FlagBadge(
              country: front,
              size: size * 0.8,
              ring: context.colors.surface,
            ),
          ),
        ],
      ),
    );
  }
}
