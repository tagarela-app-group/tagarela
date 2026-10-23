import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/inbox/term_selection.dart';

class WordPicker extends StatefulWidget {
  const WordPicker({super.key, required this.selection, required this.onPick});

  final TermSelection selection;
  final void Function(int first, int last) onPick;

  @override
  State<WordPicker> createState() => _WordPickerState();
}

class _WordPickerState extends State<WordPicker> {
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
    bool on(int i) => spans.any((s) => covers(s, _words[i]));
    bool linked(int a, int b) =>
        spans.any((s) => covers(s, _words[a]) && covers(s, _words[b]));

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
              selected: on(i),
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
    required this.selected,
    required this.joinLeft,
    required this.joinRight,
    required this.onTap,
  });

  final Word word;
  final bool selected;
  final bool joinLeft;
  final bool joinRight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    const round = Radius.circular(AppRadius.sm);
    final chip = Container(
      padding: const EdgeInsets.all(AppSpacing.s2),
      decoration: BoxDecoration(
        color: selected ? c.primarySoft : Colors.transparent,
        borderRadius: BorderRadius.horizontal(
          left: joinLeft ? Radius.zero : round,
          right: joinRight ? Radius.zero : round,
        ),
      ),
      child: Text(
        word.label,
        style: AppText.bodyLg.copyWith(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? c.primaryText : c.ink,
        ),
      ),
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
