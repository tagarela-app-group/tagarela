import 'package:flutter/widgets.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';

extension TermGroupStyle on TermGroup {
  IconData get glyph => icon?.glyph ?? AppIcons.vocabulary;

  AppAccent get accent => color.accent;
}

extension GroupIconGlyph on GroupIcon {
  IconData get glyph => switch (this) {
    GroupIcon.layers => AppIcons.layers,
    GroupIcon.talk => AppIcons.talk,
    GroupIcon.work => AppIcons.work,
    GroupIcon.travel => AppIcons.travel,
    GroupIcon.food => AppIcons.food,
    GroupIcon.tv => AppIcons.tv,
    GroupIcon.music => AppIcons.music,
    GroupIcon.study => AppIcons.study,
    GroupIcon.heart => AppIcons.heart,
    GroupIcon.game => AppIcons.game,
    GroupIcon.shopping => AppIcons.shopping,
    GroupIcon.sport => AppIcons.sport,
    GroupIcon.health => AppIcons.health,
    GroupIcon.home => AppIcons.home,
    GroupIcon.nature => AppIcons.nature,
    GroupIcon.paw => AppIcons.paw,
    GroupIcon.tech => AppIcons.tech,
    GroupIcon.money => AppIcons.money,
    GroupIcon.car => AppIcons.car,
    GroupIcon.family => AppIcons.family,
    GroupIcon.book => AppIcons.book,
    GroupIcon.art => AppIcons.art,
    GroupIcon.party => AppIcons.party,
    GroupIcon.weather => AppIcons.weather,
    GroupIcon.phone => AppIcons.phone,
    GroupIcon.mail => AppIcons.mail,
    GroupIcon.code => AppIcons.code,
    GroupIcon.science => AppIcons.science,
    GroupIcon.news => AppIcons.news,
    GroupIcon.movie => AppIcons.movie,
    GroupIcon.camera => AppIcons.camera,
    GroupIcon.place => AppIcons.place,
    GroupIcon.city => AppIcons.city,
    GroupIcon.globe => AppIcons.globe,
    GroupIcon.calendar => AppIcons.calendar,
    GroupIcon.clock => AppIcons.clock,
    GroupIcon.star => AppIcons.star,
    GroupIcon.idea => AppIcons.idea,
    GroupIcon.smile => AppIcons.smile,
    GroupIcon.shirt => AppIcons.shirt,
    GroupIcon.restaurant => AppIcons.restaurant,
    GroupIcon.drink => AppIcons.drink,
    GroupIcon.mountain => AppIcons.mountain,
    GroupIcon.gift => AppIcons.gift,
    GroupIcon.flag => AppIcons.flag,
    GroupIcon.podcast => AppIcons.podcast,
    GroupIcon.goal => AppIcons.goal,
    GroupIcon.writing => AppIcons.writing,
  };
}

extension GroupColorAccent on GroupColor {
  AppAccent get accent => AppAccent.values.byName(name);

  static GroupColor of(AppAccent accent) =>
      GroupColor.values.byName(accent.name);
}
