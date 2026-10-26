import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/device/audio_playback.dart';
import 'package:tagarela/data/device/capture_device.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/data/stores/capture_store.dart';
import 'package:tagarela/data/stores/vocabulary_store.dart';
import 'package:tagarela/design_system/design_system.dart';

import 'pump_app.dart';

extension OpenModal on WidgetTester {
  Future<List<Capture?>> openModal(
    Widget modal, {
    CaptureStore? captures,
    CaptureDevice? device,
    AudioPlayback? playback,
  }) => openModalOf<Capture>(
    modal,
    captures: captures,
    device: device,
    playback: playback,
  );

  Future<List<T?>> openModalOf<T>(
    Widget modal, {
    CaptureStore? captures,
    CaptureDevice? device,
    AudioPlayback? playback,
    VocabularyStore? vocabulary,
  }) async {
    final results = <T?>[];
    await pumpPage(
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async =>
                results.add(await AppModal.show<T>(context, (_) => modal)),
            child: const Text('abrir'),
          ),
        ),
      ),
      captures: captures,
      device: device,
      playback: playback,
      vocabulary: vocabulary,
    );
    await tap(find.text('abrir'));
    await pump();
    await pump(const Duration(milliseconds: 400));
    return results;
  }
}

AppButton button(WidgetTester tester, String label) =>
    tester.widget<AppButton>(find.widgetWithText(AppButton, label));
