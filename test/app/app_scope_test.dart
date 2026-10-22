import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/store.dart';

import '../helpers/fake_api_client.dart';

void main() {
  test('loadAll carrega todos os stores', () async {
    final scope = AppScope(api: FakeApiClient(), child: const SizedBox());

    await scope.loadAll();

    for (final store in <Store>[
      scope.user,
      scope.home,
      scope.vocabulary,
      scope.inbox,
    ]) {
      expect(store.data, isNotNull, reason: '$store');
    }
  });

  testWidgets('of acha o escopo na árvore', (tester) async {
    late AppScope found;
    final scope = AppScope(
      api: FakeApiClient(),
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
