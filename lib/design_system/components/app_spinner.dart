import 'package:flutter/material.dart';

import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/l10n/l10n.dart';

class AppSpinner extends StatelessWidget {
  const AppSpinner({super.key, this.size, this.color});

  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final size = this.size;
    final spinner = CircularProgressIndicator(
      color: color ?? context.colors.primary,
      strokeWidth: size == null ? null : 2.5,
      semanticsLabel: context.l10n.loading,
    );
    return size == null
        ? spinner
        : SizedBox.square(dimension: size, child: spinner);
  }
}
