import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/features/home/widgets/review_card.dart';

import '../../../helpers/pump_app.dart';

void main() {
  final now = DateTime(2026, 11, 1, 12);

  Future<void> pump(
    WidgetTester tester,
    ReviewSession review, {
    void Function()? onStart,
    void Function()? onAskForMore,
  }) => tester.pumpComponent(
    ReviewCard(
      review: review,
      now: now,
      onStart: onStart ?? () {},
      onAskForMore: onAskForMore ?? () {},
    ),
  );

  testWidgets('mostra quantidade, tempo e chama onStart', (tester) async {
    var taps = 0;
    await pump(
      tester,
      const ReviewSession(due: 7, rounds: []),
      onStart: () => taps++,
    );

    expect(find.text('7 termos'), findsOneWidget);
    expect(find.text('Cerca de 5 min'), findsOneWidget);
    await tester.tap(find.text('Começar'));
    expect(taps, 1);
  });

  testWidgets('com parte feita mostra o progresso', (tester) async {
    await pump(tester, const ReviewSession(due: 5, done: 7, rounds: []));

    expect(find.text('7 de 12'), findsOneWidget);
    expect(find.text('Começar'), findsOneWidget);
  });

  testWidgets('limite atingido: por hoje é só, com a opção de pedir mais', (
    tester,
  ) async {
    var asks = 0;
    await pump(
      tester,
      const ReviewSession(due: 0, done: 10, waiting: 3, rounds: []),
      onAskForMore: () => asks++,
    );

    expect(find.text('Por hoje é só'), findsOneWidget);
    expect(find.text('3 termos esperando'), findsOneWidget);
    expect(find.text('Começar'), findsNothing);
    await tester.tap(find.text('Pedir mais'));
    expect(asks, 1);
  });

  testWidgets('tudo em dia diz quando vem a próxima', (tester) async {
    await pump(
      tester,
      ReviewSession(
        due: 0,
        rounds: const [],
        nextDueAt: now.add(const Duration(days: 3)),
      ),
    );

    expect(find.text('Tudo em dia'), findsOneWidget);
    expect(find.text('A próxima vem em 3 dias'), findsOneWidget);
    expect(find.text('Pedir mais'), findsNothing);
  });
}
