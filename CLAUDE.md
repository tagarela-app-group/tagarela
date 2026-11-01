# CLAUDE.md — Tagarela (app)

App Flutter (Android/iOS): idioma (en, es, pt) a partir do que a pessoa vê e ouve no dia. Público BR primeiro, básico/intermediário, pouco tempo. API em `../api`.

Detalhe de cada feature, minigames e ambientes: `docs/produto.md`. Antes de mexer numa feature, ler a parte dela.

## Regras

1. Antes de alterar algo (código, doc, config, mockup): propor (o quê, onde, opções, recomendação) e esperar ok. Pedido fere regra/boa prática: avisar e propor alternativa.
2. UI: reusar o design system. Nada serve: procurar peça parecida em todo `lib/`, inclusive `_X` e widget de feature, e extrair pra lá, com nome pelo que é e API genérica. Valor visual sempre token (`test/design_tokens_test.dart` cobra).
3. Código novo/alterado: com teste. Teste cobra funcionamento: regra, toque, estado, acessibilidade e animação. Não mede layout (largura, altura, posição). Bug de lógica: teste que reproduz; bug só visual não ganha teste. Não testa cópia do código (valor igual ao token ou ao mockup, constante, repasse pro Flutter ou lib) nem o que outro teste já cobre (página: ligação com o store; widget: desenho; store: regra). Antes de escrever, dizer que bug ele pegaria; nenhum, não escreve.
4. Sem comentário em código/config.
5. Mudou regra: atualizar aqui. Mudou feature: `docs/produto.md`. Só o que o código não mostra.
6. Git é do usuário: no máximo um commit local, em branch da `develop` (`feat/ fix/ docs/ ci/ chore/`), nunca direto em `develop`/`main`. Conventional Commits pt-BR, enxuto, sem assinatura de IA. Push, PR, merge e erro da esteira: ele cuida.
7. Validar é do usuário: não rodar teste, análise, lint nem build. A entrega é o código e os testes escritos; ao terminar, dizer o que mudou, sem afirmar que funciona.
8. Teste em aparelho é do usuário. Print só se pedir, ~400 px.
9. Dependência nova: checar manutenção e contar ao usuário; nativa ou mal mantida: perguntar. Versões com 2+ semanas.
10. Tipagem estrita: sem `dynamic` nem tipo implícito. JSON entra como `Json`/`Object?` e vira model no `fromJson`, com cast explícito.
11. Sem repetição: antes de escrever, procurar em `lib/` e `test/`. Igual em 2 lugares vira uma peça só (`logic/`, design system, `test/helpers/`). Igual por acaso, com regra diferente, fica separado. A esteira falha com qualquer trecho repetido (`jscpd`).
12. Sem código morto: a esteira falha com classe, função, membro ou arquivo sem uso. Membro que só teste usa: tirar, salvo gancho listado no `ci.yml`.
13. Fim de task ou troca de assunto: sugerir `/compact manter: ...` ou `/clear`.

## Produto

- Fluxo: captura (foto, áudio, texto) → escolhe termos → confirma → vocabulário → pessoa agrupa → revisão até dominar.
- Curso: "aprende X por meio de Y", na conta, um ativo. Capturas, termos e grupos são do curso. O app fala o Y do curso ativo.
- A pessoa decide; a IA sugere, nunca organiza por ela.
- Tom de amigo ("você"), captura em um gesto, funciona offline, cor só com significado.
- Recurso sem dado da API ainda: card some, não inventa.

## Arquitetura

- `lib/app/`: bootstrap, auth e shell. `lib/features/<f>/`: `*_page.dart`, `modals/`, `widgets/`, `logic/` (regra sem widget). `lib/design_system/`: visual reutilizável. `lib/shared/`: conhece model e serve 2+ features. `lib/data/`: `models/`, `services/` (API, sem estado), `stores/` (estado), `storage/`, `sync/`, `device/`.
- Dependências só descem: `features` usa `data` e `design_system`; `data` não importa `design_system`, `features` nem widget; `design_system` não importa `data` nem `features`. Feature só abre página ou modal de outra. Tela não conhece HTTP. `test/architecture_test.dart` cobra.
- Fluxo: tela → store → service → `ApiClient` (único ponto de rede). Estado com `ChangeNotifier`, sem pacotes de estado, rota ou HTTP.
- Montagem: `AppDependencies.live()` cria tudo; `AppScope.of(context)` entrega pras telas; `AppSession` carrega o estudo e limpa os stores ao sair.
- Lib externa isolada no seu arquivo em `data/`.
- Captura é offline first: banco local é a verdade, API é sync disparado pela pessoa. Vocabulário é online.
- Extração (OCR, transcrição) roda no aparelho, em plugin próprio (`packages/`), fora da thread principal.
- Flavors: `dsv` (padrão) e `prd`; config pública em `env/<flavor>.json`.

## Estilo

- Toda tela é `AppPage`. Um primário por tela. Import único `design_system.dart`.
- `package:tagarela/...`, aspas simples, um widget público por arquivo.
- Texto da UI só nos ARB (`lib/l10n/arb/`, modelo `app_pt.arb`), via `context.l10n`; chave nova nos três idiomas. Rótulo de enum é `select`. Plural sempre com `=0`.
- Testes: só `flutter_test` com fakes manuais; helpers em `test/helpers/`. Monta com `fakeDependencies(...)` e `pumpPage(page, deps: ...)`, que abre em pt. Fake de API herda `FakeApi` e só declara `respond`. Função pura recebe `AppLocalizations` (`test/helpers/l10n.dart`).
- App passou a ler campo da API: entra no exemplo em `test/contract/*.json`.
- Animação de enfeite roda uma vez, nunca em loop. Em loop: `WordPicker` selecionado, `ShufflingTiles`, `RollingText`, `TypingDots`; teste com eles usa `pump` com duração. Depois de toast: `pumpUntilFound`.

## Mockup

https://claude.ai/artifact/36zen91FwEpmPP1UFrEFrR (via Artifact tool). Registro fiel do app; ideia não aprovada vai na aba Propostas. Atualizar só quando o usuário pedir.

## Comandos

Só rodar o que gera arquivo: `dart format lib test packages` · drift mudou: `dart run build_runner build` · ARB mudou: `flutter gen-l10n`.
