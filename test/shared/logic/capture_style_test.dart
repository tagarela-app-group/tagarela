import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/shared/logic/capture_style.dart';

void main() {
  test('cada fonte tem ícone e cor próprios', () {
    const sources = CaptureSource.values;

    expect(sources.map((s) => s.glyph).toSet(), hasLength(sources.length));
    expect(sources.map((s) => s.accent).toSet(), hasLength(sources.length));
    expect(
      (CaptureSource.audio.glyph, CaptureSource.audio.accent),
      (AppIcons.audio, AppAccent.coral),
    );
  });
}
