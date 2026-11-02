import 'package:flutter/material.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/practice/games/reply/widgets/mine_bubble.dart';
import 'package:tagarela/features/practice/games/reply/widgets/nina_bubble.dart';
import 'package:tagarela/l10n/l10n.dart';

class ReplyChat extends StatelessWidget {
  const ReplyChat({
    super.key,
    required this.earlier,
    required this.language,
    required this.typing,
    required this.messages,
    this.footer,
  });

  final List<ReplyExercise> earlier;
  final CourseLanguage language;
  final bool typing;
  final List<Widget> messages;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.s3,
            AppSpacing.screen,
            AppSpacing.s2,
          ),
          child: Row(
            spacing: AppSpacing.s25,
            children: [
              const ExcludeSemantics(
                child: BubbleMascot(size: AppBubbleSize.md),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.replyNina,
                      style: AppText.titleSm.copyWith(color: AppPalette.white),
                    ),
                    Text(
                      typing ? l10n.replyTyping : l10n.replyOnline,
                      style: AppText.label.copyWith(color: c.onHeaderSoft),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            reverse: true,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.s1,
              AppSpacing.screen,
              AppSpacing.s35,
            ),
            child: Semantics(
              liveRegion: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSpacing.s2,
                children: [
                  for (final (i, exercise) in earlier.indexed) ...[
                    NinaBubble.text(
                      exercise.opening(continuing: i > 0),
                      language: language,
                    ),
                    MineBubble(
                      before: exercise.before,
                      fill: exercise.filled,
                      after: exercise.after,
                      language: language,
                      tone: MineTone.right,
                    ),
                    NinaBubble.text(
                      exercise.ninaReply,
                      language: language,
                      avatar: false,
                    ),
                  ],
                  ...messages,
                ],
              ),
            ),
          ),
        ),
        ?footer,
      ],
    );
  }
}
