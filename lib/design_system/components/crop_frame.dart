import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:tagarela/design_system/tokens/app_colors.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';

class CropFrame extends StatefulWidget {
  const CropFrame({
    super.key,
    required this.imageSize,
    required this.maxHeight,
    required this.area,
    required this.onChanged,
    required this.child,
  });

  static const full = Rect.fromLTRB(0, 0, 1, 1);
  static const gutter = AppSpacing.s3;
  static const minSide = 72.0;
  static const reach = 24.0;

  final Size imageSize;
  final double maxHeight;
  final Rect area;
  final ValueChanged<Rect> onChanged;
  final Widget child;

  @override
  State<CropFrame> createState() => _CropFrameState();
}

class _Grab {
  const _Grab(this.horizontal, this.vertical);

  static const move = _Grab(0, 0);

  final int horizontal;
  final int vertical;

  Rect apply(Rect from, Offset delta, Rect bounds) {
    if (this == move) {
      return from.shift(
        Offset(
          delta.dx.clamp(bounds.left - from.left, bounds.right - from.right),
          delta.dy.clamp(bounds.top - from.top, bounds.bottom - from.bottom),
        ),
      );
    }
    final side = CropFrame.minSide.clamp(0.0, bounds.shortestSide);
    return Rect.fromLTRB(
      horizontal < 0
          ? (from.left + delta.dx).clamp(bounds.left, from.right - side)
          : from.left,
      vertical < 0
          ? (from.top + delta.dy).clamp(bounds.top, from.bottom - side)
          : from.top,
      horizontal > 0
          ? (from.right + delta.dx).clamp(from.left + side, bounds.right)
          : from.right,
      vertical > 0
          ? (from.bottom + delta.dy).clamp(from.top + side, bounds.bottom)
          : from.bottom,
    );
  }

  static int _side(double at, double start, double end) {
    final toStart = (at - start).abs();
    final toEnd = (at - end).abs();
    if (toStart > CropFrame.reach && toEnd > CropFrame.reach) return 0;
    return toStart < toEnd ? -1 : 1;
  }

  static _Grab? at(Offset point, Rect frame) {
    if (!frame.inflate(CropFrame.reach).contains(point)) return null;
    final horizontal = _side(point.dx, frame.left, frame.right);
    final vertical = _side(point.dy, frame.top, frame.bottom);
    if (horizontal != 0 || vertical != 0) return _Grab(horizontal, vertical);
    return move;
  }
}

class _EagerPan extends PanGestureRecognizer {
  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }
}

