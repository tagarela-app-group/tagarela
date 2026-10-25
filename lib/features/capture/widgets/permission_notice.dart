import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';

class PermissionNotice extends StatelessWidget {
  const PermissionNotice({
    super.key,
    required this.icon,
    required this.accent,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final AppAccent accent;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => StateMessage(
    icon: icon,
    accent: accent,
    title: title,
    message: message,
    actionLabel: context.l10n.openSettings,
    onAction: () {
      AppScope.of(context).device.openSettings();
      Navigator.pop(context);
    },
  );
}
