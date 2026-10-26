import 'package:flutter/material.dart';

import 'package:tagarela/data/device/voice.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/term/widgets/highlighted_text.dart';
import 'package:tagarela/l10n/l10n.dart';

class TermDialogue extends StatefulWidget {
  const TermDialogue({
    super.key,
    required this.lines,
    required this.term,
    required this.learning,
    required this.base,
    required this.translatable,
    required this.voice,
  });

  final List<DialogueLine> lines;
  final String term;
  final CourseLanguage learning;
  final CourseLanguage base;
  final bool translatable;
  final Voice voice;

  @override
  State<TermDialogue> createState() => _TermDialogueState();
}

class _TermDialogueState extends State<TermDialogue> {
  final _open = <int>{};

  @override
  void didUpdateWidget(TermDialogue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.translatable) _open.clear();
  }

  void _toggle(int i) => setState(() {
    if (!_open.remove(i)) _open.add(i);
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final voice = widget.voice;
    final texts = [for (final line in widget.lines) line.text];
    return ListenableBuilder(
      listenable: voice,
      builder: (context, _) {
        final talking = voice.speaking != null && voice.line != null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      l10n.dialogue,
                      style: AppText.label.copyWith(color: c.inkSoft),
                    ),
                  ),
                ),
                AppButton(
                  label: talking ? l10n.stop : l10n.listen,
                  leading: Icon(
                    talking ? AppIcons.stop : AppIcons.listen,
                    size: 18,
                  ),
                  variant: AppButtonVariant.tonal,
                  size: AppButtonSize.small,
                  onPressed: () => talking
                      ? voice.stop()
                      : voice.speakLines(texts, widget.learning),
                ),
              ],
            ),
            for (final (i, line) in widget.lines.indexed)
              _Line(
                line: line,
                term: widget.term,
                learning: Locale(widget.learning.name),
                base: Locale(widget.base.name),
                open: _open.contains(i),
                speaking: talking && voice.line == i,
                onTap: widget.translatable ? () => _toggle(i) : null,
              ),
            Text(
              widget.translatable ? l10n.dialogueHint : l10n.dialogueLocked,
              textAlign: TextAlign.center,
              style: AppText.label.copyWith(
                color: c.inkSoft,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({
    required this.line,
    required this.term,
    required this.learning,
    required this.base,
    required this.open,
    required this.speaking,
    required this.onTap,
  });

  final DialogueLine line;
  final String term;
  final Locale learning;
  final Locale base;
  final bool open;
  final bool speaking;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final mine = line.speaker == DialogueSpeaker.b;
    return Padding(
      padding: EdgeInsets.only(left: mine ? 48 : 0, right: mine ? 0 : 48),
      child: Align(
        alignment: mine
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        child: Semantics(
          button: onTap != null,
          expanded: onTap == null ? null : open,
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: AnimatedScale(
              duration: AppMotion.base,
              curve: AppMotion.spring,
              scale: speaking ? 1.03 : 1,
              child: SpeechBalloon(
                color: mine ? c.primarySoft : c.surface,
                mirrored: mine,
                radius: AppSpacing.s5,
                ring: speaking ? c.primary : null,
                shadow: mine ? null : c.cardShadow,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpacing.s1,
                  children: [
                    HighlightedText(
                      text: line.text,
                      ranges: HighlightedText.find(line.text, term),
                      locale: learning,
                    ),
                    if (open)
                      Text(
                        line.translation,
                        locale: base,
                        style: AppText.bodyMd.copyWith(color: c.inkSoft),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
