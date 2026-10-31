import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:tagarela/data/models/models.dart';

import '../../helpers/fixtures.dart';

Term _term(int level) => Term('t$level', 'word', TermKind.word, level);

TermGroup _group(List<Term> terms) => TermGroup(
  id: '1',
  name: 'Grupo',
  icon: GroupIcon.travel,
  color: GroupColor.violet,
  terms: terms,
);

void main() {
  group('Term.status', () {
    test('nível 0 a 4 = aprendendo', () {
      for (final level in [0, 1, 2, 3, 4]) {
        expect(_term(level).status, TermStatus.learning, reason: '$level');
      }
    });

    test('só o nível 5 = dominado', () {
      expect(_term(5).status, TermStatus.mastered);
    });
  });

  group('TermGroup', () {
    final group = _group([_term(1), _term(5), _term(5), _term(3)]);

    test('masteredCount conta só dominados', () {
      expect(_group([]).masteredCount, 0);
      expect(group.masteredCount, 2);
    });

    test('termsWith filtra por status; null = todos', () {
      expect(group.termsWith(null), hasLength(4));
      expect(group.termsWith(TermStatus.learning).map((t) => t.level), [1, 3]);
      expect(group.termsWith(TermStatus.mastered).map((t) => t.level), [5, 5]);
    });

    test('fromJson lê termos embutidos, ícone e cor', () {
      final g = TermGroup.fromJson({
        'id': '7',
        'name': 'Viagem',
        'icon': 'travel',
        'accent': 'sky',
        'terms': [
          {
            'id': 't1',
            'text': 'layover',
            'translation': 'escala',
            'kind': 'word',
            'level': 4,
          },
        ],
      });

      expect(
        (g.id, g.name, g.icon, g.color),
        ('7', 'Viagem', GroupIcon.travel, GroupColor.sky),
      );
      expect(g.terms.single.id, 't1');
      expect(g.terms.single.text, 'layover');
      expect(g.terms.single.kind, TermKind.word);
    });

    test('fromJson com ícone e cor desconhecidos usa padrão', () {
      final g = TermGroup.fromJson({
        'id': '1',
        'name': 'X',
        'icon': 'rocket',
        'accent': 'black',
        'terms': <Object?>[],
      });

      expect(g.icon, isNull);
      expect(g.color, GroupColor.violet);
    });
  });

  group('Vocabulary', () {
    final vocabulary = Vocabulary(
      groups: [
        _group([_term(5), _term(1)]),
        _group([_term(5), _term(5), _term(0)]),
      ],
      ungrouped: [_term(5), _term(2)],
    );

    test('totais somam grupos e Sem grupo', () {
      expect(vocabulary.termCount, 7);
      expect(vocabulary.masteredCount, 4);
      expect(vocabulary.learningCount, 3);
      expect(const Vocabulary().termCount, 0);
    });

    test('isEmpty só sem grupo e sem termo solto', () {
      expect(const Vocabulary().isEmpty, isTrue);
      expect(Vocabulary(ungrouped: [_term(1)]).isEmpty, isFalse);
      expect(Vocabulary(groups: [_group([])]).isEmpty, isFalse);
    });

    test('fromJson lê grupos e Sem grupo', () {
      final v = Vocabulary.fromJson({
        'groups': [
          {
            'id': 'g1',
            'name': 'Viagem',
            'icon': 'travel',
            'accent': 'sky',
            'terms': <Object?>[],
          },
        ],
        'ungrouped': [
          {
            'id': 'u1',
            'text': 'touch base',
            'translation': '',
            'kind': 'expression',
            'level': 0,
          },
        ],
      });

      expect(v.groups.single.name, 'Viagem');
      expect(v.ungrouped.single.text, 'touch base');
    });

    test('group acha pelo id', () {
      final v = Vocabulary(groups: [_group([])]);

      expect(v.group('1')?.name, 'Grupo');
      expect(v.group('9'), isNull);
    });

    test('hasGroupNamed ignora maiúscula e espaço sobrando', () {
      final v = Vocabulary(groups: [_group([])]);

      expect(v.hasGroupNamed('  grupo '), isTrue);
      expect(v.hasGroupNamed('GRUPO'), isTrue);
      expect(v.hasGroupNamed('Grupos'), isFalse);
    });

    test('withGroup põe o grupo novo no topo', () {
      final v = Vocabulary(groups: [_group([])], ungrouped: [_term(1)]);
      final novo = TermGroup(
        id: '2',
        name: 'Música',
        icon: GroupIcon.music,
        color: GroupColor.pink,
        terms: const [],
      );

      final next = v.withGroup(novo);

      expect(next.groups.map((g) => g.id), ['2', '1']);
      expect(next.ungrouped, v.ungrouped);
    });
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
        'country': 'BR',
      });
      final apple = User.fromJson({'id': 2, 'email': 'x@privaterelay.com'});

      expect(
        (api.name, api.picture),
        ('Bia Lima', 'https://example.com/bia.png'),
      );
      expect((apple.name, apple.picture), ('', null));
      expect(User.fromJson(api.toJson()).picture, api.picture);
      expect(User.fromJson(api.toJson()).country, 'BR');
      expect(apple.country, isNull);
      expect(apple.toJson().containsKey('picture'), isFalse);
      expect(apple.toJson().containsKey('country'), isFalse);
    });
  });

  group('Capture', () {
    test('newId gera UUID v4 diferente a cada vez', () {
      final uuid = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      );

      final ids = {for (var i = 0; i < 50; i++) Capture.newId()};

      expect(ids, hasLength(50));
      expect(ids, everyElement(matches(uuid)));
    });

    Json json({String status = 'ready', String text = 'mind the gap'}) => {
      'id': 'c1',
      'source': 'photo',
      'status': status,
      'text': text,
      'terms': [
        {'text': 'mind', 'start': 0, 'end': 4},
      ],
      'captured_at': '2026-10-23T10:00:00Z',
      'analyzed_at': null,
      'discarded_at': null,
      'updated_at': '2026-10-23T10:00:05Z',
    };

    test('fromJson lê o formato da API', () {
      final capture = Capture.fromJson(json(status: 'analyzed'));

      expect(capture.source, CaptureSource.photo);
      expect(capture.status, CaptureStatus.analyzed);
      expect(capture.terms, [
        const CaptureTerm(text: 'mind', start: 0, end: 4),
      ]);
      expect(capture.error, isNull);
      expect(capture.analyzedAt, isNull);
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
          (CaptureSection.processing, false),
          (CaptureSection.attention, true),
          (CaptureSection.ready, true),
          (null, false),
        ],
      );
    });

    test('CaptureStatus.fromApi usa o nome da API', () {
      expect(
        CaptureStatus.values.map((s) => CaptureStatus.fromApi(s.apiName)),
        CaptureStatus.values,
      );
      expect(CaptureStatus.analyzed.apiName, 'analyzed');
    });
  });

  group('Course', () {
    test('fromJson lê os idiomas, o ativo e os termos', () {
      final course = Course.fromJson(const {
        'id': 'c1',
        'learning': 'es',
        'base': 'en',
        'active': true,
        'terms': 12,
      });

      expect(course.learning, CourseLanguage.es);
      expect(course.base, CourseLanguage.en);
      expect(course.active, isTrue);
      expect(course.terms, 12);
      expect(course.copyWith(active: false).active, isFalse);
    });

    test('só inglês tem áudio; sigla em maiúscula', () {
      expect(
        [for (final l in CourseLanguage.values) l.hasAudio],
        [true, false, false],
      );
      expect(CourseLanguage.pt.code, 'PT');
      expect(CourseLanguage.es.nativeName, 'Español');
    });

    test('cada idioma tem país da bandeira, saudação e locale', () {
      expect(
        [for (final l in CourseLanguage.values) l.country],
        ['US', 'ES', 'BR'],
      );
      expect(CourseLanguage.pt.hello, 'Oi, tudo bem?');
      expect(CourseLanguage.es.locale, const Locale('es'));
      expect(CourseLanguage.of('en'), CourseLanguage.en);
      expect(CourseLanguage.of('fr'), isNull);
      expect(CourseLanguage.of(null), isNull);
    });
  });

  group('TermDetail', () {
    test('fromJson lê termo, grupo, ficha e capturas', () {
      final detail = TermDetail.fromJson({
        'id': 't1',
        'text': 'mind the gap',
        'translation': 'cuidado com o vão',
        'kind': 'expression',
        'level': 2,
        'group': {
          'id': 'g1',
          'name': 'Viagem',
          'icon': 'travel',
          'accent': 'sky',
        },
        'revealed': true,
        'pitfall_revealed': false,
        'formality_revealed': true,
        'card': sampleCardJson,
        'captures': [
          {
            'id': 'c1',
            'source': 'audio',
            'text': 'Mind the gap!',
            'captured_at': '2026-10-23T10:00:00Z',
            'terms': [
              {'text': 'Mind the gap', 'start': 0, 'end': 12, 'term': 't1'},
            ],
          },
        ],
      });

      expect(detail.term.text, 'mind the gap');
      expect(detail.group!.name, 'Viagem');
      expect(detail.group!.icon, GroupIcon.travel);
      expect(detail.revealed, isTrue);
      expect(detail.pitfallRevealed, isFalse);
      expect(detail.formalityRevealed, isTrue);
      final card = detail.card;
      expect(card.phonetic, '/maɪnd ðə ɡæp/');
      expect(card.learning.headline, 'be careful of the space');
      expect(card.base.headline, 'cuidado com o vão');
      expect(card.learning.pitfall, 'It is not "mind the hole".');
      expect(card.base.pitfall, 'Não é "mente o buraco".');
      expect(
        card.examples.single.translation,
        'Cuidado com o vão ao sair do trem.',
      );
      expect(card.formality, Formality.neutral);
      expect(card.fits.last.instead, 'careful');
      expect(card.fits.first.context, 'Aviso público');
      expect(card.formalityNote, 'Serve em qualquer lugar.');
      expect(card.hasWords, isTrue);
      expect(card.hasUsage, isTrue);
      expect(card.base.literal, 'repare no vão');
      expect(card.learning.imagine, startsWith('A yellow line'));
      expect(card.base.imagine, startsWith('Uma faixa amarela'));
      expect(card.mistake!.wrong, 'mind the hole');
      expect(card.mistake!.right, 'mind the gap');
      expect(card.hasReminders, isTrue);
      expect(card.dialogue.map((l) => l.speaker), [
        DialogueSpeaker.a,
        DialogueSpeaker.b,
      ]);
      expect(card.dialogue.last.translation, startsWith('Já vou!'));
      final seen = detail.captures.single;
      expect(seen.source, CaptureSource.audio);
      expect(seen.spans.single.termId, 't1');
    });

    test('sem grupo, sem palavras e sem uso', () {
      final detail = TermDetail.fromJson({
        'id': 't1',
        'text': 'gap',
        'translation': '',
        'kind': 'word',
        'level': 0,
        'group': null,
        'revealed': false,
        'pitfall_revealed': true,
        'formality_revealed': false,
        'card': {
          ...sampleCardJson,
          'collocations': <Object?>[],
          'synonyms': <Object?>[],
          'antonyms': <Object?>[],
          'formality': null,
          'fits': <Object?>[],
          'learning': {'definition': 'gap'},
          'base': {'translation': null},
          'mistake': null,
          'dialogue': <Object?>[],
        },
        'captures': <Object?>[],
      });

      expect(detail.group, isNull);
      expect(detail.pitfallRevealed, isTrue);
      expect(detail.card.hasWords, isFalse);
      expect(detail.card.hasUsage, isFalse);
      expect(detail.card.hasReminders, isFalse);
      expect(detail.card.mistake, isNull);
      expect(detail.card.dialogue, isEmpty);
    });
  });
}
