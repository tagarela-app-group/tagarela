import 'package:flutter/material.dart';

import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_icons.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';

class AppCheckbox extends StatelessWidget {
  const AppCheckbox({super.key, required this.checked, this.round = false});

  static const size = 24.0;

  final bool checked;
  final bool round;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AnimatedContainer(
      duration: AppMotion.fast,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: checked ? c.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(round ? size / 2 : size / 3),
        border: Border.all(color: checked ? c.primary : c.line, width: 2),
      ),
      child: checked
          ? Icon(AppIcons.check, size: 16, color: c.onPrimary)
          : null,
    );
  }
}
