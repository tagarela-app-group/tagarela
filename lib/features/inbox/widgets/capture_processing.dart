import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';

class CaptureProcessing extends StatelessWidget {
  const CaptureProcessing({super.key, required this.source});

  final CaptureSource source;

  @override
  Widget build(BuildContext context) {
    if (source == CaptureSource.photo) {
      return _StatusLine(context.l10n.readingPhoto);
    }
    final speech = AppScope.of(context).speech;
    return ListenableBuilder(
      listenable: speech,
      builder: (context, _) => _StatusLine(
        speech.ready ? context.l10n.transcribing : context.l10n.waitingModel,
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final soft = context.colors.inkSoft;
    return Row(
      spacing: AppSpacing.s2,
      children: [
        Icon(AppIcons.review, size: AppIconSize.md, color: soft),
        Expanded(
          child: Text(text, style: AppText.bodyMd.copyWith(color: soft)),
        ),
      ],
    );
  }
}
