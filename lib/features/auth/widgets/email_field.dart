import 'package:flutter/material.dart';

import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';

class EmailField extends StatelessWidget {
  const EmailField({
    super.key,
    required this.controller,
    required this.errorText,
    this.textInputAction = TextInputAction.next,
  });

  final TextEditingController controller;
  final String? errorText;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: context.l10n.email,
      hint: context.l10n.emailHint,
      icon: AppIcons.mail,
      controller: controller,
      errorText: errorText,
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction,
    );
  }
}
