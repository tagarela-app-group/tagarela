import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  const box = 400.0;
  const photo = box - CropFrame.gutter * 2;
  const origin = Offset(CropFrame.gutter, CropFrame.gutter);

  Future<ValueNotifier<Rect>> pump(
    WidgetTester tester, {
    Size imageSize = const Size(1000, 1000),
    double maxHeight = box,
    Rect area = CropFrame.full,
  }) async {
    final value = ValueNotifier(area);
    await tester.pumpComponent(
      Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: box,
          child: ValueListenableBuilder(
            valueListenable: value,
            builder: (context, current, _) => CropFrame(
              imageSize: imageSize,
              maxHeight: maxHeight,
              area: current,
              onChanged: (next) => value.value = next,
              child: const ColoredBox(color: AppPalette.mint),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return value;
  }

  Offset global(WidgetTester tester, Offset local) =>
      tester.getTopLeft(find.byType(CropFrame)) + local;

  Future<void> drag(WidgetTester tester, Offset from, Offset by) async {
    final gesture = await tester.startGesture(global(tester, origin + from));
    await gesture.moveBy(by);
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
  }

  void expectArea(Rect actual, Rect expected) {
    expect(actual.left, closeTo(expected.left, 0.01));
    expect(actual.top, closeTo(expected.top, 0.01));
    expect(actual.right, closeTo(expected.right, 0.01));
    expect(actual.bottom, closeTo(expected.bottom, 0.01));
  }

  testWidgets('arrastar o canto muda só os dois lados dele', (tester) async {
    final area = await pump(tester);

    await drag(
      tester,
      const Offset(photo, photo),
      const Offset(-photo / 2, -photo / 4),
    );

    expectArea(area.value, const Rect.fromLTRB(0, 0, 0.5, 0.75));
  });

  testWidgets('arrastar a borda muda só aquele lado', (tester) async {
    final area = await pump(tester);

    await drag(
      tester,
      const Offset(0, photo / 2),
      const Offset(photo / 4, photo / 4),
    );

    expectArea(area.value, const Rect.fromLTRB(0.25, 0, 1, 1));
  });

  Future<ValueNotifier<Rect>> moveMiddle(WidgetTester tester, Offset by) async {
    final area = await pump(
      tester,
      area: const Rect.fromLTRB(0.25, 0.25, 0.75, 0.75),
    );
    await drag(tester, const Offset(photo / 2, photo / 2), by);
    return area;
  }

  testWidgets('arrastar por dentro move sem mudar o tamanho', (tester) async {
    final area = await moveMiddle(tester, const Offset(photo / 8, 0));

    expectArea(area.value, const Rect.fromLTRB(0.375, 0.25, 0.875, 0.75));
  });

  testWidgets('mover não deixa a moldura sair da foto', (tester) async {
    final area = await moveMiddle(tester, const Offset(photo, -photo));

    expectArea(area.value, const Rect.fromLTRB(0.5, 0, 1, 0.5));
  });

  testWidgets('a moldura não fica menor que o mínimo nem cruza o outro lado', (
    tester,
  ) async {
    final area = await pump(tester);

    await drag(
      tester,
      const Offset(photo, photo),
      const Offset(-photo * 2, -photo * 2),
    );

    final side = CropFrame.minSide / photo;
    expectArea(area.value, Rect.fromLTRB(0, 0, side, side));
  });

  testWidgets('toque fora da moldura não mexe em nada', (tester) async {
    final start = const Rect.fromLTRB(0.5, 0.5, 0.75, 0.75);
    final area = await pump(tester, area: start);

    await drag(tester, const Offset(10, 10), const Offset(40, 40));

    expect(area.value, start);
  });

  testWidgets('foto bem alta respeita a altura máxima', (tester) async {
    await pump(tester, imageSize: const Size(1000, 4000), maxHeight: 300);

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(CropFrame)).height, 300);
  });

  testWidgets('dentro de um painel, o arrasto é da moldura, não do painel', (
    tester,
  ) async {
    final results = <Rect>[];
    await tester.pumpComponent(
      Builder(
        builder: (context) => TextButton(
          onPressed: () => showModalBottomSheet<void>(
            context: context,
            builder: (_) => CropFrame(
              imageSize: const Size(1000, 500),
              maxHeight: 300,
              area: CropFrame.full,
              onChanged: results.add,
              child: const ColoredBox(color: AppPalette.mint),
            ),
          ),
          child: const Text('Abrir'),
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    final frame = tester.getRect(find.byType(CropFrame));
    final edge = frame.bottomCenter - const Offset(0, CropFrame.gutter);
    final gesture = await tester.startGesture(edge);
    await gesture.moveBy(const Offset(0, -100));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.byType(CropFrame), findsOneWidget);
    expect(results, isNotEmpty);
  });
}
