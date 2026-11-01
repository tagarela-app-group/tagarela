import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:tagarela/design_system/components/drawn_icon.dart';
import 'package:tagarela/design_system/tokens/app_colors.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';

class BubbleMascot extends StatefulWidget {
  const BubbleMascot({
    super.key,
    this.size = AppBubbleSize.hero,
    this.cue = 0,
    this.talking = false,
  });

  final double size;
  final int cue;
  final bool talking;

  @override
  State<BubbleMascot> createState() => _BubbleMascotState();
}

class _BubbleMascotState extends State<BubbleMascot>
    with TickerProviderStateMixin {
  late final _hop = AnimationController(
    vsync: this,
    duration: AppMotion.mascotHop,
  );
  late final _mouth = AnimationController(
    vsync: this,
    duration: AppMotion.mascotTalk,
  );

  bool get _still => MediaQuery.disableAnimationsOf(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMouth();
  }

  @override
  void didUpdateWidget(BubbleMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cue != widget.cue && !_still) _hop.forward(from: 0);
    if (oldWidget.talking != widget.talking) _syncMouth();
  }

  void _syncMouth() {
    if (widget.talking && !_still) {
      if (!_mouth.isAnimating) _mouth.repeat(reverse: true);
    } else {
      _mouth.stop();
    }
  }

  @override
  void dispose() {
    _hop.dispose();
    _mouth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: Listenable.merge([_hop, _mouth]),
        builder: (context, child) {
          final t = _hop.value;
          final jump = math.sin(math.pi * t);
          final squash = math.sin(2 * math.pi * t) * 0.1;
          return Transform.translate(
            offset: Offset(0, -widget.size * 0.2 * jump),
            child: Transform.rotate(
              angle: -0.18 * math.sin(2 * math.pi * t),
              child: Transform.scale(
                scaleX: 1 + squash,
                scaleY: 1 - squash,
                alignment: Alignment.bottomCenter,
                child: CustomPaint(
                  foregroundPainter: _FacePainter(
                    blink: t > 0.3 && t < 0.5,
                    talking: widget.talking && !_still,
                    mouth: _mouth.value,
                  ),
                  child: child,
                ),
              ),
            ),
          );
        },
        child: DrawnIcon(
          DrawnGlyph.bubble,
          size: widget.size,
          color: AppPalette.mango,
        ),
      ),
    );
  }
}

class _FacePainter extends CustomPainter {
  const _FacePainter({
    required this.blink,
    required this.talking,
    required this.mouth,
  });

  final bool blink;
  final bool talking;
  final double mouth;

  static const _grid = 24.0;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / _grid);
    final paint = Paint()..color = AppPalette.ink;
    final eye = blink ? 0.3 : 3.1;
    for (final x in const [8.9, 13.7]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, 9.9), width: 2.3, height: eye),
        paint,
      );
    }
    if (talking) {
      canvas.drawOval(
        Rect.fromCenter(
          center: const Offset(11.2, 14),
          width: 3,
          height: 0.8 + 2.2 * mouth,
        ),
        paint,
      );
      return;
    }
    canvas.drawPath(
      Path()
        ..moveTo(8.8, 13.3)
        ..quadraticBezierTo(11.2, 15.6, 13.6, 13.3),
      Paint()
        ..color = AppPalette.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.15
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_FacePainter old) =>
      old.blink != blink || old.talking != talking || old.mouth != mouth;
}
