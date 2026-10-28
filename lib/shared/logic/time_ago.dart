import 'package:tagarela/l10n/l10n.dart';

String timeAgo(AppLocalizations l10n, DateTime at, DateTime now) {
  final local = at.toLocal();
  final diff = now.difference(local);
  if (diff.inMinutes < 1) return l10n.timeNow;
  if (diff.inHours < 1) return l10n.minutesAgo(diff.inMinutes);
  final day = DateTime(local.year, local.month, local.day);
  if (day == DateTime(now.year, now.month, now.day)) {
    return l10n.hoursAgo(diff.inHours);
  }
  if (day == DateTime(now.year, now.month, now.day - 1)) return l10n.yesterday;
  return l10n.shortDate(local);
}
