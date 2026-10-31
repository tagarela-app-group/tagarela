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
    final haystack = text.toLowerCase();
    final needle = term.toLowerCase();
    if (needle.isEmpty) return const [];
    return [
      for (
        var i = haystack.indexOf(needle);
        i >= 0;
        i = haystack.indexOf(needle, i + needle.length)
      )
        (i, i + needle.length),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final base =
        style ??
        AppText.bodyLg.copyWith(fontSize: AppFontSize.body, height: 22 / 15);
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
      TextSpan(
        style: base.copyWith(color: c.ink),
        children: spans,
      ),
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      locale: locale,
    );
  }
}
