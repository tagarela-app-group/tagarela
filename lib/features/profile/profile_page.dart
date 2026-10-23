import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/auth/login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userStore = AppScope.of(context).user;

    return ListenableBuilder(
      listenable: userStore,
      builder: (context, _) {
        final user = userStore.data;
        return SheetPage(
          header: user == null
              ? const PageHeader(title: 'Perfil')
              : PageHeader(
                  title: user.name,
                  subtitle: user.email,
                  leading: AppBubble(size: 56, child: Text(user.initials)),
                ),
          children: [
            if (user == null)
              AsyncStatus(error: userStore.error, onRetry: userStore.load),
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
