import 'dart:ui';

import 'package:tagarela/data/models/json.dart';

enum CourseLanguage {
  en('English', 'US', "Hi, how's it going?"),
  es('Español', 'ES', '¡Hola! ¿Qué tal?'),
  pt('Português', 'BR', 'Oi, tudo bem?');

  const CourseLanguage(this.nativeName, this.country, this.hello);

  final String nativeName;
  final String country;
  final String hello;

  String get code => name.toUpperCase();

  Locale get locale => Locale(name);

  bool get hasAudio => this == en;

  static CourseLanguage? of(String? code) => values.asNameMap()[code];
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
