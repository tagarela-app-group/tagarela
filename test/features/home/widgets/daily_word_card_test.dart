import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/data/services/api_client.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/home/widgets/daily_word_card.dart';

import '../../../helpers/fake_daily_word_api.dart';
import '../../../helpers/fake_voice.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late FakeVoice voice;
  late List<String> calls;

  setUp(() {
    voice = FakeVoice();
    calls = [];
  });

  Widget card({
    Json json = hangryJson,
    Future<void> Function()? onSave,
    bool still = false,
    bool visible = true,
  }) => MediaQuery(
    data: MediaQueryData(disableAnimations: still),
    child: TickerMode(
      enabled: visible,
      child: DailyWordCard(
        word: DailyWord.fromJson(json),
        language: CourseLanguage.en,
        voice: voice,
        onSave: onSave ?? () async => calls.add('guardou'),
        onOpen: (term) => calls.add('abriu ${term.id}'),
      ),
    ),
  );

  bool obscured(WidgetTester tester) =>
      tester.widget<Obscured>(find.byType(Obscured)).obscured;

  testWidgets('mostra rótulo, exemplo e o significado embaçado', (
    tester,
  ) async {
    await tester.pumpComponent(card());

    expect(find.text('PALAVRA DO DIA'), findsOneWidget);
    expect(find.textContaining('Feed me'), findsOneWidget);
    expect(obscured(tester), isTrue);
  });

  testWidgets('expressão muda o rótulo', (tester) async {
    await tester.pumpComponent(
      card(json: {...hangryJson, 'text': 'on the fence', 'kind': 'expression'}),
    );

    expect(find.text('EXPRESSÃO DO DIA'), findsOneWidget);
  });

  testWidgets('tocar no vidro revela e o leitor de tela lê o significado', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpComponent(card());
    expect(find.bySemanticsLabel('Revelar o que quer dizer'), findsOneWidget);

    await tester.tap(find.byType(Obscured));
    await tester.pump();

    expect(obscured(tester), isFalse);
    expect(find.bySemanticsLabel('com fome e de mau humor'), findsOneWidget);
    expect(find.text('sacou?'), findsOneWidget);
    await tester.pump(AppMotion.wordSay);
    handle.dispose();
  });

  testWidgets('ouvir fala a palavra no idioma do curso e o toque para', (
    tester,
  ) async {
    await tester.pumpComponent(card());

    await tester.tap(find.byTooltip('Ouvir pronúncia'));
    await tester.pump();
    expect(voice.spoken.single.$1, 'hangry');
    expect(voice.spoken.single.$2, CourseLanguage.en);

    await tester.tap(find.byTooltip('Parar'));
    await tester.pump();
    expect(voice.stops, 1);
  });

  testWidgets('guardar chama o store; já guardada abre a ficha', (
    tester,
  ) async {
    await tester.pumpComponent(card());
    await tester.tap(find.byTooltip('Guardar no vocabulário'));
    await tester.pump();
    expect(calls, ['guardou']);
    await tester.pump(AppMotion.wordSay);

    calls.clear();
    await tester.pumpComponent(
      card(json: {...hangryJson, 'term': hangryTermJson}),
    );
    await tester.tap(find.byTooltip('Abrir a ficha'));
    expect(calls, ['abriu t-hangry']);
  });

  testWidgets('falha ao guardar avisa e deixa tentar de novo', (tester) async {
    var tries = 0;
    await tester.pumpComponent(
      card(
        onSave: () async {
          tries++;
          throw ApiException(503, 'POST');
        },
      ),
    );

    await tester.tap(find.byTooltip('Guardar no vocabulário'));
    await tester.pumpUntilFound(find.textContaining('Sem conexão'));
    expect(find.textContaining('Sem conexão'), findsOneWidget);

    await tester.tap(find.byTooltip('Guardar no vocabulário'));
    await tester.pump();
    expect(tries, 2);
  });

  testWidgets('anima ao abrir, para e só volta depois do intervalo', (
    tester,
  ) async {
    await tester.pumpComponent(card());
    expect(tester.binding.hasScheduledFrame, isFalse);

    await tester.pump(AppMotion.wordFirst);
    await tester.pump();
    expect(find.text('psiu!'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(tester.binding.hasScheduledFrame, isFalse);

    await tester.pump(AppMotion.wordEvery);
    await tester.pump();
    expect(find.text('opa, embaralhou!'), findsOneWidget);
    await tester.pumpAndSettle();

    await tester.pump(AppMotion.wordEvery);
    await tester.pump();
    expect(find.text('repete comigo!'), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('com animação desligada nunca anima', (tester) async {
    await tester.pumpComponent(card(still: true));

    await tester.pump(AppMotion.wordFirst + AppMotion.wordEvery);
    await tester.pump();

    expect(find.text('psiu!'), findsNothing);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('fora da tela não anima', (tester) async {
    await tester.pumpComponent(card(visible: false));

    await tester.pump(AppMotion.wordFirst);
    await tester.pump();

    expect(find.text('psiu!'), findsNothing);
  });

  testWidgets('enquanto fala não entra número por cima', (tester) async {
    await tester.pumpComponent(card());
    await tester.tap(find.byTooltip('Ouvir pronúncia'));

    await tester.pump(AppMotion.wordFirst);
    await tester.pump();

    expect(find.text('psiu!'), findsNothing);
  });
}