class _CropFrameState extends State<CropFrame>
    with SingleTickerProviderStateMixin {
  late final _grid = AnimationController(vsync: this, duration: AppMotion.base);

  Rect _photo = Rect.zero;
  _Grab? _grab;
  Rect _from = Rect.zero;
  Offset _delta = Offset.zero;

  Rect get _frame => Rect.fromLTRB(
    _photo.left + widget.area.left * _photo.width,
    _photo.top + widget.area.top * _photo.height,
    _photo.left + widget.area.right * _photo.width,
    _photo.top + widget.area.bottom * _photo.height,
  );

  void _start(DragStartDetails details) {
    _grab = _Grab.at(details.localPosition, _frame);
    if (_grab == null) return;
    _from = _frame;
    _delta = Offset.zero;
    HapticFeedback.selectionClick();
    _grid.duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AppMotion.base;
    _grid.forward();
  }

  void _update(DragUpdateDetails details) {
    final grab = _grab;
    if (grab == null) return;
    _delta += details.delta;
    final frame = grab.apply(_from, _delta, _photo);
    widget.onChanged(
      Rect.fromLTRB(
        (frame.left - _photo.left) / _photo.width,
        (frame.top - _photo.top) / _photo.height,
        (frame.right - _photo.left) / _photo.width,
        (frame.bottom - _photo.top) / _photo.height,
      ),
    );
  }

  void _end() {
    _grab = null;
    _grid.reverse();
  }

  @override
  void dispose() {
    _grid.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        const gutter = CropFrame.gutter;
        final room = Size(
          box.maxWidth - gutter * 2,
          widget.maxHeight - gutter * 2,
        );
        final fitted = applyBoxFit(
          BoxFit.contain,
          widget.imageSize,
          room,
        ).destination;
        _photo = Rect.fromLTWH(
          (box.maxWidth - fitted.width) / 2,
          gutter,
          fitted.width,
          fitted.height,
        );
        return RawGestureDetector(
          behavior: HitTestBehavior.opaque,
          gestures: {
            _EagerPan: GestureRecognizerFactoryWithHandlers<_EagerPan>(
              _EagerPan.new,
              (pan) => pan
                ..onStart = _start
                ..onUpdate = _update
                ..onEnd = ((_) => _end())
                ..onCancel = _end,
            ),
          },
          child: SizedBox(
            height: fitted.height + gutter * 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: ColoredBox(
                color: AppPalette.ink,
                child: Stack(
                  children: [
                    Positioned.fromRect(rect: _photo, child: widget.child),
                    Positioned.fill(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: MediaQuery.disableAnimationsOf(context)
                            ? Duration.zero
                            : AppMotion.slow,
                        curve: AppMotion.standard,
                        builder: (context, handles, _) => AnimatedBuilder(
                          animation: _grid,
                          builder: (context, _) => CustomPaint(
                            painter: _CropPainter(
                              photo: _photo,
                              frame: _frame,
                              grid: _grid.value,
                              handles: handles,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CropPainter extends CustomPainter {
  const _CropPainter({
    required this.photo,
    required this.frame,
    required this.grid,
    required this.handles,
  });

  static const _corner = 22.0;
  static const _edge = 20.0;
  static const _stroke = 4.0;

  final Rect photo;
  final Rect frame;
  final double grid;
  final double handles;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(photo)
        ..addRect(frame),
      Paint()..color = AppPalette.ink.withValues(alpha: 0.62),
    );
    if (grid > 0) _paintGrid(canvas);
    canvas.drawRect(
      frame,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = AppPalette.white,
    );
    final marks = _marks();
    _stroke2(canvas, marks, AppPalette.ink.withValues(alpha: 0.3), _stroke + 2);
    _stroke2(canvas, marks, AppPalette.white, _stroke);
  }

  void _paintGrid(Canvas canvas) {
    final paint = Paint()
      ..strokeWidth = 1
      ..color = AppPalette.white.withValues(alpha: 0.55 * grid);
    for (final third in const [1 / 3, 2 / 3]) {
      final x = frame.left + frame.width * third;
      final y = frame.top + frame.height * third;
      canvas
        ..drawLine(Offset(x, frame.top), Offset(x, frame.bottom), paint)
        ..drawLine(Offset(frame.left, y), Offset(frame.right, y), paint);
    }
  }

  Path _marks() {
    final corner = _corner * handles;
    final edge = _edge * handles / 2;
    final path = Path();
    for (final (x, dx) in [(frame.left, 1.0), (frame.right, -1.0)]) {
      for (final (y, dy) in [(frame.top, 1.0), (frame.bottom, -1.0)]) {
        path
          ..moveTo(x + dx * corner, y)
          ..lineTo(x, y)
          ..lineTo(x, y + dy * corner);
      }
    }
    final center = frame.center;
    for (final x in [frame.left, frame.right]) {
      path
        ..moveTo(x, center.dy - edge)
        ..lineTo(x, center.dy + edge);
    }
    for (final y in [frame.top, frame.bottom]) {
      path
        ..moveTo(center.dx - edge, y)
        ..lineTo(center.dx + edge, y);
    }
    return path;
  }

  void _stroke2(Canvas canvas, Path path, Color color, double width) =>
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = color,
      );

  @override
  bool shouldRepaint(_CropPainter old) =>
      old.frame != frame ||
      old.photo != photo ||
      old.grid != grid ||
      old.handles != handles;
}
