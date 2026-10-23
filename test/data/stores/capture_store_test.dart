import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/database.dart';
import 'package:tagarela/data/media_storage.dart';
import 'package:tagarela/data/models.dart';
import 'package:tagarela/data/services/capture_service.dart';
import 'package:tagarela/data/stores/capture_store.dart';

import '../../helpers/fake_capture_api.dart';

void main() {
  late FakeCaptureApi api;
  late AppDatabase db;
  late Directory root;
  late String? owner;
  late CaptureStore store;

  const text = 'Please mind the gap between the train and the platform.';
  const mindTheGap = CaptureTerm(text: 'mind the gap', start: 7, end: 19);

  setUp(() async {
    api = FakeCaptureApi();
    db = AppDatabase(NativeDatabase.memory());
    root = await Directory.systemTemp.createTemp('captures_test');
    owner = 'ana@example.com';
    store = CaptureStore(
      CaptureService(api),
      db,
      MediaStorage(() async => root),
      owner: () => owner,
    );
  });

  tearDown(() async {
    await db.close();
    await root.delete(recursive: true);
  });

  Future<File> picture([String name = 'foto.jpg']) async =>
      File('${root.path}/$name')..writeAsBytesSync([1, 2, 3]);

  Capture only() => store.data!.single;

  group('criar', () {
    test('texto online: id UUID, enviado e sem pendência', () async {
      final capture = await store.createText(text);

      expect(
        capture.id,
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          ),
        ),
      );
      expect(api.calls, ['POST ${FakeCaptureApi.path}']);
      expect(api.bodies['POST ${FakeCaptureApi.path}'], {
        'id': capture.id,
        'source': 'text',
        'captured_at': capture.capturedAt.toUtc().toIso8601String(),
        'text': text,
      });
      expect(only().status, CaptureStatus.ready);
      expect(only().pending, isEmpty);
      expect(only().updatedAt, isNotNull);
      expect(capture.pending, isEmpty);
    });

    test('texto offline: fica salvo pendente e sobe no sync', () async {
      api.offline = true;
      final capture = await store.createText(text);

      expect(capture.pending, {CaptureSync.create});
      expect(only().pending, {CaptureSync.create});
      expect(api.server, isEmpty);

      api.offline = false;
      await store.sync();

      expect(only().pending, isEmpty);
      expect(api.server.keys, [only().id]);
    });

    test('foto: copia pra pasta do app, cria e manda o arquivo', () async {
      final capture = await store.createMedia(
        CaptureSource.photo,
        await picture(),
      );

      expect(capture.mediaPath, 'captures/photo/${capture.id}.jpg');
      expect(File('${root.path}/${capture.mediaPath}').readAsBytesSync(), [
        1,
        2,
        3,
      ]);
      expect(api.calls, [
        'POST ${FakeCaptureApi.path}',
        'PUT ${FakeCaptureApi.path}/${capture.id}/file',
      ]);
      expect(api.files[capture.id]?.contentType, 'image/jpeg');
      expect((await store.mediaFile(capture))?.readAsBytesSync(), [1, 2, 3]);
      expect(
        await store.mediaFile(only().copyWith(mediaPath: () => null)),
        isNull,
      );
      expect(only().status, CaptureStatus.processing);
      expect(only().pending, isEmpty);
      expect(capture.status, CaptureStatus.processing);
    });

    test('áudio offline: guarda as duas etapas pendentes', () async {
      api.offline = true;
      final capture = await store.createMedia(
        CaptureSource.audio,
        await picture('gravacao.m4a'),
      );

      expect(capture.mediaPath, 'captures/audio/${capture.id}.m4a');
      expect(only().status, CaptureStatus.waitingFile);
      expect(only().pending, {CaptureSync.create, CaptureSync.file});

      api.offline = false;
      await store.sync();

      expect(api.files[capture.id]?.contentType, 'audio/mp4');
      expect(only().pending, isEmpty);
    });
  });

  group('sync', () {
    test('puxa o texto extraído e guarda o cursor', () async {
      final capture = await store.createMedia(
        CaptureSource.photo,
        await picture(),
      );
      api.process(capture.id, 'MIND THE GAP');

      await store.sync();

      expect(only().status, CaptureStatus.ready);
      expect(only().text, 'MIND THE GAP');
      expect(only().mediaPath, isNotNull);
      final cursor = await db.cursor('ana@example.com');
      final updatedAt = api.server[capture.id]!['updated_at']! as String;
      expect(cursor!.isAtSameMomentAs(DateTime.parse(updatedAt)), isTrue);

      await store.sync();

      expect(
        api.calls.last,
        'GET ${FakeCaptureApi.path}?updated_since=${Uri.encodeQueryComponent(cursor.toUtc().toIso8601String())}',
      );
    });

    test('lista paginada: traz capturas de outro aparelho', () async {
      for (final id in ['a', 'b', 'c']) {
        await api.post(FakeCaptureApi.path, {
          'id': id,
          'source': 'text',
          'captured_at': '2026-10-23T10:00:00Z',
          'text': text,
        });
      }

      await store.sync();

      expect(store.data!.map((c) => c.id), unorderedEquals(['a', 'b', 'c']));
      expect(api.calls.where((c) => c.startsWith('GET')), [
        'GET ${FakeCaptureApi.path}',
        'GET ${FakeCaptureApi.path}?cursor=2',
      ]);
    });

    test('termos e confirmação offline sobem em ordem', () async {
      final capture = await store.createText(text);
      api.offline = true;

      await store.saveTerms(only(), text, const [mindTheGap]);
      await store.confirm(only());

      expect(only().status, CaptureStatus.analyzed);
      expect(only().pending, {CaptureSync.update, CaptureSync.confirm});

      api
        ..offline = false
        ..calls.clear();
      await store.sync();

      expect(api.calls.take(2), [
        'PATCH ${FakeCaptureApi.path}/${capture.id}',
        'POST ${FakeCaptureApi.path}/${capture.id}/confirm',
      ]);
      expect(api.bodies['PATCH ${FakeCaptureApi.path}/${capture.id}'], {
        'text': text,
        'terms': [mindTheGap.toJson()],
      });
      expect(only().status, CaptureStatus.analyzed);
      expect(only().terms, [mindTheGap]);
      expect(only().pending, isEmpty);
    });

    test('sem rede: sync lança e mantém a pendência', () async {
      api.offline = true;
      await store.createText(text);

      await expectLater(store.sync(), throwsA(isA<SocketException>()));
      expect(only().pending, {CaptureSync.create});
    });

    test('API recusa (409): larga a etapa e segue', () async {
      final capture = await store.createMedia(
        CaptureSource.photo,
        await picture(),
      );
      api.rejections['PUT ${FakeCaptureApi.path}/${capture.id}/file'] = 409;

      await store.processNow(only());

      expect(only().pending, isEmpty);
    });

    test('processar agora reenvia o arquivo', () async {
      final capture = await store.createMedia(
        CaptureSource.photo,
        await picture(),
      );
      api.server[capture.id]!['status'] = 'failed';
      api.calls.clear();

      await store.processNow(only());

      expect(api.calls.first, 'PUT ${FakeCaptureApi.path}/${capture.id}/file');
      expect(only().status, CaptureStatus.processing);
    });
  });

  group('descartar', () {
    test('nunca enviada: só some do celular, sem chamar a API', () async {
      api.offline = true;
      await store.createText(text);
      final capture = only();
      api
        ..offline = false
        ..calls.clear();

      await store.discard(capture);
      await store.sync();

      expect(store.data, isEmpty);
      expect(api.calls.where((c) => !c.startsWith('GET')), isEmpty);
    });

    test('já enviada: manda DELETE e some da lista', () async {
      final capture = await store.createText(text);

      await store.discard(only());

      expect(api.calls.last, 'DELETE ${FakeCaptureApi.path}/${capture.id}');
      expect(store.data, isEmpty);
      expect((await db.capture(capture.id))?.discardedAt, isNotNull);
    });
  });

  group('dono', () {
    test('outra conta não vê nem envia as capturas', () async {
      api.offline = true;
      await store.createText(text);
      owner = 'bia@example.com';
      api.offline = false;

      await store.sync();

      expect(store.data, isEmpty);
      expect(api.server, isEmpty);
    });

    test('sem conta: lista vazia e nada é salvo', () async {
      owner = null;

      await store.createText(text);
      await store.sync();
      await store.load();

      expect(store.data, isEmpty);
      expect(api.calls, isEmpty);
    });
  });

  group('limpeza de mídia', () {
    Future<Capture> photo() async {
      api.offline = true;
      return store.createMedia(CaptureSource.photo, await picture());
    }

    test('apaga só a de captura fechada há mais de 30 dias', () async {
      final old = await photo();
      final recent = await photo();
      final open = await photo();
      final now = DateTime(2026, 12, 1);
      await db.saveCapture(
        'ana@example.com',
        old.copyWith(analyzedAt: now.subtract(const Duration(days: 31))),
      );
      await db.saveCapture(
        'ana@example.com',
        recent.copyWith(discardedAt: now.subtract(const Duration(days: 29))),
      );

      await store.cleanMedia(now);

      expect(File('${root.path}/${old.mediaPath}').existsSync(), isFalse);
      expect((await db.capture(old.id))?.mediaPath, isNull);
      expect(File('${root.path}/${recent.mediaPath}').existsSync(), isTrue);
      expect(File('${root.path}/${open.mediaPath}').existsSync(), isTrue);
    });
  });
}
