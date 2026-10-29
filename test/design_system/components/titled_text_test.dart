import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('sem texto, só o título', (tester) async {
    await tester.pumpComponent(const TitledText(title: 'Título'));

    expect(find.byType(Text), findsOneWidget);
  });
}
