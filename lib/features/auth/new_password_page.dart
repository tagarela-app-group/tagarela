import 'package:flutter/material.dart';

import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/auth/logic/auth_form.dart';
import 'package:tagarela/features/auth/widgets/auth_header.dart';
import 'package:tagarela/l10n/l10n.dart';

class NewPasswordPage extends StatefulWidget {
  const NewPasswordPage({
    super.key,
    required this.code,
    required this.sessionToken,
  });

  final String code;
  final String sessionToken;

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> with AuthForm {
  final _password = TextEditingController();

  @override
  Set<String> get fields => const {'password'};

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      header: AuthHeader(
        title: context.l10n.newPasswordTitle,
        subtitle: context.l10n.newPasswordSubtitle,
      ),
      gap: AppSpacing.s4,
      children: [
        Text(
          context.l10n.newPasswordBody,
          style: AppText.bodyLg.copyWith(color: context.colors.inkSoft),
        ),
        AppTextField(
          label: context.l10n.newPasswordTitle,
          hint: context.l10n.newPasswordHint,
          icon: AppIcons.lock,
          controller: _password,
          helperText: context.l10n.newPasswordHelper,
          errorText: errors['password'],
          obscure: true,
          textInputAction: TextInputAction.done,
        ),
        AppButton(
          label: context.l10n.saveAndSignIn,
          onPressed: busy
              ? null
              : () => submit(
                  () => auth.resetPassword(
                    widget.code,
                    _password.text,
                    widget.sessionToken,
                  ),
                  onResult,
                ),
          loading: busy,
          size: AppButtonSize.large,
          expand: true,
        ),
      ],
    );
  }
}
