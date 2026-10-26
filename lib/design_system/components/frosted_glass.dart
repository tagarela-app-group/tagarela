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
    this.radius = AppRadius.lg,
  });

  final Widget child;
  final bool frosted;
  final Widget? overlay;
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
      if (!MediaQuery.disableAnimationsOf(context)) _sheen.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _sheen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final frosted = widget.frosted;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AppMotion.reveal;
    final radius = BorderRadius.circular(widget.radius);

    return Stack(
      alignment: Alignment.center,
      children: [
        ExcludeSemantics(excluding: frosted, child: widget.child),
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !frosted,
            child: AnimatedOpacity(
              duration: duration,
              opacity: frosted ? 1 : 0,
              child: ClipRRect(
                borderRadius: radius,
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
                          child: SpeechBubbleIcon(
                            size: 200,
                            color: c.watermark,
                          ),
                        ),
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: _sheen,
                            builder: (context, _) => _Sheen(
                              progress: _sheen.value,
                              color: c.frostSheen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (widget.overlay case final overlay?)
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
                          child: overlay,
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
