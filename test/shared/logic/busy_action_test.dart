import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/shared/logic/busy_action.dart';

class _Form extends StatefulWidget {
  const _Form(this.action);

  final Future<void> Function() action;

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> with BusyAction {
  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.ltr,
    child: GestureDetector(
      onTap: () => runAction(widget.action, failureOf: (_) => 'falhou'),
      child: Text('${busy ? 'ocupado' : 'livre'} ${failure ?? 'sem erro'}'),
    ),
  );
}

Future<void> _tap(WidgetTester tester) async {
  await tester.tap(find.byType(Text));
  await tester.pump();
}

void main() {
  testWidgets('ocupado durante a ação; a falha libera e mostra o erro', (
    tester,
  ) async {
    final done = Completer<void>();
    await tester.pumpWidget(_Form(() => done.future));

    await _tap(tester);
    expect(find.text('ocupado sem erro'), findsOneWidget);

    done.completeError(Exception('sem rede'));
    await tester.pumpAndSettle();
    expect(find.text('livre falhou'), findsOneWidget);
  });

  testWidgets('nova tentativa limpa o erro anterior', (tester) async {
    var attempts = 0;
    final retry = Completer<void>();
    await tester.pumpWidget(
      _Form(() {
        attempts++;
        return attempts == 1 ? Future.error(Exception('x')) : retry.future;
      }),
    );

    await _tap(tester);
    await tester.pumpAndSettle();
    expect(find.text('livre falhou'), findsOneWidget);

    await _tap(tester);
    expect(find.text('ocupado sem erro'), findsOneWidget);
    retry.complete();
  });

  testWidgets('falha depois de sair da tela não quebra', (tester) async {
    final done = Completer<void>();
    await tester.pumpWidget(_Form(() => done.future));
    await _tap(tester);

    await tester.pumpWidget(const SizedBox());
    done.completeError(Exception('x'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
