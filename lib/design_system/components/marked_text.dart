import 'package:flutter/material.dart';

import 'package:tagarela/design_system/theme.dart';

class MarkedText extends StatelessWidget {
  const MarkedText(
    this.text, {
    super.key,
    required this.style,
    required this.locale,
    required this.markLocale,
    this.lead,
    this.highlighted = false,
  });

  final String text;
  final TextStyle style;
  final Locale locale;
  final Locale markLocale;
  final String? lead;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final mark = TextStyle(
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.w700,
      color: highlighted ? c.primaryText : c.ink,
      backgroundColor: highlighted ? c.primarySoft : null,
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

List<({String text, bool marked})> markedParts(String text) {
  final parts = <({String text, bool marked})>[];
  var at = 0;
  while (at < text.length) {
    final open = text.indexOf('*', at);
    final close = open < 0 ? -1 : text.indexOf('*', open + 1);
    if (close < 0) {
      parts.add((text: text.substring(at), marked: false));
      break;
    }
    if (open > at) parts.add((text: text.substring(at, open), marked: false));
    if (close > open + 1) {
      parts.add((text: text.substring(open + 1, close), marked: true));
    }
    at = close + 1;
  }
  return parts;
}
