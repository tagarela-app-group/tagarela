import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/auth/login_page.dart';
import 'package:tagarela/features/profile/user_avatar.dart';
import 'package:tagarela/features/profile/widgets/speech_model_card.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AppScope.of(context).auth;

    return ListenableBuilder(
      listenable: auth,
      builder: (context, _) {
        final user = auth.user;
        return SheetPage(
          header: user == null
              ? const PageHeader(title: 'Perfil')
              : PageHeader(
                  title: user.displayName,
                  subtitle: user.email,
                  leading: UserAvatar(user: user, size: 56),
                ),
          children: [
            const SpeechModelCard(),
            AppButton(
              label: 'Sair',
              onPressed: () => _logout(context),
              variant: AppButtonVariant.outline,
              expand: true,
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    await AppScope.of(context).auth.logout();
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }
}
