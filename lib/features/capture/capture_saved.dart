import 'package:flutter/material.dart';

import 'package:tagarela/data/models.dart';
import 'package:tagarela/design_system/design_system.dart';

String savedMessage(Capture capture) =>
    capture.pending.contains(CaptureSync.extract)
    ? 'Já está processando.'
    : capture.pending.isNotEmpty
    ? 'Puxe a lista no Inbox quando tiver internet.'
    : capture.source == CaptureSource.text
    ? 'Pronto pra escolher os termos.'
    : 'Já está processando.';

void showCaptureSaved(
  BuildContext context,
  Capture capture, {
  required VoidCallback onSee,
}) => AppToast.show(
  context,
  title: 'Salvo no Inbox',
  message: savedMessage(capture),
  actionLabel: 'Ver',
  onAction: onSee,
  aboveTabBar: true,
);
