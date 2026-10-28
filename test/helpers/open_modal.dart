import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/app/app_dependencies.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';

import 'pump_app.dart';

extension OpenModal on WidgetTester {
  Future<List<Capture?>> openModal(Widget modal, {AppDependencies? deps}) =>
      openModalOf<Capture>(modal, deps: deps);

  Future<List<T?>> openModalOf<T>(Widget modal, {AppDependencies? deps}) async {
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
      deps: deps,
    );
    await tap(find.text('abrir'));
    await pump();
    await pump(const Duration(milliseconds: 400));
    return results;
  }
}

AppButton button(WidgetTester tester, String label) =>
    tester.widget<AppButton>(find.widgetWithText(AppButton, label));
