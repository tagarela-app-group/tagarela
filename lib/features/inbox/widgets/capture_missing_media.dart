import 'package:flutter/material.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';

class CaptureMissingMedia extends StatelessWidget {
  const CaptureMissingMedia(this.source, {super.key});

  final CaptureSource source;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s3,
        vertical: AppSpacing.s25,
      ),
      decoration: BoxDecoration(
        color: c.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.s2,
        children: [
          Icon(AppIcons.info, size: AppIconSize.md, color: c.inkSoft),
          Expanded(
            child: Text(
              source == CaptureSource.photo
                  ? context.l10n.missingPhoto
                  : context.l10n.missingAudio,
              style: AppText.label.copyWith(color: c.inkSoft),
            ),
          ),
        ],
      ),
    );
  }
}
