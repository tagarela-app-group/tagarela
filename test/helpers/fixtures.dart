import 'package:tagarela/data/models/models.dart';

import 'contract.dart';

const Json sampleVocabularyJson = {'groups': _groups, 'ungrouped': _ungrouped};

final sampleVocabulary = Vocabulary.fromJson(sampleVocabularyJson);

const List<Json> _ungrouped = [
  {
    'id': 'u1',
    'text': 'mind the gap',
    'translation': '',
    'kind': 'expression',
    'level': 0,
  },
  {
    'id': 'u2',
    'text': 'stand clear',
    'translation': '',
    'kind': 'expression',
    'level': 0,
  },
];

const List<Json> _groups = [
  {
    'id': '1',
    'name': 'Viagem',
    'icon': 'travel',
    'accent': 'sky',
    'terms': [
      {
        'id': 't1',
        'text': 'boarding pass',
        'translation': 'cartão de embarque',
        'kind': 'expression',
        'level': 5,
      },
      {
        'id': 't2',
        'text': 'layover',
        'translation': 'escala (de voo)',
        'kind': 'word',
        'level': 5,
      },
      {
        'id': 't3',
        'text': 'carry-on',
        'translation': 'bagagem de mão',
        'kind': 'word',
        'level': 2,
      },
      {
        'id': 't4',
        'text': 'itinerary',
        'translation': 'roteiro',
        'kind': 'word',
        'level': 5,
      },
      {
        'id': 't5',
        'text': 'jet lag',
        'translation': 'cansaço do fuso horário',
        'kind': 'expression',
        'level': 1,
      },
      {
        'id': 't6',
        'text': 'check in',
        'translation': 'fazer check-in',
        'kind': 'expression',
        'level': 5,
      },
      {
        'id': 't7',
        'text': 'souvenir',
        'translation': 'lembrancinha',
        'kind': 'word',
        'level': 3,
      },
    ],
  },
  {
    'id': '2',
    'name': 'Trabalho',
    'icon': 'work',
    'accent': 'violet',
    'terms': [
      {
        'id': 't8',
        'text': 'deadline',
        'translation': 'prazo',
        'kind': 'word',
        'level': 5,
      },
      {
        'id': 't9',
        'text': 'follow up',
        'translation': 'dar retorno',
        'kind': 'expression',
        'level': 3,
      },
      {
        'id': 't10',
        'text': 'touch base',
        'translation': 'alinhar rapidinho',
        'kind': 'expression',
        'level': 2,
      },
      {
        'id': 't11',
        'text': 'workload',
        'translation': 'carga de trabalho',
        'kind': 'word',
        'level': 5,
      },
      {
        'id': 't12',
        'text': 'out of office',
        'translation': 'fora do escritório',
        'kind': 'expression',
        'level': 1,
      },
    ],
  },
  {
    'id': '3',
    'name': 'Dia a dia',
    'icon': 'talk',
    'accent': 'mint',
    'terms': [
      {
        'id': 't13',
        'text': 'no worries',
        'translation': 'sem problemas',
        'kind': 'expression',
        'level': 5,
      },
      {
        'id': 't14',
        'text': 'catch up',
        'translation': 'colocar o papo em dia',
        'kind': 'expression',
        'level': 5,
      },
      {
        'id': 't15',
        'text': 'hang out',
        'translation': 'passar um tempo junto',
        'kind': 'expression',
        'level': 3,
      },
      {
        'id': 't16',
        'text': 'awkward',
        'translation': 'constrangedor',
        'kind': 'word',
        'level': 2,
      },
      {
        'id': 't17',
        'text': 'I\'m starving',
        'translation': 'tô morrendo de fome',
        'kind': 'expression',
        'level': 1,
      },
      {
        'id': 't18',
        'text': 'I\'m on the fence about it',
        'translation': 'estar em dúvida, indeciso',
        'kind': 'expression',
        'level': 0,
      },
    ],
  },
  {
    'id': '4',
    'name': 'Phrasal verbs',
    'icon': 'layers',
    'accent': 'coral',
    'terms': [
      {
        'id': 't19',
        'text': 'give up',
        'translation': 'desistir',
        'kind': 'expression',
        'level': 5,
      },
      {
        'id': 't20',
        'text': 'figure out',
        'translation': 'descobrir, entender',
        'kind': 'expression',
        'level': 3,
      },
      {
        'id': 't21',
        'text': 'run out of',
        'translation': 'ficar sem',
        'kind': 'expression',
        'level': 2,
      },
      {
        'id': 't22',
        'text': 'come across',
        'translation': 'deparar-se com',
        'kind': 'expression',
        'level': 1,
      },
      {
        'id': 't23',
        'text': 'put off',
        'translation': 'adiar',
        'kind': 'expression',
        'level': 2,
      },
    ],
  },
  {
    'id': '5',
    'name': 'Séries & filmes',
    'icon': 'tv',
    'accent': 'pink',
    'terms': [
      {
        'id': 't24',
        'text': 'binge-watch',
        'translation': 'maratonar',
        'kind': 'expression',
        'level': 5,
      },
      {
        'id': 't25',
        'text': 'spoiler',
        'translation': 'revelação do enredo',
        'kind': 'word',
        'level': 5,
      },
      {
        'id': 't26',
        'text': 'plot twist',
        'translation': 'reviravolta',
        'kind': 'expression',
        'level': 2,
      },
      {
        'id': 't27',
        'text': 'cliffhanger',
        'translation': 'final em suspense',
        'kind': 'word',
        'level': 1,
      },
    ],
  },
  {
    'id': '6',
    'name': 'Comida',
    'icon': 'food',
    'accent': 'mango',
    'terms': [
      {
        'id': 't28',
        'text': 'to go',
        'translation': 'para viagem',
        'kind': 'expression',
        'level': 5,
      },
      {
        'id': 't29',
        'text': 'leftovers',
        'translation': 'sobras',
        'kind': 'word',
        'level': 3,
      },
      {
        'id': 't30',
        'text': 'the bill',
        'translation': 'a conta',
        'kind': 'expression',
        'level': 5,
      },
      {
        'id': 't31',
        'text': 'spicy',
        'translation': 'apimentado',
        'kind': 'word',
        'level': 5,
      },
    ],
  },
];

final sampleCardJson = contractExample('term_detail')['card']! as Json;
