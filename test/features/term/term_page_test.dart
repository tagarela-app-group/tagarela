import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/device/voice.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/practice/practice_page.dart';
import 'package:tagarela/features/term/term_page.dart';
import 'package:tagarela/features/term/widgets/got_it_check.dart';
import 'package:tagarela/features/term/widgets/highlighted_text.dart';
import 'package:tagarela/features/term/widgets/meaning_card.dart';
import 'package:tagarela/features/term/widgets/seen_captures.dart';
import 'package:tagarela/features/term/widgets/term_pitfall.dart';
import 'package:tagarela/features/term/widgets/term_usage.dart';

import '../../helpers/fake_capture_store.dart';
import '../../helpers/fake_course_api.dart';
import '../../helpers/fake_practice_api.dart';
import '../../helpers/fake_vocabulary_api.dart';
import '../../helpers/fake_voice.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

const _mind = Term('u1', 'mind the gap', TermKind.expression, 0);
const _layover = Term('t2', 'layover', TermKind.word, 5);

final _inPitfall = find.descendant(
  of: find.byType(TermPitfall),
  matching: find.byType(Obscured),
);

Iterable<bool> _fog(WidgetTester tester) {
  final pitfall = tester.widgetList(_inPitfall).toSet();
  return tester
      .widgetList<Obscured>(find.byType(Obscured))
      .where((o) => !pitfall.contains(o))
      .map((o) => o.obscured);
}

Iterable<bool> _pitfallFog(WidgetTester tester) =>
    tester.widgetList<Obscured>(_inPitfall).map((o) => o.obscured);

