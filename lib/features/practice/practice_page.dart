import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/device/voice.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/practice/games/games.dart';
import 'package:tagarela/features/practice/logic/practice_session.dart';
import 'package:tagarela/features/practice/widgets/practice_summary.dart';
import 'package:tagarela/features/practice/widgets/round_result.dart';
import 'package:tagarela/l10n/l10n.dart';

class PracticePage extends StatefulWidget {
  const PracticePage({super.key, required this.rounds, this.review = false});

  static const termVariations = 3;

  final List<PracticeRound> rounds;
  final bool review;

  static Future<void> openReview(
    BuildContext context,
    List<ReviewRound> rounds,
  ) async {
    final scope = AppScope.of(context);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PracticePage(
          review: true,
          rounds: [for (final r in rounds) PracticeRound(r.term, r.kind)],
        ),
      ),
    );
    await Future.wait([scope.practice.load(), scope.vocabulary.load()]);
  }

  static Future<void> openTerm(
    BuildContext context,
    Term term,
    ExerciseKind kind,
  ) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => PracticePage(
        rounds: [
          for (var variant = 0; variant < termVariations; variant++)
            PracticeRound(term, kind, variant: variant),
        ],
      ),
    ),
  );

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  late final PracticeSession _session;
  late final Voice _voice;

  @override
  void initState() {
    super.initState();
    final scope = AppScope.of(context);
    final practice = scope.practice;
    _voice = scope.voice;
    _session = PracticeSession(
      widget.rounds,
      load: (term, kind) => practice.exercises(term.id, kind),
      record: widget.review ? practice.record : null,
    );
    unawaited(_session.start());
  }

  @override
  void dispose() {
    _voice.stop();
    _session.dispose();
    super.dispose();
  }

  void _next() {
    _voice.stop();
    _session.next();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final course = AppScope.of(context).courses.active;
    final learning = course?.learning ?? CourseLanguage.en;
    final base = course?.base ?? CourseLanguage.pt;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: c.header,
        body: SafeArea(
          bottom: false,
          child: ListenableBuilder(
            listenable: _session,
            builder: (context, _) => Column(
              children: [
                _TopBar(session: _session),
                Expanded(child: _body(context, learning, base)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    CourseLanguage learning,
    CourseLanguage base,
  ) {
    final session = _session;
    if (session.done) {
      return PracticeSummary(
        results: session.results,
        review: widget.review,
        language: learning,
        onFinish: () => Navigator.of(context).pop(),
      );
    }
    if (session.error case final error?) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: AppCard(
            child: AsyncStatus(error: error, onRetry: session.retry),
          ),
        ),
      );
    }
    final exercise = session.exercise;
    if (exercise == null) return const _Loading();
    final outcome = session.outcome;
    return gameFor(
      exercise,
      language: learning,
      voice: _voice,
      onSolved: session.solve,
      result: outcome == null
          ? null
          : RoundResult(
              exercise: exercise,
              outcome: outcome,
              learning: learning,
              base: base,
              voice: _voice,
              last: session.index == session.total - 1,
              onNext: _next,
            ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.session});

  final PracticeSession session;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final total = session.total;
    final current = session.done ? total : session.index + 1;
    final finished = session.done ? total : session.index;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.s3,
        AppSpacing.screen,
        AppSpacing.s1,
      ),
      child: Row(
        spacing: 14,
        children: [
          AppIconButton(
            icon: AppIcons.close,
            tooltip: l10n.practiceLeave,
            variant: AppIconButtonVariant.onHeader,
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: SegmentBar(
              semanticLabel: l10n.practiceRound(current, total),
              segments: [
                for (var i = 0; i < total; i++)
                  Segment(1, i < finished ? c.onHeaderSoft : c.headerChip),
              ],
            ),
          ),
          ExcludeSemantics(
            child: Text(
              '$current/$total',
              style: AppText.label.copyWith(color: c.onHeaderSoft),
            ),
          ),
        ],
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final label = context.l10n.practiceLoading;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screen),
        child: Semantics(
          label: label,
          liveRegion: true,
          child: ExcludeSemantics(
            child: SpeechBalloon(
              color: c.surface,
              radius: AppRadius.xl,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s5,
                vertical: AppSpacing.s4,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: AppSpacing.s3,
                children: [
                  TypingDots(color: c.primary),
                  Flexible(
                    child: Text(
                      label,
                      style: AppText.bodyLg.copyWith(color: c.inkSoft),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
