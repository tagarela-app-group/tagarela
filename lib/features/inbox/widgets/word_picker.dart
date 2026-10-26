import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/inbox/logic/term_selection.dart';

class WordPicker extends StatefulWidget {
  const WordPicker({super.key, required this.selection, required this.onPick});

  final TermSelection selection;
  final void Function(int first, int last) onPick;

  @override
  State<WordPicker> createState() => _WordPickerState();
}

class _WordPickerState extends State<WordPicker>
    with SingleTickerProviderStateMixin {
  late final _ants = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  List<GlobalKey> _keys = [];
  int? _from;
  int? _to;

  List<Word> get _words => widget.selection.words;

  int? _wordAt(Offset global) {
    for (var i = 0; i < _keys.length; i++) {
      final box = _keys[i].currentContext?.findRenderObject();
      if (box is! RenderBox || !box.hasSize || !_words[i].selectable) continue;
      if ((box.localToGlobal(Offset.zero) & box.size).contains(global)) {
        return i;
      }
    }
    return null;
  }

  void _tap(TapUpDetails details) {
    final i = _wordAt(details.globalPosition);
    if (i != null) widget.onPick(i, i);
  }

  void _start(DragStartDetails details) {
    final i = _wordAt(details.globalPosition);
    if (i != null) setState(() => _from = _to = i);
  }

  void _move(DragUpdateDetails details) {
    if (_from == null) return;
    final i = _wordAt(details.globalPosition);
    if (i != null && i != _to) setState(() => _to = i);
  }

  void _end() {
    final (from, to) = (_from, _to);
    setState(() => _from = _to = null);
    if (from != null && to != null) widget.onPick(min(from, to), max(from, to));
  }

  void _cancel() => setState(() => _from = _to = null);

  @override
  void dispose() {
    _ants.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_keys.length != _words.length) {
      _keys = [for (final _ in _words) GlobalKey()];
    }
    final spans = [
      ...widget.selection.spans,
      if ((_from, _to) case (final int from, final int to))
        widget.selection.spanOf(min(from, to), max(from, to)),
    ];
    bool covers(Span span, Word word) =>
        span.start < word.end && word.start < span.end;
    int count(int i) => spans.where((s) => covers(s, _words[i])).length;
    bool linked(int a, int b) =>
        spans.any((s) => covers(s, _words[a]) && covers(s, _words[b]));
    int runEndingAt(int i) {
      if (i < _words.length - 1 && linked(i, i + 1)) return 0;
      var n = 1;
      while (i - n >= 0 && linked(i - n, i - n + 1)) {
        n++;
      }
      return n;
    }

    if (spans.isEmpty) {
      _ants.stop();
    } else if (!_ants.isAnimating) {
      _ants.repeat();
    }

    return GestureDetector(
      dragStartBehavior: DragStartBehavior.down,
      onTapUp: _tap,
      onPanStart: _start,
      onPanUpdate: _move,
      onPanEnd: (_) => _end(),
      onPanCancel: _cancel,
      child: Wrap(
        runSpacing: AppSpacing.s1,
        children: [
          for (var i = 0; i < _words.length; i++)
            _WordChip(
              key: _keys[i],
              word: _words[i],
              terms: count(i),
              runWords: runEndingAt(i),
              ants: _ants,
              joinLeft: i > 0 && linked(i - 1, i),
              joinRight: i < _words.length - 1 && linked(i, i + 1),
              onTap: () => widget.onPick(i, i),
            ),
        ],
      ),
    );
  }
}

class _WordChip extends StatelessWidget {
  const _WordChip({
    super.key,
    required this.word,
    required this.terms,
    required this.runWords,
    required this.ants,
    required this.joinLeft,
    required this.joinRight,
    required this.onTap,
  });

  final Word word;
  final int terms;
  final int runWords;
  final Animation<double> ants;
  final bool joinLeft;
  final bool joinRight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final selected = terms > 0;
    const round = Radius.circular(AppRadius.sm);
    final text = Padding(
      padding: const EdgeInsets.all(AppSpacing.s2),
      child: Text(
        word.label,
        style: AppText.bodyLg.copyWith(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? c.primaryText : c.ink,
        ),
      ),
    );
    final box = !selected
        ? text
        : CustomPaint(
            foregroundPainter: _AntsPainter(
              progress: ants,
              color: c.primary,
              joinLeft: joinLeft,
              joinRight: joinRight,
              radius: round.x,
            ),
            child: text,
          );
    final chip = runWords < 2
        ? box
        : Stack(
            clipBehavior: Clip.none,
            children: [
              box,
              Positioned(
                top: -6,
                right: -4,
                child: AppBadge(label: '$runWords', tone: AppBadgeTone.primary),
              ),
            ],
          );
    if (!word.selectable) return ExcludeSemantics(child: chip);
    return Semantics(
      button: true,
      selected: selected,
      onTap: onTap,
      child: chip,
    );
  }
}

class _AntsPainter extends CustomPainter {
  _AntsPainter({
    required this.progress,
    required this.color,
    required this.joinLeft,
    required this.joinRight,
    required this.radius,
  }) : super(repaint: progress);

  static const _dash = 5.0;
  static const _gap = 4.0;

  final Animation<double> progress;
  final Color color;
  final bool joinLeft;
  final bool joinRight;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Rect.fromLTWH(0.75, 0.75, size.width - 1.5, size.height - 1.5);
    final rl = joinLeft ? 0.0 : radius;
    final rr = joinRight ? 0.0 : radius;
    final path = Path()..moveTo(r.left + rl, r.top);
    path.lineTo(r.right - rr, r.top);
    if (joinRight) {
      path.moveTo(r.right, r.bottom);
    } else {
      path
        ..arcToPoint(Offset(r.right, r.top + rr), radius: Radius.circular(rr))
        ..lineTo(r.right, r.bottom - rr)
        ..arcToPoint(
          Offset(r.right - rr, r.bottom),
          radius: Radius.circular(rr),
        );
    }
    path.lineTo(r.left + rl, r.bottom);
    if (!joinLeft) {
      path
        ..arcToPoint(Offset(r.left, r.bottom - rl), radius: Radius.circular(rl))
        ..lineTo(r.left, r.top + rl)
        ..arcToPoint(Offset(r.left + rl, r.top), radius: Radius.circular(rl));
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    const period = _dash + _gap;
    final shift = progress.value * period;
    for (final metric in path.computeMetrics()) {
      for (var d = shift - period; d < metric.length; d += period) {
        final a = max(0.0, d);
        final b = min(metric.length, d + _dash);
        if (b > a) canvas.drawPath(metric.extractPath(a, b), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_AntsPainter old) =>
      old.color != color ||
      old.joinLeft != joinLeft ||
      old.joinRight != joinRight ||
      old.radius != radius;
}
