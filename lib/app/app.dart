import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/app/auth_gate.dart';
import 'package:tagarela/data/stores/language_store.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';

class TagarelaApp extends StatelessWidget {
  const TagarelaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final language = AppScope.of(context).language;
    return ListenableBuilder(
      listenable: language,
      builder: (context, _) => MaterialApp(
        title: 'Tagarela',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        locale: language.locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        localeListResolutionCallback: (preferred, supported) =>
            appLocale(preferred ?? const [], supported),
        home: const AuthGate(),
      ),
    );
  }
}
