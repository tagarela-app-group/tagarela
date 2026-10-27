import 'package:flutter/material.dart';

import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/term/logic/card_text.dart';

class MarkedText extends StatelessWidget {
  const MarkedText(
    this.text, {
    super.key,
    required this.style,
    required this.locale,
    required this.markLocale,
    this.lead,
  });

  final String text;
  final TextStyle style;
  final Locale locale;
  final Locale markLocale;
  final String? lead;

  @override
  Widget build(BuildContext context) {
    final mark = TextStyle(
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.w700,
      color: context.colors.ink,
    );
    return Text.rich(
      TextSpan(
        children: [
          if (lead case final lead?)
            TextSpan(
              text: '$lead ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          for (final part in markedParts(text))
            part.marked
                ? TextSpan(text: part.text, style: mark, locale: markLocale)
                : TextSpan(text: part.text),
        ],
      ),
      locale: locale,
      style: style,
    );
  }
}
