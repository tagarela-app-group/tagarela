import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models.dart';
import 'package:tagarela/data/services/capture_service.dart';

import '../../helpers/fake_capture_api.dart';

void main() {
  late FakeCaptureApi api;
  late CaptureService service;

  setUp(() async {
    api = FakeCaptureApi();
    service = CaptureService(api);
    await api.post(FakeCaptureApi.path, {
      'id': 'c1',
      'source': 'photo',
      'captured_at': '2026-10-23T10:00:00Z',
      'text': 'MIND THE GAP',
    });
  });

  test('foto com texto lido no aparelho manda o texto', () async {
    final capture = Capture(
      id: 'c2',
      source: CaptureSource.photo,
      status: CaptureStatus.ready,
      text: 'MIND THE GAP',
      capturedAt: DateTime.utc(2026, 10, 23, 10),
    );

    final created = await service.create(capture);

    expect(api.bodies['POST ${FakeCaptureApi.path}'], {
      'id': 'c2',
      'source': 'photo',
      'captured_at': '2026-10-23T10:00:00.000Z',
      'text': 'MIND THE GAP',
    });
    expect(created.status, CaptureStatus.ready);
  });

  test('confirm e discard chamam as rotas da captura', () async {
    await service.confirm('c1');
    await service.discard('c1');

    expect(api.calls.skip(1), [
      'POST ${FakeCaptureApi.path}/c1/confirm',
      'DELETE ${FakeCaptureApi.path}/c1',
    ]);
  });
}
