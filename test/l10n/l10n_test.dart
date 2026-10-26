import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/data/services/auth_service.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/inbox/inbox_page.dart';

import '../helpers/l10n.dart';

void main() {
  test('os três idiomas têm as mesmas chaves', () {
    Set<String> keys(String lang) =>
        (jsonDecode(File('lib/l10n/app_$lang.arb').readAsStringSync())
                as Map<String, Object?>)
            .keys
            .where((k) => !k.startsWith('@'))
            .toSet();

    expect(keys('en'), keys('pt'));
    expect(keys('es'), keys('pt'));
  });

  test('todo valor de enum tem rótulo em todo idioma', () {
    for (final l10n in [pt, en, es]) {
      final labels = [
        for (final v in TermKind.values) l10n.termKind(v.name),
        for (final v in TermStatus.values) l10n.termStatus(v.name),
        for (final v in CaptureSource.values) l10n.captureSource(v.name),
        for (final v in CaptureSource.values) l10n.captureContent(v.name),
        for (final v in CaptureSection.values) l10n.captureSection(v.name),
        for (final v in CaptureStatus.values) l10n.captureStatus(v.name),
        for (final v in InboxTab.values) l10n.inboxTab(v.name),
        for (final v in GroupIcon.values) l10n.groupIcon(v.name),
        for (final v in AppAccent.values) l10n.accentName(v.name),
        for (final v in AuthFailure.values) l10n.authFailure(v.name),
        for (final p in ['morning', 'afternoon', 'evening']) l10n.greeting(p),
        for (final a in ['create', 'save']) l10n.groupSaveFailed(a),
        for (final a in ['create', 'save']) l10n.groupSaveRejected(a),
      ];
      expect(labels.where((l) => l.isEmpty), isEmpty, reason: l10n.localeName);
    }
  });

  test('plural: zero não vira singular no português', () {
    expect(pt.termCount(0), '0 termos');
    expect(pt.termCount(1), '1 termo');
    expect(pt.termCount(3), '3 termos');
    expect(en.termCount(0), '0 terms');
    expect(es.termCount(1), '1 término');
    expect(pt.moveTerms(0), 'Selecione os termos');
  });
}
