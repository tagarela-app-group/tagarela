import 'package:flutter/widgets.dart';

import 'package:tagarela/app/app_dependencies.dart';

class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.dependencies, required super.child});

  final AppDependencies dependencies;

  static AppDependencies of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.dependencies;

  @override
  bool updateShouldNotify(AppScope oldWidget) => false;
}
