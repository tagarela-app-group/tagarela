import 'package:flutter/material.dart';

import 'package:tagarela/design_system/components/state_message.dart';
import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_colors.dart';
import 'package:tagarela/design_system/tokens/app_icons.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';

/// Body enquanto o dado não chega: carregando, ou erro com "Tentar de novo".
class AsyncStatus extends StatelessWidget {
  const AsyncStatus({super.key, required this.error, required this.onRetry});

  /// `null` = carregando.
  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return StateMessage(
        icon: AppIcons.offline,
        accent: AppAccent.coral,
        title: 'Não deu pra carregar',
        message: 'Confira sua conexão e tente de novo.',
        actionLabel: 'Tentar de novo',
        onAction: onRetry,
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s10),
      child: Center(
        child: CircularProgressIndicator(
          color: context.colors.primary,
          semanticsLabel: 'Carregando',
        ),
      ),
    );
  }
}
