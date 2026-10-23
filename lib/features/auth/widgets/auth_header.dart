import 'package:flutter/material.dart';

import 'package:tagarela/design_system/design_system.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 14,
      children: [
        AppIconButton(
          icon: AppIcons.back,
          tooltip: 'Voltar',
          onPressed: () => Navigator.of(context).pop(),
          variant: AppIconButtonVariant.onHeader,
        ),
        PageHeader(title: title, subtitle: subtitle),
      ],
    );
  }
}
