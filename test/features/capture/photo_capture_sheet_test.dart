import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/capture_device.dart';
import 'package:tagarela/data/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/capture/photo_capture_sheet.dart';

import '../../helpers/fake_capture_store.dart';
import '../../helpers/open_sheet.dart';

void main() {
  late FakeCaptures captures;
  late FakeCaptureDevice device;

  setUp(() {
    captures = fakeCaptures();
    device = FakeCaptureDevice();
  });

  Future<List<Capture?>> open(WidgetTester tester) => tester.openSheet(
    const PhotoCaptureSheet(),
    captures: captures.store,
    device: device,
  );

  testWidgets('mostra câmera, galeria e aviso de privacidade', (tester) async {
    await open(tester);

    expect(find.text('Uma placa, um cardápio, uma legenda'), findsOneWidget);
    expect(find.byType(OptionRow), findsNWidgets(2));
    expect(
      find.text(
        'A foto fica só no seu celular. A gente guarda apenas o texto lido dela.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('galeria leva pra prévia; Trocar foto volta e apaga', (
    tester,
  ) async {
    await open(tester);

    await tester.tap(find.text('Escolher da galeria'));
    await tester.pump();

    expect(device.origins, [PhotoOrigin.gallery]);
    expect(find.text('Confira antes de salvar'), findsOneWidget);
    expect(find.bySemanticsLabel('Foto escolhida'), findsOneWidget);

    await tester.tap(find.text('Trocar foto'));
    await tester.pump();

    expect(device.discarded, ['cache/foto.jpg']);
    expect(find.byType(OptionRow), findsNWidgets(2));
  });

  testWidgets('desistir na câmera continua nas opções', (tester) async {
    device.nextPhoto = null;
    await open(tester);

    await tester.tap(find.text('Tirar foto'));
    await tester.pump();

    expect(device.origins, [PhotoOrigin.camera]);
    expect(find.byType(OptionRow), findsNWidgets(2));
  });

  testWidgets('Salvar no Inbox guarda a foto e fecha', (tester) async {
    final results = await open(tester);

    await tester.tap(find.text('Tirar foto'));
    await tester.pump();
    await tester.tap(find.text('Salvar no Inbox'));
    await tester.pumpAndSettle();

    final saved = results.single!;
    expect(saved.source, CaptureSource.photo);
    expect(captures.media.files.keys, ['captures/photo/${saved.id}.jpg']);
    expect(device.discarded, ['cache/foto.jpg']);
    expect(find.byType(AppSheet), findsNothing);
  });

  testWidgets('fechar com foto escolhida apaga a foto', (tester) async {
    final results = await open(tester);

    await tester.tap(find.text('Escolher da galeria'));
    await tester.pump();
    await tester.tap(find.byTooltip('Fechar'));
    await tester.pumpAndSettle();

    expect(results, [null]);
    expect(device.discarded, ['cache/foto.jpg']);
    expect(captures.store.data, isEmpty);
  });

  testWidgets('câmera negada: aviso leva pras configurações', (tester) async {
    device.camera = false;
    await open(tester);

    await tester.tap(find.text('Tirar foto'));
    await tester.pump();

    expect(device.origins, isEmpty);
    expect(find.text('Sem acesso à câmera'), findsOneWidget);

    await tester.tap(find.text('Abrir configurações'));
    await tester.pumpAndSettle();

    expect(device.settingsOpened, 1);
    expect(find.byType(AppSheet), findsNothing);
  });
}
