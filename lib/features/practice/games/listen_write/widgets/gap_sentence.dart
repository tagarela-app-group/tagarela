import 'package:flutter/material.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/practice/games/listen_write/logic/gap_fill.dart';
import 'package:tagarela/features/practice/games/listen_write/logic/sentence_layout.dart';

class GapSentence extends StatelessWidget {
  const GapSentence({
    super.key,
    required this.exercise,
    required this.fill,
    required this.spoken,
    required this.locale,
    required this.gapLabel,
  });

  static const tileWidth = 24.0;
  static const tileHeight = 34.0;
  static const markWidth = 8.0;
  static const tileGap = 3.0;
  static const groupPadding = 3.0;
  static const lineHeight = 44.0;

  final ListenWriteExercise exercise;
  final GapFill fill;
  final int? spoken;
  final Locale locale;
  final String gapLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final style = AppText.bodyLg.copyWith(
      fontSize: 22,
      height: 1.3,
      fontWeight: FontWeight.w500,
      color: c.ink,
    );
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    double measure(String text) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style, locale: locale),
        textDirection: direction,
        textScaler: scaler,
      )..layout();
      final width = painter.width;
      painter.dispose();
      return width;
    }

    final tokens = sentenceTokens(exercise);
    return LayoutBuilder(
      builder: (context, constraints) {
        final lines = layoutSentence(
          tokens,
          SentenceMetrics(
            maxWidth: constraints.maxWidth,
            space: measure(' '),
            measure: measure,
            tileWidth: (i) => fill.isSlot(i) ? tileWidth : markWidth,
            tileGap: tileGap,
            groupPadding: groupPadding,
            tileSpace: 7,
            hyphenWidth: measure('-') + SentenceMetrics.glue,
          ),
        );
        return Semantics(
          label: exercise.sentence.replaceRange(
            exercise.start,
            exercise.end,
            gapLabel,
          ),
          child: ExcludeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final line in lines)
                  SizedBox(
                    height: lineHeight,
                    child: Row(
                      children: [
                        for (final piece in line)
                          Padding(
                            padding: EdgeInsets.only(left: piece.space),
                            child: _piece(context, piece, style),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _piece(BuildContext context, LinePiece piece, TextStyle style) {
    final c = context.colors;
    final on = spoken != null;
    return switch (piece) {
      WordPiece(:final token) => AnimatedContainer(
        duration: AppMotion.fast,
        decoration: BoxDecoration(
          color: on && token.covers(spoken!) ? c.primarySoft : null,
          borderRadius: BorderRadius.circular(AppRadius.xs),
        ),
        child: Text(
          token.text,
          locale: locale,
          style: on && token.covers(spoken!)
              ? style.copyWith(color: c.primaryText)
              : style,
        ),
      ),
      TilesPiece(:final token, :final indices) => AnimatedContainer(
        duration: AppMotion.fast,
        padding: const EdgeInsets.all(groupPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: on && token.covers(spoken!) ? c.primary : Colors.transparent,
            width: 2,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: tileGap,
          children: [for (final i in indices) _tile(context, i, style)],
        ),
      ),
      HyphenPiece() => Text(
        '-',
        style: style.copyWith(
          fontFamily: AppFonts.display,
          fontWeight: FontWeight.w800,
          color: c.inkSoft,
        ),
      ),
    };
  }

  Widget _tile(BuildContext context, int i, TextStyle style) {
    if (!fill.isSlot(i)) {
      return SizedBox(
        width: markWidth,
        child: Text(
          exercise.answer[i],
          textAlign: TextAlign.center,
          style: style.copyWith(fontWeight: FontWeight.w800),
        ),
      );
    }
    final order = Iterable<int>.generate(i).where(fill.isSlot).length;
    return LetterTile(
      letter: fill.letterAt(i) ?? '',
      state: _state(i),
      width: tileWidth,
      height: tileHeight,
      delay: Duration(milliseconds: 45 * order),
    );
  }

  LetterTileState _state(int i) => switch (fill.status) {
    GapStatus.solved => LetterTileState.done,
    GapStatus.revealed => LetterTileState.help,
    _ when fill.isWrong(i) => LetterTileState.wrong,
    _ when fill.letterAt(i) == null =>
      i == fill.cursor ? LetterTileState.active : LetterTileState.empty,
    _ when fill.isHint(i) => LetterTileState.help,
    _ => LetterTileState.filled,
  };
}
