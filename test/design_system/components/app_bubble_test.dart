import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

final _pixel = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, //
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x60, 0x00, 0x02, 0x00,
  0x00, 0x05, 0x00, 0x01, 0xE9, 0xFA, 0xDC, 0xD8, 0x00, 0x00, 0x00, 0x00,
  0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

void main() {
  testWidgets('ring: anel de 4 em volta do balão', (tester) async {
    await tester.pumpComponent(
      const AppBubble(ring: AppPalette.white, child: Text('AS')),
    );

    final box = tester.widget<Container>(
      find.descendant(
        of: find.byType(AppBubble),
        matching: find.byType(Container),
      ),
    );
    final shadow = (box.decoration! as BoxDecoration).boxShadow!.single;
    expect(shadow.color, AppPalette.white);
    expect(shadow.spreadRadius, AppBubble.ringWidth);
    expect(shadow.blurRadius, 0);
  });

  testWidgets('sem imagem mostra só o conteúdo', (tester) async {
    await tester.pumpComponent(const AppBubble(child: Text('AS')));

    expect(find.text('AS'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('com imagem: foto por cima, recortada no balão', (tester) async {
    await tester.pumpComponent(
      AppBubble(image: MemoryImage(_pixel), child: const Text('AS')),
    );

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('AS'), findsOneWidget);
    final box = tester.widget<Container>(
      find.descendant(
        of: find.byType(AppBubble),
        matching: find.byType(Container),
      ),
    );
    expect(box.clipBehavior, Clip.antiAlias);
  });

  testWidgets('imagem que falha deixa as iniciais à mostra', (tester) async {
    await tester.pumpComponent(
      AppBubble(
        image: MemoryImage(Uint8List.fromList([0, 1, 2])),
        child: const Text('AS'),
      ),
    );
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();

    expect(find.text('AS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('badge no canto inferior direito, sem mudar o tamanho', (
    tester,
  ) async {
    await tester.pumpComponent(
      const Center(
        child: AppBubble(
          size: 80,
          badge: SizedBox.square(key: Key('badge'), dimension: 24),
          child: Text('AS'),
        ),
      ),
    );

    final bubble = tester.getRect(find.byType(AppBubble));
    final badge = tester.getRect(find.byKey(const Key('badge')));
    expect(bubble.size, const Size(80, 80));
    expect(badge.right, greaterThan(bubble.right));
    expect(badge.bottom, greaterThan(bubble.bottom));
    expect(badge.center.dx, greaterThan(bubble.center.dx));
  });
}
