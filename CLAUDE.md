# CLAUDE.md — Tagarela (app)

App Flutter pra aprender inglês com o que a pessoa vê e ouve no dia. Público: brasileiro, inglês básico ou intermediário, pouco tempo. Backend: repo `tagarela-app-group/tagarela-ocr-dictionary` (pasta `../api`).

## Produto

- Fluxo: captura (foto, áudio, texto) → escolhe termos → confirma → termo entra no vocabulário sem grupo → pessoa organiza em grupos → revisão espaçada (SRS) até dominar.
- Termo: palavra ou expressão, um por pessoa (maiúscula e espaço não contam). Grupo: criado pela pessoa. IA nunca escolhe grupo. Nível 0 a 5, 4+ = dominado.
- Princípios: conversa, não aula (tom de amigo, "você"). Captura em um gesto. Funciona sem rede. Cor só com significado.
- Falta (a API ainda não tem): ficha do termo via IA, nível e revisão (SRS), palavra do dia. Card some sem dado.

## Regras

1. Antes de alterar qualquer coisa (código, doc, config, mockup): propor (o que muda, onde, opções, recomendação) e esperar aprovação.
2. Pedido quebra regra ou boa prática: avisar antes, dizer qual e propor alternativa.
3. UI: reutilizar `lib/design_system/` antes de criar. Nada serve: criar o componente lá, sem perguntar.
4. Cor, fonte, espaço, raio, ícone: sempre token. Valor visual novo vira token antes de usar.
5. Código novo ou alterado: teste junto. Bug corrigido: teste que reproduz.
6. Sem comentário no código nem em config. Porquê vai neste arquivo ou no PR.
7. Mudou regra, decisão ou armadilha: atualizar este arquivo junto. Teto 8 KB: enxugar antes de somar. Só o que o código não mostra.
8. Task finalizada: branch própria da `develop` (`feat/`, `fix/`, `docs/`, `ci/`, `chore/`), commit, push e PR pra `develop`, na hora, sem perguntar.
9. Commit e PR: Conventional Commits em pt-BR, enxuto, só o necessário. Sem `Co-Authored-By` nem assinatura de IA.
10. PR pra `develop` com esteira verde: merge sozinho com `gh pr merge <n> --repo tagarela-app-group/tagarela --squash --delete-branch` (comando isolado, sem `cd`/`&&`). Depois `git switch develop && git pull`.
11. Só o usuário: merge `develop` → `main` (prod). Nunca commitar direto na `develop` nem na `main`.
12. Teste em aparelho é do usuário. Print só se pedir, reduzido pra ~400 px.
13. Fim de task ou troca de assunto: sugerir numa linha `/compact manter: ...` (mesmo assunto) ou `/clear` (assunto novo).

## Onde colocar

- `lib/app/`: MaterialApp, AuthGate, HomeShell, AppScope. `lib/features/<f>/`: `<f>_page.dart` + `widgets/`.
- Widget de 2+ features ou genérico: `design_system/components/`. De uma feature: `features/<f>/widgets/`. De um arquivo: classe privada.
- Model: `data/models.dart`, com `fromJson`. Conta sobre dado (total, filtro): no model.
- Lib externa: só no arquivo dela em `data/`. Resto do app não importa.
- API: `data/services/` (1 por recurso, sem estado). Estado compartilhado: `data/stores/`.

## Decisões e armadilhas

### Base
- Só Android e iOS. Estado `ChangeNotifier` + `setState`, `Navigator`, `dart:io`: sem pacote de estado, rota ou HTTP.
- `minSdk 26` (Moonshine), iOS 15, SPM sem Podfile. Java 21 via `mise.toml`.
- `kotlin.incremental=false`: projeto e pub cache em drives diferentes quebram o cache no Windows.
- Fluxo: tela → store → service → `ApiClient`. `Store<T>`: `data` + `error`, os 2 nulos = carregando. Tela: `ListenableBuilder` + `AsyncStatus`.
- `AppScope` injetado em `main.dart` (teste troca). `loadAll()` ao entrar.
- `ApiClient`: único ponto de rede. ≥ 400 = `ApiException`. Corpo sempre com `Content-Length` (`runserver` ignora chunked).
- `API_URL` via `--dart-define`. Padrão `http://10.0.2.2:8000`. http só no debug.

