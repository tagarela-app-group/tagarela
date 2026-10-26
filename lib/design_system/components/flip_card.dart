import 'dart:math';

import 'package:flutter/material.dart';

import 'package:tagarela/design_system/tokens/app_tokens.dart';

class FlipCard extends StatelessWidget {
  const FlipCard({
    super.key,
    required this.front,
    required this.back,
    required this.flipped,
  });

  final Widget front;
  final Widget back;
  final bool flipped;

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    return AnimatedSize(
      duration: still ? Duration.zero : AppMotion.slow,
      curve: AppMotion.standard,
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: flipped ? 1 : 0),
        duration: still ? Duration.zero : AppMotion.flip,
        curve: AppMotion.standard,
        builder: (context, turn, _) {
          final backVisible = turn > 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(turn * pi),
            child: Stack(
              children: [
                _side(front, visible: !backVisible),
                _side(
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(pi),
                    child: back,
                  ),
                  visible: backVisible,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static Widget _side(Widget child, {required bool visible}) =>
      Visibility(visible: visible, maintainState: true, child: child);
}
