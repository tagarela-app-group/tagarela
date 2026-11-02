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
  bool settle = true,
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
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump(AppMotion.slow);
    await tester.pump(AppMotion.slow);
  }
  return practice;
}

Finder _visibilityOf(Finder child) =>
    find.ancestor(of: child, matching: find.byType(Visibility)).first;

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

    expect(find.text('Chegou lá, valeu!'), findsOneWidget);
    expect(find.text('Ótimo'), findsOneWidget);
    expect(find.textContaining('Revisão retorna em'), findsOneWidget);
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
    expect(find.text('2 ficaram mais fortes'), findsOneWidget);
    expect(find.text('+ on the fence about'), findsOneWidget);
    expect(find.text('+ an awkward guy'), findsOneWidget);
    expect(find.text('Chegou lá'), findsOneWidget);
    expect(find.text('Com dica'), findsOneWidget);
    expect(find.text('Treino livre: não conta pra revisão.'), findsNothing);

    await tester.tap(find.text('Concluir'));
    await tester.pumpAndSettle();

    expect(find.byType(PracticePage), findsNothing);
  });

  testWidgets('grava erros, dicas, repetições e Devagar da rodada', (
    tester,
  ) async {
    final practice = await _open(
      tester,
      rounds: [PracticeRound(_fence, ExerciseKind.listenWrite)],
    );

    await tester.tap(find.text('Devagar'));
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('Dica: mostra uma letra'));
    await tester.pump();
    await _type(tester, 'nthefanse');
    await tester.tap(find.text('Conferir'));
    await tester.pumpAndSettle();
    await _type(tester, 'ec');
    await tester.tap(find.text('Conferir'));
    await tester.pumpAndSettle();

    final attempt = practice.api.attempts.single;
    expect(attempt['used_slow'], isTrue);
    expect(attempt['audio_replays'], 1);
    expect(attempt['errors'], 1);
    expect(attempt['hints'], 1);
    expect(attempt['response_ms'], isA<int>());
  });

  testWidgets('sem usar nada, a abertura não conta como repetição', (
    tester,
  ) async {
    final practice = await _open(
      tester,
      rounds: [PracticeRound(_fence, ExerciseKind.listenWrite)],
    );

    await _type(tester, 'onthefence');
    await tester.tap(find.text('Conferir'));
    await tester.pumpAndSettle();

    final attempt = practice.api.attempts.single;
    expect(attempt['used_slow'], isFalse);
    expect(attempt['audio_replays'], 0);
    expect(find.textContaining('De primeira e sem Devagar!'), findsOneWidget);
  });

  testWidgets('reteste avisa que o termo voltou', (tester) async {
    await _open(
      tester,
      rounds: [PracticeRound(_fence, ExerciseKind.listenWrite, retest: true)],
    );

    expect(find.text('Esse voltou pra você'), findsOneWidget);
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
    expect(find.textContaining('Revisão retorna em'), findsNothing);
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

  testWidgets('enquanto prepara o jogo, mostra a tela cheia sem o X', (
    tester,
  ) async {
    final api = FakePracticeApi()..hold = Completer();
    await tester.pumpPage(
      PracticePage(rounds: [PracticeRound(_fence, ExerciseKind.listenWrite)]),
      deps: fakeDependencies(practice: fakePractice(api).store),
    );
    await tester.pump();

    expect(find.bySemanticsLabel('Preparando o jogo…'), findsOneWidget);
    expect(find.byType(TypingDots), findsOneWidget);
    expect(find.byTooltip('Sair'), findsNothing);

    api.hold!.complete();
    await tester.pumpAndSettle();

    expect(find.byType(TypingDots), findsNothing);
    expect(find.byTooltip('Sair'), findsOneWidget);
    expect(find.text('Conferir'), findsOneWidget);
  });

  testWidgets('se o jogo demora, a tela oferece a saída', (tester) async {
    final api = FakePracticeApi()..hold = Completer();
    await _open(
      tester,
      api: api,
      settle: false,
      rounds: [PracticeRound(_fence, ExerciseKind.listenWrite)],
    );

    final leave = find.widgetWithText(AppButton, 'Sair', skipOffstage: false);
    expect(tester.widget<Visibility>(_visibilityOf(leave)).visible, isFalse);

    await tester.pump(AppMotion.loadingPatience);
    await tester.pump();

    expect(tester.widget<Visibility>(_visibilityOf(leave)).visible, isTrue);

    await tester.tap(leave);
    await tester.pump(AppMotion.slow);
    await tester.pump(AppMotion.slow);

    expect(find.byType(PracticePage), findsNothing);
    api.hold!.complete();
  });

  group('Responde aí', () {
    FakePracticeApi replyApi(List<Json> fence, [List<Json>? awkward]) =>
        FakePracticeApi()
          ..exercises['t-fence'] = fence
          ..exercises['t-awkward'] = awkward ?? const [];

    Future<void> nina(WidgetTester tester) async {
      await tester.pump(AppMotion.replyTyping);
      await tester.pumpAndSettle();
    }

    Future<void> pick(WidgetTester tester, String option) async {
      await tester.tap(find.widgetWithText(AppButton, option));
      await tester.pump();
      await nina(tester);
    }

    testWidgets(
      'acerta de primeira: envia, a Nina responde e vem o resultado',
      (tester) async {
        final voice = FakeVoice();
        final practice = await _open(
          tester,
          voice: voice,
          api: replyApi([replyJson('e0', filled: 'on the fence')]),
          rounds: [PracticeRound(_fence, ExerciseKind.reply)],
        );

        expect(find.text('Did you decide about Lisbon?'), findsOneWidget);
        expect(find.text('Conferir'), findsNothing);
        expect(voice.spoken, isEmpty);

        await tester.tap(find.widgetWithText(AppButton, 'on the fence'));
        await tester.pump();

        expect(
          voice.spoken.last.$1,
          "Not yet. I'm still on the fence about it.",
        );
        expect(practice.api.attempts.single['outcome'], 'first');
        expect(practice.api.attempts.single['kind'], 'reply');
        expect(find.text('De primeira!'), findsNothing);

        await nina(tester);

        expect(find.text('Fair enough, big move.'), findsOneWidget);
        expect(find.text('De primeira!'), findsOneWidget);
        expect(
          find.textContaining('on the fence: em cima do muro.'),
          findsOneWidget,
        );
        expect(find.textContaining('Revisão retorna em'), findsOneWidget);
      },
    );

    testWidgets(
      'erro: a Nina não entende, a opção apaga e pode ver a resposta',
      (tester) async {
        final practice = await _open(
          tester,
          api: replyApi([replyJson('e0', filled: 'on the fence')]),
          rounds: [PracticeRound(_fence, ExerciseKind.reply)],
        );

        expect(find.text('Mostrar resposta'), findsNothing);

        await pick(tester, 'awkward');

        expect(find.text('Wait, “awkward”? What do you mean?'), findsOneWidget);
        expect(find.text('Mostrar resposta'), findsOneWidget);
        expect(practice.api.attempts, isEmpty);
        final used = tester.widget<AppButton>(
          find.widgetWithText(AppButton, 'awkward'),
        );
        expect(used.onPressed, isNull);

        await pick(tester, 'on the fence');

        expect(practice.api.attempts.single['outcome'], 'slip');
        expect(practice.api.attempts.single['errors'], 1);
        expect(find.text('Na segunda, valeu!'), findsOneWidget);
      },
    );

    testWidgets('mostrar a resposta fecha a rodada como vista', (tester) async {
      final practice = await _open(
        tester,
        api: replyApi([replyJson('e0', filled: 'on the fence')]),
        rounds: [PracticeRound(_fence, ExerciseKind.reply)],
      );

      await pick(tester, 'awkward');
      await tester.tap(find.text('Mostrar resposta'));
      await tester.pump();
      await nina(tester);

      expect(practice.api.attempts.single['outcome'], 'missed');
      expect(find.text('Era assim'), findsOneWidget);
    });

    testWidgets('a conversa segue de um termo pro outro e termina no resumo', (
      tester,
    ) async {
      final practice = await _open(
        tester,
        api: replyApi(
          [replyJson('e0', filled: 'on the fence')],
          [
            replyJson(
              'e1',
              nina: 'How was dinner?',
              segue: 'Oh, by the way:',
              reply: 'It was so awkward.',
              filled: 'awkward',
              answer: 'awkward',
            ),
          ],
        ),
        rounds: [
          PracticeRound(_fence, ExerciseKind.reply),
          PracticeRound(_awkward, ExerciseKind.reply),
        ],
      );

      await pick(tester, 'on the fence');
      await tester.tap(find.text('Próxima'));
      await tester.pump();
      await nina(tester);

      expect(find.text('Did you decide about Lisbon?'), findsOneWidget);
      expect(find.text('Fair enough, big move.'), findsOneWidget);
      expect(find.text('Oh, by the way: How was dinner?'), findsOneWidget);

      await pick(tester, 'awkward');
      await tester.tap(find.text('Ver resumo'));
      await tester.pumpAndSettle();

      expect(find.text('Revisão feita!'), findsOneWidget);
      expect(find.text('2 de 2 de primeira'), findsOneWidget);
      expect(practice.api.attempts, hasLength(2));
    });

    testWidgets(
      'áudio toca sozinho, grava Devagar e só no fim mostra o texto',
      (tester) async {
        final voice = FakeVoice();
        final practice = await _open(
          tester,
          voice: voice,
          api: replyApi([
            replyJson('e0', mode: 'audio', filled: 'on the fence'),
          ]),
          rounds: [PracticeRound(_fence, ExerciseKind.reply)],
        );

        expect(voice.spoken.first.$1, 'Did you decide about Lisbon?');
        expect(find.text('Did you decide about Lisbon?'), findsNothing);

        await tester.tap(find.text('Devagar'));
        await tester.pump();
        await pick(tester, 'on the fence');

        expect(find.text('Did you decide about Lisbon?'), findsOneWidget);
        expect(practice.api.attempts.single['used_slow'], isTrue);
        expect(practice.api.attempts.single['audio_replays'], 1);
      },
    );

    testWidgets('treino da ficha não grava', (tester) async {
      final practice = await _open(
        tester,
        review: false,
        api: replyApi([replyJson('e0', filled: 'on the fence')]),
        rounds: [PracticeRound(_fence, ExerciseKind.reply)],
      );

      await pick(tester, 'on the fence');

      expect(find.text('De primeira!'), findsOneWidget);
      expect(practice.api.attempts, isEmpty);
    });
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
