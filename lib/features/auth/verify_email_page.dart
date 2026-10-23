import 'package:flutter/material.dart';

import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/auth/auth_form.dart';
import 'package:tagarela/features/auth/widgets/auth_header.dart';
import 'package:tagarela/features/auth/widgets/code_step.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({
    super.key,
    required this.email,
    required this.sessionToken,
  });

  final String email;
  final String sessionToken;

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> with AuthForm {
  final _code = TextEditingController();

  @override
  Set<String> get fields => const {'key'};

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SheetPage(
      header: const AuthHeader(
        title: 'Confirme seu e-mail',
        subtitle: 'Falta pouco pra começar.',
      ),
      children: [
        CodeStep(
          email: widget.email,
          controller: _code,
          errorText: errors['key'],
          busy: busy,
          onConfirm: () => submit(
            () => auth.verifyEmail(_code.text, widget.sessionToken),
            onResult,
          ),
          onResend: () =>
              submit(() => auth.resendEmailCode(widget.sessionToken), (_) {}),
          onChangeEmail: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
