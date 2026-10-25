import 'package:flutter/material.dart';

abstract final class AppPalette {
  static const violet = Color(0xFF5B47F5);
  static const mango = Color(0xFFFFB23F);
  static const amber = Color(0xFFF5A524);
  static const mint = Color(0xFF12B886);
  static const coral = Color(0xFFFF5D5D);
  static const ink = Color(0xFF17152B);
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
}

enum AppAccent { violet, coral, mint, mango, sky, pink }

class AccentColors {
  const AccentColors(this.soft, this.fg);

  final Color soft;
  final Color fg;
}

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.header,
    required this.headerChip,
    required this.onHeaderSoft,
    required this.bg,
    required this.surface,
    required this.surfaceAlt,
    required this.line,
    required this.ink,
    required this.inkSoft,
    required this.primary,
    required this.onPrimary,
    required this.primaryText,
    required this.primarySoft,
    required this.primaryRing,
    required this.learning,
    required this.learningSoft,
    required this.learningText,
    required this.mastered,
    required this.masteredSoft,
    required this.masteredText,
    required this.alert,
    required this.onAlert,
    required this.contrast,
    required this.onContrast,
    required this.scrim,
    required this.cardShadow,
    required this.buttonShadow,
    required this.fabShadow,
    required this.fabRing,
    required this.accents,
  });

  final Color header;
  final Color headerChip;
  final Color onHeaderSoft;
  final Color bg;
  final Color surface;
  final Color surfaceAlt;
  final Color line;
  final Color ink;
  final Color inkSoft;
  final Color primary;
  final Color onPrimary;
  final Color primaryText;
  final Color primarySoft;
  final Color primaryRing;
  final Color learning;
  final Color learningSoft;
  final Color learningText;
  final Color mastered;
  final Color masteredSoft;
  final Color masteredText;
  final Color alert;
  final Color onAlert;
  final Color contrast;
  final Color onContrast;
  final Color scrim;
  final List<BoxShadow> cardShadow;
  final List<BoxShadow> buttonShadow;
  final List<BoxShadow> fabShadow;
  final Color fabRing;
  final Map<AppAccent, AccentColors> accents;

  AccentColors accent(AppAccent accent) => accents[accent]!;

  static const light = AppColors(
    header: AppPalette.violet,
    headerChip: Color(0x29FFFFFF),
    onHeaderSoft: Color(0xE0FFFFFF),
    bg: Color(0xFFF5F4FA),
    surface: AppPalette.white,
    surfaceAlt: Color(0xFFECEAF6),
    line: Color(0xFFE2DFEF),
    ink: AppPalette.ink,
    inkSoft: Color(0xFF615E78),
    primary: AppPalette.violet,
    onPrimary: AppPalette.white,
    primaryText: Color(0xFF4B37E6),
    primarySoft: Color(0xFFE8E5FE),
    primaryRing: Color(0x2E5B47F5),
    learning: AppPalette.amber,
    learningSoft: Color(0xFFFFF0D4),
    learningText: Color(0xFF8A5300),
    mastered: AppPalette.mint,
    masteredSoft: Color(0xFFD6F5EA),
    masteredText: Color(0xFF0A6B4F),
    alert: Color(0xFFD93636),
    onAlert: AppPalette.white,
    contrast: AppPalette.black,
    onContrast: AppPalette.white,
    scrim: Color(0x9E17152B),
    cardShadow: [
      BoxShadow(color: Color(0x0A17152B), offset: Offset(0, 1), blurRadius: 2),
      BoxShadow(color: Color(0x0F17152B), offset: Offset(0, 8), blurRadius: 24),
    ],
    buttonShadow: [
      BoxShadow(color: Color(0x475B47F5), offset: Offset(0, 8), blurRadius: 20),
    ],
    fabShadow: [
      BoxShadow(
        color: Color(0x665B47F5),
        offset: Offset(0, 12),
        blurRadius: 24,
      ),
    ],
    fabRing: AppPalette.white,
    accents: {
      AppAccent.violet: AccentColors(Color(0xFFE8E5FE), Color(0xFF4B37E6)),
      AppAccent.coral: AccentColors(Color(0xFFFFE4E1), Color(0xFFC93030)),
      AppAccent.mint: AccentColors(Color(0xFFD6F5EA), Color(0xFF0A7F5C)),
      AppAccent.mango: AccentColors(Color(0xFFFFF0D4), Color(0xFFA35F00)),
      AppAccent.sky: AccentColors(Color(0xFFDDEFFF), Color(0xFF1F6FD1)),
      AppAccent.pink: AccentColors(Color(0xFFFCE3F4), Color(0xFFB8338F)),
    },
  );

  static const dark = AppColors(
    header: Color(0xFF241D5C),
    headerChip: Color(0x1AFFFFFF),
    onHeaderSoft: Color(0xBDFFFFFF),
    bg: Color(0xFF0F0E17),
    surface: Color(0xFF1A1826),
    surfaceAlt: Color(0xFF252233),
    line: Color(0xFF2D2A3D),
    ink: Color(0xFFF2F0FF),
    inkSoft: Color(0xFFA9A5C2),
    primary: Color(0xFF8B7BFF),
    onPrimary: Color(0xFF0F0E17),
    primaryText: Color(0xFFA99DFF),
    primarySoft: Color(0x2E8B7BFF),
    primaryRing: Color(0x408B7BFF),
    learning: AppPalette.amber,
    learningSoft: Color(0x29F5A524),
    learningText: Color(0xFFFFC266),
    mastered: Color(0xFF20C997),
    masteredSoft: Color(0x2920C997),
    masteredText: Color(0xFF4FD6A8),
    alert: Color(0xFFFF8A80),
    onAlert: AppPalette.ink,
    contrast: AppPalette.white,
    onContrast: AppPalette.black,
    scrim: Color(0xB805040C),
    cardShadow: [BoxShadow(color: Color(0x0DFFFFFF), spreadRadius: 1)],
    buttonShadow: [],
    fabShadow: [
      BoxShadow(
        color: Color(0x4D8B7BFF),
        offset: Offset(0, 12),
        blurRadius: 24,
      ),
    ],
    fabRing: Color(0xFF1A1826),
    accents: {
      AppAccent.violet: AccentColors(Color(0x2E8B7BFF), Color(0xFFA99DFF)),
      AppAccent.coral: AccentColors(Color(0x29FF5D5D), Color(0xFFFF8A80)),
      AppAccent.mint: AccentColors(Color(0x2920C997), Color(0xFF4FD6A8)),
      AppAccent.mango: AccentColors(Color(0x29FFB23F), Color(0xFFFFC266)),
      AppAccent.sky: AccentColors(Color(0x293BA4FF), Color(0xFF7CC0FF)),
      AppAccent.pink: AccentColors(Color(0x29F062C0), Color(0xFFF590D6)),
    },
  );

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(covariant AppColors? other, double t) =>
      t < 0.5 ? this : (other ?? this);
}
