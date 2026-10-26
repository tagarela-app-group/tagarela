import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'package:tagarela/l10n/generated/app_localizations.dart';

export 'package:tagarela/l10n/generated/app_localizations.dart';

extension L10n on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension Dates on AppLocalizations {
  String shortDate(DateTime date) => DateFormat.Md(localeName).format(date);
}
