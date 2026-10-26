import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/device/voice.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/term/term_page.dart';

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
    expect(find.text('Montando a ficha…'), findsOneWidget);
    expect(find.text('Sem grupo'), findsOneWidget);

    vocabulary.api.holdCard!.complete();
    await tester.pumpAndSettle();

    expect(vocabulary.api.calls, contains('GET /api/v1/terms/u1'));
    expect(find.text('Montando a ficha…'), findsNothing);
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
    expect(find.text('Cobrir de novo'), findsNothing);
    expect(find.bySemanticsLabel('Ver em português'), findsNothing);
  });

  testWidgets('revelar salva, mostra o inglês e deixa virar pro português', (
    tester,
  ) async {
    await open(tester);

    await tester.tap(find.text('Revelar agora'));
    await tester.pumpAndSettle();

    expect(vocabulary.api.bodies['PATCH /api/v1/terms/u1'], {'revealed': true});
    expect(_glass(tester).frosted, isFalse);
    expect(find.text('EM INGLÊS'), findsOneWidget);
    expect(find.text('be careful of the space'), findsOneWidget);
    expect(find.text('Cuidado com o vão ao sair do trem.'), findsNothing);

    await tester.tap(find.bySemanticsLabel('Ver em português'));
    await tester.pumpAndSettle();

    final flip = tester.widget<FlipCard>(find.byType(FlipCard));
    expect(flip.flipped, isTrue);
    expect(find.text('cuidado com o vão'), findsOneWidget);
    expect(find.text('Cuidado com o vão ao sair do trem.'), findsOneWidget);
    expect(find.bySemanticsLabel('Ver em inglês'), findsOneWidget);
  });

  testWidgets('cobrir de novo volta o vidro e o lado em inglês', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.text('Revelar agora'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Ver em português'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cobrir de novo'));
    await tester.pumpAndSettle();

    expect(vocabulary.api.bodies['PATCH /api/v1/terms/u1'], {
      'revealed': false,
    });
    expect(_glass(tester).frosted, isTrue);
    expect(tester.widget<FlipCard>(find.byType(FlipCard)).flipped, isFalse);
  });

  testWidgets('o que já foi revelado abre revelado', (tester) async {
    vocabulary.api.revealed.add('u1');

    await open(tester);

    expect(_glass(tester).frosted, isFalse);
    expect(find.text('Cobrir de novo'), findsOneWidget);
  });

  testWidgets('salvar sem rede não impede de revelar', (tester) async {
    await open(tester);
    vocabulary.api.offline = true;

    await tester.tap(find.text('Revelar agora'));
    await tester.pumpAndSettle();

    expect(_glass(tester).frosted, isFalse);
  });

  testWidgets('abas: contexto, palavras e uso', (tester) async {
    await open(tester);

    expect(find.text('Exemplos'), findsOneWidget);

    await tester.tap(find.text('Palavras'));
    await tester.pumpAndSettle();
    expect(find.text('Combina com'), findsOneWidget);
    expect(find.text('mind the step'), findsOneWidget);
    expect(find.text('Sinônimos'), findsOneWidget);
    expect(find.text('Antônimos'), findsNothing);

    await tester.tap(find.text('Uso'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<SegmentBar>(find.byType(SegmentBar)).semanticLabel,
      'Formalidade: Neutro, 3 de 4',
    );
    expect(find.text('Serve em qualquer lugar.'), findsOneWidget);
    expect(find.text('Onde cabe'), findsOneWidget);
    expect(find.text('Prefira careful'), findsOneWidget);
  });

  testWidgets('bloco sem dado some, e aba única fica sem seletor', (
    tester,
  ) async {
    vocabulary.api.cards['u1'] = {
      ...sampleCardJson,
      'examples': <Object?>[],
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
    expect(find.text('Também marcado'), findsOneWidget);
    final chips = tester.widgetList<AppChip>(find.byType(AppChip));
    expect(chips.map((c) => c.label), ['stand clear']);

    await tester.tap(find.text('stand clear'));
    await tester.pumpAndSettle();

    expect(find.byType(TermPage, skipOffstage: false), findsNWidgets(2));
    expect(vocabulary.api.calls, contains('GET /api/v1/terms/u2'));
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
}
