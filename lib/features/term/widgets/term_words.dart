import 'package:flutter/material.dart';

import 'package:tagarela/data/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';

class TermWords extends StatelessWidget {
  const TermWords({super.key, required this.card});

  final TermCard card;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final related = [
      if (card.synonyms.isNotEmpty) (l10n.synonyms, card.synonyms),
      if (card.antonyms.isNotEmpty) (l10n.antonyms, card.antonyms),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.s3,
      children: [
        if (card.collocations.isNotEmpty)
          AppCard(
            child: _Words(title: l10n.collocations, words: card.collocations),
          ),
        if (related.isNotEmpty)
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 14,
              children: [
                for (final (title, words) in related)
                  _Words(title: title, words: words),
              ],
            ),
          ),
      ],
    );
  }
}

class _Words extends StatelessWidget {
  const _Words({required this.title, required this.words});

  final String title;
  final List<String> words;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.s2,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            style: AppText.label.copyWith(color: context.colors.inkSoft),
          ),
        ),
        Wrap(
          spacing: AppSpacing.s2,
          runSpacing: AppSpacing.s2,
          children: [
            for (final word in words) TermChip(label: word, muted: true),
          ],
        ),
      ],
    );
  }
}
