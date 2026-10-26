import 'package:flutter/material.dart';

import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';

class Skeleton extends StatefulWidget {
  const Skeleton({
    super.key,
    this.width,
    this.height = 14,
    this.radius = AppRadius.xs,
    this.onHeader = false,
  });

  final double? width;
  final double height;
  final double radius;
  final bool onHeader;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(
    vsync: this,
    duration: AppMotion.pulse,
    lowerBound: 0.45,
    value: 1,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse.value = 1;
    } else if (!_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return FadeTransition(
      opacity: _pulse,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: widget.onHeader ? c.headerChip : c.surfaceAlt,
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        ),
      ),
    );
  }
}
