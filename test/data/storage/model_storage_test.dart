import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:on_device_extraction/on_device_extraction.dart';

import 'package:tagarela/data/device/speech_model.dart';
import 'package:tagarela/data/storage/model_storage.dart';

void main() {
  late HttpServer server;
  late Directory root;
  late Map<String, List<int>> served;
  late List<String> requested;
  late ModelStorage storage;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('model_storage_test');
    served = {};
    requested = [];
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      final name = request.uri.pathSegments.last;
      requested.add(name);
      final body = served[name];
      if (body == null) {
        request.response.statusCode = HttpStatus.notFound;
      } else {
        request.response.add(body);
      }
      await request.response.close();
    });
    storage = ModelStorage(root: () async => root);
  });

  tearDown(() async {
    await server.close(force: true);
    await root.delete(recursive: true);
  });

  ModelFile serve(String name, String content, {String? hashOf}) {
    final bytes = utf8.encode(content);
    served[name] = bytes;
    final hash = sha256.convert(utf8.encode(hashOf ?? content)).toString();
    return ModelFile(name, bytes.length, hash);
  }

  SpeechModel model(List<ModelFile> files, {String id = 'tiny'}) => SpeechModel(
    id: id,
    arch: MoonshineArch.tinyStreaming,
    baseUrl: 'http://127.0.0.1:${server.port}/model',
    files: files,
  );

  File saved(String id, String name) => File('${root.path}/models/$id/$name');

  test('baixa, confere o hash e marca pronto', () async {
    final tiny = model([
      serve('encoder.ort', 'aaaa'),
      serve('tokenizer.bin', 'bb'),
    ]);

    final progress = await storage.download(tiny).toList();

    expect(progress.last, 1);
    expect(progress, orderedEquals([...progress]..sort()));
    expect(await storage.installed(tiny), '${root.path}/models/tiny');
    expect(saved('tiny', 'encoder.ort').readAsStringSync(), 'aaaa');
    expect(saved('tiny', 'tokenizer.bin').readAsStringSync(), 'bb');
    expect(saved('tiny', 'encoder.ort.part').existsSync(), isFalse);
  });

  test('sem baixar: não instalado', () async {
    expect(await storage.installed(model([serve('a', 'x')])), isNull);
  });

  test('arquivo corrompido: lança e não marca pronto', () async {
    final tiny = model([serve('encoder.ort', 'aaaa', hashOf: 'outro')]);

    await expectLater(
      storage.download(tiny).toList(),
      throwsA(isA<FileSystemException>()),
    );
    expect(await storage.installed(tiny), isNull);
    expect(saved('tiny', 'encoder.ort').existsSync(), isFalse);
    expect(saved('tiny', 'encoder.ort.part').existsSync(), isFalse);
  });

  test('servidor sem o arquivo: lança HttpException', () async {
    final tiny = model([const ModelFile('sumiu.ort', 1, 'x')]);

    await expectLater(
      storage.download(tiny).toList(),
      throwsA(isA<HttpException>()),
    );
    expect(await storage.installed(tiny), isNull);
  });

  test('retoma: arquivo já baixado não baixa de novo', () async {
    final tiny = model([serve('a.ort', 'aaaa'), serve('b.ort', 'bb')]);
    saved('tiny', 'a.ort')
      ..parent.createSync(recursive: true)
      ..writeAsStringSync('aaaa');

    await storage.download(tiny).toList();

    expect(requested, ['b.ort']);
    expect(await storage.installed(tiny), isNotNull);
  });

  test('modelo novo apaga o antigo', () async {
    final old = model([serve('a.ort', 'aaaa')], id: 'old');
    final next = model([serve('b.ort', 'bb')], id: 'next');
    await storage.download(old).toList();

    await storage.download(next).toList();

    expect(await storage.installed(old), isNull);
    expect(Directory('${root.path}/models/old').existsSync(), isFalse);
    expect(await storage.installed(next), isNotNull);
  });
}
