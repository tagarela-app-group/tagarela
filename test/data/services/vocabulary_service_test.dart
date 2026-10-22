import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/services/vocabulary_service.dart';

import '../../helpers/fake_api_client.dart';

void main() {
  test('fetchGroups traz grupos com termos embutidos', () async {
    final api = FakeApiClient();
    final groups = await VocabularyService(api).fetchGroups();

    expect(api.calls, ['GET /groups?_embed=terms']);
    expect(groups, hasLength((api.db['groups'] as List).length));
    final total = groups.fold(0, (sum, g) => sum + g.terms.length);
    expect(total, (api.db['terms'] as List).length);
  });
}