### Conta
- allauth headless da API. Refresh token no `flutter_secure_storage`, access só na memória. 401: renova uma vez e repete. Pedidos juntos dividem um refresh.
- Refresh recusado: login com "Sua sessão expirou". Sem rede ao abrir: entra com token salvo.
- Google: client ID web vem da API (`GET config`). iOS falta `GOOGLE_IOS_CLIENT_ID` + URL scheme. Apple só iOS.

### Captura (offline first)
- Verdade: banco local (drift). API = sync. Linha guarda e-mail do dono. Id UUID do app. Só o texto sobe.
- Pendências: `extract` (local), `create`, `update`, `confirm`, `discard`. Grava local, marca, tenta enviar. Sem rede: fica pendente, sem erro.
- Sync só por ação da pessoa (decisão do produto). Envia em ordem, puxa `updated_since`. Cursor = maior `updated_at` do pull, não do envio.
- Merge: servidor manda, menos o pendente local. Analisada sai do Inbox, fica no banco.
- Mídia apagada 30 dias após analisada ou descartada.
- Posição do termo: API conta code points, Dart UTF-16. `TermSelection` converte.

### Vocabulário
- Só online. Termo nasce na API ao confirmar. `CaptureStore(onConfirmed:)` recarrega.
- Desfazer mover = mover de volta. Desfazer apagar = `restoreTerms` (só o último apagado).
- `GroupIcon`: nome = id na API, ordem = ordem no painel.

### Extração no aparelho
- Plugin `packages/on_device_extraction`. Nada na thread principal. Fila no `CaptureStore`, uma por vez.
- Foto: ML Kit v2 unbundled (Android), Vision (iOS).
- Áudio: Moonshine Tiny, 45 MB, URL fixa do Hugging Face (CDN deu 404). SHA-256, retoma, retry 30 s até 10 min. Sem modelo: espera download.
- Android: deps do Moonshine excluídas + `consumer-rules.pro` (JNI lê classe por nome, R8). Distribuir App Bundle (APK universal > 100 MB).
- iOS: `moonshine-swift` versão exata, Xcode 16.3+.

## Design system

- Import único `design_system.dart`. Cor via `context.colors`, marca via `AppPalette`. Ícone só `AppIcons`.
- Header violeta + body com topo arredondado. Assinatura: balão de fala. Tema segue o sistema. Escuro: sem preto puro, sem sombra.
- Cores: violeta = ação; manga = palavra do dia; âmbar = aprendendo; menta = dominado; coral = erro. Em manga, menta, âmbar e coral: texto tinta, nunca branco (contraste ≥ 4,5:1).
- Um botão primário por tela. Status sempre `StatusPill`. `AppIconButton` com `tooltip`. Toque mínimo 44.
- Aviso com ação: `AppToast`. Erro simples: `SnackBar` só texto.
- Toda tela = `SheetPage`. Estado vazio/erro: `centerLast: true`. `HomeShell`: `resizeToAvoidBottomInset: false`.

## Mockup

https://claude.ai/artifact/36zen91FwEpmPP1UFrEFrR. Ler e publicar via Artifact tool.

- Abas por assunto + board `DesignSystem.dc.html`. Linha de cima claro, de baixo escuro. Estados na ordem do fluxo.
- Ideia não aprovada: aba Propostas. Tela some só quando sai do app.
- Atualizar em lote, no fim de conjunto aprovado ou quando pedir. Mockup = registro fiel do app.

## Código e testes

- Import `package:tagarela/...`. Aspas simples. Um widget público por arquivo. Texto da UI em pt-BR no widget.
- Só `flutter_test`, fake manual. `pumpPage`/`pumpComponent` e fakes em `test/helpers/`.
- I/O real trava `testWidgets`: usar `FakeMediaStorage`. Tela com `pop`: abrir de outra tela. Timer: `pump(Duration)`.

## Comandos

- `dart format lib test packages`
- `flutter analyze --no-pub`
- `flutter test --no-pub -r failures-only`
- Tabela drift mudou: `dart run build_runner build`, commitar `database.g.dart`. Coluna: subir `schemaVersion` + migração.

## Dependências e CI

- Pacote novo: checar pub.dev e issues, contar ao usuário. Nativo ou pouco mantido: perguntar. Versão com 2+ semanas, transitiva também.
- `permission_handler` preso na 12 (13 exige compileSdk 37). Nativas do plugin: versão fixa.
- Esteira: formato, análise, testes, OSV-Scanner, build APK. iOS só na `main`. `FLUTTER_VERSION` do workflow = Flutter local.
