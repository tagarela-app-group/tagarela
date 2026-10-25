import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import 'package:tagarela/design_system/components/app_bubble.dart';
import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_colors.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';
import 'package:tagarela/design_system/tokens/app_typography.dart';
import 'package:tagarela/l10n/l10n.dart';

class ArcMenuItem {
  const ArcMenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
}

class ArcMenu extends StatefulWidget {
  const ArcMenu({
    super.key,
    required this.items,
    required this.anchorBottom,
    this.title,
    this.subtitle,
  });

  final List<ArcMenuItem> items;

  final double anchorBottom;
  final String? title;
  final String? subtitle;

  static const overhang = 32.0;

  static const _fabSize = 64.0;
  static const _ring = 6.0;
  static const _itemSize = 60.0;
  static const _radius = 118.0;

  static const _arcOverhang = 15.0;

  @override
  State<ArcMenu> createState() => ArcMenuState();
}

class ArcMenuState extends State<ArcMenu> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: AppMotion.slow,
  );

  bool get _isOpen =>
      _controller.status == AnimationStatus.forward ||
      _controller.status == AnimationStatus.completed;

  void open() => _controller.forward();

  void _toggle() => _isOpen ? _controller.reverse() : _controller.forward();

  void _select(ArcMenuItem item) {
    _controller.reverse();
    item.onTap();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return LayoutBuilder(
      builder: (context, constraints) {
        final center = Offset(
          constraints.maxWidth / 2,
          constraints.maxHeight - widget.anchorBottom,
        );
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            final visible = t > 0;
            return PopScope(
              canPop: !_isOpen,
              onPopInvokedWithResult: (didPop, _) {
                if (!didPop) _controller.reverse();
              },
              child: Stack(
                children: [
                  if (visible)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: _toggle,
                        child: ClipRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: AppBlur.scrim * t,
                              sigmaY: AppBlur.scrim * t,
                            ),
                            child: ColoredBox(
                              color: c.scrim.withValues(alpha: c.scrim.a * t),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (visible && widget.title != null)
                    Positioned(
                      left: AppSpacing.s6,
                      right: AppSpacing.s6,
                      bottom: widget.anchorBottom + ArcMenu._radius + 72,
                      child: Opacity(opacity: t, child: _title()),
                    ),
                  if (visible && widget.items.length > 1)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _DashedArcPainter(
                            center: center,
                            from: _degrees(0) + ArcMenu._arcOverhang,
                            to:
                                _degrees(widget.items.length - 1) -
                                ArcMenu._arcOverhang,
                            t: t,
                          ),
                        ),
                      ),
                    ),
                  if (visible)
                    for (final (i, item) in widget.items.indexed)
                      _item(i, item, center, t),
                  Positioned(
                    left: center.dx - ArcMenu._fabSize / 2,
                    top: center.dy - ArcMenu._fabSize / 2,
                    child: _fab(c, t),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _title() {
    return Column(
      spacing: AppSpacing.s1,
      children: [
        Text(
          widget.title!,
          textAlign: TextAlign.center,
          style: AppText.titleLg.copyWith(
            fontSize: 26,
            color: AppPalette.white,
          ),
        ),
        if (widget.subtitle != null)
          Text(
            widget.subtitle!,
            textAlign: TextAlign.center,
            style: AppText.bodyLg.copyWith(color: const Color(0xDBFFFFFF)),
          ),
      ],
    );
  }

  double _degrees(int index) {
    final count = widget.items.length;
    return count == 1 ? 90.0 : 150 - index * (120 / (count - 1));
  }

  Widget _item(int index, ArcMenuItem item, Offset center, double t) {
    final angle = _degrees(index) * math.pi / 180;
    final start = index * 0.1;
    final p = AppMotion.spring.transform(
      ((t - start) / (1 - start)).clamp(0.0, 1.0),
    );
    final position =
        center +
        Offset(math.cos(angle), -math.sin(angle)) * ArcMenu._radius * p;

    return Positioned(
      left: position.dx - 40,
      top: position.dy - ArcMenu._itemSize / 2,
      width: 80,
      child: Opacity(
        opacity: p.clamp(0.0, 1.0),
        child: Transform.scale(
          scale: 0.6 + 0.4 * p,
          child: Column(
            spacing: 6,
            children: [
              Semantics(
                button: true,
                label: item.label,
                excludeSemantics: true,
                child: GestureDetector(
                  onTap: () => _select(item),
                  child: AppBubble(
                    size: ArcMenu._itemSize,
                    color: item.color,
                    child: Icon(item.icon, size: 26),
                  ),
                ),
              ),
              Text(
                item.label,
                style: AppText.label.copyWith(color: AppPalette.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fab(AppColors c, double t) {
    final open = t > 0.5;
    return Semantics(
      button: true,
      label: open ? context.l10n.closeMenu : context.l10n.addTerm,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: open ? null : c.fabRing,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: open
              ? null
              : Border.all(
                  color: c.fabRing,
                  width: ArcMenu._ring,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
          boxShadow: open
              ? const [
                  BoxShadow(
                    color: Color(0x4D000000),
                    offset: Offset(0, 12),
                    blurRadius: 24,
                  ),
                ]
              : c.fabShadow,
        ),
        child: Material(
          color: Color.lerp(c.primary, c.surface, t),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: _toggle,
            child: SizedBox.square(
              dimension: ArcMenu._fabSize,
              child: Transform.rotate(
                angle: t * math.pi / 4,
                child: _Plus(color: Color.lerp(c.onPrimary, c.ink, t)!),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Plus extends StatelessWidget {
  const _Plus({required this.color});

  final Color color;

  static const _length = 20.0;
  static const _stroke = 2.8;

  @override
  Widget build(BuildContext context) {
    Widget bar(double width, double height) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(_stroke / 2),
      ),
    );
    return Stack(
      alignment: Alignment.center,
      children: [bar(_length, _stroke), bar(_stroke, _length)],
    );
  }
}

class _DashedArcPainter extends CustomPainter {
  _DashedArcPainter({
    required this.center,
    required this.from,
    required this.to,
    required this.t,
  });

  final Offset center;

  final double from;
  final double to;
  final double t;

  static const _dash = 2.0;
  static const _gap = 8.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppPalette.white.withValues(alpha: 0.4 * t)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final rect = Rect.fromCircle(center: center, radius: ArcMenu._radius);
    final start = -from * math.pi / 180;
    final sweep = (from - to) * math.pi / 180 * AppMotion.standard.transform(t);
    final dash = _dash / ArcMenu._radius;
    final step = (_dash + _gap) / ArcMenu._radius;
    for (var a = 0.0; a + dash <= sweep; a += step) {
      canvas.drawArc(rect, start + a, dash, false, paint);
    }
  }

  @override
  bool shouldRepaint(_DashedArcPainter old) =>
      old.center != center || old.from != from || old.to != to || old.t != t;
}
