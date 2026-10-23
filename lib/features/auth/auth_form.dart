import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/app/home_shell.dart';
import 'package:tagarela/data/services/auth_service.dart';
import 'package:tagarela/data/stores/auth_store.dart';
import 'package:tagarela/features/auth/reset_code_page.dart';
import 'package:tagarela/features/auth/verify_email_page.dart';

mixin AuthForm<T extends StatefulWidget> on State<T> {
  static const offline = 'Sem conexão com o servidor. Tente de novo.';

  bool busy = false;
  Map<String?, String> errors = const {};

  Set<String> get fields;

  AuthStore get auth => AppScope.of(context).auth;

  Future<void> submit<R>(
    Future<R> Function() action,
    void Function(R result) onDone, {
    String failure = offline,
  }) async {
    setState(() {
      busy = true;
      errors = const {};
    });
    try {
      final result = await action();
      if (mounted) onDone(result);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => errors = e.errors);
      final general = e.errors.entries.where((e) => !fields.contains(e.key));
      if (general.isNotEmpty) _show(general.first.value);
    } on Exception {
      if (mounted) _show(failure);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void onResult(AuthResult? result, {String email = ''}) {
    switch (result) {
      case AuthSignedIn():
        HomeShell.open(context);
      case AuthPending(step: AuthStep.verifyEmail, :final sessionToken):
        push(VerifyEmailPage(email: email, sessionToken: sessionToken));
      case AuthPending(step: AuthStep.resetPassword, :final sessionToken):
        push(ResetCodePage(email: email, sessionToken: sessionToken));
      case null:
        return;
    }
  }

  void push(Widget page) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  void _show(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
}
