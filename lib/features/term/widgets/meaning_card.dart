import 'package:flutter/material.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';

class MeaningCard extends StatefulWidget {
  const MeaningCard({
    super.key,
    required this.card,
    required this.learning,
    required this.base,
    required this.revealed,
    required this.flipped,
    required this.bursts,
    required this.onReveal,
    required this.onFlip,
  });

  final TermCard card;
  final CourseLanguage learning;
  final CourseLanguage base;
  final bool revealed;
  final bool flipped;
  final int bursts;
  final VoidCallback onReveal;
  final VoidCallback onFlip;

  @override
  State<MeaningCard> createState() => _MeaningCardState();
}

class _MeaningCardState extends State<MeaningCard> {
  var _hint = false;

  @override
  void didUpdateWidget(MeaningCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.revealed && oldWidget.revealed) _hint = false;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final card = widget.card;
    final learning = widget.learning;
    final base = widget.base;
    final other = widget.flipped ? learning : base;
    final literal = card.base.literal;
    return Stack(
      children: [
        FrostedGlass(
          frosted: !widget.revealed,
          onWiped: widget.onReveal,
          overlay: GlassPanel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: AppSpacing.s2,
              children: [
                const _SwipeHint(),
                Text(
                  l10n.guessTitle,
                  textAlign: TextAlign.center,
                  style: AppText.titleSm,
                ),
                Text(
                  l10n.guessHint,
                  textAlign: TextAlign.center,
                  style: AppText.label.copyWith(
                    color: c.inkSoft,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          actions: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: AppSpacing.s2,
            children: [
              if (_hint && literal != null)
                Semantics(
                  liveRegion: true,
                  child: SpeechBalloon(
                    color: c.glassPanel,
                    radius: AppRadius.md,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: '${l10n.literally}: '),
                          TextSpan(
                            text: literal,
                            style: TextStyle(
                              color: c.primaryText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      locale: Locale(base.name),
                      style: AppText.bodyMd,
                    ),
                  ),
                ),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: AppSpacing.s2,
                runSpacing: AppSpacing.s2,
                children: [
                  if (literal != null)
                    AppButton(
                      label: l10n.hint,
                      leading: const Icon(AppIcons.idea, size: 18),
                      variant: AppButtonVariant.tonal,
                      size: AppButtonSize.small,
                      onPressed: () => setState(() => _hint = !_hint),
                    ),
                  AppButton(
                    label: l10n.revealNow,
                    leading: const Icon(AppIcons.reveal, size: 18),
                    size: AppButtonSize.small,
                    onPressed: widget.onReveal,
                  ),
                ],
              ),
            ],
          ),
          child: FlipCard(
            flipped: widget.revealed && widget.flipped,
            front: _Side(
              label: l10n.cardSide(learning.name),
              side: card.learning,
              locale: Locale(learning.name),
            ),
            back: _Side(
              label: l10n.cardSide(base.name),
              side: card.base,
              locale: Locale(base.name),
            ),
          ),
        ),
        if (widget.revealed)
          Positioned(
            top: 10,
            right: 10,
            child: Semantics(
              container: true,
              button: true,
              label: l10n.seeIn(other.name),
              onTap: widget.onFlip,
              excludeSemantics: true,
              child: AppButton(
                label: other.code,
                leading: const Icon(AppIcons.language, size: 18),
                variant: AppButtonVariant.tonal,
                size: AppButtonSize.small,
                onPressed: widget.onFlip,
              ),
            ),
          ),
        if (widget.bursts > 0)
          Positioned.fill(child: BubbleBurst(key: ValueKey(widget.bursts))),
      ],
    );
  }
}

class _SwipeHint extends StatefulWidget {
  const _SwipeHint();

  @override
  State<_SwipeHint> createState() => _SwipeHintState();
}

class _SwipeHintState extends State<_SwipeHint>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: AppMotion.hint,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller.isDismissed && !MediaQuery.disableAnimationsOf(context)) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final swing = Curves.easeInOut.transform(_controller.value);
          final shift = switch (swing) {
            < 0.25 => -swing * 4,
            < 0.75 => -1 + (swing - 0.25) * 4,
            _ => 1 - (swing - 0.75) * 4,
          };
          return Transform.translate(
            offset: Offset(shift * 36, 0),
            child: Transform.rotate(angle: shift * 0.2, child: child),
          );
        },
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: c.primarySoft,
            shape: BoxShape.circle,
          ),
          child: Icon(AppIcons.swipe, size: 24, color: c.primaryText),
        ),
      ),
    );
  }
}

class _Side extends StatelessWidget {
  const _Side({required this.label, required this.side, required this.locale});

  final String label;
  final CardSide side;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.s4,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 76),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  label.toUpperCase(),
                  style: AppText.overline.copyWith(
                    fontSize: 11,
                    color: c.inkSoft,
                  ),
                ),
                if (side.headline case final headline?)
                  Text(
                    headline,
                    locale: locale,
                    style: AppText.titleMd.copyWith(
                      fontSize: 22,
                      color: c.primaryText,
                    ),
                  ),
              ],
            ),
          ),
          if (side.inContext case final text?)
            _Field(title: l10n.inYourContext, text: text, locale: locale),
          if (side.explanation case final text?)
            _Field(title: l10n.explanation, text: text, locale: locale),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.title, required this.text, required this.locale});

  final String title;
  final String text;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.s1,
      children: [
        Text(
          title,
          style: AppText.pill.copyWith(color: context.colors.inkSoft),
        ),
        Text(
          text,
          locale: locale,
          style: AppText.bodyLg.copyWith(fontSize: 15, height: 22 / 15),
        ),
      ],
    );
  }
}
