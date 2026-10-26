import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:tagarela/design_system/components/speech_bubble_icon.dart';
import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';

class BubbleBurst extends StatefulWidget {
  const BubbleBurst({super.key, this.count = 8, this.distance = 100});

  final int count;
  final double distance;

  @override
  State<BubbleBurst> createState() => _BubbleBurstState();
}

class _BubbleBurstState extends State<BubbleBurst>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: AppMotion.burst,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller.isDismissed && !MediaQuery.disableAnimationsOf(context)) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return IgnorePointer(
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            if (t == 0 || t == 1) return const SizedBox.shrink();
            final travel = AppMotion.standard.transform(t);
            final opacity = t < 0.2 ? t / 0.2 : 1 - (t - 0.2) / 0.8;
            return Center(
              child: SizedBox.square(
                dimension: 0,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (var i = 0; i < widget.count; i++)
                      _piece(i, travel, opacity, c.primary, c.primaryText),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _piece(
    int i,
    double travel,
    double opacity,
    Color primary,
    Color primaryText,
  ) {
    final angle = i * 2 * math.pi / widget.count - math.pi / 2;
    final reach = widget.distance * (i.isEven ? 1 : 0.8) * travel;
    final bubble = i.isEven;
    final size = bubble ? 20.0 : 12.0;
    return Positioned(
      left: math.cos(angle) * reach - size / 2,
      top: math.sin(angle) * reach - size / 2,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Transform.scale(
          scale: 0.3 + 0.7 * travel,
          child: bubble
              ? SpeechBubbleIcon(
                  size: size,
                  color: i % 4 == 0 ? primaryText : primary,
                )
              : Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                  ),
                ),
        ),
      ),
    );
  }
}
