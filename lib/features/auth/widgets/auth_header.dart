import 'package:flutter/material.dart';

import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.s35,
      children: [
        AppIconButton(
          icon: AppIcons.back,
          tooltip: context.l10n.back,
          onPressed: () => Navigator.of(context).pop(),
          variant: AppIconButtonVariant.onHeader,
        ),
        PageHeader(title: title, subtitle: subtitle),
      ],
    );
  }
}
