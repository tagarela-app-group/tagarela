import 'package:flutter/material.dart';

import 'package:tagarela/design_system/tokens/app_colors.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';
import 'package:tagarela/design_system/tokens/app_typography.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(AppColors.light, Brightness.light);
  static ThemeData get dark => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors c, Brightness brightness) {
    return ThemeData(
      brightness: brightness,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: c.primary,
        onPrimary: c.onPrimary,
        secondary: AppPalette.mango,
        onSecondary: AppPalette.ink,
        error: c.alert,
        onError: c.onAlert,
        surface: c.surface,
        onSurface: c.ink,
        outline: c.line,
      ),
      scaffoldBackgroundColor: c.bg,
      fontFamily: AppFonts.body,
      dividerColor: c.line,
      textSelectionTheme: TextSelectionThemeData(cursorColor: c.primary),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.ink,
        contentTextStyle: AppText.bodyMd.copyWith(color: c.bg),
        actionTextColor: brightness == Brightness.light
            ? AppPalette.mango
            : AppColors.light.primaryText,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      extensions: [c],
    );
  }
}

extension AppThemeContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
