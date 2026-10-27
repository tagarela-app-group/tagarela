# CLAUDE.md — Tagarela (app)

App Flutter (Android/iOS): idioma (en, es, pt) a partir do que a pessoa vê e ouve no dia. Público BR primeiro, básico/intermediário, pouco tempo; interface em pt-BR, en e es. API em `../api`.

## Produto

- Fluxo: captura (foto, áudio, texto) → escolhe termos → confirma → vocabulário → pessoa agrupa → revisão espaçada até dominar.
- Curso: "aprende X por meio de Y", fica na conta (API), um ativo. Capturas, termos e grupos são do curso; trocar recarrega o estudo. Conta sem curso escolhe no primeiro acesso ("Eu falo" e "Quero aprender", nunca o mesmo idioma). Idioma vira balão com sigla e bandeira do país (en EUA, es Espanha, pt Brasil); curso é o par de bandeiras. Idioma novo entra no `CourseLanguage` e no `select` do ARB; busca e "Mais procurados" da proposta só quando a lista crescer. Áudio só em inglês (Moonshine): outros cursos escondem a gravação e não baixam o modelo.
- A pessoa decide; a IA sugere, nunca organiza por ela.
- Tom de amigo ("você"), captura em um gesto, funciona offline, cor só com significado.
- Recurso sem dado da API ainda: card some, não inventa.
- Idioma do app é o "Eu falo" (base) do curso ativo, em todas as telas; trocar de curso troca o app. Sem escolha separada no Perfil. Fica salvo no aparelho pra abrir no mesmo idioma antes dos cursos chegarem; sem curso segue o celular; idioma que o app não tem cai em inglês. A escolha de idiomas fala o "Eu falo" marcado nela. "Eu falo" só oferece idioma em que o app está traduzido. Não confundir com país de origem. Mensagens da API seguem pt-BR por enquanto.
- Ficha do termo: a IA gera no primeiro toque e a API salva. Frente do card, palavras, uso, imagem e as formas da pegadinha ("Não diga"/"Diga") no idioma que a pessoa aprende; verso, ao pé da letra, explicação da pegadinha (compara com o idioma base, tipo falso cognato) e tradução dos exemplos e do diálogo no idioma base. Rótulos seguem o idioma do app. Enquanto gera, tela cheia violeta: o termo em peças que trocam de lugar até formar o termo (palavra curta vira letras, longa vira pedaços que se juntam; termo longo quebra linha e a letra diminui) e um balão que troca o que está montando, só de enfeite (a IA monta tudo de uma vez, sem barra de progresso). Significado sem vidro: o card aparece direto e vira pro idioma base quando a pessoa quiser; traduzir diálogo e exemplos também é livre. Em "Pra lembrar", ao pé da letra e "quer dizer" nascem desfocados; um toque revela os dois, salva, solta os balões e pergunta "Tinha sacado?", que não salva nada; ficha que já abre revelada não pergunta. Na pegadinha, tudo nasce desfocado menos os títulos; um toque ou o olho no título revela, salva à parte (`pitfall_revealed`, pra não entregar o "Pra lembrar") e solta os balões, sem "Tinha sacado?"; o olho embaça de novo. Diálogo substitui os exemplos; sem diálogo, voltam os exemplos. A lista de termos não mostra tradução, pra não entregar o que está desfocado.
- País de origem: opcional, fica na conta, vira bandeira no canto inferior direito de todo avatar (o esquerdo é a cauda do balão). Nomes em `lib/l10n/countries/country_names.dart`, gerados do CLDR, mesma lista da API.

## Regras

0. Início de sessão: ativar skill `caveman` nível `full`.
1. Antes de alterar algo (código, doc, config, mockup): propor (o quê, onde, opções, recomendação) e esperar ok. Pedido fere regra/boa prática: avisar e propor alternativa.
2. UI: reusar o design system; nada serve, criar lá. Valor visual sempre token.
   - Antes de criar UI: procurar peça parecida em todo `lib/`, inclusive widget privado (`_X`) e de feature. Achou: extrair pro design system. Nome pelo que é, não por onde é usado. API genérica: conteúdo + papel de cor, sem regra de uso embutida.
