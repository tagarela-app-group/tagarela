import 'package:flutter/material.dart';

import 'package:tagarela/data/device/voice.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/features/practice/games/listen_write/listen_write_game.dart';
import 'package:tagarela/features/practice/games/reply/reply_game.dart';

Widget gameFor(
  Exercise exercise, {
  required List<ReplyExercise> conversation,
  required CourseLanguage language,
  required Voice voice,
  required ValueChanged<RoundPlay> onSolved,
  Widget? result,
}) => switch (exercise) {
  ListenWriteExercise() => ListenWriteGame(
    key: ValueKey(exercise.id),
    exercise: exercise,
    language: language,
    voice: voice,
    onSolved: onSolved,
    result: result,
  ),
  ReplyExercise() => ReplyGame(
    key: ValueKey(exercise.id),
    exercise: exercise,
    earlier: conversation,
    language: language,
    voice: voice,
    onSolved: onSolved,
    result: result,
  ),
};
