import 'package:flutter/material.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';

class CaptureTerms extends StatelessWidget {
  const CaptureTerms({super.key, required this.terms});

  final List<CaptureTerm> terms;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.s2,
      children: [
        Text(
          context.l10n.termsChosen(terms.length),
          style: AppText.pill.copyWith(color: context.colors.inkSoft),
        ),
        Wrap(
          spacing: AppSpacing.s15,
          runSpacing: AppSpacing.s15,
          children: [for (final term in terms) TermChip(label: term.text)],
        ),
      ],
    );
  }
}
