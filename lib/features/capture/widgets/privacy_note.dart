import 'package:flutter/material.dart';

import 'package:tagarela/design_system/design_system.dart';

class PrivacyNote extends StatelessWidget {
  const PrivacyNote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.s2,
      children: [
        Icon(AppIcons.info, size: AppIconSize.md, color: c.inkSoft),
        Expanded(
          child: Text(
            text,
            style: AppText.label.copyWith(
              color: c.inkSoft,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
