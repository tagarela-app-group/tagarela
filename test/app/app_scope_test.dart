import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/app/app_dependencies.dart';
import 'package:tagarela/app/app_scope.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('of acha as dependências na árvore', (tester) async {
    late AppDependencies found;
    final dependencies = fakeDependencies();
    final scope = AppScope(
      dependencies: dependencies,
      child: Builder(
        builder: (context) {
          found = AppScope.of(context);
          return const SizedBox();
        },
      ),
    );

    await tester.pumpWidget(scope);

    expect(found, same(dependencies));
    expect(scope.updateShouldNotify(scope), isFalse);
  });
}
