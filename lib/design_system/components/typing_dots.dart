import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:tagarela/design_system/tokens/app_tokens.dart';

class TypingDots extends StatefulWidget {
  const TypingDots({super.key, required this.color, this.size = 6});

  final Color color;
  final double size;

  @override
  State<TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<TypingDots>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: AppMotion.typing,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Row(
          mainAxisSize: MainAxisSize.min,
          spacing: size * 2 / 3,
          children: [
            for (var i = 0; i < 3; i++)
              () {
                final phase = (_controller.value - i * 0.125) % 1;
                final bump = phase < 0.6
                    ? math.sin(phase / 0.6 * math.pi)
                    : 0.0;
                return Transform.translate(
                  offset: Offset(0, -bump * size * 2 / 3),
                  child: Opacity(
                    opacity: 0.45 + 0.55 * bump,
                    child: SizedBox.square(
                      dimension: size,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: widget.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                );
              }(),
          ],
        ),
      ),
    );
  }
}
