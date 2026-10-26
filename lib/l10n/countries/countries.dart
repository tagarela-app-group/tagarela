import 'package:tagarela/l10n/countries/country_names.dart';
import 'package:tagarela/l10n/generated/app_localizations.dart';

typedef Country = ({String code, String name});

extension Countries on AppLocalizations {
  String? countryName(String code) => switch (countryNames[code]) {
    (final pt, final en, final es) => switch (localeName) {
      'en' => en,
      'es' => es,
      _ => pt,
    },
    null => null,
  };

  List<Country> countries() => [
    for (final code in countryNames.keys)
      (code: code, name: countryName(code)!),
  ]..sort((a, b) => foldText(a.name).compareTo(foldText(b.name)));
}

String foldText(String text) {
  final lower = text.toLowerCase();
  final out = StringBuffer();
  for (final char in lower.split('')) {
    out.write(_plain[char] ?? char);
  }
  return out.toString();
}

const _plain = {
  'á': 'a',
  'à': 'a',
  'â': 'a',
  'ã': 'a',
  'ä': 'a',
  'å': 'a',
  'é': 'e',
  'è': 'e',
  'ê': 'e',
  'ë': 'e',
  'í': 'i',
  'ì': 'i',
  'î': 'i',
  'ï': 'i',
  'ó': 'o',
  'ò': 'o',
  'ô': 'o',
  'õ': 'o',
  'ö': 'o',
  'ø': 'o',
  'ú': 'u',
  'ù': 'u',
  'û': 'u',
  'ü': 'u',
  'ç': 'c',
  'ñ': 'n',
  'ý': 'y',
  'ÿ': 'y',
  '’': "'",
};
