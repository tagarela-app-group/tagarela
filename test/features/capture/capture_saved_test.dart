import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models.dart';
import 'package:tagarela/features/capture/capture_saved.dart';

import '../../helpers/fake_capture_store.dart';

void main() {
  test('aviso muda conforme o envio', () {
    expect(savedMessage(sampleCapture('t')), 'Pronto pra escolher os termos.');
    expect(
      savedMessage(sampleCapture('f', source: CaptureSource.photo)),
      'Já está processando.',
    );
    expect(
      savedMessage(sampleCapture('a', source: CaptureSource.audio)),
      'Já está processando.',
    );
    expect(
      savedMessage(
        sampleCapture(
          'f',
          source: CaptureSource.photo,
          pending: const {CaptureSync.create, CaptureSync.file},
        ),
      ),
      'Puxe a lista no Inbox quando tiver internet.',
    );
  });
}
