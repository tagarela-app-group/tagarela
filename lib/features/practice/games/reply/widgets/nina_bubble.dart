import 'package:flutter/material.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';

class NinaBubble extends StatelessWidget {
  const NinaBubble({super.key, required this.child, this.avatar = true});

  NinaBubble.text(
    String text, {
    Key? key,
    required CourseLanguage language,
    bool avatar = true,
  }) : this(
         key: key,
         avatar: avatar,
         child: _NinaText(text, language: language),
       );

  final Widget child;
  final bool avatar;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.s8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: AppSpacing.s2,
        children: [
          ExcludeSemantics(
            child: Visibility(
              visible: avatar,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: const BubbleMascot(size: AppBubbleSize.sm),
            ),
          ),
          Flexible(
            child: SpeechBalloon(
              color: c.surface,
              radius: AppRadius.lg,
              shadow: c.cardShadow,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _NinaText extends StatelessWidget {
  const _NinaText(this.text, {required this.language});

  final String text;
  final CourseLanguage language;

  @override
  Widget build(BuildContext context) {
    final locale = Locale(language.name);
    return MarkedText(
      text,
      style: AppText.bodyLg.copyWith(color: context.colors.ink),
      locale: locale,
      markLocale: locale,
      highlighted: true,
    );
  }
}
