import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:tagarela/app/app.dart';
import 'package:tagarela/app/app_dependencies.dart';
import 'package:tagarela/app/app_environment.dart';
import 'package:tagarela/app/app_scope.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final environment = await AppEnvironment.load();
  runApp(
    AppScope(
      dependencies: AppDependencies.live(environment),
      child: const TagarelaApp(),
    ),
  );
}
