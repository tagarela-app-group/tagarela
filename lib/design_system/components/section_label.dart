import 'package:flutter/material.dart';

import 'package:tagarela/design_system/components/app_button.dart';
import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_typography.dart';

class SectionLabel extends StatelessWidget {
  const SectionLabel({super.key, required this.label, this.action});

  final String label;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppButtonSize.small.height,
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                label.toUpperCase(),
                style: AppText.overline.copyWith(color: context.colors.inkSoft),
              ),
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}
