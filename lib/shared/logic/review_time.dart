import 'dart:math';

import 'package:tagarela/l10n/l10n.dart';

const _hoursPerDay = 24;

({int count, bool days})? _wait(DateTime due, DateTime now) {
  final left = due.difference(now);
  if (left <= Duration.zero) return null;
  if (left.inHours < _hoursPerDay) {
    return (count: max(1, (left.inMinutes / 60).ceil()), days: false);
  }
  return (count: (left.inHours / _hoursPerDay).round(), days: true);
}

String returnsIn(AppLocalizations l10n, DateTime due, DateTime now) =>
    switch (_wait(due, now)) {
      null => l10n.returnsNow,
      (:final count, days: true) => l10n.returnsInDays(count),
      (:final count, days: false) => l10n.returnsInHours(count),
    };

String nextReviewIn(AppLocalizations l10n, DateTime due, DateTime now) =>
    switch (_wait(due, now)) {
      null => l10n.returnsNow,
      (:final count, days: true) => l10n.nextReviewInDays(count),
      (:final count, days: false) => l10n.nextReviewInHours(count),
    };
