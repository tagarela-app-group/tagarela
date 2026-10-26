import 'package:flutter/widgets.dart';

import 'package:tagarela/data/models/json.dart';
import 'package:tagarela/data/models/term.dart';
import 'package:tagarela/design_system/tokens/app_colors.dart';
import 'package:tagarela/design_system/tokens/app_icons.dart';

enum GroupIcon {
  layers(AppIcons.layers),
  talk(AppIcons.talk),
  work(AppIcons.work),
  travel(AppIcons.travel),
  food(AppIcons.food),
  tv(AppIcons.tv),
  music(AppIcons.music),
  study(AppIcons.study),
  heart(AppIcons.heart),
  game(AppIcons.game),
  shopping(AppIcons.shopping),
  sport(AppIcons.sport),
  health(AppIcons.health),
  home(AppIcons.home),
  nature(AppIcons.nature),
  paw(AppIcons.paw),
  tech(AppIcons.tech),
  money(AppIcons.money),
  car(AppIcons.car),
  family(AppIcons.family),
  book(AppIcons.book),
  art(AppIcons.art),
  party(AppIcons.party),
  weather(AppIcons.weather),
  phone(AppIcons.phone),
  mail(AppIcons.mail),
  code(AppIcons.code),
  science(AppIcons.science),
  news(AppIcons.news),
  movie(AppIcons.movie),
  camera(AppIcons.camera),
  place(AppIcons.place),
  city(AppIcons.city),
  globe(AppIcons.globe),
  calendar(AppIcons.calendar),
  clock(AppIcons.clock),
  star(AppIcons.star),
  idea(AppIcons.idea),
  smile(AppIcons.smile),
  shirt(AppIcons.shirt),
  restaurant(AppIcons.restaurant),
  drink(AppIcons.drink),
  mountain(AppIcons.mountain),
  gift(AppIcons.gift),
  flag(AppIcons.flag),
  podcast(AppIcons.podcast),
  goal(AppIcons.goal),
  writing(AppIcons.writing);

  const GroupIcon(this.icon);

  final IconData icon;
}

class TermGroup {
  const TermGroup({
    required this.id,
    required this.name,
    required this.icon,
    required this.accent,
    required this.terms,
  });

  TermGroup.fromJson(Json json)
    : this(
        id: json['id']! as String,
        name: json['name']! as String,
        icon:
            GroupIcon.values.asNameMap()[json['icon']]?.icon ??
            AppIcons.vocabulary,
        accent:
            AppAccent.values.asNameMap()[json['accent']] ?? AppAccent.violet,
        terms: _terms(json['terms']),
      );

  final String id;
  final String name;
  final IconData icon;
  final AppAccent accent;
  final List<Term> terms;

  int get masteredCount => terms.masteredCount;

  List<Term> termsWith(TermStatus? status) =>
      status == null ? terms : terms.where((t) => t.status == status).toList();
}

List<Term> _terms(Object? json) => [
  for (final t in json! as List<Object?>) Term.fromJson(t! as Json),
];

class Vocabulary {
  const Vocabulary({this.groups = const [], this.ungrouped = const []});

  Vocabulary.fromJson(Json json)
    : this(
        groups: [
          for (final g in json['groups']! as List<Object?>)
            TermGroup.fromJson(g! as Json),
        ],
        ungrouped: _terms(json['ungrouped']),
      );

  final List<TermGroup> groups;
  final List<Term> ungrouped;

  bool get isEmpty => groups.isEmpty && ungrouped.isEmpty;

  int get termCount =>
      groups.fold(ungrouped.length, (sum, g) => sum + g.terms.length);

  int get masteredCount =>
      groups.fold(ungrouped.masteredCount, (sum, g) => sum + g.masteredCount);

  int get learningCount => termCount - masteredCount;

  TermGroup? group(String id) => groups.where((g) => g.id == id).firstOrNull;

  bool hasGroupNamed(String name, {String? except}) {
    final key = groupNameKey(name);
    return groups.any((g) => g.id != except && groupNameKey(g.name) == key);
  }

  Vocabulary withGroup(TermGroup group) => Vocabulary(
    groups: groups.any((g) => g.id == group.id)
        ? [for (final g in groups) g.id == group.id ? group : g]
        : [group, ...groups],
    ungrouped: ungrouped,
  );

  static String groupNameKey(String name) =>
      name.trim().split(RegExp(r'\s+')).join(' ').toLowerCase();
}

class WordOfDay {
  const WordOfDay({
    required this.text,
    required this.phonetic,
    required this.partOfSpeech,
    required this.translation,
    required this.example,
    required this.dateLabel,
  });

  WordOfDay.fromJson(Json json)
    : this(
        text: json['text']! as String,
        phonetic: json['phonetic']! as String,
        partOfSpeech: json['partOfSpeech']! as String,
        translation: json['translation']! as String,
        example: json['example']! as String,
        dateLabel: json['dateLabel']! as String,
      );

  final String text;
  final String phonetic;
  final String partOfSpeech;
  final String translation;
  final String example;
  final String dateLabel;
}