Iterable<TextSpan> _spansOf(WidgetTester tester, Finder text) =>
    (tester.widget<RichText>(text).text as TextSpan).children!
        .whereType<TextSpan>()
        .expand((span) => span.children ?? [span])
        .whereType<TextSpan>();

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
      deps: fakeDependencies(
        vocabulary: vocabulary.store,
        voice: voice,
        courses: courses?.store,
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<Finder> openFormalityNote(WidgetTester tester) async {
    await open(tester);
    await tester.tap(find.text('Uso'));
    await tester.pumpAndSettle();
    return find.ancestor(
      of: find.text('Serve em qualquer lugar.'),
      matching: find.byType(Obscured),
    );
  }

  testWidgets('primeira abertura monta a ficha e mostra o termo na hora', (
    tester,
  ) async {
    vocabulary.api.holdCard = Completer();

    await tester.pumpPage(
      TermPage(term: _mind),
      deps: fakeDependencies(vocabulary: vocabulary.store),
    );
    await tester.pump();

    expect(find.bySemanticsLabel('mind the gap'), findsOneWidget);
    expect(find.bySemanticsLabel('Montando a ficha…'), findsOneWidget);
    expect(find.byType(ShufflingTiles), findsOneWidget);
    expect(
      find.text('Só demora na primeira vez. Depois, a ficha fica salva.'),
      findsOneWidget,
    );
    expect(find.text('Sem grupo'), findsOneWidget);

    vocabulary.api.holdCard!.complete();
    await tester.pumpAndSettle();

    expect(vocabulary.api.calls, contains('GET /api/v1/terms/u1'));
    expect(find.bySemanticsLabel('Montando a ficha…'), findsNothing);
    expect(find.byType(ShufflingTiles), findsNothing);
    expect(find.text('/maɪnd ðə ɡæp/'), findsOneWidget);
    expect(find.text('SIGNIFICADO'), findsOneWidget);
  });

  testWidgets('significado aparece direto e vira pro português', (
    tester,
  ) async {
    await open(tester);

    expect(find.text('EM INGLÊS'), findsOneWidget);
    expect(
      find.text('be careful of the space', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('EM PORTUGUÊS'), findsNothing);

    await tester.tap(find.bySemanticsLabel('Ver em português'));
    await tester.pumpAndSettle();

    final flip = tester.widget<FlipCard>(find.byType(FlipCard));
    expect(flip.flipped, isTrue);
    expect(find.text('EM PORTUGUÊS'), findsOneWidget);
    expect(
      find.text('Aviso na plataforma do trem.', findRichText: true),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Ver em inglês'), findsOneWidget);
    expect(vocabulary.api.bodies, isNot(contains('PATCH /api/v1/terms/u1')));
  });

  testWidgets('termo citado no significado fica marcado nos dois lados', (
    tester,
  ) async {
    const cited = '"Mind the gap" é o aviso do metrô.';
    vocabulary.api.cards['u1'] = {
      ...sampleCardJson,
      'learning': {
        ...sampleCardJson['learning']! as Map,
        'explanation': 'People say mind the gap on trains.',
      },
      'base': {...sampleCardJson['base']! as Map, 'explanation': cited},
    };
    await open(tester);
    Map<String, List<(int, int)>> marks() => {
      for (final text in tester.widgetList<HighlightedText>(
        find.descendant(
          of: find.byType(MeaningCard),
          matching: find.byType(HighlightedText),
        ),
      ))
        text.text: text.ranges,
    };

    expect(marks()['People say mind the gap on trains.'], [(11, 23)]);

    await tester.tap(find.bySemanticsLabel('Ver em português'));
    await tester.pumpAndSettle();

    expect(marks()[cited], [(1, 13)]);
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
    final front = side();
    expect(card(), front);

    await tester.tap(find.bySemanticsLabel('Ver em português'));
    await tester.pumpAndSettle();
    expect(side(), greaterThan(front));
    expect(card(), side());
  });

  testWidgets(
    'pra lembrar nasce desfocado; revelar e embaçar trocam o desfoque',
    (tester) async {
      await open(tester);

      expect(_fog(tester), [true, true]);
      expect(find.bySemanticsLabel(RegExp('repare no vão')), findsNothing);
      expect(find.text('Embaçar de novo'), findsNothing);

      await tester.tap(find.text('Revelar'));
      await tester.pumpAndSettle();

      expect(_fog(tester), [false, false]);
      expect(find.bySemanticsLabel(RegExp('repare no vão')), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp('cuidado com o vão')),
        findsOneWidget,
      );

      await tester.tap(find.text('Embaçar de novo'));
      await tester.pumpAndSettle();

      expect(_fog(tester), [true, true]);
      expect(find.text('Revelar'), findsOneWidget);
    },
  );

  testWidgets('o que já foi revelado abre revelado, sem perguntar nem festa', (
    tester,
  ) async {
    vocabulary.api.revealed.add('u1');

    await open(tester);

    expect(_fog(tester), [false, false]);
    expect(find.text('Embaçar de novo'), findsOneWidget);
    expect(find.byType(GotItCheck), findsNothing);
    expect(find.byType(BubbleBurst), findsNothing);
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

  testWidgets('uso no idioma base: só o nível aceso, sem o termo na régua', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.text('Uso'));
    await tester.pumpAndSettle();

    const scale = AppColors.light;
    final bar = tester.widget<SegmentBar>(find.byType(SegmentBar));
    expect(bar.segments.map((s) => s.color), [
      scale.scale[0].withValues(alpha: 0.25),
      scale.scale[1].withValues(alpha: 0.25),
      scale.scale[2],
      scale.scale[3].withValues(alpha: 0.25),
    ]);
    final level = tester.widget<Text>(find.text('Neutro'));
    expect(level.style!.color, scale.scaleText[2]);
    expect(level.style!.fontWeight, FontWeight.w700);
    expect(tester.widget<Text>(find.text('Gíria')).style!.color, scale.inkSoft);
    expect(
      find.descendant(
        of: find.byType(TermUsage),
        matching: find.byType(SpeechBalloon),
      ),
      findsNothing,
    );
    expect(find.text('Fine anywhere.'), findsNothing);
    expect(find.text('Public notice'), findsNothing);
  });

  testWidgets('nota de formalidade nasce embaçada; toque revela', (
    tester,
  ) async {
    final note = await openFormalityNote(tester);
    expect(tester.widget<Obscured>(note).obscured, isTrue);

    await tester.tap(find.text('Serve em qualquer lugar.'));
    await tester.pumpAndSettle();

    expect(tester.widget<Obscured>(note).obscured, isFalse);
    expect(find.byType(BubbleBurst), findsNothing);

    await tester.tap(find.byTooltip('Embaçar de novo'));
    await tester.pumpAndSettle();

    expect(tester.widget<Obscured>(note).obscured, isTrue);
  });

  testWidgets('idioma aprendido em itálico dentro do texto no idioma base', (
    tester,
  ) async {
    vocabulary.api.pitfallRevealed.add('u1');
    vocabulary.api.cards['u1'] = {
      ...sampleCardJson,
      'base': {
        ...sampleCardJson['base']! as Map,
        'pitfall': 'Não é *mind the hole*, é *mind the gap*.',
      },
    };
    await open(tester);

    TextSpan span(String text, String part) {
      final root = tester.widget<Text>(find.text(text)).textSpan!;
      late TextSpan found;
      root.visitChildren((s) {
        if (s is TextSpan && s.text == part) found = s;
        return true;
      });
      return found;
    }

    const pitfall = 'Não é mind the hole, é mind the gap.';
    expect(find.text(pitfall), findsOneWidget);
    final hole = span(pitfall, 'mind the hole');
    expect(hole.style!.fontStyle, FontStyle.italic);
    expect(hole.style!.fontWeight, FontWeight.w700);
    expect(hole.locale, const Locale('en'));
    expect(span(pitfall, 'Não é ').style, isNull);

    await tester.tap(find.text('Uso'));
    await tester.pumpAndSettle();

    final careful = span('Prefira careful', 'careful');
    expect(careful.style!.fontStyle, FontStyle.italic);
    expect(careful.locale, const Locale('en'));
  });

  testWidgets('monta a frase: peças lado a lado', (tester) async {
    await open(tester);
    await tester.tap(find.text('Palavras'));
    await tester.pumpAndSettle();

    final mind = tester.getRect(find.text('mind the'));
    final step = tester.getRect(find.text('step'));
    expect(step.center.dy, mind.center.dy);
    expect(step.left, greaterThan(mind.right));
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
      'base': {
        ...sampleCardJson['base']! as Map,
        'fits': [
          {'context': 'Aviso público', 'fits': true, 'alternative': null},
        ],
      },
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
      tester.getSize(seenCard('please mind the gap and stand clear.')).width,
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
      tester.getSize(seenCard('please mind the gap.')).width,
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
      deps: fakeDependencies(
        vocabulary: vocabulary.store,
        captures: captures.store,
        playback: playback,
      ),
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

  testWidgets('selo do grupo fica no canto direito do cabeçalho', (
    tester,
  ) async {
    await open(tester, term: _layover);

    expect(find.text('Viagem'), findsOneWidget);
    expect(
      tester.getRect(find.byType(HeaderPill)).right,
      tester.getRect(find.byType(StatusPill)).right,
    );
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

  testWidgets('tocar no desfocado revela e solta os balões', (tester) async {
    await open(tester);

    await tester.tap(find.text('QUER DIZER'));
    await tester.pump();

    expect(_fog(tester), [false, false]);
    expect(find.byType(BubbleBurst), findsOneWidget);
    expect(find.text('Tinha sacado pelo contexto?'), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('sem ao pé da letra, só o quer dizer fica desfocado', (
    tester,
  ) async {
    vocabulary.api.cards['u1'] = {
      ...sampleCardJson,
      'base': {...sampleCardJson['base']! as Map, 'literal': null},
    };

    await open(tester);

    expect(find.text('AO PÉ DA LETRA'), findsNothing);
    expect(find.text('QUER DIZER'), findsOneWidget);
    expect(_fog(tester), [true]);
    expect(find.text('Revelar'), findsOneWidget);
  });

  testWidgets('abrir a ficha e ouvir avisam a revisão, uma vez cada', (
    tester,
  ) async {
    final practice = fakePractice();
    final voice = FakeVoice();
    await tester.pumpPage(
      const TermPage(term: _mind),
      deps: fakeDependencies(
        practice: practice.store,
        voice: voice,
        vocabulary: fakeVocabulary(sampleVocabularyJson).store,
      ),
    );
    await tester.pumpAndSettle();

    expect(practice.api.studied, [('u1', 'read')]);

    await tester.tap(find.byTooltip('Ouvir pronúncia'));
    await tester.pump();
    await voice.stop();
    await tester.pump();
    await tester.tap(find.byTooltip('Ouvir pronúncia'));
    await tester.pumpAndSettle();

    expect(practice.api.studied, [('u1', 'read'), ('u1', 'listened')]);
  });

  testWidgets('ficha mostra quando o termo volta e a memória dele', (
    tester,
  ) async {
    final vocabulary = fakeVocabulary(sampleVocabularyJson);
    vocabulary.api.termFields['u1'] = {
      'interval_days': 12.0,
      'due_at': DateTime.now()
          .add(const Duration(days: 12, hours: 1))
          .toUtc()
          .toIso8601String(),
    };
    await tester.pumpPage(
      const TermPage(term: _mind),
      deps: fakeDependencies(vocabulary: vocabulary.store),
    );
    await tester.pumpAndSettle();

    expect(find.text('Volta em 12 dias · memória de 12 dias'), findsOneWidget);
  });

  testWidgets('tinha sacado: responde como amigo e some ao embaçar', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.text('Revelar'));
    await tester.pumpAndSettle();

    final question = tester.getRect(find.text('Tinha sacado pelo contexto?'));
    final yes = tester.getRect(
      find.ancestor(of: find.text('Saquei'), matching: find.byType(AppButton)),
    );
    expect(yes.left, question.left);
    expect(yes.top, greaterThan(question.bottom));

    await tester.tap(find.text('Saquei'));
    await tester.pumpAndSettle();

    expect(find.text('Boa! O contexto te entregou.'), findsOneWidget);
    expect(find.text('Tinha sacado pelo contexto?'), findsNothing);

    await tester.tap(find.text('Embaçar de novo'));
    await tester.pumpAndSettle();

    expect(find.byType(GotItCheck), findsNothing);

    await tester.tap(find.text('Revelar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Não'));
    await tester.pumpAndSettle();

    expect(find.text('Tranquilo. Agora você sabe.'), findsOneWidget);
  });

  testWidgets('pra lembrar: imagem e pegadinha no idioma base', (tester) async {
    vocabulary.api.pitfallRevealed.add('u1');
    await open(tester);

    expect(find.text('PRA LEMBRAR'), findsOneWidget);
    expect(find.text('AO PÉ DA LETRA'), findsOneWidget);
    expect(find.text('QUER DIZER'), findsOneWidget);
    expect(
      find.text('Imagine: Uma faixa amarela piscando na beira da plataforma.'),
      findsOneWidget,
    );
    expect(find.text('Pegadinha'), findsOneWidget);
    expect(find.text('Não diga'), findsOneWidget);
    expect(find.text('mind the hole'), findsOneWidget);
    expect(find.text('Diga'), findsOneWidget);
    expect(find.text('Não é "mente o buraco".'), findsOneWidget);
  });

  testWidgets('imagine: termo citado ganha fundo, o resto não', (tester) async {
    vocabulary.api.cards['u1'] = {
      ...sampleCardJson,
      'base': {
        ...sampleCardJson['base']! as Map,
        'imagine': 'Alguém grita *mind the gap* na plataforma.',
      },
    };

    await open(tester);

    final filled = _spansOf(
      tester,
      find.textContaining('Alguém grita', findRichText: true),
    ).where((span) => span.style?.backgroundColor != null);
    expect(filled.map((span) => span.text), ['mind the gap']);
  });

  testWidgets('onde você viu: sem aspas e termo marcado sem fundo', (
    tester,
  ) async {
    vocabulary.api.seen['u1'] = [
      {
        'id': 'c1',
        'source': 'text',
        'text': 'Please mind the gap now.',
        'captured_at': DateTime.now().toIso8601String(),
        'terms': [
          {'text': 'mind the gap', 'start': 7, 'end': 19, 'term': 'u1'},
        ],
      },
    ];

    await open(tester);

    final spans = _spansOf(
      tester,
      find.text('please mind the gap now.', findRichText: true),
    );
    expect(spans.map((span) => span.text), [
      'please ',
      'mind the gap',
      ' now.',
    ]);
    expect(spans.elementAt(1).style?.fontWeight, FontWeight.w700);
    expect(spans.elementAt(1).style?.backgroundColor, isNull);
  });

  testWidgets('pegadinha nasce desfocada menos os títulos', (tester) async {
    await open(tester);

    expect(_pitfallFog(tester), [true, true, true]);
    expect(find.bySemanticsLabel(RegExp('Pegadinha')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Não diga')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Diga')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('mind the hole')), findsNothing);
    expect(find.bySemanticsLabel(RegExp('mente o buraco')), findsNothing);
  });

  testWidgets('tocar na pegadinha revela só ela e solta os balões', (
    tester,
  ) async {
    await open(tester);

    await tester.tap(find.text('Diga'));
    await tester.pump();

    expect(_pitfallFog(tester), [false, false, false]);
    expect(_fog(tester), [true, true]);
    expect(
      find.descendant(
        of: find.byType(TermPitfall),
        matching: find.byType(BubbleBurst),
      ),
      findsOneWidget,
    );
    expect(find.byType(GotItCheck), findsNothing);
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel(RegExp('mind the hole')), findsOneWidget);
  });

  testWidgets('pegadinha revelada abre revelada e embaça de novo', (
    tester,
  ) async {
    vocabulary.api.pitfallRevealed.add('u1');
    await open(tester);

    expect(_pitfallFog(tester), [false, false, false]);
    expect(find.byType(BubbleBurst), findsNothing);

    await tester.tap(find.byTooltip('Embaçar de novo'));
    await tester.pumpAndSettle();

    expect(_pitfallFog(tester), [true, true, true]);

    await tester.tap(find.byTooltip('Revelar'));
    await tester.pumpAndSettle();

    expect(_pitfallFog(tester), [false, false, false]);
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

  testWidgets('conversa: ouvir acende a fala da vez e o toque traduz', (
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

    await tester.ensureVisible(find.textContaining(first, findRichText: true));
    await tester.tap(find.textContaining(first, findRichText: true));
    await tester.pumpAndSettle();

    expect(find.text('Corre, o trem chegou!'), findsOneWidget);
    expect(find.text('Toque num balão pra ver a tradução.'), findsOneWidget);
  });

  testWidgets('sem conversa, os exemplos voltam e viram com o card', (
    tester,
  ) async {
    vocabulary.api.cards['u1'] = {...sampleCardJson, 'dialogue': <Object?>[]};

    await open(tester);

    expect(find.text('Numa conversa'), findsNothing);
    expect(find.text('Exemplos'), findsOneWidget);
    expect(find.text('Cuidado com o vão ao sair do trem.'), findsNothing);

    await tester.tap(find.bySemanticsLabel('Ver em português'));
    await tester.pumpAndSettle();

    expect(find.text('Cuidado com o vão ao sair do trem.'), findsOneWidget);
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

  testWidgets('Praticar abre o jogo com as frases do termo', (tester) async {
    final api = FakePracticeApi()
      ..exercises['u1'] = [
        listenWriteJson(
          'm0',
          sentence: 'Please mind the gap on the way out.',
          answer: 'mind the gap',
        ),
      ];
    await tester.pumpPage(
      const TermPage(term: _mind),
      deps: fakeDependencies(
        vocabulary: vocabulary.store,
        practice: fakePractice(api).store,
      ),
    );
    await tester.pumpAndSettle();

    final card = find.text('Ouvir e escrever');
    expect(
      find.text('Ouça uma frase nova e complete o que falta'),
      findsOneWidget,
    );

    await tester.ensureVisible(card);
    await tester.tap(card);
    await tester.pumpAndSettle();

    expect(find.byType(PracticePage), findsOneWidget);
    expect(find.text('1/1'), findsOneWidget);
    expect(api.calls.last, 'GET /api/v1/terms/u1/exercises/listen_write');
    expect(api.studied, [('u1', 'read')]);
  });
}
