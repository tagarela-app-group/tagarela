import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/services/capture_service.dart';

import '../../helpers/fake_capture_api.dart';

void main() {
  late FakeCaptureApi api;
  late CaptureService service;
  late Directory folder;

  setUp(() async {
    api = FakeCaptureApi();
    service = CaptureService(api);
    folder = await Directory.systemTemp.createTemp('capture_service_test');
    await api.post(FakeCaptureApi.path, {
      'id': 'c1',
      'source': 'photo',
      'captured_at': '2026-10-23T10:00:00Z',
    });
  });

  tearDown(() => folder.delete(recursive: true));

  test('content type do arquivo vem da extensão', () async {
    for (final (name, type) in [
      ('a.JPG', 'image/jpeg'),
      ('b.jpeg', 'image/jpeg'),
      ('c.png', 'image/png'),
      ('d.webp', 'image/webp'),
      ('e.m4a', 'audio/mp4'),
    ]) {
      await service.sendFile(
        'c1',
        File('${folder.path}/$name')..writeAsBytesSync([1]),
      );

      expect(api.files['c1']?.contentType, type, reason: name);
    }
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
