import 'package:flutter/material.dart';

class Waveform extends StatelessWidget {
  const Waveform({
    super.key,
    required this.progress,
    required this.color,
    required this.track,
    this.height = 30,
  });

  static const barWidth = 3.0;
  static const gap = 4.0;
  static const _shape = [
    0.27,
    0.47,
    0.67,
    0.4,
    0.8,
    0.6,
    0.33,
    0.73,
    0.93,
    0.53,
    0.4,
    0.67,
    0.87,
    0.47,
    0.27,
    0.6,
    0.8,
    0.4,
    0.67,
    0.33,
  ];

  final double progress;
  final Color color;
  final Color track;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _WavePainter(progress.clamp(0.0, 1.0), color, track),
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  const _WavePainter(this.progress, this.color, this.track);

  final double progress;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    const step = Waveform.barWidth + Waveform.gap;
    final count = ((size.width + Waveform.gap) / step).floor();
    if (count == 0) return;
    final played = Paint()..color = color;
    final rest = Paint()..color = track;
    for (var i = 0; i < count; i++) {
      final h = size.height * Waveform._shape[i % Waveform._shape.length];
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(i * step, (size.height - h) / 2, Waveform.barWidth, h),
          const Radius.circular(Waveform.barWidth / 2),
        ),
        (i + 0.5) / count <= progress ? played : rest,
      );
    }
  }

  @override
  bool shouldRepaint(_WavePainter old) =>
      old.progress != progress || old.color != color || old.track != track;
}
