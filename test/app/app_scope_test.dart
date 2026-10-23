import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/models.dart';
import 'package:tagarela/data/store.dart';

import '../helpers/fake_auth.dart';
import '../helpers/fake_capture_store.dart';
import '../helpers/pump_app.dart';

void main() {
  test('loadAll carrega todos os stores', () async {
    final scope = testScope(child: const SizedBox());

    await scope.loadAll();

    for (final store in <Store>[scope.home, scope.vocabulary, scope.captures]) {
      expect(store.data, isNotNull, reason: '$store');
    }
  });

  test('sem dados de exemplo: Home e Vocabulário vazios', () async {
    final captures = fakeCaptures();
    final scope = AppScope(
      auth: fakeAuthStore(),
      captures: captures.store,
      playback: FakeAudioPlayback(),
      device: FakeCaptureDevice(),
      child: const SizedBox(),
    );

    await scope.loadAll();

    expect(scope.home.data!.wordOfDay, isNull);
    expect(scope.home.data!.stats.reviewCount, 0);
    expect(scope.vocabulary.data, isEmpty);
  });

  test('loadAll limpa mídia vencida antes de listar', () async {
    final captures = fakeCaptures();
    const path = 'captures/photo/c1.jpg';
    captures.media.files[path] = File(path);
    await captures.db.saveCapture(
      'ana@example.com',
      sampleCapture(
        'c1',
        source: CaptureSource.photo,
        status: CaptureStatus.analyzed,
        mediaPath: path,
      ).copyWith(analyzedAt: DateTime(2020)),
    );
    final scope = testScope(captures: captures.store, child: const SizedBox());

    await scope.loadAll();

    expect(captures.media.files, isEmpty);
    expect(scope.captures.data!.single.mediaPath, isNull);
  });

  testWidgets('of acha o escopo na árvore', (tester) async {
    late AppScope found;
    final scope = testScope(
      child: Builder(
        builder: (context) {
          found = AppScope.of(context);
          return const SizedBox();
        },
      ),
    );

    await tester.pumpWidget(scope);

    expect(found, same(scope));
    expect(scope.updateShouldNotify(scope), isFalse);
  });
}
