import 'package:flutter/material.dart';

import 'package:tagarela/design_system/design_system.dart';

class HighlightedText extends StatelessWidget {
  const HighlightedText({
    super.key,
    required this.text,
    required this.ranges,
    this.style,
    this.maxLines,
    this.locale,
  });

  final String text;
  final List<(int, int)> ranges;
  final TextStyle? style;
  final int? maxLines;
  final Locale? locale;

  static List<(int, int)> find(String text, String term) {
    if (term.isEmpty) return const [];
    return [
      for (final match in RegExp(
        r'(?<![\p{L}\p{N}])' + RegExp.escape(term) + r'(?![\p{L}\p{N}])',
        caseSensitive: false,
        unicode: true,
      ).allMatches(text))
        (match.start, match.end),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final base =
        style ??
        AppText.bodyLg.copyWith(
          fontSize: AppFontSize.body,
          height: 22 / 15,
          color: c.ink,
        );
    final mark = base.copyWith(
      color: c.primaryText,
      backgroundColor: c.primarySoft,
      fontWeight: FontWeight.w700,
    );
    final sorted = [...ranges]..sort((a, b) => a.$1.compareTo(b.$1));
    final spans = <TextSpan>[];
    var at = 0;
    for (final (start, end) in sorted) {
      if (start < at || end > text.length) continue;
      if (start > at) spans.add(TextSpan(text: text.substring(at, start)));
      spans.add(TextSpan(text: text.substring(start, end), style: mark));
      at = end;
    }
    if (at < text.length) spans.add(TextSpan(text: text.substring(at)));
    return Text.rich(
      TextSpan(style: base, children: spans),
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      locale: locale,
    );
  }
}
