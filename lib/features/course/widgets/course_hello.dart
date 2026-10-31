import 'package:flutter/material.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';

class CourseHello extends StatelessWidget {
  const CourseHello({
    super.key,
    required this.label,
    this.language,
    this.mine = false,
  });

  final String label;
  final CourseLanguage? language;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final language = this.language;
    final flag = language == null
        ? null
        : FlagBadge(country: language.country, size: 16);
    final Widget balloon = switch (language) {
      null => SpeechBalloon(
        color: c.headerChip,
        mirrored: true,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
        child: const TypingDots(color: AppPalette.white, size: 7),
      ),
      final language => SpeechBalloon(
        color: mine ? c.headerChip : c.surface,
        mirrored: mine,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s4,
          vertical: AppSpacing.s3,
        ),
        child: Text(
          language.hello,
          locale: language.locale,
          textAlign: mine ? TextAlign.end : TextAlign.start,
          style: AppText.titleMd.copyWith(
            color: mine ? AppPalette.white : c.ink,
          ),
        ),
      ),
    };
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: mine ? AppSpacing.s14 : 0,
        end: mine ? 0 : AppSpacing.s14,
      ),
      child: Align(
        alignment: mine
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        child: Column(
          crossAxisAlignment: mine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          spacing: 6,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 6,
              children: [
                if (!mine) ?flag,
                Text(
                  label.toUpperCase(),
                  style: AppText.overline.copyWith(color: c.onHeaderSoft),
                ),
                if (mine) ?flag,
              ],
            ),
            if (language == null || !mine)
              balloon
            else
              _Pop(key: ValueKey(language), child: balloon),
          ],
        ),
      ),
    );
  }
}

class _Pop extends StatelessWidget {
  const _Pop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : AppMotion.slow,
      curve: AppMotion.spring,
      child: child,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0, 1),
        child: Transform.scale(
          scale: 0.6 + 0.4 * t,
          alignment: AlignmentDirectional.bottomEnd,
          child: child,
        ),
      ),
    );
  }
}
