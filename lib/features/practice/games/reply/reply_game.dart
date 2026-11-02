import 'dart:async';

import 'package:flutter/material.dart';

import 'package:tagarela/data/device/voice.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/practice/games/reply/logic/reply_round.dart';
import 'package:tagarela/features/practice/games/reply/widgets/mine_bubble.dart';
import 'package:tagarela/features/practice/games/reply/widgets/nina_audio.dart';
import 'package:tagarela/features/practice/games/reply/widgets/nina_bubble.dart';
import 'package:tagarela/features/practice/games/reply/widgets/nina_typing.dart';
import 'package:tagarela/features/practice/games/reply/widgets/reply_chat.dart';
import 'package:tagarela/features/practice/logic/round_listening.dart';
import 'package:tagarela/l10n/l10n.dart';

class ReplyGame extends StatefulWidget {
  const ReplyGame({
    super.key,
    required this.exercise,
    required this.earlier,
    required this.language,
    required this.voice,
    required this.onSolved,
    this.result,
  });

  final ReplyExercise exercise;
  final List<ReplyExercise> earlier;
  final CourseLanguage language;
  final Voice voice;
  final ValueChanged<RoundPlay> onSolved;
  final Widget? result;

  @override
  State<ReplyGame> createState() => _ReplyGameState();
}

class _ReplyGameState extends State<ReplyGame> {
  static const _confusedLines = ['a', 'b', 'c'];

  late final _round = ReplyRound(widget.exercise.answer);
  late final _listening = RoundListening(widget.voice, widget.language);
  late var _typing = widget.earlier.isNotEmpty;
  final _clock = Stopwatch()..start();
  var _awaiting = false;
  var _replied = false;
  var _bursts = 0;
  Timer? _timer;

  ReplyExercise get _exercise => widget.exercise;

  @override
  void initState() {
    super.initState();
    if (_typing) {
      _later(_arrive);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _arrive();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _round.dispose();
    super.dispose();
  }

  void _later(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(AppMotion.replyTyping, () {
      if (mounted) setState(action);
    });
  }

  void _arrive() {
    _typing = false;
    if (_exercise.mode == ReplyMode.audio) {
      _listening.play(_exercise.nina, VoiceSpeed.normal, auto: true);
    }
    if (mounted) setState(() {});
  }

  void _pick(String option) {
    if (_round.pick(option)) return _finish();
    widget.voice.speak(_sentenceWith(option), widget.language);
    setState(() => _awaiting = true);
    _later(() => _awaiting = false);
  }

  void _reveal() {
    _timer?.cancel();
    _round.reveal();
    _awaiting = false;
    _finish();
  }

  void _finish() {
    widget.voice.speak(_exercise.reply, widget.language);
    setState(() {
      if (_round.status == ReplyStatus.solved) _bursts++;
    });
    widget.onSolved(
      RoundPlay(
        _round.outcome,
        usedSlow: _listening.usedSlow,
        errors: _round.wrongs.length,
        audioReplays: _listening.replays,
        responseMs: _clock.elapsedMilliseconds,
      ),
    );
    _later(() => _replied = true);
  }

  String _fit(String option) => fitOption(option, _exercise.before);

  String _sentenceWith(String option) =>
      '${_exercise.before}${_fit(option)}${_exercise.after}';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _round,
      builder: (context, _) => ReplyChat(
        earlier: widget.earlier,
        language: widget.language,
        typing: _typing || _awaiting || (_round.finished && !_replied),
        messages: _messages(context),
        footer: _replied && widget.result != null
            ? widget.result
            : _options(context),
      ),
    );
  }

  List<Widget> _messages(BuildContext context) {
    if (_typing) return const [NinaTyping()];
    final wrongs = _round.wrongs;
    final language = widget.language;
    final learning = lookupAppLocalizations(Locale(language.name));
    return [
      _opening(),
      for (final (i, option) in wrongs.indexed) ...[
        MineBubble(
          before: _exercise.before,
          fill: _fit(option),
          after: _exercise.after,
          language: language,
          tone: MineTone.wrong,
          shake: i == wrongs.length - 1,
        ),
        if (i == wrongs.length - 1 && _awaiting)
          const NinaTyping()
        else
          NinaBubble.text(
            learning.replyConfused(
              _confusedLines[i % _confusedLines.length],
              option,
            ),
            language: language,
          ),
      ],
      if (_round.finished) ...[
        Stack(
          clipBehavior: Clip.none,
          children: [
            MineBubble(
              before: _exercise.before,
              fill: _exercise.filled,
              after: _exercise.after,
              language: language,
              tone: _round.status == ReplyStatus.solved
                  ? MineTone.right
                  : MineTone.revealed,
            ),
            if (_bursts > 0)
              Positioned.fill(child: BubbleBurst(key: ValueKey(_bursts))),
          ],
        ),
        if (_replied)
          NinaBubble.text(_exercise.ninaReply, language: language)
        else
          const NinaTyping(),
      ] else if (!_awaiting)
        MineBubble(
          before: _exercise.before,
          after: _exercise.after,
          language: language,
          tone: MineTone.open,
        ),
    ];
  }

  Widget _opening() => switch (_exercise.mode) {
    ReplyMode.use || ReplyMode.understand => NinaBubble.text(
      _exercise.opening(continuing: widget.earlier.isNotEmpty),
      language: widget.language,
    ),
    ReplyMode.audio => NinaBubble(
      child: NinaAudio(
        text: _exercise.nina,
        language: widget.language,
        voice: widget.voice,
        showText: _round.finished,
        onListen: (speed) => _listening.play(_exercise.nina, speed),
      ),
    ),
  };

  Widget _options(BuildContext context) {
    final options = _exercise.options;
    final idle = !_typing && !_awaiting && !_round.finished;
    return BottomPanel(
      child: Visibility(
        visible: !_typing && !_round.finished,
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.s2,
          children: [
            if (_round.canReveal && !_awaiting)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: AppButton(
                  label: context.l10n.showAnswer,
                  variant: AppButtonVariant.text,
                  size: AppButtonSize.small,
                  onPressed: _reveal,
                ),
              ),
            for (var i = 0; i < options.length; i += 2)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSpacing.s2,
                  children: [
                    for (final option in options.skip(i).take(2))
                      Expanded(
                        child: AppButton(
                          label: option,
                          variant: AppButtonVariant.tonal,
                          expand: true,
                          maxLines: 2,
                          locale: Locale(widget.language.name),
                          onPressed: idle && !_round.isUsed(option)
                              ? () => _pick(option)
                              : null,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
