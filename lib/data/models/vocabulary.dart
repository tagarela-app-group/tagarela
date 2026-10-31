import 'package:tagarela/data/models/json.dart';
import 'package:tagarela/data/models/term.dart';

enum GroupIcon {
  layers,
  talk,
  work,
  travel,
  food,
  tv,
  music,
  study,
  heart,
  game,
  shopping,
  sport,
  health,
  home,
  nature,
  paw,
  tech,
  money,
  car,
  family,
  book,
  art,
  party,
  weather,
  phone,
  mail,
  code,
  science,
  news,
  movie,
  camera,
  place,
  city,
  globe,
  calendar,
  clock,
  star,
  idea,
  smile,
  shirt,
  restaurant,
  drink,
  mountain,
  gift,
  flag,
  podcast,
  goal,
  writing,
}

enum GroupColor {
  violet,
  coral,
  mint,
  mango,
  sky,
  pink,
  grape,
  cocoa,
  lime,
  gold,
  teal,
  slate,
}

class TermGroup {
  const TermGroup({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.terms,
  });

  TermGroup.fromJson(Json json)
    : this(
        id: json['id']! as String,
        name: json['name']! as String,
        icon: GroupIcon.values.asNameMap()[json['icon']],
        color:
            GroupColor.values.asNameMap()[json['accent']] ?? GroupColor.violet,
        terms: _terms(json['terms']),
      );

  final String id;
  final String name;
  final GroupIcon? icon;
  final GroupColor color;
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
