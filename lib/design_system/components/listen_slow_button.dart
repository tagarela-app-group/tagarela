import 'package:flutter/material.dart';

import 'package:tagarela/design_system/components/app_button.dart';
import 'package:tagarela/design_system/components/drawn_icon.dart';
import 'package:tagarela/design_system/tokens/app_icons.dart';
import 'package:tagarela/l10n/l10n.dart';

class ListenSlowButton extends StatelessWidget {
  const ListenSlowButton({
    super.key,
    required this.playing,
    required this.onPressed,
  });

  final bool playing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: context.l10n.listenSlow,
      variant: AppButtonVariant.onHeader,
      size: AppButtonSize.small,
      leading: playing
          ? const Icon(AppIcons.stop, size: 18)
          : const DrawnIcon(DrawnGlyph.turtle, size: 20),
      onPressed: onPressed,
    );
  }
}
