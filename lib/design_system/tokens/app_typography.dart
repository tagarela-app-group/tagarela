import 'package:flutter/painting.dart';

abstract final class AppFonts {
  /// Títulos, números e termos em inglês.
  static const display = 'Bricolage';

  /// Texto, rótulos e UI.
  static const body = 'DMSans';
}

/// Escala de texto. Sem cor: herda do tema (`ink`).
abstract final class AppText {
  static const display = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 38,
    height: 42 / 38,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.3,
  );
  static const statLg = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 44,
    height: 48 / 44,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.5,
  );
  static const stat = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 30,
    height: 36 / 30,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.9,
  );
  static const titleLg = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 28,
    height: 34 / 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.56,
  );
  static const titleMd = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 20,
    height: 26 / 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
  );
  static const term = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
  );
  static const titleSm = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 17,
    height: 22 / 17,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
  );
  static const bodyLg = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
  );
  static const bodyMd = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
  );
  static const button = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 15,
    height: 20 / 15,
    fontWeight: FontWeight.w700,
  );
  static const label = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w700,
  );
  static const pill = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w700,
  );

  /// Usar com texto em caixa alta.
  static const overline = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.96,
  );

  /// Usar com texto em caixa alta.
  static const tag = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 10,
    height: 14 / 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
  );
  static const caption = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w600,
  );
}
