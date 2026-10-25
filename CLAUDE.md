# CLAUDE.md — Tagarela (app)

App Flutter (Android/iOS): inglês a partir do que a pessoa vê e ouve no dia. Público BR, básico/intermediário, pouco tempo. API em `../api`.

## Produto

- Fluxo: captura (foto, áudio, texto) → escolhe termos → confirma → vocabulário → pessoa agrupa → revisão espaçada até dominar.
- A pessoa decide; a IA sugere, nunca organiza por ela.
- Tom de amigo ("você"), captura em um gesto, funciona offline, cor só com significado.
- Recurso sem dado da API ainda: card some, não inventa.

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

- `lib/app/`: bootstrap, auth e shell. `lib/features/<f>/`: página + widgets da feature. `lib/design_system/`: tudo visual reutilizável. `lib/data/`: models, services (API, sem estado), stores (estado), integrações externas.
- Fluxo: tela → store → service → `ApiClient` (único ponto de rede). Estado com `ChangeNotifier`, sem pacotes de estado, rota ou HTTP.
- Dependências injetadas por `AppScope` (teste troca).
- Lib externa isolada no seu arquivo em `data/`; resto do app não importa.
- Captura é offline first: banco local é a verdade, API é sync disparado pela pessoa.
- Vocabulário é online: nasce na API ao confirmar.
- Extração (OCR, transcrição) roda no aparelho, em plugin próprio (`packages/`), fora da thread principal.

## Estilo

- Visual: header violeta + body arredondado, balão de fala como assinatura, tema do sistema. Cores têm papel fixo (ação, palavra do dia, aprendendo, dominado, erro); ver tokens.
- Toda tela é `SheetPage`. Um primário por tela. Import único `design_system.dart`.
- Código: `package:tagarela/...`, aspas simples, um widget público por arquivo, texto da UI pt-BR no widget.
- Testes: só `flutter_test` com fakes manuais; helpers em `test/helpers/`.
- Toast tem anel animado até sumir: depois de ação que mostra toast, `pumpUntilFound`, não `pumpAndSettle` (só assenta quando o toast já saiu).

## Mockup

https://claude.ai/artifact/36zen91FwEpmPP1UFrEFrR (via Artifact tool). Registro fiel do app; ideia não aprovada vai na aba Propostas. Atualizar em todo PR que muda UI (skill `entregar`).

## Comandos

`dart format lib test packages` · `flutter analyze --no-pub` · `flutter test --no-pub -r failures-only` · drift mudou: `dart run build_runner build`.
