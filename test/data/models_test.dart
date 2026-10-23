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

  test('rótulos dos enums em pt-BR', () {
    expect(TermKind.word.label, 'Palavra');
    expect(TermKind.expression.label, 'Expressão');
    expect(TermStatus.learning.label, 'Aprendendo');
    expect(TermStatus.mastered.label, 'Dominado');
    expect(CaptureSource.photo.label, 'Foto');
    expect(CaptureSource.audio.label, 'Áudio');
    expect(CaptureSource.text.label, 'Texto');
  });

  group('Capture', () {
    Json json({String status = 'ready', String text = 'mind the gap'}) => {
      'id': 'c1',
      'source': 'photo',
      'status': status,
      'text': text,
      'original_text': 'MIND THE GAP',
      'terms': [
        {'text': 'mind', 'start': 0, 'end': 4},
      ],
      'error': '',
      'captured_at': '2026-10-23T10:00:00Z',
      'processed_at': '2026-10-23T10:00:05Z',
      'analyzed_at': null,
      'discarded_at': null,
      'updated_at': '2026-10-23T10:00:05Z',
    };

    test('fromJson lê o formato da API', () {
      final capture = Capture.fromJson(json(status: 'waiting_file'));

      expect(capture.source, CaptureSource.photo);
      expect(capture.status, CaptureStatus.waitingFile);
      expect(capture.terms, [
        const CaptureTerm(text: 'mind', start: 0, end: 4),
      ]);
      expect(capture.error, isNull);
      expect(capture.processedAt, DateTime.utc(2026, 10, 23, 10, 0, 5));
      expect(capture.analyzedAt, isNull);
      expect(
        Capture.fromJson({...json(), 'error': 'no_text'}).error,
        'no_text',
      );
    });

    test('merge sem pendência fica igual ao servidor', () {
      final local = Capture(
        id: 'c1',
        source: CaptureSource.photo,
        status: CaptureStatus.processing,
        capturedAt: DateTime.utc(2026, 10, 23, 10),
        mediaPath: 'captures/photo/c1.jpg',
      );

      final merged = local.merge(Capture.fromJson(json()));

      expect(merged.status, CaptureStatus.ready);
      expect(merged.text, 'mind the gap');
      expect(merged.updatedAt, DateTime.utc(2026, 10, 23, 10, 0, 5));
      expect(merged.mediaPath, 'captures/photo/c1.jpg');
    });

    test('merge mantém edição, confirmação e descarte pendentes', () {
      final analyzedAt = DateTime.utc(2026, 10, 24);
      final local = Capture.fromJson(json()).copyWith(
        status: CaptureStatus.analyzed,
        text: 'mind the gap!',
        terms: const [],
        analyzedAt: analyzedAt,
        discardedAt: analyzedAt,
        pending: const {
          CaptureSync.update,
          CaptureSync.confirm,
          CaptureSync.discard,
        },
      );

      final merged = local.merge(Capture.fromJson(json(text: 'outro')));

      expect(merged.text, 'mind the gap!');
      expect(merged.terms, isEmpty);
      expect(merged.status, CaptureStatus.analyzed);
      expect(merged.analyzedAt, analyzedAt);
      expect(merged.discardedAt, analyzedAt);
      expect(merged.pending, local.pending);
    });

    test('mídia vence 30 dias depois de analisada ou descartada', () {
      final now = DateTime(2026, 12, 1);
      final base = Capture.fromJson(
        json(),
      ).copyWith(mediaPath: () => 'captures/photo/c1.jpg');

      expect(base.mediaExpired(now), isFalse);
      expect(
        base
            .copyWith(analyzedAt: now.subtract(const Duration(days: 31)))
            .mediaExpired(now),
        isTrue,
      );
      expect(
        base
            .copyWith(discardedAt: now.subtract(const Duration(days: 30)))
            .mediaExpired(now),
        isFalse,
      );
      expect(
        base
            .copyWith(
              analyzedAt: now.subtract(const Duration(days: 31)),
              mediaPath: () => null,
            )
            .mediaExpired(now),
        isFalse,
      );
    });

    test('seção do Inbox e se precisa de ação vêm do status', () {
      Capture at(CaptureStatus status) =>
          Capture.fromJson(json()).copyWith(status: status);

      expect(
        CaptureStatus.values.map((s) => (at(s).section, at(s).needsAction)),
        [
          (CaptureSection.waiting, false),
          (CaptureSection.processing, false),
          (CaptureSection.attention, true),
          (CaptureSection.ready, true),
          (CaptureSection.done, false),
        ],
      );
      expect(CaptureSection.waiting.label, 'Esperando envio');
    });

    test('CaptureStatus.fromApi usa o nome da API', () {
      expect(
        CaptureStatus.values.map((s) => CaptureStatus.fromApi(s.apiName)),
        CaptureStatus.values,
      );
      expect(CaptureStatus.waitingFile.apiName, 'waiting_file');
    });
  });
}
