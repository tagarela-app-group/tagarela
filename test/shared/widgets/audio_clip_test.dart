import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/shared/widgets/audio_clip.dart';

import '../../helpers/fake_capture_store.dart';
import '../../helpers/pump_app.dart';

void main() {
  test('clockLabel', () {
    expect(clockLabel(null), '–:––');
    expect(clockLabel(const Duration(seconds: 4)), '0:04');
    expect(clockLabel(const Duration(seconds: 65)), '1:05');
  });

  testWidgets('mostra a duração e toca/para no toque', (tester) async {
    final playback = FakeAudioPlayback();
    final file = File('captures/audio/a1.m4a');
    await tester.pumpPage(AudioClip(file: file), playback: playback);
    await tester.pump();

    expect(find.text('0:04'), findsOneWidget);
    expect(find.byTooltip('Ouvir gravação'), findsOneWidget);

    await tester.tap(find.byIcon(AppIcons.play));
    await tester.pump();
    expect(find.byTooltip('Parar'), findsOneWidget);

    await tester.tap(find.byIcon(AppIcons.stop));
    await tester.pump();
    expect(find.byTooltip('Ouvir gravação'), findsOneWidget);
    expect(playback.toggled, [file.path, file.path]);
  });
}
