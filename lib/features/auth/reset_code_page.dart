import 'package:flutter/material.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/auth/logic/auth_form.dart';
import 'package:tagarela/features/auth/new_password_page.dart';
import 'package:tagarela/features/auth/widgets/auth_header.dart';
import 'package:tagarela/features/auth/widgets/code_step.dart';
import 'package:tagarela/l10n/l10n.dart';

class ResetCodePage extends StatefulWidget {
  const ResetCodePage({
    super.key,
    required this.email,
    required this.sessionToken,
  });

  final String email;
  final String sessionToken;

  @override
  State<ResetCodePage> createState() => _ResetCodePageState();
}

class _ResetCodePageState extends State<ResetCodePage> with AuthForm {
  final _code = TextEditingController();
  late String _sessionToken = widget.sessionToken;

  @override
  Set<String> get fields => const {'key'};

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _confirm() {
    final code = _code.text;
    submit(
      () => auth.checkResetCode(code, _sessionToken),
      (_) => push(NewPasswordPage(code: code, sessionToken: _sessionToken)),
    );
  }

  Future<void> _resend() =>
      submit(() => auth.requestPasswordReset(widget.email), (result) {
        if (result is AuthPending) _sessionToken = result.sessionToken;
      }, button: AuthAction.resend);

  @override
  Widget build(BuildContext context) {
    return AppPage(
      header: AuthHeader(
        title: context.l10n.resetCodeTitle,
        subtitle: context.l10n.resetCodeSubtitle,
      ),
      children: [
        CodeStep(
          email: widget.email,
          controller: _code,
          errorText: errors['key'],
          loading: loading,
          onConfirm: _confirm,
          onResend: _resend,
          onChangeEmail: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
