import 'package:flutter/material.dart';

import 'package:tagarela/data/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';

String savedMessage(AppLocalizations l10n, Capture capture) =>
    capture.pending.contains(CaptureSync.extract)
    ? l10n.savedProcessing
    : capture.pending.isNotEmpty
    ? l10n.savedOffline
    : capture.source == CaptureSource.text
    ? l10n.savedReady
    : l10n.savedProcessing;

void showCaptureSaved(
  BuildContext context,
  Capture capture, {
  required VoidCallback onSee,
}) => AppToast.show(
  context,
  title: context.l10n.savedToInbox,
  message: savedMessage(context.l10n, capture),
  actionLabel: context.l10n.see,
  onAction: onSee,
  aboveTabBar: true,
);
