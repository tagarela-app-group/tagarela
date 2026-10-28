import 'package:flutter/material.dart';

import 'package:tagarela/app/app.dart';
import 'package:tagarela/app/app_dependencies.dart';
import 'package:tagarela/app/app_scope.dart';

void main() => runApp(
  AppScope(dependencies: AppDependencies.live(), child: const TagarelaApp()),
);
