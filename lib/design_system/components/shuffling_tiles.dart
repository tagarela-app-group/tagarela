import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:tagarela/design_system/components/bubble_burst.dart';
import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';
import 'package:tagarela/design_system/tokens/app_typography.dart';

class ShufflingTiles extends StatefulWidget {
  const ShufflingTiles({
    super.key,
    required this.pieces,
    this.joined = false,
    this.locale,
  });

  final List<String> pieces;
  final bool joined;
  final Locale? locale;

  static List<List<int>> steps(List<String> pieces) {
    final n = pieces.length;
    final solved = List<int>.generate(n, (i) => i);
    final steps = [solved];
    if (n < 2) return steps;
    final middle = math.max(0, n ~/ 2 - 1);
    final at = [n - 2, middle, if (middle == 0) n - 2 else 0];
    String text(List<int> order) => order.map((i) => pieces[i]).join(' ');
    var last = -1;
    for (final k in at) {
      if (k == last) continue;
      final order = [...steps.first];
      final pair = [
        for (var j = k; j < n - 1; j++) j,
        for (var j = k - 1; j >= 0; j--) j,
      ].where((j) => pieces[order[j]] != pieces[order[j + 1]]).firstOrNull;
      if (pair == null) break;
      order.insert(pair, order.removeAt(pair + 1));
      if (text(order) == text(solved)) break;
      steps.insert(0, order);
      last = k;
    }
    return steps;
  }

  @override
  State<ShufflingTiles> createState() => _ShufflingTilesState();
}

class _ShufflingTilesState extends State<ShufflingTiles> {
  late var _steps = ShufflingTiles.steps(widget.pieces);
  var _step = 0;
  var _solves = 0;
  Timer? _timer;

  bool get _solved => _step == _steps.length - 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _restart();
  }

  @override
  void didUpdateWidget(ShufflingTiles oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pieces.join('\u0000') != widget.pieces.join('\u0000')) {
      _steps = ShufflingTiles.steps(widget.pieces);
      _step = 0;
      _restart();
    }
  }

  void _restart() {
    _timer?.cancel();
    if (MediaQuery.disableAnimationsOf(context) || _steps.length < 2) {
      _step = _steps.length - 1;
      return;
    }
    _schedule();
  }

  void _schedule() {
    _timer = Timer(_solved ? AppMotion.shuffleHold : AppMotion.shuffleStep, () {
      if (!mounted) return;
      setState(() {
        _step = (_step + 1) % _steps.length;
        if (_solved) _solves++;
      });
      _schedule();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return LayoutBuilder(
      builder: (context, box) {
        _Layout measure(TextStyle style) => _Layout(
          pieces: widget.pieces,
          steps: _steps,
          style: style,
          maxWidth: box.maxWidth,
          joined: widget.joined,
          scaler: MediaQuery.textScalerOf(context),
          direction: Directionality.of(context),
          locale: widget.locale,
        );
        var layout = measure(
          AppText.titleLg.copyWith(fontWeight: FontWeight.w800),
        );
        if (layout.rows > (widget.joined ? 1 : 2)) {
          layout = measure(
            AppText.titleMd.copyWith(fontWeight: FontWeight.w800),
          );
        }
        final solved = _solved;
        final spots = layout.spots[_step];
        final last = widget.pieces.length - 1;
        return SizedBox(
          width: box.maxWidth,
          height: layout.height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (_solves > 0)
                Positioned(
                  left: 0,
                  top: 0,
                  width: layout.solvedWidth,
                  height: layout.height,
                  child: BubbleBurst(key: ValueKey(_solves), distance: 120),
                ),
              for (var i = 0; i <= last; i++)
                AnimatedPositioned(
                  key: ValueKey(i),
                  duration: AppMotion.shuffle,
                  curve: AppMotion.spring,
                  left: spots[i].dx,
                  top:
                      spots[i].dy +
                      (solved ? 0 : (i * 29 + _step * 17) % 9 - 4),
                  width: layout.widths[i],
                  height: layout.tile,
                  child: AnimatedRotation(
                    duration: AppMotion.shuffle,
                    curve: AppMotion.spring,
                    turns: solved ? 0 : ((i * 37 + _step * 53) % 13 - 6) / 360,
                    child: AnimatedScale(
                      duration: AppMotion.shuffle,
                      curve: AppMotion.spring,
                      scale: solved ? 1 : 0.96,
                      child: AnimatedContainer(
                        duration: AppMotion.base,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: solved ? c.primary : c.primarySoft,
                          borderRadius: widget.joined && solved
                              ? BorderRadius.horizontal(
                                  left: Radius.circular(
                                    i == 0 ? AppRadius.md : 0,
                                  ),
                                  right: Radius.circular(
                                    i == last ? AppRadius.md : 0,
                                  ),
                                )
                              : BorderRadius.circular(AppRadius.md),
                          boxShadow: solved ? c.buttonShadow : null,
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            widget.pieces[i],
                            locale: widget.locale,
                            maxLines: 1,
                            softWrap: false,
                            style: layout.style.copyWith(
                              color: solved ? c.onPrimary : c.primaryText,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Layout {
  factory _Layout({
    required List<String> pieces,
    required List<List<int>> steps,
    required TextStyle style,
    required double maxWidth,
    required bool joined,
    required TextScaler scaler,
    required TextDirection direction,
    required Locale? locale,
  }) {
    final pad = joined ? AppSpacing.s2 : AppSpacing.s3;
    var tile = 0.0;
    final texts = [
      for (final piece in pieces)
        TextPainter(
          text: TextSpan(text: piece, style: style),
          textDirection: direction,
          textScaler: scaler,
          locale: locale,
          maxLines: 1,
        )..layout(),
    ];
    for (final t in texts) {
      tile = math.max(tile, t.height + AppSpacing.s4);
    }
    final widths = [
      for (final t in texts)
        math.min(maxWidth, math.max(t.width + pad * 2, tile * 0.7)),
    ];
    var rows = 1;
    final spots = [
      for (var s = 0; s < steps.length; s++)
        () {
          final gap = joined
              ? (s == steps.length - 1 ? 0.0 : AppSpacing.s1)
              : AppSpacing.s2;
          final spot = List.filled(pieces.length, Offset.zero);
          var x = 0.0;
          var row = 0;
          for (final i in steps[s]) {
            if (x > 0 && x + widths[i] > maxWidth) {
              row++;
              x = 0;
            }
            spot[i] = Offset(x, row * (tile + AppSpacing.s2));
            x += widths[i] + gap;
          }
          rows = math.max(rows, row + 1);
          return spot;
        }(),
    ];
    for (final t in texts) {
      t.dispose();
    }
    var solvedWidth = 0.0;
    for (var i = 0; i < pieces.length; i++) {
      final spot = spots.last[i];
      if (spot.dy == 0) {
        solvedWidth = math.max(solvedWidth, spot.dx + widths[i]);
      }
    }
    return _Layout._(
      style: style,
      widths: widths,
      tile: tile,
      spots: spots,
      rows: rows,
      solvedWidth: solvedWidth,
    );
  }

  const _Layout._({
    required this.style,
    required this.widths,
    required this.tile,
    required this.spots,
    required this.rows,
    required this.solvedWidth,
  });

  final TextStyle style;
  final List<double> widths;
  final double tile;
  final List<List<Offset>> spots;
  final int rows;
  final double solvedWidth;

  double get height => rows * tile + (rows - 1) * AppSpacing.s2;
}
