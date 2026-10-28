import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/home/widgets/word_of_day_card.dart';

import '../../../helpers/pump_app.dart';

const _word = WordOfDay(
  text: 'cozy',
  phonetic: '/ˈkoʊ.zi/',
  partOfSpeech: 'adjetivo',
  translation: 'aconchegante',
  example: 'A cozy room.',
  dateLabel: 'Seg, 1 jan',
);

void main() {
  testWidgets('mostra todos os campos da palavra', (tester) async {
    await tester.pumpComponent(const WordOfDayCard(word: _word));

    expect(find.text('PALAVRA DO DIA'), findsOneWidget);
    expect(find.text('Seg, 1 jan'), findsOneWidget);
    expect(find.text('cozy'), findsOneWidget);
    expect(find.text('/ˈkoʊ.zi/ · adjetivo'), findsOneWidget);
    expect(find.text('aconchegante'), findsOneWidget);
    expect(find.text('“A cozy room.”'), findsOneWidget);
  });

  testWidgets('balão de fundo passa da borda do card, como no mockup', (
    tester,
  ) async {
    await tester.pumpComponent(const WordOfDayCard(word: _word));

    final card = tester.getRect(find.byType(AppCard));
    final bubble = tester.getRect(drawnIcon(DrawnGlyph.bubble));
    expect(bubble.right - card.right, 34);
    expect(card.top - bubble.top, 38);
  });

  testWidgets('tem ações de ouvir e adicionar', (tester) async {
    await tester.pumpComponent(const WordOfDayCard(word: _word));

    expect(find.byTooltip('Ouvir pronúncia'), findsOneWidget);
    expect(find.text('Adicionar ao vocabulário'), findsOneWidget);
  });
}
