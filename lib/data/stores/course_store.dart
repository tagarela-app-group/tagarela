import 'package:tagarela/data/models.dart';
import 'package:tagarela/data/services/course_service.dart';
import 'package:tagarela/data/store.dart';

class CourseStore extends Store<List<Course>> {
  CourseStore(this._service);

  final CourseService _service;

  Course? get active => data?.where((c) => c.active).firstOrNull;

  @override
  Future<List<Course>> fetch() => _service.fetch();

  Future<Course> start(CourseLanguage learning, CourseLanguage base) async {
    final course = await _service.start(learning, base);
    emit(_activated(course));
    return course;
  }

  Future<void> activate(Course course) async =>
      emit(_activated(await _service.activate(course.id)));

  List<Course> _activated(Course course) {
    final others = [
      for (final c in data ?? const <Course>[])
        if (c.id != course.id) c.copyWith(active: false),
    ];
    final index = data?.indexWhere((c) => c.id == course.id) ?? -1;
    return index < 0 ? [...others, course] : (others..insert(index, course));
  }
}
