import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/app/home_shell.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/auth/login_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Future<bool> _restored = _restore();

  Future<bool> _restore() async {
    final scope = AppScope.of(context);
    final signedIn = await scope.auth.restore();
    if (signedIn) scope.loadAll();
    return signedIn;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _restored,
      builder: (context, snapshot) => switch (snapshot.data) {
        null => const _Splash(),
        true => const HomeShell(),
        false => const LoginPage(),
      },
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.header,
      body: const Center(
        child: AppBubble(
          size: 64,
          child: Text('t', style: TextStyle(fontSize: 38)),
        ),
      ),
    );
  }
}
