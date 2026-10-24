import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/auth/login_page.dart';
import 'package:tagarela/features/profile/user_avatar.dart';
import 'package:tagarela/features/profile/widgets/offline_section.dart';
import 'package:tagarela/features/profile/widgets/profile_section.dart';
import 'package:tagarela/features/profile/widgets/progress_card.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge([
        scope.auth,
        scope.captures,
        scope.vocabulary,
      ]),
      builder: (context, _) {
        final user = scope.auth.user;
        final vocabulary = scope.vocabulary.data;
        return SheetPage(
          header: user == null
              ? const PageHeader(title: 'Perfil')
              : PageHeader(
                  title: user.displayName,
                  subtitle: user.email,
                  centered: true,
                  leading: UserAvatar(
                    user: user,
                    size: 84,
                    ring: context.colors.headerChip,
                  ),
                ),
          gap: AppSpacing.s3,
          children: [
            ProgressCard(
              captures: scope.captures.data?.length ?? 0,
              terms: vocabulary?.termCount ?? 0,
              mastered: vocabulary?.masteredCount ?? 0,
            ),
            const OfflineSection(),
            if (user != null)
              ProfileSection(
                title: 'Conta',
                rows: [
                  ProfileRow(
                    icon: AppIcons.mail,
                    accent: AppAccent.violet,
                    title: 'E-mail',
                    text: user.email,
                  ),
                  const ProfileRow(
                    icon: AppIcons.lock,
                    accent: AppAccent.mint,
                    title: 'Privacidade',
                    text:
                        'Foto e áudio ficam só neste celular. '
                        'A API guarda só o texto.',
                  ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.s1),
              child: AppButton(
                label: 'Sair',
                onPressed: () => _logout(context),
                variant: AppButtonVariant.outline,
                expand: true,
              ),
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
