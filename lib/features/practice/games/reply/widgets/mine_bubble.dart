import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';

enum MineTone { open, right, wrong, revealed }

class MineBubble extends StatelessWidget {
  const MineBubble({
    super.key,
    required this.before,
    required this.after,
    required this.language,
    required this.tone,
    this.fill = '',
    this.shake = false,
  });

  final String before;
  final String after;
  final CourseLanguage language;
  final MineTone tone;
  final String fill;
  final bool shake;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (bg, fillColor, ring) = switch (tone) {
      MineTone.open || MineTone.right => (c.primarySoft, c.primaryText, null),
      MineTone.wrong => (c.surface, c.alert, c.alert),
      MineTone.revealed => (c.learningSoft, c.learningText, null),
    };
    final icon = switch (tone) {
      MineTone.open => null,
      MineTone.right => AppIcons.check,
      MineTone.wrong => AppIcons.wrong,
      MineTone.revealed => AppIcons.reveal,
    };
    final strong = TextStyle(fontWeight: FontWeight.w800, color: fillColor);
    final bubble = SpeechBalloon(
      color: bg,
      mirrored: true,
      radius: AppRadius.lg,
      ring: ring,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: before),
            if (tone == MineTone.open)
              TextSpan(
                text: '…',
                style: strong,
                semanticsLabel: context.l10n.replyGap,
              )
            else
              TextSpan(text: fill, style: strong),
            TextSpan(text: after),
            if (icon != null)
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.s15),
                  child: Icon(icon, size: AppIconSize.sm, color: fillColor),
                ),
              ),
          ],
        ),
        locale: Locale(language.name),
        style: AppText.bodyLg.copyWith(color: c.ink),
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.s8),
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: shake && !MediaQuery.disableAnimationsOf(context)
            ? TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: AppMotion.slow,
                builder: (context, value, child) => Transform.translate(
                  offset: Offset(
                    math.sin(value * math.pi * 4) * (1 - value) * AppSpacing.s1,
                    0,
                  ),
                  child: child,
                ),
                child: bubble,
              )
            : bubble,
      ),
    );
  }
}
