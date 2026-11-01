import 'dart:math' as math;

import 'package:flutter/animation.dart';

enum WordAct { hop, shuffle, chat }

WordAct actOfRound(int round) => WordAct.values[round % WordAct.values.length];

class LetterPose {
  const LetterPose({
    this.slots = 0,
    this.lift = 0,
    this.angle = 0,
    this.squash = 0,
    this.tinted = false,
  });

  final double slots;
  final double lift;
  final double angle;
  final double squash;
  final bool tinted;
}

const _shuffleKeys = [0.0, 0.25, 0.5, 0.75, 0.92];
const _tintUntil = 0.85;

LetterPose letterPose(WordAct act, double t, int index, int count) =>
    switch (act) {
      WordAct.hop => _hop(_staggered(t, index, count, span: 0.45)),
      WordAct.chat => _chat(_staggered(t, index, count, span: 0.5)),
      WordAct.shuffle => _shuffle(t, index, count),
    };

double _staggered(double t, int index, int count, {required double span}) {
  final start = count < 2 ? 0.0 : index / (count - 1) * (1 - span);
  return ((t - start) / span).clamp(0.0, 1.0);
}

LetterPose _hop(double t) => LetterPose(
  lift: 16 * math.sin(math.pi * t),
  squash: 0.1 * math.sin(2 * math.pi * t),
);

LetterPose _chat(double t) =>
    LetterPose(angle: 0.16 * math.sin(4 * math.pi * t) * (1 - t));

LetterPose _shuffle(double t, int index, int count) {
  if (t <= 0 || t >= _shuffleKeys.last) return const LetterPose();
  final spots = [
    index,
    if (index.isEven) math.min(index + 1, count - 1) else index - 1,
    count - 1 - index,
    (index + 2) % count,
    index,
  ];
  var step = 0;
  while (t >= _shuffleKeys[step + 1]) {
    step++;
  }
  final from = _shuffleKeys[step];
  final progress = (t - from) / (_shuffleKeys[step + 1] - from);
  final spot =
      spots[step] +
      (spots[step + 1] - spots[step]) * Curves.easeOutBack.transform(progress);
  final strength = math.sin(math.pi * t / _shuffleKeys.last);
  return LetterPose(
    slots: spot - index,
    lift: ((index * 29 + step * 17) % 9 - 4) * strength,
    angle: ((index * 37 + step * 53) % 17 - 8) * math.pi / 180 * strength,
    tinted: t < _tintUntil,
  );
}
