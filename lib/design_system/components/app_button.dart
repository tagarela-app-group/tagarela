import 'package:flutter/material.dart';

import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_colors.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';
import 'package:tagarela/design_system/tokens/app_typography.dart';

enum AppButtonVariant {
  /// Ação principal. Um por tela.
  primary,
  tonal,
  outline,

  /// Sobre fundo manga.
  ink,
  text,
}

enum AppButtonSize {
  large(56),
  medium(48),
  small(44);

  const AppButtonSize(this.height);

  final double height;
}

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leading,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final AppButtonVariant variant;
  final AppButtonSize size;

  /// Ocupa toda a largura disponível.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isText = variant == AppButtonVariant.text;
    final (bg, fg) = switch (variant) {
      AppButtonVariant.primary => (c.primary, c.onPrimary),
      AppButtonVariant.tonal => (c.primarySoft, c.primaryText),
      AppButtonVariant.outline => (Colors.transparent, c.ink),
      AppButtonVariant.ink => (AppPalette.ink, AppPalette.white),
      AppButtonVariant.text => (Colors.transparent, c.primaryText),
    };

    final button = TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        disabledBackgroundColor: isText ? Colors.transparent : c.surfaceAlt,
        disabledForegroundColor: c.inkSoft,
        minimumSize: Size(expand ? double.infinity : 0, size.height),
        padding: EdgeInsets.symmetric(
          horizontal: isText ? AppSpacing.s2 : AppSpacing.s5,
        ),
        textStyle: size == AppButtonSize.large
            ? AppText.button.copyWith(fontSize: 16)
            : AppText.button,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        side: variant == AppButtonVariant.outline
            ? BorderSide(color: c.line, width: 1.5)
            : null,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.s3,
        children: [?leading, Text(label)],
      ),
    );

    final hasShadow =
        variant == AppButtonVariant.primary &&
        size == AppButtonSize.large &&
        onPressed != null;
    if (!hasShadow) return button;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: c.buttonShadow,
      ),
      child: button,
    );
  }
}
