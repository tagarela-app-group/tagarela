import 'package:flutter/material.dart';

import 'package:tagarela/app/auth_gate.dart';
import 'package:tagarela/design_system/design_system.dart';

class TagarelaApp extends StatelessWidget {
  const TagarelaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tagarela',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const AuthGate(),
    );
  }
}
