import 'package:flutter/material.dart';

enum DrawnGlyph {
  turtle,
  sandal,
  tie,
  bubble(filled: true);

  const DrawnGlyph({this.filled = false});

  final bool filled;
}

class DrawnIcon extends StatelessWidget {
  const DrawnIcon(this.glyph, {super.key, this.size, this.color});

  final DrawnGlyph glyph;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    return SizedBox.square(
      dimension: size ?? theme.size ?? 24,
      child: CustomPaint(
        painter: _GlyphPainter(
          _paths[glyph]!,
          color ?? theme.color ?? Colors.black,
          filled: glyph.filled,
        ),
      ),
    );
  }

  static final _paths = {
    DrawnGlyph.bubble: Path()
      ..moveTo(21, 11.5)
      ..arcToPoint(const Offset(12, 19.9), radius: const Radius.circular(8.4))
      ..arcToPoint(const Offset(8, 19), radius: const Radius.circular(9))
      ..lineTo(3, 21)
      ..lineTo(4.9, 16.4)
      ..arcToPoint(const Offset(3, 11.5), radius: const Radius.circular(8.4))
      ..arcToPoint(const Offset(12, 3), radius: const Radius.circular(8.5))
      ..arcToPoint(const Offset(21, 11.5), radius: const Radius.circular(8.4))
      ..close(),
    DrawnGlyph.turtle: Path()
      ..moveTo(12, 10)
      ..lineTo(14, 14)
      ..lineTo(14, 17)
      ..arcToPoint(
        const Offset(15, 18),
        radius: const Radius.circular(1),
        clockwise: false,
      )
      ..lineTo(17, 18)
      ..arcToPoint(
        const Offset(18, 17),
        radius: const Radius.circular(1),
        clockwise: false,
      )
      ..lineTo(18, 14)
      ..arcToPoint(
        const Offset(2, 14),
        radius: const Radius.circular(8),
        largeArc: true,
        clockwise: false,
      )
      ..lineTo(2, 17)
      ..arcToPoint(
        const Offset(3, 18),
        radius: const Radius.circular(1),
        clockwise: false,
      )
      ..lineTo(5, 18)
      ..arcToPoint(
        const Offset(6, 17),
        radius: const Radius.circular(1),
        clockwise: false,
      )
      ..lineTo(6, 14)
      ..lineTo(8, 10)
      ..close()
      ..moveTo(4.82, 7.9)
      ..lineTo(8, 10)
      ..moveTo(15.18, 7.9)
      ..lineTo(12, 10)
      ..moveTo(16.93, 10)
      ..lineTo(20, 10)
      ..arcToPoint(const Offset(20, 14), radius: const Radius.circular(2))
      ..lineTo(2, 14),
    DrawnGlyph.sandal: Path()
      ..moveTo(12, 2.5)
      ..cubicTo(8.8, 2.5, 7, 5.8, 7, 10.7)
      ..cubicTo(7, 15.9, 8.6, 21.5, 12, 21.5)
      ..cubicTo(15.4, 21.5, 17, 15.9, 17, 10.7)
      ..cubicTo(17, 5.8, 15.2, 2.5, 12, 2.5)
      ..close()
      ..moveTo(8, 11.5)
      ..lineTo(12, 8)
      ..lineTo(16, 11.5),
    DrawnGlyph.tie: Path()
      ..moveTo(10, 2)
      ..lineTo(14, 2)
      ..lineTo(13, 5.5)
      ..lineTo(11, 5.5)
      ..close()
      ..moveTo(11, 5.5)
      ..lineTo(9, 16)
      ..lineTo(12, 22)
      ..lineTo(15, 16)
      ..lineTo(13, 5.5),
  };
}

class _GlyphPainter extends CustomPainter {
  const _GlyphPainter(this.path, this.color, {required this.filled});

  final Path path;
  final Color color;
  final bool filled;

  static const _grid = 24.0;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / _grid);
    final paint = Paint()..color = color;
    if (!filled) {
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.9
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.path != path || old.color != color || old.filled != filled;
}
