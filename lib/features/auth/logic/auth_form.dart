import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/app/home_shell.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/data/stores/auth_store.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/auth/reset_code_page.dart';
import 'package:tagarela/features/auth/verify_email_page.dart';
import 'package:tagarela/l10n/l10n.dart';

enum AuthAction { submit, google, apple, resend }

mixin AuthForm<T extends StatefulWidget> on State<T> {
  AuthAction? loading;
  Map<String?, String> errors = const {};

  bool get busy => loading != null;

  Set<String> get fields;

  AuthStore get auth => AppScope.of(context).auth;

  Future<void> submit<R>(
    Future<R> Function() action,
    void Function(R result) onDone, {
    String? failure,
    AuthAction button = AuthAction.submit,
  }) async {
    setState(() {
      loading = button;
      errors = const {};
    });
    try {
      final result = await action();
      if (mounted) onDone(result);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => errors = e.errors);
      final general = e.errors.entries.where((e) => !fields.contains(e.key));
      if (e.failure case final failure?) {
        AppToast.notice(context, context.l10n.authFailure(failure.name));
      } else if (general.isNotEmpty) {
        AppToast.notice(context, general.first.value);
      }
    } on Exception catch (e) {
      debugPrint('Falha no login: $e');
      if (mounted) {
        AppToast.notice(context, failure ?? context.l10n.authOffline);
      }
    } finally {
      if (mounted) setState(() => loading = null);
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

  VoidCallback? get onGoogle => busy
      ? null
      : () => submit(
          auth.signInWithGoogle,
          onResult,
          failure: context.l10n.googleFailed,
          button: AuthAction.google,
        );

  VoidCallback? get onApple => busy
      ? null
      : () => submit(
          auth.signInWithApple,
          onResult,
          failure: context.l10n.appleFailed,
          button: AuthAction.apple,
        );

  void push(Widget page) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
}
