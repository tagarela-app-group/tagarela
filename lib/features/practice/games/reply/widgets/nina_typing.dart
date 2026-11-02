import 'package:flutter/material.dart';

import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/practice/games/reply/widgets/nina_bubble.dart';
import 'package:tagarela/l10n/l10n.dart';

class NinaTyping extends StatelessWidget {
  const NinaTyping({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.replyTyping,
      child: NinaBubble(child: TypingDots(color: context.colors.primary)),
    );
  }
}
