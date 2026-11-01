import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/device/capture_device.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/capture/modals/photo_capture_modal.dart';

import '../../../helpers/fake_capture_store.dart';
import '../../../helpers/open_modal.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late FakeCaptures captures;
  late FakeCaptureDevice device;

  setUp(() {
    captures = fakeCaptures();
    device = FakeCaptureDevice();
  });

  Future<List<Capture?>> open(WidgetTester tester) => tester.openModal(
    const PhotoCaptureModal(),
    deps: fakeDependencies(captures: captures.store, device: device),
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
    expect(
      find.text('Arraste os cantos pra deixar só o texto.'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Foto escolhida'), findsOneWidget);

    await tester.tap(find.text('Trocar foto'));
    await tester.pump();

    expect(device.discarded, ['cache/foto.jpg']);
    expect(find.byType(OptionRow), findsNWidgets(2));
  });

  testWidgets('prévia cabe em tela estreita', (tester) async {
    await open(tester);
    tester.view.physicalSize = const Size(360, 800);
    await tester.pump();

    await tester.tap(find.text('Escolher da galeria'));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  Future<void> takePhoto(WidgetTester tester) async {
    await tester.tap(find.text('Tirar foto'));
    await tester.pump();
    await tester.pump(AppMotion.slow);
  }

  Future<void> cropOnce(WidgetTester tester) async {
    final frame = tester.getRect(find.byType(CropFrame));
    final gesture = await tester.startGesture(
      frame.bottomCenter - const Offset(0, CropFrame.gutter),
    );
    await gesture.moveBy(const Offset(0, -100));
    await tester.pump();
    await gesture.up();
    await tester.pump();
    await tester.pump(AppMotion.slow);
  }

  Future<Capture> saveCropped(WidgetTester tester) async {
    final results = await open(tester);
    await takePhoto(tester);
    await cropOnce(tester);
    await tester.tap(find.text('Salvar no Inbox'));
    await tester.pumpAndSettle();
    return results.single!;
  }

  testWidgets('sem cortar: salva a foto original, sem gerar outra', (
    tester,
  ) async {
    await open(tester);
    await takePhoto(tester);

    await tester.tap(find.text('Salvar no Inbox'));
    await tester.pumpAndSettle();

    expect(device.crops, isEmpty);
  });

  testWidgets('cortou: salva o recorte e apaga os dois temporários', (
    tester,
  ) async {
    final saved = await saveCropped(tester);

    expect(device.crops.single.bottom, lessThan(1));
    expect(captures.media.files.keys, ['captures/photo/${saved.id}.png']);
    expect(
      device.discarded,
      unorderedEquals(['cache/recorte.png', 'cache/foto.jpg']),
    );
  });

  testWidgets('Usar a foto inteira desfaz o corte', (tester) async {
    await open(tester);
    await takePhoto(tester);
    await cropOnce(tester);

    await tester.tap(find.text('Usar a foto inteira'));
    await tester.pump();
    await tester.tap(find.text('Salvar no Inbox'));
    await tester.pumpAndSettle();

    expect(device.crops, isEmpty);
  });

  testWidgets('recorte falhou: salva a foto inteira, sem perder a captura', (
    tester,
  ) async {
    device.cropFails = true;
    final saved = await saveCropped(tester);

    expect(captures.media.files.keys, ['captures/photo/${saved.id}.jpg']);
  });

  testWidgets('foto que não abre: prévia simples, sem moldura', (tester) async {
    device.nextPhotoSize = null;
    await open(tester);

    await takePhoto(tester);

    expect(find.byType(CropFrame), findsNothing);
    expect(find.text('Confira antes de salvar'), findsOneWidget);
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
    expect(find.byType(AppModal), findsNothing);
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

    await tester.expectOpensSettings(device);
  });
}
