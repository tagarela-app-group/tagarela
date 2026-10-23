import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

abstract final class AppSpacing {
  static const s1 = 4.0;
  static const s2 = 8.0;
  static const s3 = 12.0;
  static const s4 = 16.0;
  static const s5 = 20.0;
  static const s6 = 24.0;
  static const s8 = 32.0;
  static const s10 = 40.0;
  static const s14 = 56.0;

  static const screen = s5;
}

abstract final class AppRadius {
  static const xs = 6.0;
  static const sm = 10.0;
  static const md = 16.0;
  static const lg = 22.0;
  static const xl = 28.0;
  static const sheet = 32.0;
  static const pill = 999.0;

  static BorderRadius bubble(double radius) => BorderRadius.only(
    topLeft: Radius.circular(radius),
    topRight: Radius.circular(radius),
    bottomRight: Radius.circular(radius),
    bottomLeft: Radius.circular(radius * 0.27),
  );
}

abstract final class AppBlur {
  static const scrim = 2.0;
}

abstract final class AppMotion {
  static const fast = Duration(milliseconds: 120);
  static const base = Duration(milliseconds: 200);
  static const slow = Duration(milliseconds: 320);
  static const standard = Cubic(0.2, 0.8, 0.2, 1);
  static const spring = Curves.easeOutBack;
}
