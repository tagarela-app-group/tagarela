import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/audio_playback.dart';
import 'package:tagarela/data/capture_device.dart';
import 'package:tagarela/data/models.dart';
import 'package:tagarela/data/stores/capture_store.dart';
import 'package:tagarela/design_system/design_system.dart';

import 'pump_app.dart';

extension OpenSheet on WidgetTester {
  Future<List<Capture?>> openSheet(
    Widget sheet, {
    CaptureStore? captures,
    CaptureDevice? device,
    AudioPlayback? playback,
  }) async {
    final results = <Capture?>[];
    await pumpPage(
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async => results.add(
              await AppSheet.show<Capture>(context, (_) => sheet),
            ),
            child: const Text('abrir'),
          ),
        ),
      ),
      captures: captures,
      device: device,
      playback: playback,
    );
    await tap(find.text('abrir'));
    await pump();
    await pump(const Duration(milliseconds: 400));
    return results;
  }
}

AppButton button(WidgetTester tester, String label) =>
    tester.widget<AppButton>(find.widgetWithText(AppButton, label));
