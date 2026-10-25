import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/stores/language_store.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';

class LanguageSheet extends StatelessWidget {
  const LanguageSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final language = AppScope.of(context).language;
    final l10n = context.l10n;

    void pick(AppLanguage? choice) {
      language.choose(choice);
      Navigator.pop(context);
    }

    return AppSheet(
      icon: AppIcons.language,
      accent: AppAccent.sky,
      title: l10n.language,
      subtitle: l10n.languageSheetSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.s2,
        children: [
          OptionRow(
            icon: AppIcons.phone,
            accent: AppAccent.violet,
            title: l10n.languageAuto,
            subtitle: l10n.languageAutoHint,
            selected: language.choice == null,
            onTap: () => pick(null),
          ),
          for (final option in AppLanguage.values)
            OptionRow(
              icon: AppIcons.language,
              accent: AppAccent.sky,
              title: option.label,
              selected: language.choice == option,
              onTap: () => pick(option),
            ),
        ],
      ),
    );
  }
}
