import 'dart:async';

import 'package:flutter/material.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/term/logic/term_pieces.dart';
import 'package:tagarela/features/term/widgets/term_top_bar.dart';
import 'package:tagarela/l10n/l10n.dart';

const _steps = [
  'meaning',
  'trick',
  'pitfall',
  'dialogue',
  'phrase',
  'neighbors',
];

class TermBuilding extends StatefulWidget {
  const TermBuilding({
    super.key,
    required this.term,
    required this.group,
    required this.language,
  });

  final Term term;
  final TermGroup? group;
  final CourseLanguage language;

  @override
  State<TermBuilding> createState() => _TermBuildingState();
}

class _TermBuildingState extends State<TermBuilding> {
  late final Timer _timer;
  var _line = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      AppMotion.rollEvery,
      (_) => setState(() => _line++),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final term = widget.term;
    final split = termPieces(term.text);
    final rolling = AppText.titleLg.copyWith(fontWeight: FontWeight.w800);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TermTopBar(group: widget.group),
        Expanded(
          child: Semantics(
            container: true,
            label: l10n.termCardLoading,
            child: LayoutBuilder(
              builder: (context, box) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: box.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: AppSpacing.s4,
                    children: [
                      SpeechBalloon(
                        color: c.surface,
                        radius: AppRadius.xl,
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.s5,
                          AppSpacing.s4,
                          AppSpacing.s5,
                          AppSpacing.s5,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: AppSpacing.s3,
                          children: [
                            AppTag(label: l10n.termKind(term.kind.name)),
                            Semantics(
                              label: term.text,
                              excludeSemantics: true,
                              child: ShufflingTiles(
                                pieces: split.pieces,
                                joined: split.joined,
                                locale: Locale(widget.language.name),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: ExcludeSemantics(
                          child: SpeechBalloon(
                            color: c.headerChip,
                            mirrored: true,
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.s4,
                              AppSpacing.s3,
                              AppSpacing.s4,
                              AppSpacing.s4,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              spacing: AppSpacing.s1,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: AppSpacing.s2,
                                  children: [
                                    Text(
                                      l10n.termBuildingTitle.toUpperCase(),
                                      style: AppText.overline.copyWith(
                                        color: c.onHeaderSoft,
                                      ),
                                    ),
                                    TypingDots(color: c.onHeaderSoft),
                                  ],
                                ),
                                RollingText(
                                  index: _line,
                                  texts: [
                                    for (final s in _steps)
                                      l10n.termBuildingVerb(s),
                                  ],
                                  style: rolling.copyWith(
                                    color: AppPalette.white,
                                  ),
                                ),
                                RollingText(
                                  index: _line,
                                  texts: [
                                    for (final s in _steps)
                                      l10n.termBuildingObject(s),
                                  ],
                                  style: rolling.copyWith(
                                    color: c.onHeaderSoft,
                                  ),
                                ),
                              ],
                            ),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s5),
          child: Text(
            l10n.termBuildingNote,
            textAlign: TextAlign.center,
            style: AppText.label.copyWith(
              color: c.onHeaderSoft,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
