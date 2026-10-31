import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/data/services/api_client.dart';
import 'package:tagarela/data/services/capture_service.dart';
import 'package:tagarela/data/storage/database.dart';
import 'package:tagarela/data/sync/capture_synchronizer.dart';

import '../../helpers/fake_capture_api.dart';

void main() {
  const owner = 'ana@example.com';
  const id = '6f1c7a52-0f3e-4b7d-9a11-2f6f0d3c1a10';
  const createRoute = 'POST ${FakeCaptureApi.path}';
  const confirmRoute = 'POST ${FakeCaptureApi.path}/$id/confirm';
  const updateRoute = 'PATCH ${FakeCaptureApi.path}/$id';
  const term = CaptureTerm(text: 'gap', start: 0, end: 3);

  late FakeCaptureApi api;
  late AppDatabase db;
  late CaptureSynchronizer sync;
  late int reloads;

  setUp(() {
    api = FakeCaptureApi();
    db = AppDatabase(NativeDatabase.memory());
    reloads = 0;
    sync = CaptureSynchronizer(
      CaptureService(api),
      db,
      onConfirmed: () async => reloads++,
    );
  });

  tearDown(() => db.close());

  Capture analyzed() => Capture(
    id: id,
    source: CaptureSource.text,
    status: CaptureStatus.analyzed,
    text: 'gap',
    terms: const [term],
    capturedAt: DateTime.utc(2026, 10, 30),
    analyzedAt: DateTime.utc(2026, 10, 30),
    pending: const {
      CaptureSync.create,
      CaptureSync.update,
      CaptureSync.confirm,
    },
  );

  Future<Capture> saved() async => (await db.capture(id))!;

  group('API recusa de verdade (400)', () {
    test('confirmação: volta pro Inbox como falha, não some', () async {
      api.rejections[confirmRoute] = 400;

      await sync.push(owner, analyzed());

      final capture = await saved();
      expect(capture.status, CaptureStatus.failed);
      expect(capture.refused, isTrue);
      expect(capture.analyzedAt, isNull);
      expect(capture.pending, {CaptureSync.confirm});
      expect(reloads, 0);
    });

    test('criação: para ali e não tenta as etapas seguintes', () async {
      api.rejections[createRoute] = 400;

      await sync.push(owner, analyzed());

      expect(api.calls, [createRoute]);
      expect((await saved()).refused, isTrue);
    });

    test('recusada não insiste a cada sync', () async {
      api.rejections[confirmRoute] = 400;
      await sync.push(owner, analyzed());
      api.calls.clear();

      await sync.push(owner, await saved());

      expect(api.calls, isEmpty);
    });

    test('pull não apaga a falha', () async {
      api.rejections[confirmRoute] = 400;
      await sync.push(owner, analyzed());

      await sync.pull(owner);

      final capture = await saved();
      expect(capture.status, CaptureStatus.failed);
      expect(capture.refused, isTrue);
    });

    test('recusada ainda pode ser descartada', () async {
      api.rejections[confirmRoute] = 400;
      await sync.push(owner, analyzed());
      final refused = await saved();

      await sync.push(
        owner,
        refused.copyWith(
          discardedAt: DateTime.utc(2026, 10, 31),
          pending: {...refused.pending, CaptureSync.discard},
        ),
      );

      expect(api.calls.last, 'DELETE ${FakeCaptureApi.path}/$id');
      expect((await saved()).pending, isNot(contains(CaptureSync.discard)));
    });
  });

  group('etapa encerrada (404 e 409)', () {
    for (final status in [404, 409]) {
      test('$status: larga a etapa e segue pra próxima', () async {
        api.rejections[updateRoute] = status;

        await sync.push(owner, analyzed());

        final capture = await saved();
        expect(capture.pending, isEmpty);
        expect(capture.refused, isFalse);
        expect(capture.status, CaptureStatus.analyzed);
        expect(api.calls.last, confirmRoute);
        expect(reloads, 1);
      });
    }
  });

  group('tenta de novo depois (429 e 5xx)', () {
    for (final status in [429, 500, 503]) {
      test('$status: lança e mantém a etapa na fila', () async {
        api.rejections[confirmRoute] = status;
        final capture = analyzed();

        await expectLater(
          sync.push(owner, capture),
          throwsA(isA<ApiException>()),
        );

        final kept = await saved();
        expect(kept.status, CaptureStatus.analyzed);
        expect(kept.refused, isFalse);
        expect(kept.pending, {CaptureSync.confirm});
        expect(reloads, 0);
      });
    }
  });
}
