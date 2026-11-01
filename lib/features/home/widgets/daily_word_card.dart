import 'dart:async';

import 'package:flutter/material.dart';

import 'package:tagarela/data/device/voice.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/home/logic/word_acts.dart';
import 'package:tagarela/l10n/l10n.dart';
import 'package:tagarela/shared/widgets/phonetic_text.dart';

class DailyWordCard extends StatefulWidget {
  const DailyWordCard({
    super.key,
    required this.word,
    required this.language,
    required this.voice,
    required this.onSave,
    required this.onOpen,
  });

  final DailyWord word;
  final CourseLanguage language;
  final Voice voice;
  final Future<void> Function() onSave;
  final ValueChanged<Term> onOpen;

  @override
  State<DailyWordCard> createState() => _DailyWordCardState();
}

class _DailyWordCardState extends State<DailyWordCard>
    with TickerProviderStateMixin {
  late final _acting = AnimationController(vsync: this);
  late final _saying = AnimationController(
    vsync: this,
    duration: AppMotion.wordSay,
  );

  Timer? _timer;
  WordAct? _act;
  var _round = 0;
  var _cue = 0;
  var _bursts = 0;
  String? _say;
  var _revealed = false;
  var _saving = false;

  bool get _still => MediaQuery.disableAnimationsOf(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_still) {
      _timer?.cancel();
      _timer = null;
    } else {
      _timer ??= Timer(AppMotion.wordFirst, _tick);
    }
  }

  void _tick() {
    if (!mounted) return;
    if (TickerMode.getValuesNotifier(context).value.enabled &&
        widget.voice.speaking == null) {
      _perform(actOfRound(_round++));
    }
    _timer = Timer(AppMotion.wordEvery, _tick);
  }

  void _perform(WordAct act) {
    _speak(context.l10n.dailyWordSay(act.name));
    setState(() {
      _act = act;
      _cue++;
    });
    _acting.duration = switch (act) {
      WordAct.hop => AppMotion.wordHop,
      WordAct.shuffle => AppMotion.wordShuffle,
      WordAct.chat => AppMotion.wordChat,
    };
    _acting.forward(from: 0).then((_) {
      if (!mounted) return;
      setState(() {
        _act = null;
        if (act == WordAct.shuffle) _bursts++;
      });
    });
  }

  void _speak(String text) {
    setState(() => _say = text);
    _saying.forward(from: 0);
  }

  void _celebrate(String say) {
    if (_still) return;
    _speak(say);
    setState(() {
      _cue++;
      _bursts++;
    });
  }

  void _reveal() {
    if (_revealed) return;
    setState(() => _revealed = true);
    _celebrate(context.l10n.dailyWordSay('reveal'));
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await widget.onSave();
      if (mounted) _celebrate(context.l10n.dailyWordSay('saved'));
    } on Exception {
      if (mounted) AppToast.notice(context, context.l10n.noConnectionRetry);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _acting.dispose();
    _saying.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final word = widget.word;
    final voice = widget.voice;
    final term = word.term;
    final radius = AppRadius.bubble(AppRadius.xl);
    return Semantics(
      container: true,
      label: l10n.dailyWordLabel(word.kind.name),
      child: SpeechBalloon(
        color: c.header,
        radius: AppRadius.xl,
        padding: EdgeInsets.zero,
        shadow: c.buttonShadow,
        child: ClipRRect(
          borderRadius: radius,
          child: ListenableBuilder(
            listenable: voice,
            builder: (context, _) {
              final speaking =
                  voice.speaking != null && voice.text == word.text;
              return Stack(
                children: [
                  Positioned(
                    right: -AppSpacing.s10,
                    bottom: -AppSpacing.s14,
                    child: DrawnIcon(
                      DrawnGlyph.bubble,
                      size: AppBubbleSize.backdrop,
                      color: AppPalette.white.withValues(alpha: 0.06),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s45,
                      AppSpacing.s4,
                      AppSpacing.s45,
                      AppSpacing.s45,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.dailyWordLabel(word.kind.name).toUpperCase(),
                          style: AppText.overline.copyWith(
                            color: c.onHeaderSoft,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: AppSpacing.s1,
                            right: AppSpacing.s14,
                          ),
                          child: Semantics(
                            header: true,
                            label: word.text,
                            excludeSemantics: true,
                            child: _Letters(
                              text: word.text,
                              locale: Locale(widget.language.name),
                              act: _act,
                              progress: _acting,
                              spoken: speaking
                                  ? voice.word ?? (0, word.text.length)
                                  : null,
                            ),
                          ),
                        ),
                        if (word.phonetic case final phonetic?)
                          PhoneticText(
                            phonetic,
                            style: AppText.bodyMd.copyWith(
                              color: c.onHeaderSoft,
                            ),
                            stressColor: AppPalette.white,
                          ),
                        const SizedBox(height: AppSpacing.s15),
                        _Example(
                          example: word.example,
                          term: word.text,
                          locale: Locale(widget.language.name),
                        ),
                        const SizedBox(height: AppSpacing.s3),
                        Row(
                          spacing: AppSpacing.s2,
                          children: [
                            Expanded(
                              child: _Meaning(
                                meaning: word.meaning,
                                revealed: _revealed,
                                onTap: _reveal,
                              ),
                            ),
                            AppIconButton(
                              icon: speaking ? AppIcons.stop : AppIcons.listen,
                              tooltip: speaking
                                  ? l10n.stop
                                  : l10n.listenPronunciation,
                              variant: AppIconButtonVariant.onHeader,
                              onPressed: () => speaking
                                  ? voice.stop()
                                  : voice.speak(word.text, widget.language),
                            ),
                            if (term == null)
                              AppIconButton(
                                icon: AppIcons.save,
                                tooltip: l10n.dailyWordSave,
                                variant: AppIconButtonVariant.onHeader,
                                onPressed: _save,
                              )
                            else
                              AppIconButton(
                                icon: AppIcons.saved,
                                tooltip: l10n.dailyWordOpen,
                                variant: AppIconButtonVariant.onHeaderSolid,
                                onPressed: () => widget.onOpen(term),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: AppSpacing.s25,
                    right: AppSpacing.s3,
                    child: BubbleMascot(
                      cue: _cue,
                      talking: speaking || _act == WordAct.chat,
                    ),
                  ),
                  if (_say case final say?)
                    Positioned(
                      top: AppSpacing.s3,
                      right: AppSpacing.s19,
                      child: _SayBalloon(text: say, progress: _saying),
                    ),
                  if (_bursts > 0)
                    Positioned.fill(
                      child: BubbleBurst(
                        key: ValueKey(_bursts),
                        count: 6,
                        distance: 110,
                        color: AppPalette.mango,
                        accent: AppPalette.white,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Letters extends StatelessWidget {
  const _Letters({
    required this.text,
    required this.locale,
    required this.act,
    required this.progress,
    required this.spoken,
  });

  final String text;
  final Locale locale;
  final WordAct? act;
  final Animation<double> progress;
  final (int, int)? spoken;

  @override
  Widget build(BuildContext context) {
    const style = AppText.statLg;
    final slot = style.fontSize! * 0.54;
    final letters = text.split('');
    return Align(
      alignment: Alignment.centerLeft,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: AnimatedBuilder(
          animation: progress,
          builder: (context, _) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < letters.length; i++)
                _letter(i, letters[i], letters.length, slot, style),
            ],
          ),
        ),
      ),
    );
  }

  Widget _letter(
    int i,
    String letter,
    int count,
    double slot,
    TextStyle style,
  ) {
    final pose = act == null
        ? const LetterPose()
        : letterPose(act!, progress.value, i, count);
    final lit = switch (spoken) {
      (final start, final end) => i >= start && i < end,
      null => false,
    };
    return Transform.translate(
      offset: Offset(pose.slots * slot, -pose.lift),
      child: Transform.rotate(
        angle: pose.angle,
        child: Transform.scale(
          scaleX: 1 + pose.squash,
          scaleY: 1 - pose.squash,
          alignment: Alignment.bottomCenter,
          child: Text(
            letter,
            locale: locale,
            style: style.copyWith(
              color: lit || pose.tinted ? AppPalette.mango : AppPalette.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _Example extends StatelessWidget {
  const _Example({
    required this.example,
    required this.term,
    required this.locale,
  });

  final String example;
  final String term;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final match = RegExp(
      RegExp.escape(term),
      caseSensitive: false,
    ).firstMatch(example);
    return Text.rich(
      TextSpan(
        children: match == null
            ? [TextSpan(text: example)]
            : [
                TextSpan(text: example.substring(0, match.start)),
                TextSpan(
                  text: match.group(0),
                  style: const TextStyle(
                    color: AppPalette.mango,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: example.substring(match.end)),
              ],
      ),
      locale: locale,
      style: AppText.bodyMd.copyWith(color: AppPalette.white),
    );
  }
}

class _Meaning extends StatelessWidget {
  const _Meaning({
    required this.meaning,
    required this.revealed,
    required this.onTap,
  });

  final String meaning;
  final bool revealed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      container: true,
      button: !revealed,
      label: revealed ? meaning : context.l10n.dailyWordReveal,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ExcludeSemantics(
          child: Container(
            constraints: const BoxConstraints(minHeight: AppBubbleSize.touch),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s3,
              vertical: AppSpacing.s1,
            ),
            decoration: BoxDecoration(
              color: c.headerChip,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              spacing: AppSpacing.s2,
              children: [
                Expanded(
                  child: Obscured(
                    obscured: !revealed,
                    child: Text(
                      meaning,
                      style: AppText.label.copyWith(color: AppPalette.white),
                    ),
                  ),
                ),
                if (!revealed)
                  const Icon(
                    AppIcons.reveal,
                    size: AppIconSize.md,
                    color: AppPalette.white,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SayBalloon extends StatelessWidget {
  const _SayBalloon({required this.text, required this.progress});

  final String text;
  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: progress,
        child: SpeechBalloon(
          color: AppPalette.white,
          mirrored: true,
          radius: AppRadius.sm,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s25,
            vertical: AppSpacing.s1,
          ),
          child: Text(
            text,
            style: AppText.label.copyWith(color: AppPalette.ink),
          ),
        ),
        builder: (context, child) {
          final t = progress.value;
          final enter = Curves.easeOutBack.transform(
            (t / 0.15).clamp(0.0, 1.0),
          );
          final leave = ((1 - t) / 0.15).clamp(0.0, 1.0);
          return Opacity(
            opacity: t == 0 ? 0 : leave,
            child: Transform.scale(
              scale: 0.3 + 0.7 * enter,
              alignment: Alignment.bottomRight,
              child: child,
            ),
          );
        },
      ),
    );
  }
}
