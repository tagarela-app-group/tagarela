import 'package:flutter/material.dart';

import 'package:tagarela/design_system/components/app_spinner.dart';
import 'package:tagarela/design_system/components/state_message.dart';
import 'package:tagarela/design_system/tokens/app_colors.dart';
import 'package:tagarela/design_system/tokens/app_icons.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';
import 'package:tagarela/l10n/l10n.dart';

class AsyncStatus extends StatelessWidget {
  const AsyncStatus({super.key, required this.error, required this.onRetry});

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return StateMessage(
        icon: AppIcons.offline,
        accent: AppAccent.coral,
        title: context.l10n.loadFailedTitle,
        message: context.l10n.loadFailedMessage,
        actionLabel: context.l10n.tryAgain,
        onAction: onRetry,
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s10),
      child: const Center(child: AppSpinner()),
    );
  }
}
