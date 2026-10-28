import 'package:flutter/material.dart';

import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_typography.dart';

class TitledText extends StatelessWidget {
  const TitledText({super.key, required this.title, this.text});

  final String title;
  final String? text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: [
        Text(
          title,
          style: AppText.bodyLg.copyWith(fontWeight: FontWeight.w700),
        ),
        if (text case final text?)
          Text(
            text,
            style: AppText.label.copyWith(
              color: context.colors.inkSoft,
              fontWeight: FontWeight.w400,
            ),
          ),
      ],
    );
  }
}
