import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/features/capture/widgets/capture_saved_toast.dart';

import '../../../helpers/fake_capture_store.dart';
import '../../../helpers/l10n.dart';

void main() {
  test('aviso muda conforme o envio', () {
    expect(
      savedMessage(pt, sampleCapture('t')),
      'Pronto pra escolher os termos.',
    );
    expect(
      savedMessage(pt, sampleCapture('f', source: CaptureSource.photo)),
      'Já está processando.',
    );
    expect(
      savedMessage(pt, sampleCapture('a', source: CaptureSource.audio)),
      'Já está processando.',
    );
    expect(
      savedMessage(pt, sampleCapture('f', pending: const {CaptureSync.create})),
      'Puxe a lista no Inbox quando tiver internet.',
    );
    expect(
      savedMessage(
        pt,
        sampleCapture(
          'a',
          source: CaptureSource.audio,
          status: CaptureStatus.processing,
          pending: const {CaptureSync.extract, CaptureSync.create},
        ),
      ),
      'Já está processando.',
    );
  });
}
