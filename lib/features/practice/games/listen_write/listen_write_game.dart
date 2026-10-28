import 'package:flutter/material.dart';

import 'package:tagarela/data/device/voice.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/practice/games/listen_write/logic/gap_fill.dart';
import 'package:tagarela/features/practice/games/listen_write/widgets/gap_sentence.dart';
import 'package:tagarela/features/practice/logic/keyboard_rows.dart';
import 'package:tagarela/l10n/l10n.dart';

class ListenWriteGame extends StatefulWidget {
  const ListenWriteGame({
    super.key,
    required this.exercise,
    required this.language,
    required this.voice,
    required this.onSolved,
    this.result,
  });

  final ListenWriteExercise exercise;
  final CourseLanguage language;
  final Voice voice;
  final ValueChanged<Outcome> onSolved;
  final Widget? result;

  @override
  State<ListenWriteGame> createState() => _ListenWriteGameState();
}

class _ListenWriteGameState extends State<ListenWriteGame> {
  late final _fill = GapFill(widget.exercise.answer);
  var _bursts = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _listen(VoiceSpeed.normal);
    });
  }

  @override
  void dispose() {
    _fill.dispose();
    super.dispose();
  }

  void _listen(VoiceSpeed speed) {
    final voice = widget.voice;
    if (voice.speaking == speed && voice.text == widget.exercise.sentence) {
      voice.stop();
    } else {
      voice.speak(widget.exercise.sentence, widget.language, speed: speed);
    }
  }

  void _check() {
    if (_fill.check()) {
      setState(() => _bursts++);
      widget.onSolved(_fill.outcome);
    }
  }

  void _reveal() {
    _fill.reveal();
    widget.onSolved(_fill.outcome);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_fill, widget.voice]),
      builder: (context, _) => Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screen,
                  vertical: AppSpacing.s4,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - AppSpacing.s4 * 2,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 14,
                    children: [
                      _controls(context),
                      _balloon(context),
                      if (!_fill.finished) _help(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
          widget.result ?? _keyboard(context),
        ],
      ),
    );
  }

  Widget _controls(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final voice = widget.voice;
    final mine = voice.text == widget.exercise.sentence;
    final saying = mine ? voice.speaking : null;
    return Row(
      spacing: AppSpacing.s3,
      children: [
        AppIconButton(
          icon: saying == VoiceSpeed.normal ? AppIcons.stop : AppIcons.play,
          tooltip: saying == VoiceSpeed.normal
              ? l10n.stop
              : l10n.listenSentence,
          onPressed: () => _listen(VoiceSpeed.normal),
          variant: AppIconButtonVariant.onHeaderSolid,
          size: 64,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: 6,
                children: [
                  Icon(AppIcons.headphones, size: 14, color: c.onHeaderSoft),
                  Flexible(
                    child: Text(
                      l10n
                          .exerciseKind(ExerciseKind.listenWrite.name)
                          .toUpperCase(),
                      style: AppText.overline.copyWith(color: c.onHeaderSoft),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Text(
                saying == null ? l10n.listenTap : l10n.listening,
                style: AppText.titleMd.copyWith(color: AppPalette.white),
              ),
            ],
          ),
        ),
        ListenSlowButton(
          playing: saying == VoiceSpeed.slow,
          onPressed: () => _listen(VoiceSpeed.slow),
        ),
      ],
    );
  }

  Widget _balloon(BuildContext context) {
    final c = context.colors;
    final voice = widget.voice;
    final spoken = voice.text == widget.exercise.sentence
        ? voice.word?.$1
        : null;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SpeechBalloon(
          color: c.surface,
          radius: AppRadius.xl,
          shadow: c.cardShadow,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s5,
            AppSpacing.s3,
            AppSpacing.s5,
            AppSpacing.s4,
          ),
          child: GapSentence(
            exercise: widget.exercise,
            fill: _fill,
            spoken: spoken,
            locale: Locale(widget.language.name),
            gapLabel: context.l10n.gapLetters(_fill.letters),
          ),
        ),
        if (_bursts > 0)
          Positioned.fill(child: BubbleBurst(key: ValueKey(_bursts))),
      ],
    );
  }

  Widget _help(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final wrong = _fill.status == GapStatus.wrong;
    final typed = _fill.left < _fill.letters;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 44),
      child: Row(
        spacing: AppSpacing.s2,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: wrong
                  ? Semantics(
                      liveRegion: true,
                      child: StatusPill(
                        label: l10n.gapWrong(_fill.wrongCount),
                        tone: StatusTone.alert,
                      ),
                    )
                  : Text(
                      typed
                          ? l10n.gapLeft(_fill.left)
                          : l10n.gapLetters(_fill.letters),
                      style: AppText.bodyMd.copyWith(color: c.onHeaderSoft),
                    ),
            ),
          ),
          if (_fill.tries > 0)
            AppButton(
              label: l10n.showAnswer,
              variant: AppButtonVariant.onHeader,
              size: AppButtonSize.small,
              onPressed: _reveal,
            ),
        ],
      ),
    );
  }

  Widget _keyboard(BuildContext context) {
    final l10n = context.l10n;
    return BottomPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.s3,
        children: [
          LetterKeyboard(
            rows: keyboardRows(widget.language, widget.exercise.answer),
            onLetter: _fill.type,
            onBackspace: _fill.erase,
            backspaceLabel: l10n.backspace,
            letterLabel: (letter) => l10n.letterKey(letter.toUpperCase()),
            action: KeyboardAction(
              icon: AppIcons.idea,
              label: l10n.hintKey,
              tone: StatusTone.learning,
              onPressed: _fill.hint,
            ),
          ),
          AppButton(
            label: l10n.checkAnswer,
            expand: true,
            onPressed: _fill.complete ? _check : null,
          ),
        ],
      ),
    );
  }
}
