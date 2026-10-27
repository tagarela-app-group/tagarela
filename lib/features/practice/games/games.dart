import 'package:flutter/material.dart';

import 'package:tagarela/data/device/voice.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/practice/games/listen_write/listen_write_game.dart';

IconData gameIcon(ExerciseKind kind) => switch (kind) {
  ExerciseKind.listenWrite => AppIcons.headphones,
};

Widget gameFor(
  Exercise exercise, {
  required CourseLanguage language,
  required Voice voice,
  required ValueChanged<Outcome> onSolved,
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
};
