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
}) {
  final c = context.colors;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.s4,
          0,
          AppSpacing.s4,
          AppTabBar.height + AppSpacing.s4,
        ),
        content: Row(
          spacing: AppSpacing.s3,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: c.mastered,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                AppIcons.check,
                size: 18,
                color: AppPalette.white,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Salvo no Inbox', style: AppText.button),
                  Text(
                    savedMessage(capture),
                    style: AppText.label.copyWith(fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ],
        ),
        action: SnackBarAction(label: 'Ver', onPressed: onSee),
      ),
    );
}
