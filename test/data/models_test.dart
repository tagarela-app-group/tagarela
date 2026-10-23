import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models.dart';
import 'package:tagarela/design_system/design_system.dart';

Term _term(int level) => Term('word', 'palavra', TermKind.word, level);

TermGroup _group(List<Term> terms) => TermGroup(
  id: '1',
  name: 'Grupo',
  icon: AppIcons.travel,
  accent: AppAccent.violet,
  terms: terms,
);

void main() {
  group('Term.status', () {
    test('nível 0 a 3 = aprendendo', () {
      for (final level in [0, 1, 2, 3]) {
        expect(_term(level).status, TermStatus.learning, reason: '$level');
      }
    });

    test('nível 4 e 5 = dominado', () {
      expect(_term(4).status, TermStatus.mastered);
      expect(_term(5).status, TermStatus.mastered);
    });
  });

  group('TermGroup', () {
    final group = _group([_term(1), _term(4), _term(5), _term(3)]);

    test('masteredCount conta só dominados', () {
      expect(_group([]).masteredCount, 0);
      expect(group.masteredCount, 2);
    });

    test('termsWith filtra por status; null = todos', () {
      expect(group.termsWith(null), hasLength(4));
      expect(group.termsWith(TermStatus.learning).map((t) => t.level), [1, 3]);
      expect(group.termsWith(TermStatus.mastered).map((t) => t.level), [4, 5]);
    });

    test('fromJson lê termos embutidos, ícone e cor', () {
      final g = TermGroup.fromJson({
        'id': '7',
        'name': 'Viagem',
        'icon': 'travel',
        'accent': 'sky',
        'terms': [
          {
            'text': 'layover',
            'translation': 'escala',
            'kind': 'word',
            'level': 4,
          },
        ],
      });

      expect(
        (g.id, g.name, g.icon, g.accent),
        ('7', 'Viagem', AppIcons.travel, AppAccent.sky),
      );
      expect(g.terms.single.text, 'layover');
      expect(g.terms.single.kind, TermKind.word);
    });

    test('fromJson com ícone e cor desconhecidos usa padrão', () {
      final g = TermGroup.fromJson({
        'id': '1',
        'name': 'X',
        'icon': 'rocket',
        'accent': 'gold',
        'terms': <Object?>[],
      });

      expect(g.icon, AppIcons.vocabulary);
      expect(g.accent, AppAccent.violet);
    });
  });

  test('totais da lista de grupos', () {
    final groups = [
      _group([_term(5), _term(1)]),
      _group([_term(4), _term(4), _term(0)]),
    ];

    expect(groups.termCount, 5);
    expect(groups.masteredCount, 3);
    expect(groups.learningCount, 2);
    expect(<TermGroup>[].termCount, 0);
  });

  group('User', () {
    User user(String name) => User(name: name, email: 'mari@email.com');

    test('um nome = uma inicial', () {
      expect(user('Moeb').initials, 'M');
    });

    test('nome composto = inicial do primeiro e do último nome', () {
      expect(user('Bruno Pinheiro').initials, 'BP');
      expect(user('marina de souza').initials, 'MS');
    });

    test('sem nome: iniciais e nome de exibição vêm do e-mail', () {
      expect(
        (user('').initials, user('').displayName),
        ('M', 'mari@email.com'),
      );
      expect(user('').firstName, '');
    });

    test('primeiro nome', () {
      expect(user('  Marina de Souza ').firstName, 'Marina');
    });

    test('fromJson da API e ida e volta pelo toJson', () {
      final api = User.fromJson({
        'id': 1,
        'display': 'Bia',
        'email': 'bia@gmail.com',
        'name': 'Bia Lima',
        'picture': 'https://example.com/bia.png',
      });
      final apple = User.fromJson({'id': 2, 'email': 'x@privaterelay.com'});

      expect(
        (api.name, api.picture),
        ('Bia Lima', 'https://example.com/bia.png'),
      );
      expect((apple.name, apple.picture), ('', null));
      expect(User.fromJson(api.toJson()).picture, api.picture);
      expect(apple.toJson().containsKey('picture'), isFalse);
    });
  });

  test('InboxItem.fromJson com e sem sugestão', () {
    final ready = InboxItem.fromJson({
      'id': '1',
      'source': 'camera',
      'content': 'Mind the gap',
      'capturedAt': 'há 1 h',
      'status': 'ready',
      'suggestion': {
        'translation': 'cuidado com o vão',
        'kind': 'expression',
        'groupId': '1',
        'groupName': 'Viagem',
      },
    });
    final queued = InboxItem.fromJson({
      'id': '2',
      'source': 'audio',
      'content': '0:04',
      'capturedAt': 'agora',
      'status': 'queued',
    });

    expect(ready.source, CaptureSource.camera);
    expect(ready.status, InboxStatus.ready);
    expect(ready.suggestion!.groupId, '1');
    expect(ready.suggestion!.kind, TermKind.expression);
    expect(queued.status, InboxStatus.queued);
    expect(queued.suggestion, isNull);
  });

  test('rótulos dos enums em pt-BR', () {
    expect(TermKind.word.label, 'Palavra');
    expect(TermKind.expression.label, 'Expressão');
    expect(TermStatus.learning.label, 'Aprendendo');
    expect(TermStatus.mastered.label, 'Dominado');
    expect(CaptureSource.camera.label, 'Câmera');
    expect(CaptureSource.audio.label, 'Áudio');
    expect(CaptureSource.text.label, 'Texto');
  });
}
