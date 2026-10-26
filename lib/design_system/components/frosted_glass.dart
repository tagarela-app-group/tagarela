import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:tagarela/design_system/components/speech_bubble_icon.dart';
import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';

class FrostedGlass extends StatefulWidget {
  const FrostedGlass({
    super.key,
    required this.child,
    required this.frosted,
    this.overlay,
    this.actions,
    this.onWiped,
    this.radius = AppRadius.lg,
  });

  static const wipeRadius = 30.0;
  static const _columns = 8;
  static const _rows = 6;
  static const _clearAt = 0.6;

  final Widget child;
  final bool frosted;
  final Widget? overlay;
  final Widget? actions;
  final VoidCallback? onWiped;
  final double radius;

  @override
  State<FrostedGlass> createState() => _FrostedGlassState();
}

class _FrostedGlassState extends State<FrostedGlass>
    with SingleTickerProviderStateMixin {
  late final _sheen = AnimationController(
    vsync: this,
    duration: AppMotion.sheen,
  );
  final _wipes = <Offset>[];
  final _cells = <int>{};
  var _wiped = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.frosted && !MediaQuery.disableAnimationsOf(context)) {
      _sheen.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(FrostedGlass oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.frosted && !oldWidget.frosted) {
      _wipes.clear();
      _cells.clear();
      _wiped = false;
      if (!MediaQuery.disableAnimationsOf(context)) _sheen.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _sheen.dispose();
    super.dispose();
  }

  void _wipe(Offset point, Size size) {
    if (!widget.frosted || _wiped || size.isEmpty) return;
    final x = (point.dx / size.width).clamp(0.0, 0.999);
    final y = (point.dy / size.height).clamp(0.0, 0.999);
    setState(() {
      _wipes.add(Offset(x, y));
      _cells.add(
        (y * FrostedGlass._rows).floor() * FrostedGlass._columns +
            (x * FrostedGlass._columns).floor(),
      );
    });
    const total = FrostedGlass._columns * FrostedGlass._rows;
    if (_cells.length >= total * FrostedGlass._clearAt) {
      _wiped = true;
      widget.onWiped?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final frosted = widget.frosted;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AppMotion.reveal;
    final radius = BorderRadius.circular(widget.radius);
    final wiping = _wipes.isNotEmpty;

    final frost = AnimatedOpacity(
      duration: duration,
      opacity: frosted ? 1 : 0,
      child: ClipPath(
        clipper: _WipeClipper(List.of(_wipes), radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppBlur.frost,
            sigmaY: AppBlur.frost,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: c.frost,
              ),
            ),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned(
                  right: -44,
                  bottom: -52,
                  child: SpeechBubbleIcon(size: 200, color: c.watermark),
                ),
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _sheen,
                    builder: (context, _) =>
                        _Sheen(progress: _sheen.value, color: c.frostSheen),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    final glass = widget.onWiped == null
        ? frost
        : LayoutBuilder(
            builder: (context, constraints) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: (d) =>
                  _wipe(d.localPosition, constraints.biggest),
              onHorizontalDragUpdate: (d) =>
                  _wipe(d.localPosition, constraints.biggest),
              child: frost,
            ),
          );

    final overlay = widget.overlay;
    final actions = widget.actions;
    return Stack(
      alignment: Alignment.center,
      children: [
        ExcludeSemantics(excluding: frosted, child: widget.child),
        Positioned.fill(
          child: IgnorePointer(ignoring: !frosted, child: glass),
        ),
        if (overlay != null || actions != null)
          IgnorePointer(
            ignoring: !frosted,
            child: ExcludeSemantics(
              excluding: !frosted,
              child: AnimatedSize(
                duration: duration,
                curve: AppMotion.standard,
                clipBehavior: Clip.none,
                child: AnimatedSwitcher(
                  duration: duration,
                  child: frosted
                      ? Padding(
                          padding: const EdgeInsets.all(AppSpacing.s5),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            spacing: AppSpacing.s3,
                            children: [
                              if (overlay != null)
                                IgnorePointer(
                                  ignoring: wiping,
                                  child: AnimatedOpacity(
                                    duration: AppMotion.slow,
                                    opacity: wiping ? 0 : 1,
                                    child: overlay,
                                  ),
                                ),
                              ?actions,
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _WipeClipper extends CustomClipper<Path> {
  const _WipeClipper(this.wipes, this.radius);

  final List<Offset> wipes;
  final BorderRadius radius;

  @override
  Path getClip(Size size) {
    final glass = Path()..addRRect(radius.toRRect(Offset.zero & size));
    if (wipes.isEmpty) return glass;
    final holes = Path();
    for (final w in wipes) {
      holes.addOval(
        Rect.fromCircle(
          center: Offset(w.dx * size.width, w.dy * size.height),
          radius: FrostedGlass.wipeRadius,
        ),
      );
    }
    return Path.combine(PathOperation.difference, glass, holes);
  }

  @override
  bool shouldReclip(_WipeClipper old) =>
      old.wipes.length != wipes.length || old.radius != radius;
}

class _Sheen extends StatelessWidget {
  const _Sheen({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (progress == 0 || progress == 1) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth * 0.6;
        return Transform.translate(
          offset: Offset(-width + (constraints.maxWidth + width) * progress, 0),
          child: Transform(
            transform: Matrix4.skewX(-0.32),
            child: SizedBox(
              width: width,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0),
                      color,
                      color.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