3. Código novo/alterado: com teste. Bug: teste que reproduz.
4. Sem comentário em código/config. Porquê vai aqui ou no PR.
5. Mudou regra ou decisão: atualizar aqui. Guia, não inventário: só o que o código não mostra.
6. Fim de task: skill `entregar` (checagem, PR, esteira, merge, mockup, volta pra `develop`), sem perguntar.
7. Nunca commitar direto em `develop`/`main`. `develop` → `main` só o usuário.
8. Teste em aparelho é do usuário. Print só se pedir, ~400 px.
9. Dependência nova: checar manutenção e contar ao usuário; nativa ou mal mantida: perguntar. Versões com 2+ semanas.
10. Troca de assunto: sugerir `/compact manter: ...` ou `/clear`.

## Arquitetura

- `lib/app/`: bootstrap, auth e shell. `lib/features/<f>/`: pages (`*_page.dart`) na raiz; `modals/` (`*_modal.dart`, abre com `AppModal.show`); `widgets/` (o que aparece na tela, inclusive toast); `logic/` (regra sem widget, testável sem tela). `lib/design_system/`: tudo visual reutilizável. `lib/data/`: `models/` (um arquivo por domínio, import via `models.dart`), `services/` (API, sem estado, com o `ApiClient`), `stores/` (estado), `storage/` (o que fica salvo no aparelho) e `device/` (recursos do aparelho e libs nativas).
- Fluxo: tela → store → service → `ApiClient` (único ponto de rede). Estado com `ChangeNotifier`, sem pacotes de estado, rota ou HTTP.
- Dependências injetadas por `AppScope` (teste troca).
- Lib externa isolada no seu arquivo em `data/`; resto do app não importa.
- Captura é offline first: banco local é a verdade, API é sync disparado pela pessoa. Guarda o curso em que nasceu; o Inbox mostra só o curso ativo (curso desconhecido: todas).
- Vocabulário é online: nasce na API ao confirmar.
- Extração (OCR, transcrição) roda no aparelho, em plugin próprio (`packages/`), fora da thread principal.

## Estilo

- Visual: header violeta + body arredondado, balão de fala como assinatura, tema do sistema. Cores têm papel fixo (ação, palavra do dia, aprendendo, dominado, erro); ver tokens.
- Toda tela é `AppPage`. Um primário por tela. Import único `design_system.dart`.
- Código: `package:tagarela/...`, aspas simples, um widget público por arquivo.
- Texto da UI só nos ARB (`lib/l10n/arb/`, modelo `app_pt.arb`; código gerado em `lib/l10n/generated/`, uso via `lib/l10n/l10n.dart`), via `context.l10n`; chave nova entra nos três idiomas. Rótulo de enum é `select` no ARB, não campo no model. Plural sempre com `=0` (no pt o CLDR põe 0 em `one`).
- Testes: só `flutter_test` com fakes manuais; helpers em `test/helpers/`. `pumpPage` abre em pt; função pura recebe `AppLocalizations` (`pt`/`en`/`es` de `test/helpers/l10n.dart`).
- Animação de enfeite roda uma vez, nunca em loop: loop trava o `pumpAndSettle`. Exceção: palavra selecionada no `WordPicker` anima sem parar; teste com ela usa `pump` com duração. `Skeleton`, `ShufflingTiles`, `RollingText` e `TypingDots` rodam em loop enquanto carrega, como um spinner; `TypingDots` também na escolha de idiomas até escolher o que aprender; teste nesse estado usa `pump`.
- Toast tem anel animado até sumir: depois de ação que mostra toast, `pumpUntilFound`, não `pumpAndSettle` (só assenta quando o toast já saiu).

## Mockup

https://claude.ai/artifact/36zen91FwEpmPP1UFrEFrR (via Artifact tool). Registro fiel do app; ideia não aprovada vai na aba Propostas. Atualizar em todo PR que muda UI (skill `entregar`).

## Comandos

`dart format lib test packages` · `flutter analyze --no-pub` · `flutter test --no-pub -r failures-only` · drift mudou: `dart run build_runner build` · ARB mudou: `flutter gen-l10n`.
