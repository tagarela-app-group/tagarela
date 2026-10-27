import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';
import 'package:tagarela/design_system/tokens/app_typography.dart';

enum LetterTileState { empty, active, filled, help, wrong, done }

class LetterTile extends StatefulWidget {
  const LetterTile({
    super.key,
    required this.letter,
    required this.state,
    this.width = 24,
    this.height = 34,
    this.delay = Duration.zero,
  });

  final String letter;
  final LetterTileState state;
  final double width;
  final double height;
  final Duration delay;

  @override
  State<LetterTile> createState() => _LetterTileState();
}

class _LetterTileState extends State<LetterTile>
    with SingleTickerProviderStateMixin {
  static const _bounce = Duration(milliseconds: 420);

  late final _controller = AnimationController(
    vsync: this,
    duration: widget.delay + _bounce,
  );

  @override
  void didUpdateWidget(LetterTile old) {
    super.didUpdateWidget(old);
    final moved = widget.state != old.state;
    final bounces =
        widget.state == LetterTileState.wrong ||
        widget.state == LetterTileState.done;
    if (moved && bounces && !MediaQuery.disableAnimationsOf(context)) {
      _controller.forward(from: 0);
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
    final (bg, fg, ring) = switch (widget.state) {
      LetterTileState.empty => (c.surfaceAlt, c.ink, null),
      LetterTileState.active => (c.surfaceAlt, c.ink, c.primary),
      LetterTileState.filled => (c.primarySoft, c.primaryText, null),
      LetterTileState.help => (c.learningSoft, c.learningText, null),
      LetterTileState.wrong => (c.surface, c.alert, c.alert),
      LetterTileState.done => (c.primary, c.onPrimary, null),
    };
    final start =
        widget.delay.inMicroseconds / _controller.duration!.inMicroseconds;
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, 1),
    );
    return AnimatedBuilder(
      animation: curve,
      builder: (context, child) {
        final t = curve.value;
        final wave = t == 0 || t == 1 ? 0.0 : math.sin(t * math.pi);
        final transform = widget.state == LetterTileState.wrong
            ? Matrix4.translationValues(
                math.sin(t * math.pi * 4) * 4 * (1 - t),
                0,
                0,
              )
            : (Matrix4.translationValues(0, -5 * wave, 0)..multiply(
                Matrix4.diagonal3Values(1 + 0.18 * wave, 1 + 0.18 * wave, 1),
              ));
        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: child,
        );
      },
      child: AnimatedContainer(
        duration: AppMotion.base,
        width: widget.width,
        height: widget.height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.xs),
          border: Border.all(
            color: ring ?? Colors.transparent,
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          boxShadow: widget.state == LetterTileState.done
              ? c.buttonShadow
              : null,
        ),
        child: Text(
          widget.letter,
          style: AppText.titleMd.copyWith(
            fontSize: widget.height * 0.6,
            height: 1,
            fontWeight: FontWeight.w800,
            color: fg,
          ),
        ),
      ),
    );
  }
}
