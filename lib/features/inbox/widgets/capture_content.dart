import 'package:flutter/material.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';

class CaptureContent extends StatelessWidget {
  const CaptureContent({super.key, required this.capture});

  final Capture capture;

  @override
  Widget build(BuildContext context) {
    final clamp = capture.source == CaptureSource.photo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: [
        Text(
          context.l10n.captureContent(capture.source.name),
          style: AppText.pill.copyWith(color: context.colors.inkSoft),
        ),
        Text(
          capture.text,
          style: AppText.bodyLg,
          maxLines: clamp ? 3 : null,
          overflow: clamp ? TextOverflow.ellipsis : null,
        ),
      ],
    );
  }
}
