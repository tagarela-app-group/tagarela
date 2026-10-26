import 'package:tagarela/data/models/json.dart';

enum CourseLanguage {
  en('English'),
  es('Español'),
  pt('Português');

  const CourseLanguage(this.nativeName);

  final String nativeName;

  String get code => name.toUpperCase();

  bool get hasAudio => this == en;
}

class Course {
  const Course({
    required this.id,
    required this.learning,
    required this.base,
    this.active = false,
    this.terms = 0,
  });

  Course.fromJson(Json json)
    : this(
        id: json['id']! as String,
        learning: CourseLanguage.values.byName(json['learning']! as String),
        base: CourseLanguage.values.byName(json['base']! as String),
        active: json['active']! as bool,
        terms: json['terms']! as int,
      );

  final String id;
  final CourseLanguage learning;
  final CourseLanguage base;
  final bool active;
  final int terms;

  Course copyWith({bool? active}) => Course(
    id: id,
    learning: learning,
    base: base,
    active: active ?? this.active,
    terms: terms,
  );
}
