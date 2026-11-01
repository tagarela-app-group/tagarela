import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/features/practice/logic/practice_session.dart';
import 'package:tagarela/l10n/l10n.dart';
import 'package:tagarela/shared/logic/review_time.dart';

String? roundFeedback(
  AppLocalizations l10n,
  PracticeResult result,
  DateTime now,
) {
  final effect = result.effect;
  if (effect == null || effect.role == EffectRole.extra) return null;
  if (effect.role == EffectRole.retest) return l10n.feedbackRetest;
  final due = effect.dueAt;
  if (due == null) return null;
  final lead = switch (effect) {
    ReviewEffect(wentBadly: true) => l10n.feedbackPoor,
    ReviewEffect(mastered: true) => l10n.feedbackMastered,
    ReviewEffect(escaped: true) => l10n.feedbackEscaped,
    _ when result.outcome != Outcome.first => null,
    _ when result.usedSlow => l10n.feedbackSlow,
    _ => l10n.feedbackClean,
  };
  final back = returnsIn(l10n, due, now);
  return lead == null ? '$back.' : '$lead $back.';
}

String? sessionRecap(AppLocalizations l10n, List<PracticeResult> results) {
  final effects = [for (final r in results) ?r.effect];
  final mastered = effects.where((e) => e.mastered).length;
  final back = effects.where((e) => e.wentBadly).length;
  final stronger = effects
      .where((e) => e.stronger && !e.mastered && !e.wentBadly)
      .length;
  final parts = [
    if (stronger > 0) l10n.recapStronger(stronger),
    if (mastered > 0) l10n.recapMastered(mastered),
    if (back > 0) l10n.recapBackToday(back),
  ];
  return parts.isEmpty ? null : parts.join(', ');
}
