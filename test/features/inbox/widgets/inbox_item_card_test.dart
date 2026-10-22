import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/inbox/widgets/inbox_item_card.dart';

import '../../../helpers/pump_app.dart';

InboxItem _item({
  CaptureSource source = CaptureSource.text,
  String content = 'Mind the gap',
  InboxStatus status = InboxStatus.ready,
  Suggestion? suggestion,
}) => InboxItem(
  id: '1',
  source: source,
  content: content,
  capturedAt: 'há 1 h',
  status: status,
  suggestion: suggestion,
);

void main() {
  testWidgets('pronto: mostra sugestão e ações', (tester) async {
    var added = 0;
    var discarded = 0;
    await tester.pumpComponent(
      InboxItemCard(
        item: _item(
          suggestion: const Suggestion(
            'cuidado com o vão',
            TermKind.expression,
            '1',
            'Viagem',
          ),
        ),
        onAdd: () => added++,
        onDiscard: () => discarded++,
      ),
    );

    expect(find.text('Texto · há 1 h'), findsOneWidget);
    expect(find.text('Pronto'), findsOneWidget);
    expect(find.text('Mind the gap'), findsOneWidget);
    expect(find.text('cuidado com o vão'), findsOneWidget);
    expect(find.text('EXPRESSÃO'), findsOneWidget);
    expect(find.text('→ VIAGEM'), findsOneWidget);

    await tester.tap(find.text('Adicionar'));
    await tester.tap(find.text('Descartar'));
    expect((added, discarded), (1, 1));
  });

  testWidgets('em análise: sem ações, com aviso', (tester) async {
    await tester.pumpComponent(
      InboxItemCard(item: _item(status: InboxStatus.analyzing)),
    );

    expect(find.text('Analisando'), findsOneWidget);
    expect(
      find.text('Transcrevendo e buscando o significado…'),
      findsOneWidget,
    );
    expect(find.byType(AppButton), findsNothing);
  });

  testWidgets('na fila: avisa falta de conexão', (tester) async {
    await tester.pumpComponent(
      InboxItemCard(item: _item(status: InboxStatus.queued)),
    );

    expect(find.text('Na fila'), findsOneWidget);
    expect(
      find.text('Sem conexão. Analisamos assim que a rede voltar.'),
      findsOneWidget,
    );
    expect(find.byIcon(AppIcons.offline), findsOneWidget);
  });

  testWidgets('áudio: mostra player com duração', (tester) async {
    await tester.pumpComponent(
      InboxItemCard(
        item: _item(
          source: CaptureSource.audio,
          content: '0:04',
          status: InboxStatus.analyzing,
        ),
      ),
    );

    expect(find.text('Áudio · há 1 h'), findsOneWidget);
    expect(find.byTooltip('Ouvir gravação'), findsOneWidget);
    expect(find.text('0:04'), findsOneWidget);
  });

  testWidgets('câmera: mostra texto capturado', (tester) async {
    await tester.pumpComponent(
      InboxItemCard(
        item: _item(source: CaptureSource.camera, content: 'Exit'),
      ),
    );

    expect(find.text('Câmera · há 1 h'), findsOneWidget);
    expect(find.text('Exit'), findsOneWidget);
    expect(find.byTooltip('Ouvir gravação'), findsNothing);
  });
}
