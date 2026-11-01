import 'package:flutter/material.dart';

import 'package:tagarela/shared/logic/card_text.dart';

class PhoneticText extends StatelessWidget {
  const PhoneticText(
    this.phonetic, {
    super.key,
    required this.style,
    required this.stressColor,
  });

  final String phonetic;
  final TextStyle style;
  final Color stressColor;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          for (final part in stressedParts(phonetic))
            TextSpan(
              text: part.text,
              style: part.marked
                  ? TextStyle(color: stressColor, fontWeight: FontWeight.w700)
                  : null,
            ),
        ],
      ),
      style: style,
    );
  }
}
