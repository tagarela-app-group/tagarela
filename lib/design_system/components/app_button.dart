import 'package:flutter/material.dart';

import 'package:tagarela/design_system/components/app_spinner.dart';
import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_colors.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';
import 'package:tagarela/design_system/tokens/app_typography.dart';

enum AppButtonVariant {
  primary,
  tonal,
  danger,
  outline,
  ink,
  contrast,
  text,
  onHeader,
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
    this.loading = false,
    this.maxLines = 1,
    this.locale,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final AppButtonVariant variant;
  final AppButtonSize size;

  final bool expand;
  final bool loading;
  final int maxLines;
  final Locale? locale;

  static void _ignore() {}

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isText = variant == AppButtonVariant.text;
    final (bg, fg) = switch (variant) {
      AppButtonVariant.primary => (c.primary, c.onPrimary),
      AppButtonVariant.tonal => (c.primarySoft, c.primaryText),
      AppButtonVariant.danger => (c.alert, c.onAlert),
      AppButtonVariant.outline => (Colors.transparent, c.ink),
      AppButtonVariant.ink => (AppPalette.ink, AppPalette.white),
      AppButtonVariant.contrast => (c.contrast, c.onContrast),
      AppButtonVariant.text => (Colors.transparent, c.primaryText),
      AppButtonVariant.onHeader => (c.headerChip, AppPalette.white),
    };
    final radius = variant == AppButtonVariant.onHeader
        ? AppRadius.pill
        : AppRadius.md;

    final enabled = onPressed != null || loading;
    final button = TextButton(
      onPressed: loading ? _ignore : onPressed,
      style: TextButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        disabledBackgroundColor: isText ? Colors.transparent : c.surfaceAlt,
        disabledForegroundColor: c.inkSoft,
        minimumSize: Size(expand ? double.infinity : 0, size.height),
        padding: maxLines > 1
            ? const EdgeInsets.symmetric(
                horizontal: AppSpacing.s3,
                vertical: AppSpacing.s2,
              )
            : EdgeInsets.symmetric(
                horizontal: isText ? AppSpacing.s2 : AppSpacing.s5,
              ),
        textStyle: size == AppButtonSize.large
            ? AppText.button.copyWith(fontSize: 16)
            : AppText.button,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        side: variant == AppButtonVariant.outline
            ? BorderSide(color: c.line, width: 1.5)
            : null,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.s3,
        children: [
          ?(loading ? AppSpinner(size: 18, color: fg) : leading),
          Flexible(
            child: Text(
              label,
              locale: locale,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );

    final hasShadow =
        variant == AppButtonVariant.primary &&
        size == AppButtonSize.large &&
        enabled;
    final body = IgnorePointer(ignoring: loading, child: button);
    if (!hasShadow) return body;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: c.buttonShadow,
      ),
      child: body,
    );
  }
}
