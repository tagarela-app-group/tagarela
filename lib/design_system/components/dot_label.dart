import 'package:flutter/material.dart';

import 'package:tagarela/design_system/tokens/app_tokens.dart';
import 'package:tagarela/design_system/tokens/app_typography.dart';

class DotLabel extends StatelessWidget {
  const DotLabel({
    super.key,
    required this.label,
    required this.dot,
    required this.color,
    this.fontWeight,
  });

  final String label;
  final Color dot;
  final Color color;
  final FontWeight? fontWeight;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 6,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: dot,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: AppText.label.copyWith(color: color, fontWeight: fontWeight),
          ),
        ),
      ],
    );
  }
}
