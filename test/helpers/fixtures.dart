import 'package:tagarela/data/models.dart';

final sampleHome = (
  stats: Stats.fromJson(_stats),
  wordOfDay: WordOfDay.fromJson(_wordOfDay),
);

final sampleGroups = [for (final g in _groups) TermGroup.fromJson(g)];

const Json _stats = {'weekGain': 5, 'reviewCount': 12};

const Json _wordOfDay = {
  'text': 'serendipity',
  'phonetic': '/ˌser.ənˈdɪp.ə.ti/',
  'partOfSpeech': 'substantivo',
  'translation': 'acaso feliz',
  'example': 'Finding this café was pure serendipity.',
  'dateLabel': 'Qua, 22 out',
};

const List<Json> _groups = [
  {
    'id': '1',
    'name': 'Viagem',
    'icon': 'travel',
    'accent': 'sky',
    'terms': [
      {
        'text': 'boarding pass',
        'translation': 'cartão de embarque',
        'kind': 'expression',
        'level': 5,
      },
      {
        'text': 'layover',
        'translation': 'escala (de voo)',
        'kind': 'word',
        'level': 4,
      },
      {
        'text': 'carry-on',
        'translation': 'bagagem de mão',
        'kind': 'word',
        'level': 2,
      },
      {
        'text': 'itinerary',
        'translation': 'roteiro',
        'kind': 'word',
        'level': 5,
      },
      {
        'text': 'jet lag',
        'translation': 'cansaço do fuso horário',
        'kind': 'expression',
        'level': 1,
      },
      {
        'text': 'check in',
        'translation': 'fazer check-in',
        'kind': 'expression',
        'level': 4,
      },
      {
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
      {'text': 'deadline', 'translation': 'prazo', 'kind': 'word', 'level': 5},
      {
        'text': 'follow up',
        'translation': 'dar retorno',
        'kind': 'expression',
        'level': 3,
      },
      {
        'text': 'touch base',
        'translation': 'alinhar rapidinho',
        'kind': 'expression',
        'level': 2,
      },
      {
        'text': 'workload',
        'translation': 'carga de trabalho',
        'kind': 'word',
        'level': 4,
      },
      {
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
        'text': 'no worries',
        'translation': 'sem problemas',
        'kind': 'expression',
        'level': 5,
      },
      {
        'text': 'catch up',
        'translation': 'colocar o papo em dia',
        'kind': 'expression',
        'level': 4,
      },
      {
        'text': 'hang out',
        'translation': 'passar um tempo junto',
        'kind': 'expression',
        'level': 3,
      },
      {
        'text': 'awkward',
        'translation': 'constrangedor',
        'kind': 'word',
        'level': 2,
      },
      {
        'text': 'I\'m starving',
        'translation': 'tô morrendo de fome',
        'kind': 'expression',
        'level': 1,
      },
      {
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
        'text': 'give up',
        'translation': 'desistir',
        'kind': 'expression',
        'level': 4,
      },
      {
        'text': 'figure out',
        'translation': 'descobrir, entender',
        'kind': 'expression',
        'level': 3,
      },
      {
        'text': 'run out of',
        'translation': 'ficar sem',
        'kind': 'expression',
        'level': 2,
      },
      {
        'text': 'come across',
        'translation': 'deparar-se com',
        'kind': 'expression',
        'level': 1,
      },
      {
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
        'text': 'binge-watch',
        'translation': 'maratonar',
        'kind': 'expression',
        'level': 5,
      },
      {
        'text': 'spoiler',
        'translation': 'revelação do enredo',
        'kind': 'word',
        'level': 4,
      },
      {
        'text': 'plot twist',
        'translation': 'reviravolta',
        'kind': 'expression',
        'level': 2,
      },
      {
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
        'text': 'to go',
        'translation': 'para viagem',
        'kind': 'expression',
        'level': 5,
      },
      {
        'text': 'leftovers',
        'translation': 'sobras',
        'kind': 'word',
        'level': 3,
      },
      {
        'text': 'the bill',
        'translation': 'a conta',
        'kind': 'expression',
        'level': 4,
      },
      {
        'text': 'spicy',
        'translation': 'apimentado',
        'kind': 'word',
        'level': 5,
      },
    ],
  },
];
