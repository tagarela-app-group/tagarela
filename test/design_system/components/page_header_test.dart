import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/design_system/design_system.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('centered: leading em cima e textos no meio', (tester) async {
    await tester.pumpComponent(
      const PageHeader(
        title: 'Ana Souza',
        subtitle: 'ana@example.com',
        leading: Icon(AppIcons.profile),
        centered: true,
      ),
    );

    final header = tester.getRect(find.byType(PageHeader));
    final icon = tester.getRect(find.byIcon(AppIcons.profile));
    final title = tester.getRect(find.text('Ana Souza'));
    expect(icon.bottom, lessThanOrEqualTo(title.top));
    expect(icon.center.dx, closeTo(header.center.dx, 1));
    expect(
      tester.widget<Text>(find.text('ana@example.com')).textAlign,
      TextAlign.center,
    );
  });
}
