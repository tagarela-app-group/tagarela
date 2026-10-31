import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/device/voice.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/practice/logic/practice_session.dart';
import 'package:tagarela/features/practice/practice_page.dart';

import '../../helpers/fake_practice_api.dart';
import '../../helpers/fake_voice.dart';
import '../../helpers/pump_app.dart';

final _fence = Term.fromJson(fenceTermJson);
final _awkward = Term.fromJson(awkwardTermJson);

Future<void> _type(WidgetTester tester, String letters) async {
  for (final letter in letters.split('')) {
    await tester.tap(find.bySemanticsLabel('Letra ${letter.toUpperCase()}'));
    await tester.pump();
  }
}

Future<FakePractice> _open(
  WidgetTester tester, {
  required List<PracticeRound> rounds,
  bool review = true,
  FakeVoice? voice,
  FakePracticeApi? api,
}) async {
  final practice = fakePractice(api);
  await tester.pumpPage(
    Builder(
      builder: (context) => Scaffold(
        body: TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => PracticePage(rounds: rounds, review: review),
            ),
          ),
          child: const Text('abrir'),
        ),
      ),
    ),
    deps: fakeDependencies(practice: practice.store, voice: voice),
  );
  await tester.tap(find.text('abrir'));
  await tester.pumpAndSettle();
  return practice;
}

