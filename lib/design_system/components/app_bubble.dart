import 'package:flutter/material.dart';

import 'package:tagarela/design_system/tokens/app_colors.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';
import 'package:tagarela/design_system/tokens/app_typography.dart';

class AppBubble extends StatelessWidget {
  const AppBubble({
    super.key,
    required this.child,
    this.size = 44,
    this.color = AppPalette.mango,
    this.foreground = AppPalette.ink,
    this.image,
  });

  final Widget child;
  final double size;
  final Color color;
  final Color foreground;
  final ImageProvider? image;

  @override
  Widget build(BuildContext context) {
    final content = IconTheme.merge(
      data: IconThemeData(color: foreground, size: size * 0.45),
      child: DefaultTextStyle.merge(
        style: TextStyle(
          fontFamily: AppFonts.display,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.38,
          height: 1,
          color: foreground,
        ),
        child: child,
      ),
    );

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      clipBehavior: image == null ? Clip.none : Clip.antiAlias,
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.bubble(size * 0.35),
      ),
      child: switch (image) {
        null => content,
        final image => Stack(
          fit: StackFit.expand,
          children: [
            Center(child: content),
            Image(
              image: image,
              fit: BoxFit.cover,
              excludeFromSemantics: true,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ],
        ),
      },
    );
  }
}
