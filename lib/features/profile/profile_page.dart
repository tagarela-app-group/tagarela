import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/stores/language_store.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/auth/login_page.dart';
import 'package:tagarela/features/course/widgets/course_bubble.dart';
import 'package:tagarela/features/course/widgets/course_sheet.dart';
import 'package:tagarela/features/profile/user_avatar.dart';
import 'package:tagarela/features/profile/widgets/country_sheet.dart';
import 'package:tagarela/features/profile/widgets/language_sheet.dart';
import 'package:tagarela/features/profile/widgets/offline_section.dart';
import 'package:tagarela/features/profile/widgets/profile_section.dart';
import 'package:tagarela/features/profile/widgets/progress_card.dart';
import 'package:tagarela/l10n/countries.dart';
import 'package:tagarela/l10n/l10n.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge([
        scope.auth,
        scope.courses,
        scope.vocabulary,
        scope.language,
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
        return SheetPage(
          header: user == null
              ? PageHeader(title: l10n.tabProfile)
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
            if (course == null)
              progress
            else ...[
              ProfileSection(
                title: l10n.profileStudy,
                rows: [
                  ProfileRow(
                    leading: CourseBubble(language: course.learning, size: 40),
                    title: l10n.courseName(
                      course.learning.name,
                      course.base.name,
                    ),
                    text: l10n.courseChange,
                    onTap: () => CourseSheet.show(context),
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
                    onTap: () => AppSheet.show<void>(
                      context,
                      (_) => const CountrySheet(),
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
            ProfileSection(
              title: l10n.preferences,
              rows: [
                ProfileRow(
                  icon: AppIcons.language,
                  accent: AppAccent.sky,
                  title: l10n.language,
                  text: switch (scope.language.choice) {
                    final choice? => choice.label,
                    null => l10n.languageAutoValue(
                      AppLanguage.resolve([
                        Localizations.localeOf(context),
                      ]).label,
                    ),
                  },
                  onTap: () => AppSheet.show<void>(
                    context,
                    (_) => const LanguageSheet(),
                  ),
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
    await AppScope.of(context).auth.logout();
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }
}
