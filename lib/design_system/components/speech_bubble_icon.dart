import 'package:flutter/material.dart';

class SpeechBubbleIcon extends StatelessWidget {
  const SpeechBubbleIcon({super.key, this.size, this.color});

  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    return SizedBox.square(
      dimension: size ?? theme.size ?? 24,
      child: CustomPaint(
        painter: _BubblePainter(color ?? theme.color ?? Colors.black),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  const _BubblePainter(this.color);

  final Color color;

  static const _grid = 24.0;

  static final _path = Path()
    ..moveTo(21, 11.5)
    ..arcToPoint(const Offset(12, 19.9), radius: const Radius.circular(8.4))
    ..arcToPoint(const Offset(8, 19), radius: const Radius.circular(9))
    ..lineTo(3, 21)
    ..lineTo(4.9, 16.4)
    ..arcToPoint(const Offset(3, 11.5), radius: const Radius.circular(8.4))
    ..arcToPoint(const Offset(12, 3), radius: const Radius.circular(8.5))
    ..arcToPoint(const Offset(21, 11.5), radius: const Radius.circular(8.4))
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / _grid);
    canvas.drawPath(_path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_BubblePainter old) => old.color != color;
}
