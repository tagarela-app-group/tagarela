import 'package:flutter/material.dart';

import 'package:tagarela/data/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/term/widgets/highlighted_text.dart';
import 'package:tagarela/l10n/l10n.dart';

class TermExamples extends StatelessWidget {
  const TermExamples({
    super.key,
    required this.examples,
    required this.term,
    required this.locale,
    required this.translated,
  });

  final List<CardExample> examples;
  final String term;
  final Locale locale;
  final bool translated;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        Semantics(
          header: true,
          child: Text(
            context.l10n.examples,
            style: AppText.label.copyWith(color: c.inkSoft),
          ),
        ),
        for (final example in examples)
          AppCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s4,
              vertical: 14,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.s1,
              children: [
                HighlightedText(
                  text: example.text,
                  ranges: HighlightedText.find(example.text, term),
                  locale: locale,
                ),
                if (translated)
                  Text(
                    example.translation,
                    style: AppText.bodyMd.copyWith(color: c.inkSoft),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
