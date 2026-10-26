import 'package:flutter/material.dart';

import 'package:tagarela/design_system/tokens/app_tokens.dart';

class RollingText extends StatelessWidget {
  const RollingText({
    super.key,
    required this.texts,
    required this.index,
    this.style,
  });

  final List<String> texts;
  final int index;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    Text line(String text, {Key? key}) =>
        Text(text, key: key, style: style, maxLines: 1, softWrap: false);
    return ClipRect(
      child: Stack(
        children: [
          for (final text in texts)
            Visibility(
              visible: false,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: line(text),
            ),
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: AppMotion.roll,
              switchInCurve: AppMotion.spring,
              switchOutCurve: AppMotion.smooth,
              layoutBuilder: (current, previous) => Stack(
                alignment: AlignmentDirectional.topStart,
                children: [...previous, ?current],
              ),
              transitionBuilder: (child, animation) => SlideTransition(
                position: Tween(
                  begin: Offset(0, child.key == ValueKey(index) ? 1 : -1),
                  end: Offset.zero,
                ).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: line(texts[index % texts.length], key: ValueKey(index)),
            ),
          ),
        ],
      ),
    );
  }
}
