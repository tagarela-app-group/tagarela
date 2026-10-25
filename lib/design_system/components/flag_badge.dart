import 'dart:math' as math;

import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';

class FlagBadge extends StatelessWidget {
  const FlagBadge({
    super.key,
    required this.country,
    this.size = 24,
    this.ring,
    this.semanticLabel,
  });

  final String country;
  final double size;
  final Color? ring;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final ringWidth = ring == null ? 0.0 : math.max(2.0, size * 0.08);
    final inner = size - ringWidth * 2;
    return Semantics(
      label: semanticLabel,
      image: semanticLabel != null,
      excludeSemantics: true,
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(ringWidth),
        decoration: BoxDecoration(color: ring, shape: BoxShape.circle),
        child: CountryFlag.fromCountryCode(
          country,
          theme: ImageTheme(shape: const Circle(), width: inner, height: inner),
        ),
      ),
    );
  }
}
