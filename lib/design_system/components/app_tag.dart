import 'package:flutter/material.dart';

import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_colors.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';
import 'package:tagarela/design_system/tokens/app_typography.dart';

class AppTag extends StatelessWidget {
  const AppTag({super.key, required this.label, this.onHeader = false});

  final String label;
  final bool onHeader;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: onHeader ? c.onHeaderSoft : c.line),
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppText.tag.copyWith(
          color: onHeader ? AppPalette.white : c.inkSoft,
        ),
      ),
    );
  }
}
