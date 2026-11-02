import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

abstract final class AppSpacing {
  static const s05 = 2.0;
  static const s075 = 3.0;
  static const s1 = 4.0;
  static const s15 = 6.0;
  static const s2 = 8.0;
  static const s25 = 10.0;
  static const s3 = 12.0;
  static const s35 = 14.0;
  static const s4 = 16.0;
  static const s45 = 18.0;
  static const s5 = 20.0;
  static const s55 = 22.0;
  static const s6 = 24.0;
  static const s8 = 32.0;
  static const s9 = 36.0;
  static const s10 = 40.0;
  static const s12 = 48.0;
  static const s14 = 56.0;
  static const s19 = 76.0;

  static const screen = s5;
}

abstract final class AppRadius {
  static const xxs = 2.0;
  static const xs = 6.0;
  static const sm = 10.0;
  static const md = 16.0;
  static const lg = 22.0;
  static const xl = 28.0;
  static const sheet = 32.0;
  static const pill = 999.0;

  static BorderRadius bubble(double radius, {bool mirrored = false}) =>
      BorderRadius.only(
        topLeft: Radius.circular(radius),
        topRight: Radius.circular(radius),
        bottomRight: Radius.circular(mirrored ? radius * 0.27 : radius),
        bottomLeft: Radius.circular(mirrored ? radius : radius * 0.27),
      );
}

abstract final class AppIconSize {
  static const dot = 7.0;
  static const xs = 14.0;
  static const sm = 16.0;
  static const md = 18.0;
  static const lg = 20.0;
  static const spinner = 22.0;
  static const xl = 26.0;
  static const xxl = 36.0;
}

abstract final class AppBubbleSize {
  static const xs = 28.0;
  static const sm = 32.0;
  static const md = 40.0;
  static const xl = 52.0;
  static const xxl = 56.0;
  static const hero = 64.0;
  static const avatar = 84.0;
  static const touch = 44.0;
  static const backdrop = 190.0;
}

abstract final class AppFontSize {
  static const caption = 11.0;
  static const label = 14.0;
  static const body = 15.0;
  static const lead = 17.0;
  static const title = 22.0;
  static const mark = 38.0;
}

abstract final class AppBlur {
  static const scrim = 2.0;
  static const obscured = 5.0;
}

abstract final class AppOpacity {
  static const obscured = 0.4;
}

abstract final class AppMotion {
  static const fast = Duration(milliseconds: 120);
  static const base = Duration(milliseconds: 200);
  static const slow = Duration(milliseconds: 320);
  static const toast = Duration(seconds: 5);
  static const reveal = Duration(milliseconds: 700);
  static const flip = Duration(milliseconds: 650);
  static const burst = Duration(milliseconds: 1000);
  static const shuffle = Duration(milliseconds: 480);
  static const shuffleStep = Duration(milliseconds: 640);
  static const shuffleHold = Duration(milliseconds: 1700);
  static const roll = Duration(milliseconds: 520);
  static const rollEvery = Duration(milliseconds: 2200);
  static const typing = Duration(milliseconds: 1200);
  static const replyTyping = Duration(milliseconds: 900);
  static const loadingPatience = Duration(seconds: 12);
  static const wordFirst = Duration(milliseconds: 1200);
  static const wordEvery = Duration(seconds: 30);
  static const wordHop = Duration(milliseconds: 1500);
  static const wordShuffle = Duration(milliseconds: 1700);
  static const wordChat = Duration(milliseconds: 1900);
  static const wordSay = Duration(milliseconds: 1500);
  static const mascotHop = Duration(milliseconds: 760);
  static const mascotTalk = Duration(milliseconds: 240);
  static const standard = Cubic(0.2, 0.8, 0.2, 1);
  static const smooth = Curves.easeInOutCubic;
  static const spring = Curves.easeOutBack;
}