void main() {
  testWidgets('revisão: erra, corrige, usa dica e termina no resumo', (
    tester,
  ) async {
    final voice = FakeVoice();
    final practice = await _open(
      tester,
      voice: voice,
      rounds: [
        PracticeRound(_fence, ExerciseKind.listenWrite),
        PracticeRound(_awkward, ExerciseKind.listenWrite),
      ],
    );

    expect(find.text('1/2'), findsOneWidget);
    expect(voice.spoken.first, (
      "I'm still on the fence about moving to Lisbon.",
      CourseLanguage.en,
      VoiceSpeed.normal,
    ));
    expect(find.text('Ouça e complete: 10 letras'), findsOneWidget);

    await _type(tester, 'onthefanse');
    await tester.tap(find.text('Conferir'));
    await tester.pumpAndSettle();

    expect(find.text('Quase! 2 letras trocadas'), findsOneWidget);
    expect(find.text('Mostrar resposta'), findsOneWidget);
    expect(practice.api.attempts, isEmpty);

    await _type(tester, 'ec');
    await tester.tap(find.text('Conferir'));
    await tester.pumpAndSettle();

    expect(find.text('Na segunda, valeu!'), findsOneWidget);
    expect(
      find.text('Ainda tô em cima do muro sobre me mudar pra Lisboa.'),
      findsOneWidget,
    );
    expect(find.text('LEVA JUNTO'), findsOneWidget);
    expect(find.text('Conferir'), findsNothing);
    expect(practice.api.attempts.single, containsPair('term', 't-fence'));
    expect(practice.api.attempts.single, containsPair('outcome', 'retry'));

    await tester.tap(find.text('Próxima'));
    await tester.pumpAndSettle();

    expect(find.text('2/2'), findsOneWidget);
    expect(voice.spoken.last.$1, 'That silence after his joke was so awkward.');

    await tester.tap(find.bySemanticsLabel('Dica: mostra uma letra'));
    await tester.pump();
    await _type(tester, 'wkward');
    await tester.tap(find.text('Conferir'));
    await tester.pumpAndSettle();

    expect(find.text('Foi, com uma ajuda'), findsOneWidget);
    expect(practice.api.attempts.last['outcome'], 'hint');

    await tester.tap(find.text('Ver resumo'));
    await tester.pumpAndSettle();

    expect(find.text('Revisão feita!'), findsOneWidget);
    expect(find.text('0 de 2 de primeira'), findsOneWidget);
    expect(find.text('+ on the fence about'), findsOneWidget);
    expect(find.text('+ an awkward guy'), findsOneWidget);
    expect(find.text('Na segunda'), findsOneWidget);
    expect(find.text('Com dica'), findsOneWidget);
    expect(find.text('Treino livre: não conta pra revisão.'), findsNothing);

    await tester.tap(find.text('Concluir'));
    await tester.pumpAndSettle();

    expect(find.byType(PracticePage), findsNothing);
  });

  testWidgets('mostrar a resposta fecha a rodada como vista', (tester) async {
    final practice = await _open(
      tester,
      rounds: [PracticeRound(_fence, ExerciseKind.listenWrite)],
    );

    await _type(tester, 'onthefanse');
    await tester.tap(find.text('Conferir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mostrar resposta'));
    await tester.pumpAndSettle();

    expect(find.text('Era assim'), findsOneWidget);
    expect(find.text('Ver resumo'), findsOneWidget);
    expect(practice.api.attempts.single['outcome'], 'missed');
  });

  testWidgets('treino da ficha passa pelas variações e não grava', (
    tester,
  ) async {
    final practice = await _open(
      tester,
      review: false,
      rounds: [
        for (var v = 0; v < 3; v++)
          PracticeRound(_fence, ExerciseKind.listenWrite, variant: v),
      ],
    );

    expect(find.text('1/2'), findsOneWidget);

    await _type(tester, 'onthefence');
    await tester.tap(find.text('Conferir'));
    await tester.pumpAndSettle();
    expect(find.text('De primeira!'), findsOneWidget);

    await tester.tap(find.text('Próxima'));
    await tester.pumpAndSettle();
    await _type(tester, 'onthefence');
    await tester.tap(find.text('Conferir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ver resumo'));
    await tester.pumpAndSettle();

    expect(find.text('Treino feito!'), findsOneWidget);
    expect(find.text('2 de 2 de primeira'), findsOneWidget);
    expect(find.text('Treino livre: não conta pra revisão.'), findsOneWidget);
    expect(practice.api.attempts, isEmpty);
    expect(
      practice.api.calls.where((c) => c.contains('/exercises/')),
      hasLength(1),
    );
  });

  testWidgets('falha ao buscar a frase: tenta de novo', (tester) async {
    final api = FakePracticeApi()..failing.add('t-fence');
    await _open(
      tester,
      api: api,
      rounds: [PracticeRound(_fence, ExerciseKind.listenWrite)],
    );

    expect(find.text('Tentar de novo'), findsOneWidget);

    api.failing.clear();
    await tester.tap(find.text('Tentar de novo'));
    await tester.pumpAndSettle();

    expect(find.text('Conferir'), findsOneWidget);
  });

  testWidgets('enquanto prepara a frase, mostra o balão esperando', (
    tester,
  ) async {
    final api = FakePracticeApi()..hold = Completer();
    await tester.pumpPage(
      PracticePage(rounds: [PracticeRound(_fence, ExerciseKind.listenWrite)]),
      deps: fakeDependencies(practice: fakePractice(api).store),
    );
    await tester.pump();

    expect(find.bySemanticsLabel('Preparando a frase…'), findsOneWidget);
    expect(find.byType(TypingDots), findsOneWidget);

    api.hold!.complete();
    await tester.pumpAndSettle();

    expect(find.byType(TypingDots), findsNothing);
    expect(find.text('Conferir'), findsOneWidget);
  });

  testWidgets('palavra longa quebra com hífen e mantém o tamanho da peça', (
    tester,
  ) async {
    final api = FakePracticeApi()
      ..exercises['t-fence'] = [
        listenWriteJson(
          'e-long',
          sentence: 'Procrastination is why I am writing this at 3 a.m.',
          answer: 'Procrastination',
          syllables: 'Pro|cras|ti|na|tion',
        ),
      ];
    final practice = fakePractice(api);
    await tester.pumpPage(
      PracticePage(rounds: [PracticeRound(_fence, ExerciseKind.listenWrite)]),
      deps: fakeDependencies(practice: practice.store),
    );
    tester.view.physicalSize = const Size(360, 780);
    await tester.pumpAndSettle();

    expect(find.text('-'), findsOneWidget);
    for (final tile in tester.widgetList<LetterTile>(find.byType(LetterTile))) {
      expect(tile.width, 24);
    }
  });
}
