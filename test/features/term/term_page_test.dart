import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/device/voice.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/term/term_page.dart';
import 'package:tagarela/features/term/widgets/got_it_check.dart';
import 'package:tagarela/features/term/widgets/seen_captures.dart';

import '../../helpers/fake_capture_store.dart';
import '../../helpers/fake_course_api.dart';
import '../../helpers/fake_vocabulary_api.dart';
import '../../helpers/fake_voice.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

const _mind = Term('u1', 'mind the gap', '', TermKind.expression, 0);
const _layover = Term('t2', 'layover', 'escala (de voo)', TermKind.word, 4);

FrostedGlass _glass(WidgetTester tester) =>
    tester.widget<FrostedGlass>(find.byType(FrostedGlass));

Finder seenCard(String text) => find
    .ancestor(
      of: find.textContaining(text, findRichText: true),
      matching: find.byType(AppCard),
    )
    .first;

void main() {
  late FakeVocabulary vocabulary;

  setUp(() => vocabulary = fakeVocabulary());

  Future<void> open(
    WidgetTester tester, {
    Term term = _mind,
    FakeVoice? voice,
    FakeCourses? courses,
  }) async {
    await tester.pumpPage(
      TermPage(term: term),
      vocabulary: vocabulary.store,
      voice: voice,
      courses: courses?.store,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('primeira abertura monta a ficha e mostra o termo na hora', (
    tester,
  ) async {
    vocabulary.api.holdCard = Completer();

    await tester.pumpPage(TermPage(term: _mind), vocabulary: vocabulary.store);
    await tester.pump();

    expect(find.text('mind the gap'), findsOneWidget);
    expect(find.bySemanticsLabel('Montando a ficha…'), findsOneWidget);
    expect(find.byType(Skeleton), findsWidgets);
    expect(find.text('Sem grupo'), findsOneWidget);

    vocabulary.api.holdCard!.complete();
    await tester.pumpAndSettle();

    expect(vocabulary.api.calls, contains('GET /api/v1/terms/u1'));
    expect(find.bySemanticsLabel('Montando a ficha…'), findsNothing);
    expect(find.byType(Skeleton), findsNothing);
    expect(find.text('/maɪnd ðə ɡæp/'), findsOneWidget);
    expect(find.text('SIGNIFICADO'), findsOneWidget);
  });

  testWidgets('significado começa embaçado, com convite pra revelar', (
    tester,
  ) async {
    await open(tester);

    expect(_glass(tester).frosted, isTrue);
    expect(find.text('O que será que é?'), findsOneWidget);
    expect(find.bySemanticsLabel('be careful of the space'), findsNothing);
    expect(find.text('Embaçar de novo'), findsNothing);
    expect(find.bySemanticsLabel('Ver em português'), findsNothing);
  });

  testWidgets('revelar salva, mostra o inglês e deixa virar pro português', (
    tester,
  ) async {
    await open(tester);

    await tester.tap(find.text('Revelar de uma vez'));
    await tester.pumpAndSettle();

    expect(vocabulary.api.bodies['PATCH /api/v1/terms/u1'], {'revealed': true});
    expect(_glass(tester).frosted, isFalse);
    expect(find.text('EM INGLÊS'), findsOneWidget);
    expect(find.text('be careful of the space'), findsOneWidget);
    expect(find.text('EM PORTUGUÊS'), findsNothing);

    await tester.tap(find.bySemanticsLabel('Ver em português'));
    await tester.pumpAndSettle();

    final flip = tester.widget<FlipCard>(find.byType(FlipCard));
    expect(flip.flipped, isTrue);
    expect(find.text('EM PORTUGUÊS'), findsOneWidget);
    expect(find.text('Aviso na plataforma do trem.'), findsOneWidget);
    expect(find.bySemanticsLabel('Ver em inglês'), findsOneWidget);
  });

  testWidgets('o card tem a altura do lado à mostra', (tester) async {
    double side() => tester
        .getSize(
          find.descendant(
            of: find.byType(FlipCard),
            matching: find.byType(AppCard),
          ),
        )
        .height;
    double card() => tester.getSize(find.byType(FlipCard)).height;
    vocabulary.api.cards['u1'] = {
      ...sampleCardJson,
      'base': {
        ...sampleCardJson['base']! as Map,
        'explanation':
            'Frase famosa do metrô de Londres, repetida em todo trem que '
            'para na plataforma, pra ninguém pisar no vão.',
      },
    };

    await open(tester);
    await tester.tap(find.text('Revelar de uma vez'));
    await tester.pumpAndSettle();
    final front = side();
    expect(card(), front);

    await tester.tap(find.bySemanticsLabel('Ver em português'));
    await tester.pumpAndSettle();
    expect(side(), greaterThan(front));
    expect(card(), side());
  });

  testWidgets('embaçar de novo volta o vidro e o lado em inglês', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.text('Revelar de uma vez'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Ver em português'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Embaçar de novo'));
    await tester.pumpAndSettle();

    expect(vocabulary.api.bodies['PATCH /api/v1/terms/u1'], {
      'revealed': false,
    });
    expect(_glass(tester).frosted, isTrue);
    expect(tester.widget<FlipCard>(find.byType(FlipCard)).flipped, isFalse);
  });

  testWidgets('o que já foi revelado abre revelado, sem perguntar nem festa', (
    tester,
  ) async {
    vocabulary.api.revealed.add('u1');

    await open(tester);

    expect(_glass(tester).frosted, isFalse);
    expect(find.text('Embaçar de novo'), findsOneWidget);
    expect(find.byType(GotItCheck), findsNothing);
    expect(find.byType(BubbleBurst), findsNothing);
    expect(find.text('PRA LEMBRAR'), findsOneWidget);
  });

  testWidgets('salvar sem rede não impede de revelar', (tester) async {
    await open(tester);
    vocabulary.api.offline = true;

    await tester.tap(find.text('Revelar de uma vez'));
    await tester.pumpAndSettle();

    expect(_glass(tester).frosted, isFalse);
  });

  testWidgets('abas: contexto, palavras e uso', (tester) async {
    await open(tester);

    expect(find.text('Numa conversa'), findsOneWidget);
    expect(find.text('Exemplos'), findsNothing);

    await tester.tap(find.text('Palavras'));
    await tester.pumpAndSettle();
    expect(find.text('Monta a frase'), findsOneWidget);
    expect(find.text('mind the'), findsOneWidget);
    expect(find.text('step'), findsOneWidget);
    expect(find.text('Vizinhos'), findsOneWidget);
    expect(find.text('Quase o mesmo'), findsOneWidget);
    expect(find.text('watch out'), findsOneWidget);
    expect(find.text('O contrário'), findsNothing);

    await tester.tap(find.text('Uso'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<SegmentBar>(find.byType(SegmentBar)).semanticLabel,
      'Formalidade: Neutro, 3 de 4',
    );
    expect(find.text('Do chinelo à gravata'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (w) => w is DrawnIcon && w.glyph != DrawnGlyph.turtle,
      ),
      findsNWidgets(2),
    );
    expect(find.text('Serve em qualquer lugar.'), findsOneWidget);
    expect(find.text('Onde cabe'), findsOneWidget);
    expect(find.bySemanticsLabel('Cabe: Aviso público'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('^Não cabe: Conversa com amigos')),
      findsOneWidget,
    );
    expect(find.text('Prefira careful'), findsOneWidget);
  });

  testWidgets('bloco sem dado some, e aba única fica sem seletor', (
    tester,
  ) async {
    vocabulary.api.cards['u1'] = {
      ...sampleCardJson,
      'examples': <Object?>[],
      'dialogue': <Object?>[],
      'collocations': <Object?>[],
      'synonyms': <Object?>[],
      'formality': null,
      'fits': [
        {'context': 'Aviso público', 'fits': true, 'alternative': null},
      ],
      'phonetic': null,
    };

    await open(tester);

    expect(find.byType(SegmentedControl), findsNothing);
    expect(find.text('Onde cabe'), findsOneWidget);
    expect(find.text('Formalidade'), findsNothing);
    expect(find.text('/maɪnd ðə ɡæp/'), findsNothing);
  });

  testWidgets('onde você viu: captura com o termo marcado e vizinhos', (
    tester,
  ) async {
    vocabulary.api.seen['u1'] = [
      {
        'id': 'c1',
        'source': 'text',
        'text': 'Please mind the gap and stand clear.',
        'captured_at': DateTime.now().toIso8601String(),
        'terms': [
          {'text': 'mind the gap', 'start': 7, 'end': 19, 'term': 'u1'},
          {'text': 'stand clear', 'start': 24, 'end': 35, 'term': 'u2'},
          {'text': 'Please', 'start': 0, 'end': 6, 'term': null},
        ],
      },
    ];

    await open(tester);

    expect(find.text('Onde você viu'), findsOneWidget);
    expect(find.text('1 captura'), findsOneWidget);
    expect(
      find.textContaining('Você anotou · ', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Também marcado'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(SeenCaptures),
        matching: find.byType(SingleChildScrollView),
      ),
      findsNothing,
    );
    expect(
      tester.getSize(find.byType(SeenCaptures)).width,
      tester.getSize(seenCard('Please mind the gap and stand clear.')).width,
    );
    final chips = tester.widgetList<AppChip>(find.byType(AppChip));
    expect(chips.map((c) => c.label), ['stand clear']);

    await tester.tap(find.text('stand clear'));
    await tester.pumpAndSettle();

    expect(find.byType(TermPage, skipOffstage: false), findsNWidgets(2));
    expect(vocabulary.api.calls, contains('GET /api/v1/terms/u2'));
  });

  testWidgets('onde você viu: mais de uma captura vira carrossel', (
    tester,
  ) async {
    vocabulary.api.seen['u1'] = [
      for (final (id, text) in [
        ('c1', 'Please mind the gap.'),
        ('c2', 'Mind the gap, please.'),
      ])
        {
          'id': id,
          'source': 'text',
          'text': text,
          'captured_at': DateTime.now().toIso8601String(),
          'terms': <Object?>[],
        },
    ];

    await open(tester);

    expect(find.text('2 capturas'), findsOneWidget);
    expect(
      tester.getSize(seenCard('Please mind the gap.')).width,
      SeenCaptures.cardWidth,
    );
  });

  testWidgets('captura de áudio no aparelho deixa ouvir a gravação', (
    tester,
  ) async {
    final captures = fakeCaptures();
    const path = 'captures/audio/a1.m4a';
    captures.media.files[path] = File(path);
    await captures.db.saveCapture(
      'ana@example.com',
      sampleCapture(
        'a1',
        source: CaptureSource.audio,
        status: CaptureStatus.analyzed,
      ).copyWith(mediaPath: () => path),
    );
    vocabulary.api.seen['u1'] = [
      {
        'id': 'a1',
        'source': 'audio',
        'text': 'Mind the gap!',
        'captured_at': DateTime.now().toIso8601String(),
        'terms': [
          {'text': 'Mind the gap', 'start': 0, 'end': 12, 'term': 'u1'},
        ],
      },
    ];
    final playback = FakeAudioPlayback();

    await tester.pumpPage(
      const TermPage(term: _mind),
      vocabulary: vocabulary.store,
      captures: captures.store,
      playback: playback,
    );
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Você ouviu', findRichText: true),
      findsOneWidget,
    );
    expect(find.byType(Waveform), findsOneWidget);

    await tester.tap(find.byTooltip('Ouvir gravação'));
    await tester.pump();

    expect(playback.toggled, [path]);
  });

  testWidgets('ouvir e devagar falam o termo no idioma do curso', (
    tester,
  ) async {
    final voice = FakeVoice();
    await open(
      tester,
      term: _layover,
      voice: voice,
      courses: fakeCourses([
        {...spanishCourseJson, 'active': true},
      ]),
    );

    await tester.tap(find.byTooltip('Ouvir pronúncia'));
    await tester.pump();
    expect(find.byTooltip('Parar'), findsOneWidget);
    await tester.tap(find.text('Devagar'));
    await tester.pump();

    expect(voice.spoken, [
      ('layover', CourseLanguage.es, VoiceSpeed.normal),
      ('layover', CourseLanguage.es, VoiceSpeed.slow),
    ]);
    expect(find.text('Viagem'), findsOneWidget);
    expect(find.text('Dominado'), findsOneWidget);
  });

  testWidgets('sair da ficha cala a voz', (tester) async {
    final voice = FakeVoice();
    await open(tester, voice: voice);

    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();

    expect(voice.stops, 1);
  });

  testWidgets('falha ao montar: tenta de novo', (tester) async {
    vocabulary.api.rejections['GET /api/v1/terms/u1'] = 503;

    await open(tester);

    expect(find.text('Não deu pra carregar'), findsOneWidget);
    expect(find.text('mind the gap'), findsOneWidget);

    vocabulary.api.rejections.clear();
    await tester.tap(find.text('Tentar de novo'));
    await tester.pumpAndSettle();

    expect(find.text('SIGNIFICADO'), findsOneWidget);
  });

  Future<void> wipe(WidgetTester tester) async {
    final box = tester.getRect(find.byType(FrostedGlass));
    for (var y = 12.0; y < box.height; y += 36) {
      await tester.timedDragFrom(
        Offset(box.left + 4, box.top + y),
        Offset(box.width - 8, 0),
        const Duration(milliseconds: 300),
      );
    }
    await tester.pump();
  }

  testWidgets('passar o dedo no vidro revela, salva e solta os balões', (
    tester,
  ) async {
    await open(tester);

    await wipe(tester);

    expect(vocabulary.api.bodies['PATCH /api/v1/terms/u1'], {'revealed': true});
    expect(_glass(tester).frosted, isFalse);
    expect(find.byType(BubbleBurst), findsOneWidget);
    expect(find.text('Tinha sacado pelo contexto?'), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('dica mostra o ao pé da letra sem revelar', (tester) async {
    await open(tester);

    expect(
      find.textContaining('repare no vão', findRichText: true),
      findsNothing,
    );

    await tester.tap(find.text('Dica'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Ao pé da letra: repare no vão', findRichText: true),
      findsOneWidget,
    );
    expect(_glass(tester).frosted, isTrue);
  });

  testWidgets('sem ao pé da letra, não tem dica', (tester) async {
    vocabulary.api.cards['u1'] = {
      ...sampleCardJson,
      'base': {...sampleCardJson['base']! as Map, 'literal': null},
    };

    await open(tester);

    expect(find.text('Dica'), findsNothing);
    expect(find.text('Revelar de uma vez'), findsOneWidget);
  });

  testWidgets('tinha sacado: responde como amigo e some ao embaçar', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.text('Revelar de uma vez'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Saquei'));
    await tester.pumpAndSettle();

    expect(find.text('Boa! O contexto te entregou.'), findsOneWidget);
    expect(find.text('Tinha sacado pelo contexto?'), findsNothing);

    await tester.tap(find.text('Embaçar de novo'));
    await tester.pumpAndSettle();

    expect(find.byType(GotItCheck), findsNothing);

    await tester.tap(find.text('Revelar de uma vez'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Não'));
    await tester.pumpAndSettle();

    expect(find.text('Tranquilo. Agora você sabe.'), findsOneWidget);
  });

  testWidgets('pra lembrar: ao pé da letra, imagem e pegadinha só revelada', (
    tester,
  ) async {
    await open(tester);

    expect(find.text('PRA LEMBRAR'), findsNothing);
    expect(find.text('mind the hole'), findsNothing);

    await tester.tap(find.text('Revelar de uma vez'));
    await tester.pumpAndSettle();

    expect(find.text('PRA LEMBRAR'), findsOneWidget);
    expect(find.text('AO PÉ DA LETRA'), findsOneWidget);
    expect(find.text('repare no vão'), findsOneWidget);
    expect(find.text('QUER DIZER'), findsOneWidget);
    expect(
      find.textContaining('Imagine: Uma faixa amarela', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Pegadinha'), findsOneWidget);
    expect(find.text('Não diga'), findsOneWidget);
    expect(find.text('mind the hole'), findsOneWidget);
    expect(find.text('Diga'), findsOneWidget);
    expect(find.text('Não é "mente o buraco".'), findsOneWidget);
  });

  testWidgets('pegadinha sem formas mostra só o aviso', (tester) async {
    vocabulary.api.revealed.add('u1');
    vocabulary.api.cards['u1'] = {
      ...sampleCardJson,
      'base': {
        ...sampleCardJson['base']! as Map,
        'literal': null,
        'imagine': null,
      },
      'mistake': null,
    };

    await open(tester);

    expect(find.text('AO PÉ DA LETRA'), findsNothing);
    expect(find.text('Não diga'), findsNothing);
    expect(find.text('Não é "mente o buraco".'), findsOneWidget);
  });

  testWidgets('conversa: ouvir acende a fala da vez, tradução só revelada', (
    tester,
  ) async {
    final voice = FakeVoice();
    await open(tester, voice: voice);
    const first = 'Hurry up, the train is here!';
    const second = 'Coming! I always forget to mind the gap.';

    await tester.tap(find.text('Ouvir'));
    await tester.pump();

    expect(voice.conversations, [
      [first, second],
    ]);
    voice.say(second, line: 1);
    await tester.pumpAndSettle();

    SpeechBalloon balloon(String text) => tester.widget<SpeechBalloon>(
      find.ancestor(
        of: find.textContaining(text, findRichText: true),
        matching: find.byType(SpeechBalloon),
      ),
    );
    expect(balloon(second).ring, isNotNull);
    expect(balloon(first).ring, isNull);
    expect(balloon(second).mirrored, isTrue);

    await tester.tap(find.textContaining(first, findRichText: true));
    await tester.pumpAndSettle();
    expect(find.text('Corre, o trem chegou!'), findsNothing);
    expect(
      find.text('A tradução aparece depois que você revelar.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Revelar de uma vez'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.textContaining(first, findRichText: true));
    await tester.tap(find.textContaining(first, findRichText: true));
    await tester.pumpAndSettle();

    expect(find.text('Corre, o trem chegou!'), findsOneWidget);
    expect(find.text('Toque num balão pra ver a tradução.'), findsOneWidget);
  });

  testWidgets('sem conversa, os exemplos voltam', (tester) async {
    vocabulary.api.cards['u1'] = {...sampleCardJson, 'dialogue': <Object?>[]};

    await open(tester);

    expect(find.text('Numa conversa'), findsNothing);
    expect(find.text('Exemplos'), findsOneWidget);
  });

  testWidgets('monta a frase: ouvir cada combinação', (tester) async {
    final voice = FakeVoice();
    await open(tester, voice: voice);
    await tester.tap(find.text('Palavras'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Ouvir mind the step'));
    await tester.pump();

    expect(voice.spoken, [
      ('mind the step', CourseLanguage.en, VoiceSpeed.normal),
    ]);
    expect(find.byTooltip('Ouvir mind the step'), findsOneWidget);
    expect(
      tester
          .widget<AppIconButton>(
            find.ancestor(
              of: find.byIcon(AppIcons.stop),
              matching: find.byType(AppIconButton),
            ),
          )
          .tooltip,
      'Ouvir mind the step',
    );
  });

  testWidgets('a palavra falada acende no balão do termo', (tester) async {
    final voice = FakeVoice();
    await open(tester, voice: voice);

    await tester.tap(find.byTooltip('Ouvir pronúncia'));
    await tester.pump();
    voice.say('mind the gap', word: (5, 8));
    await tester.pump();

    final spoken = tester
        .widgetList<RichText>(find.byType(RichText))
        .firstWhere((w) => w.text.toPlainText() == 'mind the gap');
    final lit = <String>[];
    spoken.text.visitChildren((span) {
      if (span is TextSpan && span.style?.color != null) lit.add(span.text!);
      return true;
    });
    expect(lit, ['the']);
  });
}
