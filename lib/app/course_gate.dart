import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/app/home_shell.dart';
import 'package:tagarela/features/course/course_picker_page.dart';

class CourseGate extends StatelessWidget {
  const CourseGate({super.key});

  @override
  Widget build(BuildContext context) {
    final courses = AppScope.of(context).courses;
    return ListenableBuilder(
      listenable: courses,
      builder: (context, _) => switch (courses.data) {
        [] => const CoursePickerPage(),
        _ => const HomeShell(),
      },
    );
  }
}
