import 'package:flutter/material.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';

void showAnalyzed(
  BuildContext context,
  Capture capture, {
  required VoidCallback? onSee,
}) {
  if (capture.refused) return;
  final l10n = context.l10n;
  final sent = capture.pending.isEmpty;
  AppToast.show(
    context,
    title: sent
        ? l10n.termsAnalyzed(capture.terms.length)
        : l10n.analysisQueued,
    message: sent ? l10n.termsAnalyzedMessage : l10n.savedOffline,
    actionLabel: sent && onSee != null ? l10n.see : null,
    onAction: onSee,
    aboveTabBar: true,
  );
}
