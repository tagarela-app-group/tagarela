import 'package:flutter/material.dart';

import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';

class Segment {
  const Segment(this.value, this.color);

  final num value;
  final Color color;
}

class SegmentBar extends StatelessWidget {
  const SegmentBar({
    super.key,
    required this.segments,
    this.total,
    this.height = 8,
    this.gap = 4,
    this.semanticLabel,
  });

  final List<Segment> segments;
  final num? total;
  final double height;
  final double gap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final sum = segments.fold<num>(0, (acc, s) => acc + s.value);
    final fraction = total == null || total == 0
        ? 1.0
        : (sum / total!).clamp(0.0, 1.0).toDouble();
    final radius = BorderRadius.circular(AppRadius.pill);

    return Semantics(
      label: semanticLabel,
      child: Container(
        height: height,
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: total == null ? null : context.colors.surfaceAlt,
          borderRadius: radius,
        ),
        child: FractionallySizedBox(
          widthFactor: fraction,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: gap,
            children: [
              for (final s in segments)
                if (s.value > 0)
                  Expanded(
                    flex: (s.value * 100).round(),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: s.color,
                        borderRadius: radius,
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
