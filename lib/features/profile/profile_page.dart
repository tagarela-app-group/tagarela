import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/auth/login_page.dart';
import 'package:tagarela/features/course/modals/course_modal.dart';
import 'package:tagarela/features/profile/modals/country_modal.dart';
import 'package:tagarela/features/profile/widgets/offline_section.dart';
import 'package:tagarela/features/profile/widgets/profile_section.dart';
import 'package:tagarela/features/profile/widgets/progress_card.dart';
import 'package:tagarela/shared/widgets/user_avatar.dart';
import 'package:tagarela/l10n/countries/countries.dart';
import 'package:tagarela/l10n/l10n.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static Future<void> open(BuildContext context) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const ProfilePage()));

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge([
        scope.auth,
        scope.courses,
        scope.vocabulary,
      ]),
      builder: (context, _) {
        final user = scope.auth.user;
        final course = scope.courses.active;
        final vocabulary = scope.vocabulary.data;
        final progress = ProgressCard(
          terms: vocabulary?.termCount ?? 0,
          learning: vocabulary?.learningCount ?? 0,
          mastered: vocabulary?.masteredCount ?? 0,
        );
        final l10n = context.l10n;
        return AppPage(
          header: Stack(
            children: [
              if (user == null)
                PageHeader(title: l10n.tabProfile, centered: true)
              else
                PageHeader(
                  title: user.displayName,
                  subtitle: user.email,
                  centered: true,
                  leading: UserAvatar(
                    user: user,
                    size: AppBubbleSize.avatar,
                    ring: context.colors.headerChip,
                  ),
                ),
              Positioned(
                top: 0,
                left: 0,
                child: AppIconButton(
                  icon: AppIcons.back,
                  tooltip: l10n.back,
                  onPressed: () => Navigator.maybePop(context),
                  variant: AppIconButtonVariant.onHeader,
                ),
              ),
            ],
          ),
          gap: AppSpacing.s3,
          children: [
            if (course == null)
              progress
            else ...[
              ProfileSection(
                title: l10n.profileStudy,
                rows: [
                  ProfileRow(
                    leading: FlagPair(
                      back: course.base.country,
                      front: course.learning.country,
                    ),
                    title: l10n.coursePair(
                      course.base.name,
                      course.learning.name,
                    ),
                    text: l10n.courseCount(scope.courses.data!.length),
                    onTap: () => CourseModal.show(context),
                  ),
                ],
              ),
              ProfileSection(
                title: l10n.progressIn(course.learning.name),
                child: progress,
              ),
            ],
            const OfflineSection(),
            if (user != null)
              ProfileSection(
                title: l10n.account,
                rows: [
                  ProfileRow(
                    icon: AppIcons.mail,
                    accent: AppAccent.violet,
                    title: l10n.email,
                    text: user.email,
                  ),
                  ProfileRow(
                    icon: AppIcons.flag,
                    accent: AppAccent.mango,
                    title: l10n.countryOfOrigin,
                    text: switch (user.country) {
                      final country? => l10n.countryName(country) ?? country,
                      null => l10n.countryNotSet,
                    },
                    onTap: () => AppModal.show<void>(
                      context,
                      (_) => const CountryModal(),
                    ),
                  ),
                  ProfileRow(
                    icon: AppIcons.lock,
                    accent: AppAccent.mint,
                    title: l10n.privacy,
                    text: l10n.privacyText,
                  ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.s1),
              child: AppButton(
                label: l10n.signOut,
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
    await AppScope.of(context).session.signOut();
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }
}
